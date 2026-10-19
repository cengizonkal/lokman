import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:lokman/data/db/database.dart';
import 'package:lokman/data/repository.dart';

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

Repository memoryRepo() => Repository(memoryDb());

/// Depodaki örnek klinik paketini okur (`fhir/examples`).
String exampleBundle([String name = 'klinik-cikti-ayse.json']) {
  var dir = Directory.current;
  while (!File('${dir.path}/fhir/examples/$name').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('fhir/examples/$name bulunamadı');
    }
    dir = parent;
  }
  return File('${dir.path}/fhir/examples/$name').readAsStringSync();
}
