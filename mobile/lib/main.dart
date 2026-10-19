import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/db/database.dart';
import 'data/repository.dart';
import 'notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr');
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'DejaVu fonts',
    ], await rootBundle.loadString('assets/fonts/DejaVu-LICENSE.txt'));
  });

  final db = AppDatabase.open();
  final repo = Repository(db);
  final notifications = NotificationService();
  // İlk profil oluşturulduysa tanıtım tamamlanmış sayılır (izin adımı
  // yarıda kalsa da ikinci bir profil açtırmayız).
  final onboarded = (await repo.profiles()).isNotEmpty;

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: LokmanApp(onboarded: onboarded),
    ),
  );

  // Bildirimleri her açılışta güncel kayıtlardan yeniden kur (biten ilaçlar
  // düşer, sonlu süreli ilaçların ileriki dozları eklenir).
  if (onboarded) await notifications.reschedule(repo);
}
