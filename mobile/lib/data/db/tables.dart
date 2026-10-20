import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newId() => _uuid.v7();

/// Kayıt kaynağı: klinikten / kurumdan gelen ya da kullanıcının kendi girdiği.
abstract final class RecordSource {
  static const clinic = 'clinic';
  static const self = 'self';
}

/// Hastalığın durumu (FHIR `Condition.clinicalStatus`).
abstract final class ConditionStatus {
  static const active = 'active';
  static const resolved = 'resolved';
}

/// Profile bağlı tüm sağlık kayıtlarının ortak kolonları.
mixin RecordColumns on Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get source =>
      text().withDefault(const Constant(RecordSource.self))();

  /// Kaydın geldiği kurumun adı (yalnızca klinikten gelenlerde).
  TextColumn get originName => text().nullable()();

  /// Kaynak sistemdeki kimlik (`<kaynak>|<Tür>/<id>`). Tekrar aktarımda
  /// aynı kaydın bulunmasını sağlar.
  TextColumn get originRef => text().nullable().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Profiles extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  DateTimeColumn get birthDate => dateTime().nullable()();

  /// `female`, `male`, `other` ya da boş.
  TextColumn get gender => text().nullable()();
  TextColumn get bloodType => text().nullable()();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Profil ↔ klinik eşlemesi: klinikteki hasta kimliği (`Patient.identifier`).
class ProfileLinks extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get system => text()();
  TextColumn get value => text()();
  TextColumn get organizationName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {system, value},
  ];
}

/// Muayeneler: klinikten gelenler ve kullanıcının kendi girdiği doktor
/// ziyaretleri.
class Encounters extends Table with RecordColumns {
  DateTimeColumn get date => dateTime()();
  TextColumn get practitioner => text().nullable()();

  /// Gidilen hastane / klinik (FHIR `Encounter.serviceProvider`).
  TextColumn get location => text().nullable()();
  TextColumn get complaint => text().nullable()();
  TextColumn get findings => text().nullable()();

  /// Hekimin hastaya önerileri.
  TextColumn get plan => text().nullable()();

  /// Kullanıcının kendi notu.
  TextColumn get note => text().nullable()();
}

@DataClassName('Diagnosis')
class Diagnoses extends Table with RecordColumns {
  TextColumn get encounterId => text().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();

  /// `provisional` (ön tanı) ya da `confirmed` (kesin tanı).
  TextColumn get verification =>
      text().withDefault(const Constant('confirmed'))();
}

class Medications extends Table with RecordColumns {
  TextColumn get name => text()();

  /// Serbest metin doz: "1 tablet", "5 ml".
  TextColumn get dose => text().withDefault(const Constant(''))();

  /// Virgülle ayrılmış saatler: "08:00,20:00".
  TextColumn get timesOfDay => text().withDefault(const Constant(''))();
  DateTimeColumn get startDate => dateTime()();

  /// Gün olarak süre; boşsa sürekli kullanım.
  IntColumn get durationDays => integer().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get atcCode => text().nullable()();

  /// Aynı reçetedeki kalemleri gruplar (`MedicationRequest.groupIdentifier`).
  TextColumn get prescriptionRef => text().nullable()();

  /// İlacın yazıldığı muayene (`MedicationRequest.encounter`).
  TextColumn get encounterId => text().nullable()();
  DateTimeColumn get stoppedAt => dateTime().nullable()();
}

/// Aldım / atladım kayıtları. Yalnızca telefonda kalır, dışa aktarılmaz.
class DoseEvents extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledAt => dateTime()();

  /// `taken` ya da `skipped`.
  TextColumn get status => text()();
  DateTimeColumn get markedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {medicationId, scheduledAt},
  ];
}

class Immunizations extends Table with RecordColumns {
  TextColumn get vaccineName => text()();
  TextColumn get vaccineCode => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get doseNumber => integer().nullable()();
  TextColumn get lotNumber => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// Planlanan aşılar (`ImmunizationRecommendation`).
@DataClassName('DueVaccine')
class ImmunizationDue extends Table with RecordColumns {
  TextColumn get vaccineName => text()();
  TextColumn get vaccineCode => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  IntColumn get doseNumber => integer().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class Observations extends Table with RecordColumns {
  /// Uygulamanın ölçüm türü anahtarı (`bp`, `weight`…) ya da `other`.
  TextColumn get typeKey => text()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  RealColumn get value => real().nullable()();

  /// Tansiyonda küçük (diyastolik) değer.
  RealColumn get value2 => real().nullable()();
  TextColumn get unit => text().withDefault(const Constant(''))();
  DateTimeColumn get effectiveAt => dateTime()();
  TextColumn get note => text().nullable()();
}

class Appointments extends Table with RecordColumns {
  DateTimeColumn get start => dateTime()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get practitioner => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get note => text().nullable()();
}

class Allergies extends Table with RecordColumns {
  TextColumn get substance => text()();
  TextColumn get code => text().nullable()();
  TextColumn get reaction => text().nullable()();

  /// `high` (ağır) ya da `low` (hafif); boş olabilir.
  TextColumn get criticality => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// Devam eden ve geçirilmiş hastalıklar.
class Conditions extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  DateTimeColumn get onsetDate => dateTime().nullable()();

  /// [ConditionStatus] değerlerinden biri.
  TextColumn get status =>
      text().withDefault(const Constant(ConditionStatus.active))();

  /// Hastalığın geçtiği tarih (yalnızca geçirilmiş hastalıklarda).
  DateTimeColumn get resolvedDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

/// İçe aktarılan her kaynağın ham FHIR JSON'u.
class FhirResources extends Table {
  TextColumn get resourceType => text()();

  /// İlgili tablodaki satır kimliği.
  TextColumn get localId => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get json => text()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {resourceType, localId};
}

@DataClassName('ImportRecord')
class ImportHistory extends Table {
  TextColumn get id => text().clientDefault(newId)();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get originName => text().nullable()();
  TextColumn get summary => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
