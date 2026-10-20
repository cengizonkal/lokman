import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lokman/app/app.dart';
import 'package:lokman/app/providers.dart';
import 'package:lokman/data/db/database.dart';
import 'package:lokman/data/repository.dart';
import 'package:lokman/fhir/importer.dart';
import 'package:lokman/notifications/notification_service.dart';

import 'test_utils.dart';

Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  bool onboarded = false,
}) async {
  // Yaygın bir Android telefon ekranı.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(
          NotificationService(enabled: false),
        ),
      ],
      child: LokmanApp(onboarded: onboarded),
    ),
  );
  await tester.pumpAndSettle();
}

/// Drift akışlarının zamanlayıcıları bitsin diye ağacı kaldırıp
/// veritabanını kapatır.
Future<void> tearDownApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

void main() {
  setUpAll(() => initializeDateFormatting('tr'));

  testWidgets('ilk açılış: profil oluşturulur ve Bugün ekranı açılır', (
    tester,
  ) async {
    final db = memoryDb();
    await pumpApp(tester, db);

    expect(find.text('Lokman’a hoş geldiniz'), findsOneWidget);
    await tester.tap(find.text('Başlayalım'));
    await tester.pumpAndSettle();

    final next = find.widgetWithText(FilledButton, 'Devam');
    expect(tester.widget<FilledButton>(next).onPressed, isNull);
    await tester.enterText(find.widgetWithText(TextField, 'Ad *'), 'Ayşe');
    await tester.pump();
    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(find.text('Hatırlatmalara izin verin'), findsOneWidget);
    await tester.tap(find.text('Şimdi değil'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ayşe'), findsWidgets);
    expect(find.text('Bugünün ilaçları'), findsOneWidget);
    final done = await tester.runAsync(
      () => Repository(db).getFlag(SettingKeys.onboardingDone),
    );
    expect(done, isTrue);
    await tearDownApp(tester, db);
  });

  testWidgets('ilaç eklenir, Bugün ekranında Aldım işaretlenir', (
    tester,
  ) async {
    final db = memoryDb();
    final repo = Repository(db);
    await tester.runAsync(
      () => repo.addProfile(ProfilesCompanion.insert(firstName: 'Ali')),
    );
    await pumpApp(tester, db, onboarded: true);

    await tester.tap(find.text('İlaç ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Parol');
    await tester.pump();
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 tablet').first);
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    // Varsayılan sabah 08:00 seçili; gün içinde her saat görünsün diye
    // tüm hazır saatleri seç.
    for (final label in ['Öğle', 'Akşam', 'Gece']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sürekli kullanıyorum'));
    await tester.pump();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final meds = (await tester.runAsync(db.select(db.medications).get))!;
    expect(meds.single.name, 'Parol');
    expect(meds.single.dose, '1 tablet');
    expect(meds.single.timesOfDay, '08:00,13:00,20:00,23:00');
    expect(meds.single.durationDays, isNull);

    expect(find.text('0 / 4 alındı'), findsOneWidget);
    await tester.tap(find.text('Aldım').first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 4 alındı'), findsOneWidget);
    final events = (await tester.runAsync(db.select(db.doseEvents).get))!;
    expect(events.single.status, 'taken');

    await tester.tap(find.text('Geri al').first);
    await tester.pumpAndSettle();
    expect(find.text('0 / 4 alındı'), findsOneWidget);
    await tearDownApp(tester, db);
  });

  testWidgets('sekmeler ve boş durumlar açılır', (tester) async {
    final db = memoryDb();
    await tester.runAsync(
      () =>
          Repository(db).addProfile(ProfilesCompanion.insert(firstName: 'Ali')),
    );
    await pumpApp(tester, db, onboarded: true);

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alerjiler'));
    await tester.pumpAndSettle();
    expect(find.text('Bilinen alerji yok'), findsOneWidget);
    await tester.tap(find.text('Alerji ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Penisilin');
    await tester.pump();
    await tester.tap(find.text('Ağır'));
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Penisilin'), findsOneWidget);
    expect(find.text('Kendi girdiğim'), findsOneWidget);

    await tester.tap(find.text('Paylaş'));
    await tester.pumpAndSettle();
    expect(find.text('QR kod okut'), findsOneWidget);
    await tearDownApp(tester, db);
  });

  testWidgets('geçirilmiş hastalık eklenir ve ayrı grupta görünür', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      final repo = Repository(db);
      final id = await repo.addProfile(
        ProfilesCompanion.insert(firstName: 'Ali'),
      );
      await repo.save(
        db.conditions,
        ConditionsCompanion.insert(profileId: id, name: 'Astım'),
      );
    });
    await pumpApp(tester, db, onboarded: true);

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hastalıklar'));
    await tester.pumpAndSettle();
    expect(find.text('Devam eden'), findsOneWidget);
    expect(find.text('Geçirilmiş'), findsNothing);

    await tester.tap(find.text('Hastalık ekle'));
    await tester.pumpAndSettle();
    expect(find.text('Ne zamandan beri? (isteğe bağlı)'), findsOneWidget);
    await tester.tap(find.text('Geçti'));
    await tester.pumpAndSettle();
    expect(find.text('Ne zaman başladı? (isteğe bağlı)'), findsOneWidget);
    expect(find.text('Ne zaman geçti? (isteğe bağlı)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Su çiçeği');
    await tester.pump();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Geçirilmiş'), findsOneWidget);
    expect(find.text('Su çiçeği'), findsOneWidget);
    final rows = (await tester.runAsync(db.select(db.conditions).get))!;
    final chickenpox = rows.firstWhere((c) => c.name == 'Su çiçeği');
    expect(chickenpox.status, ConditionStatus.resolved);
    expect(chickenpox.source, RecordSource.self);

    // Durum düzenlenince kayıt "Devam eden" grubuna geçer.
    await tester.tap(find.text('Su çiçeği'));
    await tester.pumpAndSettle();
    expect(find.text('Geçti'), findsOneWidget);
    await tester.tap(find.text('Düzenle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Devam ediyor'));
    await tester.pumpAndSettle();
    expect(find.text('Ne zaman geçti? (isteğe bağlı)'), findsNothing);
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Geçirilmiş'), findsNothing);
    final edited = (await tester.runAsync(
      (db.select(
        db.conditions,
      )..where((t) => t.name.equals('Su çiçeği'))).getSingle,
    ))!;
    expect(edited.status, ConditionStatus.active);
    await tearDownApp(tester, db);
  });

  testWidgets(
    'kullanıcı doktor ziyareti ekler, ziyarette yazılan ilaç bağlanır',
    (tester) async {
      final db = memoryDb();
      await tester.runAsync(
        () =>
            Repository(db)
                .addProfile(ProfilesCompanion.insert(firstName: 'Ali')),
      );
      await pumpApp(tester, db, onboarded: true);

      await tester.tap(find.text('Kayıtlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Muayeneler'));
      await tester.pumpAndSettle();
      expect(find.text('Muayene kaydı yok'), findsOneWidget);
      await tester.tap(find.text('Ziyaret ekle'));
      await tester.pumpAndSettle();

      expect(find.text('Doktor ziyareti ekle'), findsOneWidget);
      expect(find.text('Kontrol randevusu (varsa)'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Hastane / klinik'),
        'Şehir Hastanesi',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Neden gittiniz?'),
        'Boğaz ağrısı',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Doktorun söylediği tanı'),
        'Bademcik iltihabı',
      );
      await tester.pump();
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      // Kaydedince ilaç sorulur; ilaç sihirbazı bu ziyarete bağlı açılır.
      expect(find.text('Bu ziyarette ilaç yazıldı mı?'), findsOneWidget);
      await tester.tap(find.text('İlaç ekle'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Amoksisilin');
      await tester.pump();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 tablet').first);
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      final encounter = (await tester.runAsync(
        db.select(db.encounters).getSingle,
      ))!;
      expect(encounter.source, RecordSource.self);
      expect(encounter.location, 'Şehir Hastanesi');
      expect(encounter.complaint, 'Boğaz ağrısı');
      final dx = (await tester.runAsync(db.select(db.diagnoses).getSingle))!;
      expect(dx.name, 'Bademcik iltihabı');
      expect(dx.encounterId, encounter.id);
      final med = (await tester.runAsync(db.select(db.medications).getSingle))!;
      expect(med.name, 'Amoksisilin');
      expect(med.encounterId, encounter.id);

      // "İlaç kaydedildi" bildirimi kapansın (alt sayfadaki düğmeleri örter).
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.textContaining('Şehir Hastanesi'), findsOneWidget);
      await tester.tap(find.textContaining('Şehir Hastanesi'));
      await tester.pumpAndSettle();
      expect(find.text('Yazılan ilaçlar'), findsOneWidget);
      expect(find.text('Amoksisilin'), findsOneWidget);

      // Düzenleme: tanı silinince bağlı tanı kaydı da silinir.
      await tester.ensureVisible(find.text('Düzenle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Düzenle'));
      await tester.pumpAndSettle();
      expect(find.text('Kontrol randevusu (varsa)'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Doktorun söylediği tanı'),
        '',
      );
      await tester.pump();
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(await tester.runAsync(db.select(db.diagnoses).get), isEmpty);
      await tearDownApp(tester, db);
    },
  );

  testWidgets('klinikten aktarılan kayıtlar tüm ekranlarda görünür', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      final repo = Repository(db);
      final importer = Importer(repo);
      final bundle = await importer.parse(exampleBundle());
      final id = await importer.createProfileFrom(bundle.patient);
      await importer.apply(bundle, id);
      // Grafik için ikinci bir tansiyon ölçümü.
      await repo.save(
        db.observations,
        ObservationsCompanion.insert(
          profileId: id,
          typeKey: 'bp',
          name: 'Tansiyon',
          value: const Value(128),
          value2: const Value(82),
          unit: const Value('mmHg'),
          effectiveAt: DateTime.now(),
        ),
      );
    });
    await pumpApp(tester, db, onboarded: true);
    expect(find.textContaining('Ayşe'), findsWidgets);

    await tester.tap(find.text('İlaçlar'));
    await tester.pumpAndSettle();
    expect(find.text('Ramipril 5 mg tablet'), findsOneWidget);
    expect(find.text('Örnek Aile Kliniği'), findsWidgets);

    await tester.tap(find.text('Kayıtlar'));
    await tester.pumpAndSettle();
    for (final (tile, expected) in [
      ('Aşılar', 'Tetanoz-difteri (Td)'),
      ('Alerjiler', 'Penisilin grubu'),
      ('Hastalıklar', 'Esansiyel hipertansiyon'),
      ('Ölçümler', '128/82 mmHg'),
      ('Randevular', 'Tansiyon kontrolü'),
      (
        'Muayeneler',
        'Dr. Mehmet Yılmaz · Boğaz ağrısı ve baş ağrısı · Akut farenjit',
      ),
    ]) {
      await tester.tap(find.text(tile));
      await tester.pumpAndSettle();
      expect(find.text(expected), findsWidgets, reason: tile);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Paylaş'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Örnek Aile Kliniği'), 200);
    expect(find.text('Örnek Aile Kliniği'), findsOneWidget);
    await tearDownApp(tester, db);
  });
}
