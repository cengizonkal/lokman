import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../data/repository.dart';
import 'bundle_reader.dart';
import 'fhir_common.dart';

class ProfileMatch {
  const ProfileMatch({this.exact, this.suggestion});

  /// Kimliği bilinen profil: soru sormadan buna aktarılır.
  final Profile? exact;

  /// Ad ve doğum tarihine göre en olası profil.
  final Profile? suggestion;
}

class ImportResult {
  const ImportResult({
    required this.profileId,
    required this.added,
    required this.updated,
    required this.counts,
  });

  final String profileId;
  final int added;
  final int updated;
  final Map<RecordKind, int> counts;
}

/// Türkçe karakterleri sadeleştirilmiş, küçük harfli ad (eşleştirme için).
String normalizeName(String s) {
  const map = {
    'ç': 'c',
    'Ç': 'c',
    'ğ': 'g',
    'Ğ': 'g',
    'ı': 'i',
    'I': 'i',
    'İ': 'i',
    'ö': 'o',
    'Ö': 'o',
    'ş': 's',
    'Ş': 's',
    'ü': 'u',
    'Ü': 'u',
  };
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(map[ch] ?? ch.toLowerCase());
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

class Importer {
  Importer(this.repo);

  final Repository repo;

  AppDatabase get db => repo.db;

  Future<ParsedBundle> parse(String text) async =>
      readBundle(text, db: db, ownAppId: await repo.appId());

  Future<ProfileMatch> match(ParsedPatient? patient) async {
    final profiles = await repo.profiles();
    if (patient == null) {
      return ProfileMatch(
        suggestion: profiles.length == 1 ? profiles.first : null,
      );
    }
    final appId = await repo.appId();
    final ownSystem = LokmanFhir.appProfileSystem(appId);
    for (final i in patient.identifiers) {
      if (i.system == ownSystem) {
        final p = await repo.profile(i.value);
        if (p != null) return ProfileMatch(exact: p);
      }
      final link =
          await (db.select(db.profileLinks)..where(
                (t) => t.system.equals(i.system) & t.value.equals(i.value),
              ))
              .getSingleOrNull();
      if (link != null) {
        final p = await repo.profile(link.profileId);
        if (p != null) return ProfileMatch(exact: p);
      }
    }

    Profile? best;
    var bestScore = 0;
    final first = normalizeName(patient.firstName);
    final full = normalizeName(patient.fullName);
    for (final p in profiles) {
      var score = 0;
      final pFull = normalizeName('${p.firstName} ${p.lastName}');
      if (pFull == full) {
        score += 3;
      } else if (normalizeName(p.firstName) == first) {
        score += 1;
      }
      final b1 = p.birthDate;
      final b2 = patient.birthDate;
      if (b1 != null && b2 != null) {
        if (b1.year == b2.year && b1.month == b2.month && b1.day == b2.day) {
          score += 3;
        } else {
          score -= 3;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    return ProfileMatch(suggestion: best);
  }

  /// Paketteki hastadan yeni profil oluşturur.
  Future<String> createProfileFrom(ParsedPatient? patient) => repo.addProfile(
    ProfilesCompanion.insert(
      firstName: patient?.firstName ?? 'Yeni profil',
      lastName: Value(patient?.lastName ?? ''),
      birthDate: Value(patient?.birthDate),
      gender: Value(patient?.gender),
    ),
  );

  /// Kayıtları profile yazar. Aynı kayıt daha önce aktarıldıysa güncellenir.
  Future<ImportResult> apply(ParsedBundle bundle, String profileId) async {
    final appId = await repo.appId();
    final ownSystem = LokmanFhir.appProfileSystem(appId);
    var added = 0;
    var updated = 0;

    await db.transaction(() async {
      // 1. Her kaydın yerel kimliğini belirle.
      final ids = <ParsedRecord, String>{};
      final existing = <ParsedRecord, bool>{};
      for (final r in bundle.records) {
        final table = r.table;
        final idCol = table.columnsByName['id']! as GeneratedColumn<String>;
        final refCol =
            table.columnsByName['origin_ref']! as GeneratedColumn<String>;
        String? found;
        if (r.originRef != null) {
          final row =
              await (db.selectOnly(table)
                    ..addColumns([idCol])
                    ..where(refCol.equals(r.originRef!)))
                  .getSingleOrNull();
          found = row?.read(idCol);
        }
        var id = found;
        if (id == null) {
          final candidate = isUuid(r.resourceId) ? r.resourceId : newId();
          final clash =
              await (db.selectOnly(table)
                    ..addColumns([refCol])
                    ..where(idCol.equals(candidate)))
                  .getSingleOrNull();
          // Kendi kaydımız (originRef yok) aynı kimlikle güncellenir; başka
          // kaynaktan gelen çakışan kimlik için yeni kimlik üretilir.
          if (clash != null && r.originRef != null) {
            id = newId();
          } else {
            id = candidate;
            found = clash != null ? candidate : null;
          }
        }
        ids[r] = id;
        existing[r] = found != null;
      }

      final byKey = <String, String>{};
      for (final r in bundle.records) {
        for (final k in r.keys) {
          byKey[k] = ids[r]!;
        }
      }
      String? resolve(String? ref) => ref == null ? null : byKey[ref];

      // 2. Satırları yaz.
      for (final r in bundle.records) {
        final id = ids[r]!;
        final row = r.build(
          RecordContext(
            id: id,
            profileId: profileId,
            originRef: r.originRef,
            resolve: resolve,
          ),
        );
        await db.into(r.table).insertOnConflictUpdate(row);
        await db
            .into(db.fhirResources)
            .insertOnConflictUpdate(
              FhirResourcesCompanion.insert(
                resourceType: r.resourceType,
                localId: id,
                profileId: profileId,
                json: jsonEncode(r.raw),
                lastUpdated: Value(DateTime.now()),
              ),
            );
        if (existing[r]!) {
          updated++;
        } else {
          added++;
        }
      }

      // 3. Hasta kimliklerini profile bağla (bir sonraki aktarımda soru
      // sorulmasın).
      for (final i in bundle.patient?.identifiers ?? const []) {
        if (i.system == ownSystem) continue;
        await db
            .into(db.profileLinks)
            .insert(
              ProfileLinksCompanion.insert(
                profileId: profileId,
                system: i.system,
                value: i.value,
                organizationName: Value(bundle.organizationName),
              ),
              onConflict: DoUpdate(
                (old) => ProfileLinksCompanion(
                  profileId: Value(profileId),
                  organizationName: Value(bundle.organizationName),
                ),
                target: [db.profileLinks.system, db.profileLinks.value],
              ),
            );
      }

      await db
          .into(db.importHistory)
          .insert(
            ImportHistoryCompanion.insert(
              profileId: profileId,
              originName: Value(bundle.organizationName),
              summary: jsonEncode({
                for (final e in bundle.counts.entries) e.key.name: e.value,
              }),
            ),
          );
    });

    return ImportResult(
      profileId: profileId,
      added: added,
      updated: updated,
      counts: bundle.counts,
    );
  }
}
