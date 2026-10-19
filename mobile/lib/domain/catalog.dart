/// Uygulamanın bildiği ölçüm türleri (LOINC + UCUM). Kullanıcı yalnızca
/// Türkçe adı görür; kodlar dışa aktarımda kullanılır.
class ObservationType {
  const ObservationType({
    required this.key,
    required this.nameTr,
    required this.nameEn,
    required this.loinc,
    required this.unit,
    required this.ucum,
    this.loinc2,
    this.nameTr2,
    this.decimals = 0,
    this.normalLow,
    this.normalHigh,
  });

  final String key;
  final String nameTr;
  final String nameEn;
  final String loinc;

  /// Kullanıcıya gösterilen birim.
  final String unit;

  /// UCUM birim kodu.
  final String ucum;

  /// İki değerli ölçümlerde (tansiyon) ikinci bileşen.
  final String? loinc2;
  final String? nameTr2;
  final int decimals;
  final double? normalLow;
  final double? normalHigh;

  bool get hasTwoValues => loinc2 != null;
}

const bloodPressureSystolicLoinc = '8480-6';
const bloodPressureDiastolicLoinc = '8462-4';

const observationTypes = <ObservationType>[
  ObservationType(
    key: 'bp',
    nameTr: 'Tansiyon',
    nameEn: 'Blood pressure',
    loinc: '85354-9',
    loinc2: bloodPressureDiastolicLoinc,
    nameTr2: 'Küçük tansiyon',
    unit: 'mmHg',
    ucum: 'mm[Hg]',
    normalLow: 90,
    normalHigh: 140,
  ),
  ObservationType(
    key: 'pulse',
    nameTr: 'Nabız',
    nameEn: 'Heart rate',
    loinc: '8867-4',
    unit: '/dk',
    ucum: '/min',
    normalLow: 50,
    normalHigh: 100,
  ),
  ObservationType(
    key: 'glucose',
    nameTr: 'Kan şekeri',
    nameEn: 'Blood glucose',
    loinc: '2339-0',
    unit: 'mg/dL',
    ucum: 'mg/dL',
    normalLow: 70,
    normalHigh: 140,
  ),
  ObservationType(
    key: 'weight',
    nameTr: 'Kilo',
    nameEn: 'Body weight',
    loinc: '29463-7',
    unit: 'kg',
    ucum: 'kg',
    decimals: 1,
  ),
  ObservationType(
    key: 'height',
    nameTr: 'Boy',
    nameEn: 'Body height',
    loinc: '8302-2',
    unit: 'cm',
    ucum: 'cm',
  ),
  ObservationType(
    key: 'temp',
    nameTr: 'Ateş',
    nameEn: 'Body temperature',
    loinc: '8310-5',
    unit: '°C',
    ucum: 'Cel',
    decimals: 1,
    normalLow: 36,
    normalHigh: 37.5,
  ),
  ObservationType(
    key: 'spo2',
    nameTr: 'Oksijen (SpO₂)',
    nameEn: 'Oxygen saturation',
    loinc: '59408-5',
    unit: '%',
    ucum: '%',
    normalLow: 94,
  ),
];

ObservationType? observationTypeByKey(String key) {
  for (final t in observationTypes) {
    if (t.key == key) return t;
  }
  return null;
}

ObservationType? observationTypeByLoinc(String? code) {
  if (code == null) return null;
  for (final t in observationTypes) {
    if (t.loinc == code) return t;
  }
  // Tansiyon tek bileşenle (büyük tansiyon) gelirse de tanınır.
  if (code == bloodPressureSystolicLoinc) return observationTypeByKey('bp');
  if (code == '2708-6') return observationTypeByKey('spo2');
  return null;
}

/// Form alanlarında öneri olarak gösterilen yaygın değerler.
const vaccineSuggestions = [
  'Grip (influenza)',
  'COVID-19',
  'Tetanoz-difteri (Td)',
  'Hepatit B',
  'Hepatit A',
  'KKK (kızamık, kızamıkçık, kabakulak)',
  'Suçiçeği',
  'Pnömokok',
  'HPV',
  'BCG (verem)',
  'DaBT-İPA-Hib',
  'Rotavirüs',
  'Meningokok',
];

const allergySuggestions = [
  'Penisilin',
  'Amoksisilin',
  'Sefalosporin',
  'Aspirin',
  'Ağrı kesici (NSAİİ)',
  'Sülfonamid',
  'Lateks',
  'Fıstık',
  'Süt',
  'Yumurta',
  'Deniz ürünleri',
  'Polen',
  'Ev tozu',
  'Arı sokması',
];

const conditionSuggestions = [
  'Hipertansiyon (yüksek tansiyon)',
  'Tip 2 diyabet',
  'Tip 1 diyabet',
  'Astım',
  'KOAH',
  'Hipotiroidi',
  'Hipertiroidi',
  'Kalp yetmezliği',
  'Koroner arter hastalığı',
  'Migren',
  'Epilepsi',
  'Böbrek yetmezliği',
];

const doseSuggestions = [
  '1 tablet',
  '1/2 tablet',
  '2 tablet',
  '1 kapsül',
  '5 ml',
  '1 ölçek',
  '1 damla',
  '1 puf',
];
