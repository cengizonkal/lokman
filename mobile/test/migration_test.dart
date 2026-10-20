import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokman/data/db/database.dart';

void main() {
  test(
    'sürüm 1 veritabanı geçirilmiş hastalık alanlarıyla yükseltilir',
    () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final dir = await Directory.systemTemp.createTemp('lokman_migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/lokman.sqlite');

      // Sürüm 1 şeması: hastalık tablosunda durum ve bitiş tarihi yok.
      final v1 = AppDatabase(NativeDatabase(file));
      final profileId = newId();
      await v1
          .into(v1.profiles)
          .insert(
            ProfilesCompanion.insert(id: Value(profileId), firstName: 'Ali'),
          );
      await v1.close();
      final raw = NativeDatabase(
        file,
        setup: (db) {
          db.execute('DELETE FROM conditions');
          db.execute('ALTER TABLE conditions DROP COLUMN status');
          db.execute('ALTER TABLE conditions DROP COLUMN resolved_date');
          // Sürüm 3'te eklenen kolonlar da sürüm 1'de yoktu.
          db.execute('ALTER TABLE encounters DROP COLUMN location');
          db.execute('ALTER TABLE encounters DROP COLUMN note');
          db.execute('ALTER TABLE medications DROP COLUMN encounter_id');
          db.execute(
            'INSERT INTO conditions (id, profile_id, source, created_at, name) '
            "VALUES ('c1', '$profileId', 'self', 0, 'Astım')",
          );
          db.userVersion = 1;
        },
      );
      await raw.ensureOpen(_NoMigration(1));
      await raw.close();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      final condition = await db.select(db.conditions).getSingle();
      expect(condition.name, 'Astım');
      expect(condition.status, ConditionStatus.active);
      expect(condition.resolvedDate, isNull);

      await db
          .into(db.conditions)
          .insert(
            ConditionsCompanion.insert(
              profileId: profileId,
              name: 'Zatürre',
              status: const Value(ConditionStatus.resolved),
              resolvedDate: Value(DateTime(2020)),
            ),
          );
      expect(await db.select(db.conditions).get(), hasLength(2));
    },
  );

  test('sürüm 2 veritabanı doktor ziyareti alanlarıyla yükseltilir', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('lokman_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/lokman.sqlite');

    final v2 = AppDatabase(NativeDatabase(file));
    final profileId = newId();
    await v2
        .into(v2.profiles)
        .insert(
          ProfilesCompanion.insert(id: Value(profileId), firstName: 'Ali'),
        );
    await v2.close();
    final raw = NativeDatabase(
      file,
      setup: (db) {
        db.execute('ALTER TABLE encounters DROP COLUMN location');
        db.execute('ALTER TABLE encounters DROP COLUMN note');
        db.execute('ALTER TABLE medications DROP COLUMN encounter_id');
        db.execute(
          'INSERT INTO encounters (id, profile_id, source, created_at, date) '
          "VALUES ('e1', '$profileId', 'clinic', 0, 0)",
        );
        db.execute(
          'INSERT INTO medications '
          '(id, profile_id, source, created_at, name, start_date) '
          "VALUES ('m1', '$profileId', 'self', 0, 'Parol', 0)",
        );
        db.userVersion = 2;
      },
    );
    await raw.ensureOpen(_NoMigration(2));
    await raw.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final encounter = await db.select(db.encounters).getSingle();
    expect(encounter.id, 'e1');
    expect(encounter.location, isNull);
    expect(encounter.note, isNull);
    final medication = await db.select(db.medications).getSingle();
    expect(medication.encounterId, isNull);
  });
}

class _NoMigration extends QueryExecutorUser {
  _NoMigration(this.schemaVersion);

  @override
  final int schemaVersion;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
