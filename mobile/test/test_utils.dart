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
String exampleBundle([String name = 'klinik-cikti-ayse.json']) =>
    _repoFile('fhir/examples/$name');

/// Terminoloji paketi varlığını okur (`mobile/assets/terminology`).
String terminologyAsset(String name) =>
    _repoFile('mobile/assets/terminology/$name');

/// Depo kökünden verilen yolu, çalışma dizininden yukarı çıkarak bulur.
String _repoFile(String relative) {
  var dir = Directory.current;
  while (!File('${dir.path}/$relative').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('$relative bulunamadı');
    }
    dir = parent;
  }
  return File('${dir.path}/$relative').readAsStringSync();
}
