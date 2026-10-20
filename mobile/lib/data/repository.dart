import 'package:drift/drift.dart';

import '../domain/terminology/icd11.dart';
import '../fhir/fhir_common.dart' show FhirSystems;
import 'db/database.dart';

abstract final class SettingKeys {
  static const appId = 'app_id';
  static const currentProfile = 'current_profile';
  static const onboardingDone = 'onboarding_done';
  static const lastFullExport = 'last_full_export';
  static const notifyDoses = 'notify_doses';
  static const notifyVaccines = 'notify_vaccines';
  static const notifyAppointments = 'notify_appointments';

  /// Kodsuz kayıtların eşleştirildiği terminoloji paketi sürümü.
  static const terminologyPackage = 'terminology_package';
}

/// Uygulamanın tüm veri erişimi. Ekranlar doğrudan veritabanını değil bu
/// sınıfı kullanır.
class Repository {
  Repository(this.db);

  final AppDatabase db;

  // ---------------------------------------------------------------- Ayarlar

  Future<String?> getSetting(String key) async {
    final row = await (db.select(
      db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchSetting(String key) => (db.select(
    db.appSettings,
  )..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.appSettings)..where((t) => t.key.equals(key))).go();
    } else {
      await db
          .into(db.appSettings)
          .insertOnConflictUpdate(AppSetting(key: key, value: value));
    }
  }

  Future<bool> getFlag(String key, {bool fallback = true}) async {
    final v = await getSetting(key);
    return v == null ? fallback : v == '1';
  }

  Future<void> setFlag(String key, bool value) =>
      setSetting(key, value ? '1' : '0');

  /// Uygulama kurulum kimliği; ilk çağrıda üretilir ve kalıcıdır.
  Future<String> appId() async {
    final existing = await getSetting(SettingKeys.appId);
    if (existing != null) return existing;
    final id = newId();
    await setSetting(SettingKeys.appId, id);
    return id;
  }

  // -------------------------------------------------------------- Profiller

  Stream<List<Profile>> watchProfiles() => (db.select(
    db.profiles,
  )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).watch();

  Future<List<Profile>> profiles() => (db.select(
    db.profiles,
  )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).get();

  Future<Profile?> profile(String id) =>
      (db.select(db.profiles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<String> addProfile(ProfilesCompanion p) async {
    final count = await db.profiles.count().getSingle();
    final row = await db
        .into(db.profiles)
        .insertReturning(
          p.copyWith(
            colorIndex: p.colorIndex.present ? p.colorIndex : Value(count),
          ),
        );
    return row.id;
  }

  Future<void> updateProfile(Profile p) => db.update(db.profiles).replace(p);

  Future<void> deleteProfile(String id) =>
      (db.delete(db.profiles)..where((t) => t.id.equals(id))).go();

  Future<List<ProfileLink>> profileLinks(String profileId) => (db.select(
    db.profileLinks,
  )..where((t) => t.profileId.equals(profileId))).get();

  Stream<List<ProfileLink>> watchProfileLinks(String profileId) => (db.select(
    db.profileLinks,
  )..where((t) => t.profileId.equals(profileId))).watch();

  // ------------------------------------------------------ Genel kayıt işleri

  Stream<List<D>> _watchByProfile<T extends RecordColumns, D>(
    TableInfo<T, D> table,
    String profileId,
    Expression<DateTime> Function(T t) orderBy, {
    bool descending = true,
  }) =>
      (db.select(table)
            ..where((t) => t.profileId.equals(profileId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: orderBy(t),
                mode: descending ? OrderingMode.desc : OrderingMode.asc,
              ),
            ]))
          .watch();

  /// Kaydı ekler, aynı kimlikte kayıt varsa günceller.
  ///
  /// `toColumns(false)`: drift ekleme yaparken null alanları "verilmemiş"
  /// sayar ve güncellemede eski değeri bırakırdı; o yüzden boşaltılan alanlar
  /// (ör. adı değişince düşen tanı kodu, silinen not) kayıtta kalıyordu.
  /// Burada null'lar açıkça yazılır; verilmemiş alanlar (`Value.absent()`)
  /// yine varsayılanını alır.
  Future<void> save<T extends Table, D>(
    TableInfo<T, D> table,
    Insertable<D> row,
  ) => db
      .into(table)
      .insertOnConflictUpdate(RawValuesInsertable<D>(row.toColumns(false)));

  Future<void> deleteRecord<T extends RecordColumns, D>(
    TableInfo<T, D> table,
    String id,
  ) async {
    await db.transaction(() async {
      await (db.delete(table)..where((t) => t.id.equals(id))).go();
      await (db.delete(
        db.fhirResources,
      )..where((t) => t.localId.equals(id))).go();
    });
  }

  /// Silmeyi geri alır (Geri al düğmesi).
  Future<void> restore<T extends Table, D>(
    TableInfo<T, D> table,
    Insertable<D> row,
  ) => db.into(table).insertOnConflictUpdate(row);

  // ---------------------------------------------------------------- İlaçlar

  Stream<List<Medication>> watchMedications(String profileId) =>
      _watchByProfile(db.medications, profileId, (t) => t.startDate);

  Future<List<Medication>> allMedications() => db.select(db.medications).get();

  Future<void> stopMedication(Medication m) => db
      .update(db.medications)
      .replace(m.copyWith(stoppedAt: Value(DateTime.now())));

  Stream<List<DoseEvent>> watchDoseEvents(String profileId, DateTime since) {
    final q =
        db.select(db.doseEvents).join([
          innerJoin(
            db.medications,
            db.medications.id.equalsExp(db.doseEvents.medicationId),
          ),
        ])..where(
          db.medications.profileId.equals(profileId) &
              db.doseEvents.scheduledAt.isBiggerOrEqualValue(since),
        );
    return q.watch().map(
      (rows) => rows.map((r) => r.readTable(db.doseEvents)).toList(),
    );
  }

  Future<void> markDose(
    String medicationId,
    DateTime at,
    String? status,
  ) async {
    if (status == null) {
      await (db.delete(db.doseEvents)..where(
            (t) =>
                t.medicationId.equals(medicationId) & t.scheduledAt.equals(at),
          ))
          .go();
      return;
    }
    await db
        .into(db.doseEvents)
        .insert(
          DoseEventsCompanion.insert(
            medicationId: medicationId,
            scheduledAt: at,
            status: status,
            markedAt: Value(DateTime.now()),
          ),
          onConflict: DoUpdate(
            (old) => DoseEventsCompanion(
              status: Value(status),
              markedAt: Value(DateTime.now()),
            ),
            target: [db.doseEvents.medicationId, db.doseEvents.scheduledAt],
          ),
        );
  }

  // --------------------------------------------------------- Diğer kayıtlar

  Stream<List<Immunization>> watchImmunizations(String profileId) =>
      _watchByProfile(db.immunizations, profileId, (t) => t.date);

  Stream<List<DueVaccine>> watchDueVaccines(String profileId) =>
      _watchByProfile(
        db.immunizationDue,
        profileId,
        (t) => t.dueDate,
        descending: false,
      );

  Future<List<DueVaccine>> allDueVaccines() =>
      (db.select(db.immunizationDue)..where((t) => t.done.equals(false))).get();

  Stream<List<Observation>> watchObservations(String profileId) =>
      _watchByProfile(db.observations, profileId, (t) => t.effectiveAt);

  Stream<List<Appointment>> watchAppointments(String profileId) =>
      _watchByProfile(
        db.appointments,
        profileId,
        (t) => t.start,
        descending: false,
      );

  Future<List<Appointment>> allAppointments() =>
      db.select(db.appointments).get();

  Stream<List<Allergy>> watchAllergies(String profileId) =>
      _watchByProfile(db.allergies, profileId, (t) => t.createdAt);

  Stream<List<Condition>> watchConditions(String profileId) =>
      _watchByProfile(db.conditions, profileId, (t) => t.createdAt);

  Stream<List<Encounter>> watchEncounters(String profileId) =>
      _watchByProfile(db.encounters, profileId, (t) => t.date);

  Stream<List<Diagnosis>> watchDiagnoses(String profileId) =>
      _watchByProfile(db.diagnoses, profileId, (t) => t.createdAt);

  // ------------------------------------------------------- Terminoloji

  /// Terminoloji paketi yenilendiğinde kodsuz kayıtları bir kez eşleştirir.
  /// Paket büyük olduğu için [load] yalnızca gerçekten gerekiyorsa çağrılır.
  /// Eşleşen kayıt sayısını döndürür.
  Future<int> applyTerminologyPackage(
    Future<Icd11Catalog> Function() load,
  ) async {
    if (await getSetting(SettingKeys.terminologyPackage) ==
        Icd11Asset.release) {
      return 0;
    }
    final matched = await matchCodelessRecords(await load());
    await setSetting(SettingKeys.terminologyPackage, Icd11Asset.release);
    return matched;
  }

  /// Kullanıcının kendi girdiği, kodu olmayan hastalık ve tanılara katalogdaki
  /// karşılığını yazar. Yalnızca ad katalogda birebir ve tek bir kategoriye
  /// eşleşirse kod yazılır; emin olunamayan kayıt olduğu gibi kalır (kullanıcı
  /// kaydı düzenlerken listeden seçebilir). Klinikten gelen kayıtlara
  /// dokunulmaz: onlar kurumun gönderdiği gibi durur.
  Future<int> matchCodelessRecords(Icd11Catalog catalog) async {
    var matched = 0;
    await db.transaction(() async {
      final conditions =
          await (db.select(db.conditions)..where(
                (t) => t.code.isNull() & t.source.equals(RecordSource.self),
              ))
              .get();
      for (final c in conditions) {
        final hit = catalog.byExactTerm(c.name);
        if (hit == null) continue;
        await (db.update(db.conditions)..where((t) => t.id.equals(c.id))).write(
          ConditionsCompanion(
            code: Value(hit.code),
            codeSystem: const Value(FhirSystems.icd11),
          ),
        );
        matched++;
      }
      final diagnoses =
          await (db.select(db.diagnoses)..where(
                (t) => t.code.isNull() & t.source.equals(RecordSource.self),
              ))
              .get();
      for (final d in diagnoses) {
        final hit = catalog.byExactTerm(d.name);
        if (hit == null) continue;
        await (db.update(db.diagnoses)..where((t) => t.id.equals(d.id))).write(
          DiagnosesCompanion(
            code: Value(hit.code),
            codeSystem: const Value(FhirSystems.icd11),
          ),
        );
        matched++;
      }
    });
    return matched;
  }

  Stream<List<ImportRecord>> watchImportHistory() => (db.select(
    db.importHistory,
  )..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).watch();

  /// Kayıtlar ekranındaki sayaçlar.
  Stream<Map<String, int>> watchCounts(String profileId) {
    final tables = <TableInfo>[
      db.immunizations,
      db.immunizationDue,
      db.allergies,
      db.conditions,
      db.observations,
      db.appointments,
      db.encounters,
    ];
    final columns = tables
        .map(
          (t) =>
              '(SELECT COUNT(*) FROM ${t.actualTableName} '
              'WHERE profile_id = ?1) AS ${t.actualTableName}',
        )
        .join(', ');
    return db
        .customSelect(
          'SELECT $columns',
          variables: [Variable.withString(profileId)],
          readsFrom: tables.toSet(),
        )
        .watchSingle()
        .map(
          (row) => {
            for (final t in tables)
              t.actualTableName: row.read<int>(t.actualTableName),
          },
        );
  }
}
