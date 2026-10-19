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
