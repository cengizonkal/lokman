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
  int get schemaVersion => 3;

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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
