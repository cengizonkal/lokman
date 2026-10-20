import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../domain/catalog.dart';
import '../domain/dose_schedule.dart';
import 'bundle_reader.dart' show RecordKind;
import 'fhir_common.dart';

/// Dışa aktarılacak profil verisi.
class ExportData {
  ExportData({
    required this.profile,
    required this.links,
    this.allergies = const [],
    this.conditions = const [],
    this.medications = const [],
    this.immunizations = const [],
    this.dueVaccines = const [],
    this.observations = const [],
    this.encounters = const [],
    this.diagnoses = const [],
    this.appointments = const [],
  });

  final Profile profile;
  final List<ProfileLink> links;
  final List<Allergy> allergies;
  final List<Condition> conditions;
  final List<Medication> medications;
  final List<Immunization> immunizations;
  final List<DueVaccine> dueVaccines;
  final List<Observation> observations;
  final List<Encounter> encounters;
  final List<Diagnosis> diagnoses;
  final List<Appointment> appointments;

  int get recordCount =>
      allergies.length +
      conditions.length +
      medications.length +
      immunizations.length +
      dueVaccines.length +
      observations.length +
      encounters.length +
      diagnoses.length +
      appointments.length;

  /// Veritabanından profilin seçilen kayıt türlerini yükler. İlaç uyum
  /// kayıtları (aldım / atladım) hiçbir zaman dışa aktarılmaz.
  static Future<ExportData> load(
    AppDatabase db,
    String profileId, {
    Set<RecordKind> kinds = const {...RecordKind.values},
  }) async {
    final profile = await (db.select(
      db.profiles,
    )..where((t) => t.id.equals(profileId))).getSingle();
    Future<List<D>> rows<T extends RecordColumns, D>(
      RecordKind kind,
      TableInfo<T, D> table,
    ) async {
      if (!kinds.contains(kind)) return [];
      return (db.select(
        table,
      )..where((t) => t.profileId.equals(profileId))).get();
    }

    return ExportData(
      profile: profile,
      links: await (db.select(
        db.profileLinks,
      )..where((t) => t.profileId.equals(profileId))).get(),
      allergies: await rows(RecordKind.allergy, db.allergies),
      conditions: await rows(RecordKind.condition, db.conditions),
      medications: await rows(RecordKind.medication, db.medications),
      immunizations: await rows(RecordKind.immunization, db.immunizations),
      dueVaccines: await rows(RecordKind.dueVaccine, db.immunizationDue),
      observations: await rows(RecordKind.observation, db.observations),
      encounters: await rows(RecordKind.encounter, db.encounters),
      diagnoses: await rows(RecordKind.diagnosis, db.diagnoses),
      appointments: await rows(RecordKind.appointment, db.appointments),
    );
  }
}

/// Profil verisinden IPS uyumlu FHIR R4 belge paketi (Bundle) üretir.
Json buildBundle(ExportData data, {required String appId, DateTime? now}) =>
    _BundleWriter(data, appId, now ?? DateTime.now()).build();

String encodeBundle(Json bundle) =>
    const JsonEncoder.withIndent('  ').convert(bundle);

final _atcPattern = RegExp(r'^[A-Z]\d{2}([A-Z]{1,2}(\d{2})?)?$');
final _icdPattern = RegExp(r'^[A-Z]\d{2}(\.\d{1,4})?$');

class _BundleWriter {
  _BundleWriter(this.data, this.appId, this.now);

  final ExportData data;
  final String appId;
  final DateTime now;

  final _entries = <Json>[];

  String get _patientUrl => 'urn:uuid:${data.profile.id}';
  Json get _patientRef => {'reference': _patientUrl};

  Json build() {
    final bundleId = newId();
    final compositionId = newId();
    final p = data.profile;

    final patient = <String, dynamic>{
      'resourceType': 'Patient',
      'id': p.id,
      'identifier': [
        {'system': LokmanFhir.appProfileSystem(appId), 'value': p.id},
        for (final l in data.links) {'system': l.system, 'value': l.value},
      ],
      'name': [
        {
          if (p.lastName.isNotEmpty) 'family': p.lastName,
          'given': [p.firstName],
        },
      ],
      'gender': ?p.gender,
      if (p.birthDate != null) 'birthDate': fhirDate(p.birthDate!),
    };

    final allergies = data.allergies.map(_allergy).toList();
    final problems = [
      for (final c in data.conditions)
        if (c.status != ConditionStatus.resolved) _condition(c),
    ];
    final pastIllnesses = [
      for (final c in data.conditions)
        if (c.status == ConditionStatus.resolved) _condition(c),
    ];
    final encounterIds = {for (final e in data.encounters) e.id};
    final meds = data.medications
        .map((m) => _medication(m, encounterIds))
        .toList();
    final immunizations = data.immunizations.map(_immunization).toList();
    final observations = data.observations.map(_observation).toList();
    final encounters = [
      ...data.encounters.map(_encounter),
      ...data.diagnoses.map((d) => _diagnosis(d, encounterIds)),
    ];
    final plan = [
      ...data.appointments.map(_appointment),
      ...data.dueVaccines.map(_recommendation),
    ];

    final sections = [
      _section('Alerjiler / Allergies', '48765-2', allergies, required: true),
      _section(
        'Aktif problemler / Problem list',
        '11450-4',
        problems,
        required: true,
      ),
      _section(
        'Geçirilmiş hastalıklar / History of past illness',
        '11348-0',
        pastIllnesses,
      ),
      _section('İlaçlar / Medications', '10160-0', meds, required: true),
      _section('Aşılar / Immunizations', '11369-6', immunizations),
      _section('Vital bulgular / Vital signs', '8716-3', observations),
      _section('Muayeneler / Encounters', '46240-8', encounters),
      _section('Plan / Plan of care', '18776-5', plan),
    ].nonNulls.toList();

    final composition = {
      'resourceType': 'Composition',
      'id': compositionId,
      'status': 'final',
      'type': {
        'coding': [
          {
            'system': FhirSystems.loinc,
            'code': '60591-5',
            'display': 'Patient summary Document',
          },
        ],
      },
      'subject': _patientRef,
      'date': fhirDateTime(now),
      'author': [_patientRef],
      'title': 'Hasta özeti / Patient summary',
      'section': sections,
    };

    return {
      'resourceType': 'Bundle',
      'id': bundleId,
      'meta': {
        'profile': [
          'http://hl7.org/fhir/uv/ips/StructureDefinition/Bundle-uv-ips',
        ],
      },
      'identifier': {
        'system': 'urn:ietf:rfc:3986',
        'value': 'urn:uuid:$bundleId',
      },
      'type': 'document',
      'timestamp': fhirDateTime(now),
      'entry': [
        {'fullUrl': 'urn:uuid:$compositionId', 'resource': composition},
        {'fullUrl': _patientUrl, 'resource': patient},
        ..._entries,
      ],
    };
  }

  Json? _section(
    String title,
    String loinc,
    List<_Item> items, {
    bool required = false,
  }) {
    if (items.isEmpty && !required) return null;
    final rows = items.isEmpty
        ? '<p>Kayıt yok / No information</p>'
        : '<ul>${items.map((i) => '<li>${_escape(i.summary)}</li>').join()}</ul>';
    return {
      'title': title,
      'code': {
        'coding': [
          {'system': FhirSystems.loinc, 'code': loinc},
        ],
      },
      'text': {
        'status': 'generated',
        'div': '<div xmlns="http://www.w3.org/1999/xhtml">$rows</div>',
      },
      if (items.isEmpty)
        'emptyReason': {
          'coding': [
            {
              'system': FhirSystems.listEmptyReason,
              'code': 'unavailable',
              'display': 'Unavailable',
            },
          ],
        }
      else
        'entry': [
          for (final i in items) {'reference': i.url},
        ],
    };
  }

  /// Kaynağı pakete ekler; ortak kimlik ve kaynak bilgisini doldurur.
  _Item _add(
    String type,
    String id,
    String source,
    String? originName,
    String? originRef,
    Json body,
    String summary,
  ) {
    final url = 'urn:uuid:$id';
    final selfReported = source == RecordSource.self;
    final metaSource = originRef == null
        ? LokmanFhir.appSource(appId)
        : originRef.substring(
            0,
            originRef.lastIndexOf('|').clamp(0, originRef.length),
          );
    final resource = <String, dynamic>{
      'resourceType': type,
      'id': id,
      'meta': {
        if (metaSource.isNotEmpty) 'source': metaSource,
        'tag': [
          {
            'system': LokmanFhir.recordSourceTag,
            'code': selfReported
                ? LokmanFhir.tagPatientReported
                : LokmanFhir.tagExternal,
            'display': selfReported ? 'Hasta beyanı' : (originName ?? 'Kurum'),
          },
        ],
      },
      if (originRef != null)
        'identifier': [
          {'system': LokmanFhir.originRefSystem, 'value': originRef},
        ],
      ...body,
    };
    _entries.add({'fullUrl': url, 'resource': resource});
    return _Item(url, summary);
  }

  Json? _code(String? code, RegExp pattern, String system, String? text) {
    if (code == null && text == null) return null;
    final known = code != null && pattern.hasMatch(code);
    return concept(system: known ? system : null, code: code, text: text);
  }

  _Item _allergy(Allergy a) =>
      _add('AllergyIntolerance', a.id, a.source, a.originName, a.originRef, {
        'clinicalStatus': {
          'coding': [
            {'system': FhirSystems.allergyClinical, 'code': 'active'},
          ],
        },
        'criticality': ?a.criticality,
        'code': _code(a.code, _atcPattern, FhirSystems.atc, a.substance),
        'patient': _patientRef,
        if (a.source == RecordSource.self) 'asserter': _patientRef,
        if (a.reaction != null)
          'reaction': [
            {
              'manifestation': [
                {'text': a.reaction},
              ],
            },
          ],
        if (a.note != null)
          'note': [
            {'text': a.note},
          ],
      }, [a.substance, a.reaction].nonNulls.join(' — '));

  _Item _condition(Condition c) =>
      _add('Condition', c.id, c.source, c.originName, c.originRef, {
        'clinicalStatus': {
          'coding': [
            {
              'system': FhirSystems.conditionClinical,
              'code': c.status == ConditionStatus.resolved
                  ? 'resolved'
                  : 'active',
            },
          ],
        },
        'category': [
          {
            'coding': [
              {
                'system': FhirSystems.conditionCategory,
                'code': 'problem-list-item',
              },
            ],
          },
        ],
        'code': _code(c.code, _icdPattern, FhirSystems.icd10, c.name),
        'subject': _patientRef,
        if (c.onsetDate != null) 'onsetDateTime': fhirDate(c.onsetDate!),
        if (c.status == ConditionStatus.resolved && c.resolvedDate != null)
          'abatementDateTime': fhirDate(c.resolvedDate!),
        if (c.note != null)
          'note': [
            {'text': c.note},
          ],
      }, c.name);

  _Item _diagnosis(Diagnosis d, Set<String> encounterIds) =>
      _add('Condition', d.id, d.source, d.originName, d.originRef, {
        'verificationStatus': {
          'coding': [
            {
              'system': FhirSystems.conditionVerification,
              'code': d.verification == 'provisional'
                  ? 'provisional'
                  : 'confirmed',
            },
          ],
        },
        'category': [
          {
            'coding': [
              {
                'system': FhirSystems.conditionCategory,
                'code': 'encounter-diagnosis',
              },
            ],
          },
        ],
        'code': _code(d.code, _icdPattern, FhirSystems.icd10, d.name),
        'subject': _patientRef,
        if (d.encounterId != null && encounterIds.contains(d.encounterId))
          'encounter': {'reference': 'urn:uuid:${d.encounterId}'},
        if (d.date != null) 'recordedDate': fhirDate(d.date!),
      }, d.name);

  _Item _medication(Medication m, Set<String> encounterIds) {
    final times = DoseTime.parseList(m.timesOfDay);
    final last = lastDay(m);
    final status = m.stoppedAt != null
        ? 'stopped'
        : (last != null && dateOnly(now).isAfter(last)
              ? 'completed'
              : 'active');
    final doseMatch = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(.*)$')
        .firstMatch(m.dose.trim());
    final instructions = [
      m.dose,
      m.note,
    ].nonNulls.where((s) => s.trim().isNotEmpty).join(' — ');
    return _add(
      'MedicationRequest',
      m.id,
      m.source,
      m.originName,
      m.originRef,
      {
        'status': status,
        'intent': m.source == RecordSource.self ? 'plan' : 'order',
        if (m.prescriptionRef != null)
          'groupIdentifier': {'value': m.prescriptionRef},
        'medicationCodeableConcept': _code(
          m.atcCode,
          _atcPattern,
          FhirSystems.atc,
          m.name,
        ),
        'subject': _patientRef,
        if (m.encounterId != null && encounterIds.contains(m.encounterId))
          'encounter': {'reference': 'urn:uuid:${m.encounterId}'},
        'authoredOn': fhirDate(m.startDate),
        'dosageInstruction': [
          {
            if (instructions.isNotEmpty) 'text': instructions,
            'timing': {
              'repeat': {
                'boundsPeriod': {
                  'start': fhirDate(m.startDate),
                  if (last != null) 'end': fhirDate(last),
                },
                if (times.isNotEmpty)
                  'timeOfDay': [for (final t in times) '${t.label}:00'],
              },
            },
            if (doseMatch != null)
              'doseAndRate': [
                {
                  'doseQuantity': {
                    'value': num.parse(
                      doseMatch.group(1)!.replaceAll(',', '.'),
                    ),
                    if (doseMatch.group(2)!.isNotEmpty)
                      'unit': doseMatch.group(2),
                  },
                },
              ],
          },
        ],
      },
      [
        m.name,
        m.dose,
        if (times.isNotEmpty) times.join(', '),
      ].where((s) => s.isNotEmpty).join(' — '),
    );
  }

  _Item _immunization(Immunization i) =>
      _add('Immunization', i.id, i.source, i.originName, i.originRef, {
        'status': 'completed',
        'vaccineCode': _code(
          i.vaccineCode,
          _atcPattern,
          FhirSystems.atc,
          i.vaccineName,
        ),
        'patient': _patientRef,
        'occurrenceDateTime': fhirDateTime(i.date),
        'primarySource': i.source != RecordSource.self,
        if (i.source == RecordSource.self)
          'reportOrigin': {'text': 'Hasta beyanı / Patient reported'},
        'lotNumber': ?i.lotNumber,
        if (i.note != null)
          'note': [
            {'text': i.note},
          ],
        if (i.doseNumber != null)
          'protocolApplied': [
            {'doseNumberPositiveInt': i.doseNumber},
          ],
      }, '${i.vaccineName} (${fhirDate(i.date)})');

  _Item _recommendation(DueVaccine d) => _add(
    'ImmunizationRecommendation',
    d.id,
    d.source,
    d.originName,
    d.originRef,
    {
      'patient': _patientRef,
      'date': fhirDateTime(d.createdAt),
      'recommendation': [
        {
          'vaccineCode': [
            _code(d.vaccineCode, _atcPattern, FhirSystems.atc, d.vaccineName),
          ],
          'forecastStatus': {
            'coding': [
              {
                'system': FhirSystems.recommendationStatus,
                'code': d.done ? 'complete' : 'due',
              },
            ],
          },
          'dateCriterion': [
            {
              'code': {
                'coding': [
                  {
                    'system': FhirSystems.loinc,
                    'code': '30980-7',
                    'display': 'Date vaccine due',
                  },
                ],
              },
              'value': fhirDateTime(d.dueDate),
            },
          ],
          'doseNumberPositiveInt': ?d.doseNumber,
          'description': ?d.note,
        },
      ],
    },
    '${d.vaccineName} (${fhirDate(d.dueDate)})',
  );

  _Item _observation(Observation o) {
    final type = observationTypeByKey(o.typeKey);
    Json quantity(double v) => {
      'value': v,
      'unit': o.unit,
      if (type != null) 'system': FhirSystems.ucum,
      if (type != null) 'code': type.ucum,
    };
    final Json value;
    if (type != null && type.hasTwoValues) {
      value = {
        'component': [
          if (o.value != null)
            {
              'code': concept(
                system: FhirSystems.loinc,
                code: bloodPressureSystolicLoinc,
                display: 'Systolic blood pressure',
              ),
              'valueQuantity': quantity(o.value!),
            },
          if (o.value2 != null)
            {
              'code': concept(
                system: FhirSystems.loinc,
                code: bloodPressureDiastolicLoinc,
                display: 'Diastolic blood pressure',
              ),
              'valueQuantity': quantity(o.value2!),
            },
        ],
      };
    } else if (o.value != null) {
      value = {'valueQuantity': quantity(o.value!)};
    } else {
      value = {'valueString': o.note ?? ''};
    }
    final code = type?.loinc ?? o.code;
    return _add('Observation', o.id, o.source, o.originName, o.originRef, {
      'status': 'final',
      'category': [
        {
          'coding': [
            {'system': FhirSystems.observationCategory, 'code': 'vital-signs'},
          ],
        },
      ],
      'code': concept(
        system: type != null ? FhirSystems.loinc : null,
        code: code,
        display: type?.nameEn,
        text: o.name,
      ),
      'subject': _patientRef,
      'effectiveDateTime': fhirDateTime(o.effectiveAt),
      if (o.source == RecordSource.self) 'performer': [_patientRef],
      ...value,
      if (o.note != null && o.value != null)
        'note': [
          {'text': o.note},
        ],
    }, '${o.name}: ${_valueText(o)} (${fhirDate(o.effectiveAt)})');
  }

  _Item _encounter(Encounter e) => _add(
    'Encounter',
    e.id,
    e.source,
    e.originName,
    e.originRef,
    {
      'extension': [
        if (e.findings != null)
          {'url': LokmanFhir.encounterFindings, 'valueString': e.findings},
        if (e.plan != null)
          {'url': LokmanFhir.encounterPlan, 'valueString': e.plan},
        if (e.note != null)
          {'url': LokmanFhir.encounterNote, 'valueString': e.note},
      ],
      'status': 'finished',
      'class': {
        'system': 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
        'code': 'AMB',
      },
      'subject': _patientRef,
      if (e.practitioner != null)
        'participant': [
          {
            'individual': {'display': e.practitioner},
          },
        ],
      'period': {'start': fhirDateTime(e.date)},
      if (e.location != null) 'serviceProvider': {'display': e.location},
      if (e.complaint != null)
        'reasonCode': [
          {'text': e.complaint},
        ],
    }..removeWhere((k, v) => k == 'extension' && (v as List).isEmpty),
    [
      fhirDate(e.date),
      e.location ?? e.originName,
      e.practitioner,
      e.complaint,
    ].nonNulls.join(' — '),
  );

  _Item _appointment(Appointment a) => _add(
    'Appointment',
    a.id,
    a.source,
    a.originName,
    a.originRef,
    {
      'status': a.start.isBefore(now) ? 'fulfilled' : 'booked',
      if (a.title.isNotEmpty) 'description': a.title,
      'start': fhirDateTime(a.start),
      'end': fhirDateTime(a.start.add(const Duration(minutes: 30))),
      'comment': ?a.note,
      'participant': [
        {'actor': _patientRef, 'status': 'accepted'},
        if (a.practitioner != null)
          {
            'actor': {'display': a.practitioner},
            'status': 'accepted',
          },
        if (a.location != null)
          {
            'actor': {'display': a.location},
            'status': 'accepted',
          },
      ],
    },
    [
      fhirDateTime(a.start).substring(0, 16).replaceFirst('T', ' '),
      a.title,
      a.practitioner,
    ].nonNulls.where((s) => s.isNotEmpty).join(' — '),
  );
}

String _valueText(Observation o) {
  if (o.value == null) return o.note ?? '';
  final v = o.value2 != null
      ? '${fmtNumber(o.value!)}/${fmtNumber(o.value2!)}'
      : fmtNumber(o.value!);
  return '$v ${o.unit}'.trim();
}

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

class _Item {
  _Item(this.url, this.summary);
  final String url;
  final String summary;
}
