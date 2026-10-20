import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../domain/catalog.dart';
import '../domain/dose_schedule.dart';
import 'fhir_common.dart';

/// Kayıt türleri (içe aktarım özeti ve tablolar için).
enum RecordKind {
  encounter,
  diagnosis,
  medication,
  immunization,
  dueVaccine,
  observation,
  appointment,
  allergy,
  condition,
}

class ParsedPatient {
  const ParsedPatient({
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.gender,
    this.identifiers = const [],
  });

  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? gender;
  final List<({String system, String value})> identifiers;

  String get fullName =>
      [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
}

/// İçe aktarılacak kaydın kimliği belirlendikten sonra satırı üretmek için
/// gereken bağlam.
class RecordContext {
  RecordContext({
    required this.id,
    required this.profileId,
    required this.originRef,
    required this.resolve,
  });

  final String id;
  final String profileId;
  final String? originRef;

  /// FHIR referansını (`urn:uuid:…`, `Encounter/…`) aynı paketteki kaydın
  /// yerel kimliğine çevirir.
  final String? Function(String? reference) resolve;
}

class ParsedRecord {
  ParsedRecord({
    required this.kind,
    required this.resourceType,
    required this.resourceId,
    required this.table,
    required this.originRef,
    required this.source,
    required this.originName,
    required this.raw,
    required this.keys,
    required this.build,
  });

  final RecordKind kind;
  final String resourceType;
  final String resourceId;
  final TableInfo<RecordColumns, dynamic> table;

  /// Bu uygulamanın kendi kaydıysa `null` (kimlik doğrudan kullanılır).
  final String? originRef;
  final String source;
  final String? originName;
  final Json raw;

  /// Bu kayda işaret edebilecek referanslar (fullUrl, `Tür/id`).
  final Set<String> keys;
  final Insertable<dynamic> Function(RecordContext ctx) build;
}

class ParsedBundle {
  ParsedBundle({
    required this.patient,
    required this.organizationName,
    required this.records,
    required this.ignored,
  });

  final ParsedPatient? patient;

  /// Paketi üreten kurumun adı (varsa).
  final String? organizationName;
  final List<ParsedRecord> records;

  /// Uygulamanın tanımadığı ya da geçersiz olduğu için atlanan kaynak sayısı.
  final int ignored;

  Map<RecordKind, int> get counts {
    final m = <RecordKind, int>{};
    for (final r in records) {
      m[r.kind] = (m[r.kind] ?? 0) + 1;
    }
    return m;
  }
}

class BundleFormatException implements Exception {
  BundleFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// FHIR (IPS) Bundle JSON'unu ayrıştırır. Veritabanına yazmaz.
ParsedBundle readBundle(
  String text, {
  required AppDatabase db,
  required String ownAppId,
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException {
    throw BundleFormatException(
      'Dosya okunamadı: geçerli bir sağlık dosyası değil.',
    );
  }
  final bundle = asMap(decoded);
  if (bundle == null || bundle['resourceType'] != 'Bundle') {
    throw BundleFormatException(
      'Bu dosya bir sağlık dosyası (FHIR Bundle) değil.',
    );
  }
  return _BundleReader(db, bundle, ownAppId).read();
}

class _BundleReader {
  _BundleReader(this.db, this.bundle, this.ownAppId);

  final AppDatabase db;
  final Json bundle;
  final String ownAppId;

  final _resources = <String, Json>{};
  final _entries = <({String? fullUrl, Json resource})>[];

  String get _ownSource => LokmanFhir.appSource(ownAppId);

  ParsedBundle read() {
    for (final e in asMapList(bundle['entry'])) {
      final r = asMap(e['resource']);
      if (r == null) continue;
      final fullUrl = asString(e['fullUrl']);
      _entries.add((fullUrl: fullUrl, resource: r));
      if (fullUrl != null) _resources[fullUrl] = r;
      final type = asString(r['resourceType']);
      final id = asString(r['id']);
      if (type != null && id != null) _resources['$type/$id'] = r;
    }

    final composition = _entries
        .map((e) => e.resource)
        .where((r) => r['resourceType'] == 'Composition')
        .firstOrNull;
    final custodian =
        _deref(composition?['custodian']) ??
        asMapList(composition?['author'])
            .map(_deref)
            .where((r) => r?['resourceType'] == 'Organization')
            .firstOrNull ??
        _entries
            .map((e) => e.resource)
            .where((r) => r['resourceType'] == 'Organization')
            .firstOrNull;
    final orgName = asString(custodian?['name']);
    final orgIdentifier = asMapList(custodian?['identifier']).firstOrNull;
    final bundleSource = orgIdentifier != null
        ? '${orgIdentifier['system']}|${orgIdentifier['value']}'
        : asString(asMap(bundle['identifier'])?['value']) ??
              asString(bundle['id']) ??
              'urn:unknown';

    ParsedPatient? patient;
    final records = <ParsedRecord>[];
    var ignored = 0;

    for (final e in _entries) {
      final r = e.resource;
      final type = asString(r['resourceType']);
      final id = asString(r['id']);
      if (type == 'Patient') {
        patient ??= _patient(r);
        continue;
      }
      if (type == 'Composition' || type == 'Organization') continue;
      if (type == null || id == null) {
        ignored++;
        continue;
      }
      final meta = asMap(r['meta']);
      final source = asString(meta?['source']) ?? bundleSource;
      final tag = asMapList(meta?['tag'])
          .where((t) => t['system'] == LokmanFhir.recordSourceTag)
          .firstOrNull;
      final patientReported = tag?['code'] == LokmanFhir.tagPatientReported;
      final own = source == _ownSource;
      // Başka bir telefondan / Lokman'dan iletilen kayıt asıl kimliğini
      // taşır; tekrar aktarımda aynı satır bulunur.
      final forwardedRef = asMapList(r['identifier'])
          .where((i) => i['system'] == LokmanFhir.originRefSystem)
          .map((i) => asString(i['value']))
          .nonNulls
          .firstOrNull;
      // Bu telefondan çıkıp başka telefondan geri gelen kendi kaydımız.
      final ownForwarded =
          forwardedRef != null && forwardedRef.startsWith('$_ownSource|');
      final localId = ownForwarded
          ? forwardedRef.substring(forwardedRef.lastIndexOf('/') + 1)
          : id;
      final origin = _Origin(
        originRef: ownForwarded
            ? null
            : forwardedRef ?? (own ? null : '$source|$type/$id'),
        source: patientReported ? RecordSource.self : RecordSource.clinic,
        originName: patientReported
            ? null
            : asString(tag?['display']) ?? orgName,
      );
      final keys = {'$type/$id', ?e.fullUrl};

      final parsed = switch (type) {
        'Encounter' => _encounter(r, origin),
        'Condition' => _condition(r, origin),
        'MedicationRequest' => _medication(r, origin),
        'Immunization' => _immunization(r, origin),
        'ImmunizationRecommendation' => _recommendation(r, origin),
        'Observation' => _observation(r, origin),
        'Appointment' => _appointment(r, origin),
        'AllergyIntolerance' => _allergy(r, origin),
        _ => null,
      };
      if (parsed == null || parsed.isEmpty) {
        ignored++;
        continue;
      }
      for (final (i, p) in parsed.indexed) {
        // Bir kaynaktan birden çok satır çıkabilir (aşı önerisi).
        final suffix = parsed.length > 1 ? '#$i' : '';
        records.add(
          ParsedRecord(
            kind: p.kind,
            resourceType: type,
            resourceId: '$localId$suffix',
            table: p.table,
            originRef: origin.originRef == null
                ? null
                : '${origin.originRef}$suffix',
            source: origin.source,
            originName: origin.originName,
            raw: r,
            keys: suffix.isEmpty ? keys : const {},
            build: p.build,
          ),
        );
      }
    }

    return ParsedBundle(
      patient: patient,
      organizationName: orgName,
      records: records,
      ignored: ignored,
    );
  }

  Json? _deref(Object? reference) {
    final ref = asString(asMap(reference)?['reference']);
    return ref == null ? null : _resources[ref];
  }

  ParsedPatient _patient(Json r) {
    final name = asMapList(r['name']).firstOrNull;
    final given =
        (name?['given'] as List?)?.whereType<String>().join(' ') ?? '';
    final family = asString(name?['family']) ?? '';
    final text = asString(name?['text']);
    return ParsedPatient(
      firstName: given.isNotEmpty ? given : (text ?? 'Adsız'),
      lastName: given.isNotEmpty ? family : '',
      birthDate: parseFhirDate(r['birthDate']),
      gender: switch (r['gender']) {
        'female' => 'female',
        'male' => 'male',
        'other' => 'other',
        _ => null,
      },
      identifiers: [
        for (final i in asMapList(r['identifier']))
          if (asString(i['system']) != null && asString(i['value']) != null)
            (system: i['system'] as String, value: i['value'] as String),
      ],
    );
  }

  String? _note(Json r) =>
      asMapList(r['note'])
          .map((n) => asString(n['text']))
          .nonNulls
          .join('\n')
          .nullIfEmpty;

  List<_Row>? _encounter(Json r, _Origin o) {
    final date = parseFhirDate(asMap(r['period'])?['start']);
    if (date == null) return null;
    String? ext(String url) =>
        asMapList(r['extension'])
            .where((e) => e['url'] == url)
            .map((e) => asString(e['valueString']))
            .firstOrNull;
    final practitioner = asMapList(r['participant'])
        .map((p) => asString(asMap(p['individual'])?['display']))
        .nonNulls
        .firstOrNull;
    final location =
        asString(asMap(r['serviceProvider'])?['display']) ??
        asMapList(r['location'])
            .map((l) => asString(asMap(l['location'])?['display']))
            .nonNulls
            .firstOrNull;
    final complaint = asMapList(r['reasonCode'])
        .map(conceptText)
        .nonNulls
        .join(', ');
    return [
      _Row(RecordKind.encounter, db.encounters, (c) {
        return EncountersCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          date: date,
          practitioner: Value(practitioner),
          location: Value(location),
          complaint: Value(complaint.nullIfEmpty),
          findings: Value(ext(LokmanFhir.encounterFindings)),
          plan: Value(ext(LokmanFhir.encounterPlan)),
          note: Value(ext(LokmanFhir.encounterNote)),
        );
      }),
    ];
  }

  List<_Row>? _condition(Json r, _Origin o) {
    final name = conceptText(r['code']);
    if (name == null) return null;
    final code =
        conceptCode(r['code'], FhirSystems.icd10) ?? conceptCode(r['code']);
    final isDiagnosis = asMapList(r['category']).any(
      (c) =>
          conceptHas(c, FhirSystems.conditionCategory, 'encounter-diagnosis'),
    );
    if (isDiagnosis) {
      final provisional =
          conceptCode(
            r['verificationStatus'],
            FhirSystems.conditionVerification,
          ) ==
          'provisional';
      final encounterRef = asString(asMap(r['encounter'])?['reference']);
      final date =
          parseFhirDate(r['recordedDate']) ?? parseFhirDate(r['onsetDateTime']);
      return [
        _Row(RecordKind.diagnosis, db.diagnoses, (c) {
          return DiagnosesCompanion.insert(
            id: Value(c.id),
            profileId: c.profileId,
            source: Value(o.source),
            originName: Value(o.originName),
            originRef: Value(c.originRef),
            encounterId: Value(c.resolve(encounterRef)),
            date: Value(date),
            code: Value(code),
            name: name,
            verification: Value(provisional ? 'provisional' : 'confirmed'),
          );
        }),
      ];
    }
    final resolvedDate = parseFhirDate(r['abatementDateTime']);
    // inactive / resolved geçmiş hastalıktır; durum yazılmamışsa bitiş
    // tarihine bakılır. Diğer durumlar (remission dahil) devam eden sayılır.
    final resolved = switch (conceptCode(
      r['clinicalStatus'],
      FhirSystems.conditionClinical,
    )) {
      'inactive' || 'resolved' => true,
      null => resolvedDate != null,
      _ => false,
    };
    return [
      _Row(RecordKind.condition, db.conditions, (c) {
        return ConditionsCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          name: name,
          code: Value(code),
          onsetDate: Value(parseFhirDate(r['onsetDateTime'])),
          status: Value(
            resolved ? ConditionStatus.resolved : ConditionStatus.active,
          ),
          resolvedDate: Value(resolved ? resolvedDate : null),
          note: Value(_note(r)),
        );
      }),
    ];
  }

  List<_Row>? _medication(Json r, _Origin o) {
    final name = conceptText(r['medicationCodeableConcept']);
    if (name == null) return null;
    final atc = conceptCode(r['medicationCodeableConcept'], FhirSystems.atc);
    final dosage = asMapList(r['dosageInstruction']).firstOrNull;
    final repeat = asMap(asMap(dosage?['timing'])?['repeat']);
    final times = ((repeat?['timeOfDay'] as List?) ?? const [])
        .whereType<String>()
        .map(DoseTime.tryParse)
        .nonNulls;
    final doseQty = asMap(
      asMapList(dosage?['doseAndRate']).firstOrNull?['doseQuantity'],
    );
    final dose = doseQty?['value'] is num
        ? '${fmtNumber(doseQty!['value'] as num)} ${asString(doseQty['unit']) ?? ''}'
              .trim()
        : '';
    final period = asMap(repeat?['boundsPeriod']);
    final authored = parseFhirDate(r['authoredOn']);
    final start = parseFhirDate(period?['start']) ?? authored ?? DateTime.now();
    int? duration;
    final end = parseFhirDate(period?['end']);
    if (end != null) {
      duration = dateOnly(end).difference(dateOnly(start)).inDays + 1;
    }
    final bounds = asMap(repeat?['boundsDuration']);
    if (bounds?['value'] is num) {
      final v = (bounds!['value'] as num).toDouble();
      final factor = switch (asString(bounds['code']) ??
          asString(bounds['unit'])) {
        'wk' => 7,
        'mo' => 30,
        'a' => 365,
        _ => 1,
      };
      duration = (v * factor).ceil();
    }
    final status = asString(r['status']);
    final stopped =
        status == 'stopped' || status == 'completed' || status == 'cancelled';
    final stoppedAt =
        end ??
        (duration != null
            ? dateOnly(start).add(Duration(days: duration - 1))
            : authored ?? DateTime.now());
    final instructions = asString(dosage?['text']);
    final note = [instructions, _note(r)].nonNulls.join('\n').nullIfEmpty;
    return [
      _Row(RecordKind.medication, db.medications, (c) {
        return MedicationsCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          name: name,
          dose: Value(dose),
          timesOfDay: Value(DoseTime.formatList(times)),
          startDate: dateOnly(start),
          durationDays: Value(
            duration != null && duration > 0 ? duration : null,
          ),
          note: Value(note),
          atcCode: Value(atc),
          prescriptionRef: Value(
            asString(asMap(r['groupIdentifier'])?['value']),
          ),
          encounterId: Value(
            c.resolve(asString(asMap(r['encounter'])?['reference'])),
          ),
          stoppedAt: Value(stopped ? stoppedAt : null),
        );
      }),
    ];
  }

  List<_Row>? _immunization(Json r, _Origin o) {
    if (r['status'] == 'entered-in-error' || r['status'] == 'not-done') {
      return null;
    }
    final name = conceptText(r['vaccineCode']);
    final date = parseFhirDate(r['occurrenceDateTime']);
    if (name == null || date == null) return null;
    final dose = asMapList(r['protocolApplied'])
        .firstOrNull?['doseNumberPositiveInt'];
    return [
      _Row(RecordKind.immunization, db.immunizations, (c) {
        return ImmunizationsCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          vaccineName: name,
          vaccineCode: Value(conceptCode(r['vaccineCode'])),
          date: date,
          doseNumber: Value(dose is int ? dose : null),
          lotNumber: Value(asString(r['lotNumber'])),
          note: Value(_note(r)),
        );
      }),
    ];
  }

  List<_Row>? _recommendation(Json r, _Origin o) {
    final rows = <_Row>[];
    for (final rec in asMapList(r['recommendation'])) {
      final vaccine = asMapList(rec['vaccineCode']).firstOrNull;
      final name = conceptText(vaccine) ?? conceptText(rec['targetDisease']);
      final due = asMapList(rec['dateCriterion'])
          .map((d) => parseFhirDate(d['value']))
          .nonNulls
          .firstOrNull;
      if (name == null || due == null) continue;
      final status = conceptCode(rec['forecastStatus']);
      final dose = rec['doseNumberPositiveInt'];
      rows.add(
        _Row(RecordKind.dueVaccine, db.immunizationDue, (c) {
          return ImmunizationDueCompanion.insert(
            id: Value(c.id),
            profileId: c.profileId,
            source: Value(o.source),
            originName: Value(o.originName),
            originRef: Value(c.originRef),
            vaccineName: name,
            vaccineCode: Value(conceptCode(vaccine)),
            dueDate: due,
            doseNumber: Value(dose is int ? dose : null),
            note: Value(asString(rec['description'])),
            done: Value(status == 'complete' || status == 'immune'),
          );
        }),
      );
    }
    return rows;
  }

  List<_Row>? _observation(Json r, _Origin o) {
    if (r['status'] == 'entered-in-error' || r['status'] == 'cancelled') {
      return null;
    }
    final loinc = conceptCode(r['code'], FhirSystems.loinc);
    final type = observationTypeByLoinc(loinc);
    final date =
        parseFhirDate(r['effectiveDateTime']) ??
        parseFhirDate(asMap(r['effectivePeriod'])?['start']) ??
        parseFhirDate(r['issued']);
    if (date == null) return null;
    double? value;
    double? value2;
    String unit = '';
    final q = asMap(r['valueQuantity']);
    if (q != null && q['value'] is num) {
      value = (q['value'] as num).toDouble();
      unit = asString(q['unit']) ?? asString(q['code']) ?? '';
    }
    for (final comp in asMapList(r['component'])) {
      final cq = asMap(comp['valueQuantity']);
      if (cq == null || cq['value'] is! num) continue;
      final v = (cq['value'] as num).toDouble();
      final code = conceptCode(comp['code'], FhirSystems.loinc);
      if (code == bloodPressureSystolicLoinc) {
        value = v;
      } else if (code == bloodPressureDiastolicLoinc) {
        value2 = v;
      } else {
        value ??= v;
      }
      unit = unit.isEmpty
          ? (asString(cq['unit']) ?? asString(cq['code']) ?? '')
          : unit;
    }
    final valueString =
        asString(r['valueString']) ?? conceptText(r['valueCodeableConcept']);
    if (value == null && valueString == null) return null;
    final name = type?.nameTr ?? conceptText(r['code']) ?? 'Ölçüm';
    final note = [valueString, _note(r)].nonNulls.join('\n').nullIfEmpty;
    return [
      _Row(RecordKind.observation, db.observations, (c) {
        return ObservationsCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          typeKey: type?.key ?? 'other',
          code: Value(loinc ?? conceptCode(r['code'])),
          name: name,
          value: Value(value),
          value2: Value(value2),
          unit: Value(type?.unit ?? unit),
          effectiveAt: date,
          note: Value(note),
        );
      }),
    ];
  }

  List<_Row>? _appointment(Json r, _Origin o) {
    final start = parseFhirDate(r['start']);
    if (start == null ||
        r['status'] == 'cancelled' ||
        r['status'] == 'entered-in-error') {
      return null;
    }
    String? practitioner;
    String? location;
    for (final p in asMapList(r['participant'])) {
      final actor = asMap(p['actor']);
      final ref = asString(actor?['reference']) ?? '';
      final display = asString(actor?['display']);
      if (display == null) continue;
      if (ref.startsWith('Location') || ref.contains('Location/')) {
        location ??= display;
      } else if (!ref.contains('Patient')) {
        practitioner ??= display;
      }
    }
    final title =
        asString(r['description']) ??
        asMapList(r['serviceType']).map(conceptText).nonNulls.firstOrNull ??
        '';
    return [
      _Row(RecordKind.appointment, db.appointments, (c) {
        return AppointmentsCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          start: start,
          title: Value(title),
          practitioner: Value(practitioner),
          location: Value(location ?? o.originName),
          note: Value(asString(r['comment'])),
        );
      }),
    ];
  }

  List<_Row>? _allergy(Json r, _Origin o) {
    final name = conceptText(r['code']);
    if (name == null) return null;
    final reaction = asMapList(r['reaction'])
        .expand((x) => asMapList(x['manifestation']))
        .map(conceptText)
        .nonNulls
        .join(', ');
    return [
      _Row(RecordKind.allergy, db.allergies, (c) {
        return AllergiesCompanion.insert(
          id: Value(c.id),
          profileId: c.profileId,
          source: Value(o.source),
          originName: Value(o.originName),
          originRef: Value(c.originRef),
          substance: name,
          code: Value(conceptCode(r['code'])),
          reaction: Value(reaction.nullIfEmpty),
          criticality: Value(switch (r['criticality']) {
            'high' => 'high',
            'low' => 'low',
            _ => null,
          }),
          note: Value(_note(r)),
        );
      }),
    ];
  }
}

class _Origin {
  const _Origin({
    required this.originRef,
    required this.source,
    required this.originName,
  });
  final String? originRef;
  final String source;
  final String? originName;
}

class _Row {
  _Row(this.kind, this.table, this.build);
  final RecordKind kind;
  final TableInfo<RecordColumns, dynamic> table;
  final Insertable<dynamic> Function(RecordContext ctx) build;
}

extension on String {
  String? get nullIfEmpty => trim().isEmpty ? null : this;
}
