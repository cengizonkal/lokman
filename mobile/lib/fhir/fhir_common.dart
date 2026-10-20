/// FHIR JSON'u okurken ve yazarken kullanılan ortak sabitler ve yardımcılar.
library;

typedef Json = Map<String, dynamic>;

abstract final class FhirSystems {
  static const loinc = 'http://loinc.org';
  static const ucum = 'http://unitsofmeasure.org';
  static const icd10 = 'http://hl7.org/fhir/sid/icd-10';
  static const icd10cm = 'http://hl7.org/fhir/sid/icd-10-cm';

  /// ICD-11 MMS (hastalık ve tanı kodları; bkz. docs/TERMINOLOJI.md §3).
  static const icd11 = 'http://id.who.int/icd/release/11/mms';
  static const atc = 'http://www.whocc.no/atc';
  static const conditionCategory =
      'http://terminology.hl7.org/CodeSystem/condition-category';
  static const conditionVerification =
      'http://terminology.hl7.org/CodeSystem/condition-ver-status';
  static const conditionClinical =
      'http://terminology.hl7.org/CodeSystem/condition-clinical';
  static const allergyClinical =
      'http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical';
  static const observationCategory =
      'http://terminology.hl7.org/CodeSystem/observation-category';
  static const listEmptyReason =
      'http://terminology.hl7.org/CodeSystem/list-empty-reason';
  static const recommendationStatus =
      'http://terminology.hl7.org/CodeSystem/immunization-recommendation-status';
}

/// Lokman'a özgü tanımlar (bkz. docs/fhir-sozlesmesi.md).
abstract final class LokmanFhir {
  static const extensionBase =
      'https://github.com/cengizonkal/lokman/fhir/StructureDefinition/';
  static const encounterFindings = '${extensionBase}encounter-findings';
  static const encounterPlan = '${extensionBase}encounter-plan';
  static const encounterNote = '${extensionBase}encounter-note';

  /// Kaydın kaynağını taşıyan `meta.tag` sistemi.
  static const recordSourceTag = 'urn:lokman:record-source';
  static const tagPatientReported = 'patient-reported';
  static const tagExternal = 'external';

  static const installationSystem = 'urn:lokman:installation';

  /// İletilen kaydın kaynak sistemdeki kimliği (`<kaynak>|<Tür>/<id>`).
  static const originRefSystem = 'urn:lokman:origin-ref';

  static String appSource(String appId) => 'urn:lokman:app:$appId';
  static String appProfileSystem(String appId) =>
      'urn:lokman:app:$appId:profile';
}

Json? asMap(Object? v) => v is Map<String, dynamic> ? v : null;

List<Json> asMapList(Object? v) =>
    v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];

String? asString(Object? v) => v is String && v.trim().isNotEmpty ? v : null;

/// FHIR tarih / tarih-saat değerini yerel saate çevirir. Yalnızca tarih
/// verilmişse o günün yerel gece yarısını döndürür.
DateTime? parseFhirDate(Object? v) {
  final s = asString(v);
  if (s == null) return null;
  if (RegExp(r'^\d{4}$').hasMatch(s)) return DateTime(int.parse(s));
  if (RegExp(r'^\d{4}-\d{2}$').hasMatch(s)) {
    return DateTime(int.parse(s.substring(0, 4)), int.parse(s.substring(5)));
  }
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
    final d = DateTime.parse(s);
    return DateTime(d.year, d.month, d.day);
  }
  return DateTime.tryParse(s)?.toLocal();
}

String fhirDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}';

/// Saat dilimi ofsetiyle tarih-saat: `2026-10-15T10:00:00+03:00`.
String fhirDateTime(DateTime d) {
  final local = d.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  return '${fhirDate(local)}T${_pad2(local.hour)}:${_pad2(local.minute)}:'
      '${_pad2(local.second)}$sign${_pad2(abs.inHours)}:${_pad2(abs.inMinutes % 60)}';
}

String _pad2(int v) => v.toString().padLeft(2, '0');

/// CodeableConcept'ten gösterilecek ad: önce `text`, sonra ilk `display`.
String? conceptText(Object? concept) {
  final c = asMap(concept);
  if (c == null) return null;
  final text = asString(c['text']);
  if (text != null) return text;
  for (final coding in asMapList(c['coding'])) {
    final d = asString(coding['display']) ?? asString(coding['code']);
    if (d != null) return d;
  }
  return null;
}

/// CodeableConcept içinden verilen sistemdeki kod. [system] boşsa ilk kod.
String? conceptCode(Object? concept, [String? system]) {
  for (final coding in asMapList(asMap(concept)?['coding'])) {
    if (system == null || coding['system'] == system) {
      final code = asString(coding['code']);
      if (code != null) return code;
    }
  }
  return null;
}

/// Kod sisteminin kullanıcıya gösterilen kısa adı; tanınmayan sistemde boş.
String? codeSystemLabel(String? system) => switch (system) {
  FhirSystems.icd11 => 'ICD-11',
  FhirSystems.icd10 => 'ICD-10',
  FhirSystems.icd10cm => 'ICD-10-CM',
  FhirSystems.atc => 'ATC',
  FhirSystems.loinc => 'LOINC',
  _ => null,
};

/// CodeableConcept içinden tercih edilen kodlama: [systems] sırayla denenir,
/// hiçbiri yoksa koda sahip ilk kodlama döner (dışarıdan gelen, katalogda
/// olmayan sistemler de kaybolmaz).
Json? preferredCoding(Object? concept, List<String> systems) {
  final codings = asMapList(asMap(concept)?['coding'])
      .where((c) => asString(c['code']) != null)
      .toList();
  for (final system in systems) {
    for (final coding in codings) {
      if (coding['system'] == system) return coding;
    }
  }
  return codings.firstOrNull;
}

bool conceptHas(Object? concept, String system, String code) =>
    asMapList(asMap(concept)?['coding'])
        .any((c) => c['system'] == system && c['code'] == code);

Json concept({String? system, String? code, String? display, String? text}) => {
  if (code != null)
    'coding': [
      {'system': ?system, 'code': code, 'display': ?display},
    ],
  'text': ?text,
};

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

bool isUuid(String s) => _uuidPattern.hasMatch(s);

String fmtNumber(num v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();
