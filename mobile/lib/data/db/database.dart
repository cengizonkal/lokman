import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    ProfileLinks,
    Encounters,
    Diagnoses,
    Medications,
    DoseEvents,
    Immunizations,
    ImmunizationDue,
    Observations,
    Appointments,
    Allergies,
    Conditions,
    FhirResources,
    ImportHistory,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'lokman'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Geçirilmiş hastalıklar: mevcut kayıtlar "devam ediyor" kalır.
        await m.addColumn(conditions, conditions.status);
        await m.addColumn(conditions, conditions.resolvedDate);
      }
      if (from < 3) {
        // Kullanıcının girdiği doktor ziyaretleri ve ziyaret–ilaç bağı.
        await m.addColumn(encounters, encounters.location);
        await m.addColumn(encounters, encounters.note);
        await m.addColumn(medications, medications.encounterId);
      }
      if (from < 4) {
        // Hastalık ve tanı kodlarının kod sistemi (ICD-11 terminoloji paketi).
        await m.addColumn(conditions, conditions.codeSystem);
        await m.addColumn(diagnoses, diagnoses.codeSystem);
        // Eski kayıtlarda sistem yazılmıyordu: kodun biçiminden çıkarırız.
        // v0.1'de kod yalnızca içe aktarımla gelebiliyordu ve ICD-10 biçimi
        // (`I10`, `J02.9`) dışındaki kodlar sistemsiz saklanıyordu.
        for (final table in ['conditions', 'diagnoses']) {
          await customStatement(
            "UPDATE $table SET code_system = 'http://hl7.org/fhir/sid/icd-10' "
            "WHERE code IS NOT NULL AND code GLOB '[A-Z][0-9][0-9]*'",
          );
          await customStatement(
            'UPDATE $table SET code_system = '
            "'http://id.who.int/icd/release/11/mms' "
            'WHERE code_system IS NULL AND code IS NOT NULL '
            "AND code GLOB '[0-9A-Z][A-Z][0-9A-Z][0-9A-Z]*'",
          );
        }
      }
      if (from < 5) {
        // Cinsiyet yalnızca kadın/erkek olarak saklanıyor: eski kayıtlardaki
        // diğer değerler boşaltılır.
        await customStatement(
          'UPDATE profiles SET gender = NULL '
          "WHERE gender IS NOT NULL AND gender NOT IN ('female', 'male')",
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
