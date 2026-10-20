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
          db.execute(
            'INSERT INTO conditions (id, profile_id, source, created_at, name) '
            "VALUES ('c1', '$profileId', 'self', 0, 'Astım')",
          );
          db.userVersion = 1;
        },
      );
      await raw.ensureOpen(_NoMigration());
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
}

class _NoMigration extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
