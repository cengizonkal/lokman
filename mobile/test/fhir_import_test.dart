import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import 'package:flutter_test/flutter_test.dart';
import 'package:lokman/data/db/database.dart';
import 'package:lokman/data/repository.dart';
import 'package:lokman/fhir/bundle_reader.dart';
import 'package:lokman/fhir/bundle_writer.dart';
import 'package:lokman/fhir/importer.dart';

import 'test_utils.dart';

Future<Map<String, int>> counts(Repository repo, String profileId) =>
    repo.watchCounts(profileId).first;

void main() {
  late Repository repo;
  late Importer importer;

  setUp(() {
    repo = memoryRepo();
    importer = Importer(repo);
  });

  tearDown(() => repo.db.close());

  test('örnek klinik paketi ayrıştırılır', () async {
    final parsed = await importer.parse(exampleBundle());
    expect(parsed.patient!.firstName, 'Ayşe');
    expect(parsed.patient!.lastName, 'Şahin');
    expect(parsed.organizationName, 'Örnek Aile Kliniği');
    expect(parsed.ignored, 0);
    expect(parsed.counts, {
      RecordKind.allergy: 1,
      RecordKind.condition: 1,
      RecordKind.encounter: 1,
      RecordKind.diagnosis: 1,
      RecordKind.medication: 2,
      RecordKind.immunization: 1,
      RecordKind.dueVaccine: 1,
      RecordKind.observation: 2,
      RecordKind.appointment: 1,
    });
  });

  test('içe aktarım kayıtları yazar, tekrar aktarım çoğaltmaz', () async {
    final parsed = await importer.parse(exampleBundle());
    final match = await importer.match(parsed.patient);
    expect(match.exact, isNull);
    final profileId = await importer.createProfileFrom(parsed.patient);

    final first = await importer.apply(parsed, profileId);
    expect(first.added, 11);
    expect(first.updated, 0);
    final before = await counts(repo, profileId);

    // İkinci kez: profil kimlikten tanınır, kayıt sayısı değişmez.
    final again = await importer.parse(exampleBundle());
    final match2 = await importer.match(again.patient);
    expect(match2.exact?.id, profileId);
    final second = await importer.apply(again, profileId);
    expect(second.added, 0);
    expect(second.updated, 11);
    expect(await counts(repo, profileId), before);

    final meds = await repo.watchMedications(profileId).first;
    final azi = meds.firstWhere((m) => m.name.startsWith('Azitromisin'));
    expect(azi.timesOfDay, '20:00');
    expect(azi.durationDays, 3);
    expect(azi.dose, '1 tablet');
    expect(azi.source, RecordSource.clinic);
    expect(azi.originName, 'Örnek Aile Kliniği');

    final dx = await repo.watchDiagnoses(profileId).first;
    final enc = await repo.watchEncounters(profileId).first;
    expect(dx.single.encounterId, enc.single.id);
    expect(dx.single.verification, 'provisional');
    expect(enc.single.plan, contains('yürüyüş'));

    final obs = await repo.watchObservations(profileId).first;
    final bp = obs.firstWhere((o) => o.typeKey == 'bp');
    expect((bp.value, bp.value2), (150.0, 95.0));
  });

  test('ad ve doğum tarihi benzer profili önerir', () async {
    final id = await repo.addProfile(
      ProfilesCompanion.insert(
        firstName: 'ayse',
        lastName: const Value('SAHIN'),
        birthDate: Value(DateTime(1984, 3, 12)),
      ),
    );
    await repo.addProfile(ProfilesCompanion.insert(firstName: 'Ali'));
    final parsed = await importer.parse(exampleBundle());
    final match = await importer.match(parsed.patient);
    expect(match.exact, isNull);
    expect(match.suggestion?.id, id);
  });

  test(
    'dışa aktarılan paket yeniden içe aktarılınca aynı kayıtlar oluşur',
    () async {
      final parsed = await importer.parse(exampleBundle());
      final profileId = await importer.createProfileFrom(parsed.patient);
      await importer.apply(parsed, profileId);
      // Kullanıcının kendi girdiği kayıt ve doz kaydı.
      await repo.save(
        repo.db.allergies,
        AllergiesCompanion.insert(profileId: profileId, substance: 'Fıstık'),
      );
      final meds = await repo.watchMedications(profileId).first;
      await repo.markDose(meds.first.id, DateTime(2026, 10, 16, 8), 'taken');
      final before = await counts(repo, profileId);

      final data = await ExportData.load(repo.db, profileId);
      final bundle = buildBundle(data, appId: await repo.appId());
      final text = encodeBundle(bundle);
      expect(text, isNot(contains('taken')));
      expect(bundle['type'], 'document');
      expect(
        (bundle['entry'] as List).first['resource']['resourceType'],
        'Composition',
      );

      // Aynı telefona geri yükleme: çoğalmaz.
      final back = await importer.parse(text);
      final match = await importer.match(back.patient);
      expect(match.exact?.id, profileId);
      final r = await importer.apply(back, profileId);
      expect(r.added, 0);
      expect(await counts(repo, profileId), before);

      // Başka bir telefona aktarım: kayıtlar kaynaklarıyla gelir.
      final other = memoryRepo();
      addTearDown(other.db.close);
      final otherImporter = Importer(other);
      final parsed2 = await otherImporter.parse(text);
      final pid = await otherImporter.createProfileFrom(parsed2.patient);
      await otherImporter.apply(parsed2, pid);
      expect(await counts(other, pid), before);
      final allergies = await other.watchAllergies(pid).first;
      expect(
        allergies.firstWhere((a) => a.substance == 'Fıstık').source,
        RecordSource.self,
      );
      expect(
        allergies.firstWhere((a) => a.substance != 'Fıstık').originName,
        'Örnek Aile Kliniği',
      );

      // İkinci telefondan geri gelen paket ilk telefonda çoğaltmaz.
      final roundTrip = encodeBundle(
        buildBundle(
          await ExportData.load(other.db, pid),
          appId: await other.appId(),
        ),
      );
      final parsed3 = await importer.parse(roundTrip);
      final r3 = await importer.apply(parsed3, profileId);
      expect(
        r3.added,
        0,
        reason: jsonEncode(r3.counts.keys.map((k) => k.name).toList()),
      );
      expect(await counts(repo, profileId), before);
    },
  );

  test(
    'geçirilmiş hastalık ayrı bölümde dışa aktarılır, durumu korunur',
    () async {
      final profileId = await repo.addProfile(
        ProfilesCompanion.insert(firstName: 'Ali'),
      );
      await repo.save(
        repo.db.conditions,
        ConditionsCompanion.insert(profileId: profileId, name: 'Astım'),
      );
      await repo.save(
        repo.db.conditions,
        ConditionsCompanion.insert(
          profileId: profileId,
          name: 'Zatürre (pnömoni)',
          onsetDate: Value(DateTime(2019, 3, 2)),
          status: const Value(ConditionStatus.resolved),
          resolvedDate: Value(DateTime(2019, 3, 20)),
        ),
      );

      final bundle = buildBundle(
        await ExportData.load(repo.db, profileId),
        appId: await repo.appId(),
      );
      final entries = [
        for (final e in bundle['entry'] as List) e['resource'] as Map,
      ];
      final sections = entries.first['section'] as List;
      List<String> names(String loinc) {
        final section = sections.firstWhere(
          (s) => s['code']['coding'][0]['code'] == loinc,
        );
        final urls = [for (final e in section['entry'] as List) e['reference']];
        return [
          for (final e in bundle['entry'] as List)
            if (urls.contains(e['fullUrl'])) e['resource']['code']['text'],
        ];
      }

      expect(names('11450-4'), ['Astım']);
      expect(names('11348-0'), ['Zatürre (pnömoni)']);
      final past = entries.firstWhere(
        (r) => r['code']?['text'] == 'Zatürre (pnömoni)',
      );
      expect(past['clinicalStatus']['coding'][0]['code'], 'resolved');
      expect(past['abatementDateTime'], '2019-03-20');

      // Başka telefona aktarımda durum ve tarih korunur.
      final other = memoryRepo();
      addTearDown(other.db.close);
      final otherImporter = Importer(other);
      final parsed = await otherImporter.parse(encodeBundle(bundle));
      final pid = await otherImporter.createProfileFrom(parsed.patient);
      await otherImporter.apply(parsed, pid);
      final conditions = await other.watchConditions(pid).first;
      final asthma = conditions.firstWhere((c) => c.name == 'Astım');
      final pneumonia = conditions.firstWhere((c) => c.name != 'Astım');
      expect(asthma.status, ConditionStatus.active);
      expect(asthma.resolvedDate, isNull);
      expect(pneumonia.status, ConditionStatus.resolved);
      expect(pneumonia.onsetDate, DateTime(2019, 3, 2));
      expect(pneumonia.resolvedDate, DateTime(2019, 3, 20));
    },
  );

  test('klinikten gelen hastalığın durumu okunur', () async {
    Future<Condition> importWith(Map<String, dynamic> fields) async {
      final json = jsonDecode(exampleBundle()) as Map<String, dynamic>;
      final condition =
          [for (final e in json['entry'] as List) e['resource'] as Map]
              .firstWhere(
                (r) =>
                    r['resourceType'] == 'Condition' &&
                    jsonEncode(r['category']).contains('problem-list-item'),
              );
      condition.remove('clinicalStatus');
      condition.addAll(fields);
      final r = memoryRepo();
      addTearDown(r.db.close);
      final imp = Importer(r);
      final parsed = await imp.parse(jsonEncode(json));
      final pid = await imp.createProfileFrom(parsed.patient);
      await imp.apply(parsed, pid);
      return (await r.watchConditions(pid).first).single;
    }

    Map<String, dynamic> status(String code) => {
      'clinicalStatus': {
        'coding': [
          {
            'system':
                'http://terminology.hl7.org/CodeSystem/condition-clinical',
            'code': code,
          },
        ],
      },
    };

    final resolved = await importWith({
      ...status('resolved'),
      'abatementDateTime': '2024-05-01',
    });
    expect(resolved.status, ConditionStatus.resolved);
    expect(resolved.resolvedDate, DateTime(2024, 5, 1));

    final inactive = await importWith(status('inactive'));
    expect(inactive.status, ConditionStatus.resolved);
    expect(inactive.resolvedDate, isNull);

    final remission = await importWith(status('remission'));
    expect(remission.status, ConditionStatus.active);

    // Durum yazılmamış ama bitiş tarihi var: geçmiş hastalık.
    final noStatus = await importWith({'abatementDateTime': '2023-01-10'});
    expect(noStatus.status, ConditionStatus.resolved);
    expect((await importWith({})).status, ConditionStatus.active);
  });

  test(
    'kullanıcının doktor ziyareti hastane, not ve ilaç bağıyla aktarılır',
    () async {
      final profileId = await repo.addProfile(
        ProfilesCompanion.insert(firstName: 'Ali'),
      );
      final encounterId = newId();
      await repo.save(
        repo.db.encounters,
        EncountersCompanion.insert(
          id: Value(encounterId),
          profileId: profileId,
          date: DateTime(2026, 10, 14),
          location: const Value('Şehir Hastanesi'),
          practitioner: const Value('Dr. Elif Kaya, KBB'),
          complaint: const Value('Boğaz ağrısı'),
          note: const Value('Sabah aç gitmem gerekti'),
        ),
      );
      await repo.save(
        repo.db.diagnoses,
        DiagnosesCompanion.insert(
          profileId: profileId,
          encounterId: Value(encounterId),
          name: 'Bademcik iltihabı',
        ),
      );
      await repo.save(
        repo.db.medications,
        MedicationsCompanion.insert(
          profileId: profileId,
          name: 'Amoksisilin',
          startDate: DateTime(2026, 10, 14),
          encounterId: Value(encounterId),
        ),
      );

      final bundle = buildBundle(
        await ExportData.load(repo.db, profileId),
        appId: await repo.appId(),
      );
      final resources = [
        for (final e in bundle['entry'] as List) e['resource'] as Map,
      ];
      final enc = resources.firstWhere((r) => r['resourceType'] == 'Encounter');
      expect(enc['serviceProvider'], {'display': 'Şehir Hastanesi'});
      expect(enc['meta']['tag'][0]['code'], 'patient-reported');
      final medRes = resources.firstWhere(
        (r) => r['resourceType'] == 'MedicationRequest',
      );
      expect(medRes['encounter'], {'reference': 'urn:uuid:$encounterId'});

      // Başka bir telefona aktarım: ziyaret, tanı ve ilaç bağı korunur.
      final other = memoryRepo();
      addTearDown(other.db.close);
      final otherImporter = Importer(other);
      final parsed = await otherImporter.parse(encodeBundle(bundle));
      final pid = await otherImporter.createProfileFrom(parsed.patient);
      await otherImporter.apply(parsed, pid);
      final e2 = (await other.watchEncounters(pid).first).single;
      expect(e2.location, 'Şehir Hastanesi');
      expect(e2.practitioner, 'Dr. Elif Kaya, KBB');
      expect(e2.note, 'Sabah aç gitmem gerekti');
      expect(e2.source, RecordSource.self);
      final dx2 = (await other.watchDiagnoses(pid).first).single;
      expect(dx2.encounterId, e2.id);
      final med2 = (await other.watchMedications(pid).first).single;
      expect(med2.encounterId, e2.id);
    },
  );

  test('geçersiz dosya anlaşılır hata verir', () async {
    expect(
      () => importer.parse('{"resourceType":"Patient"}'),
      throwsA(isA<BundleFormatException>()),
    );
    expect(
      () => importer.parse('merhaba'),
      throwsA(isA<BundleFormatException>()),
    );
  });
}
