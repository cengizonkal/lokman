import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repository.dart';
import '../fhir/importer.dart';
import '../notifications/notification_service.dart';

/// `main()` içinde gerçek veritabanıyla, testlerde bellek içi veritabanıyla
/// değiştirilir.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider override edilmeli'),
);

final repositoryProvider = Provider<Repository>(
  (ref) => Repository(ref.watch(databaseProvider)),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final importerProvider = Provider<Importer>(
  (ref) => Importer(ref.watch(repositoryProvider)),
);

final profilesProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(repositoryProvider).watchProfiles(),
);

final _currentProfileSetting = StreamProvider<String?>(
  (ref) =>
      ref.watch(repositoryProvider).watchSetting(SettingKeys.currentProfile),
);

/// Seçili profil. Ayar boşsa ya da profil silindiyse ilk profil.
final currentProfileProvider = Provider<Profile?>((ref) {
  final profiles = ref.watch(profilesProvider).value ?? const [];
  if (profiles.isEmpty) return null;
  final id = ref.watch(_currentProfileSetting).value;
  return profiles.where((p) => p.id == id).firstOrNull ?? profiles.first;
});

Future<void> selectProfile(WidgetRef ref, String id) =>
    ref.read(repositoryProvider).setSetting(SettingKeys.currentProfile, id);

/// Kayıtlar değiştiğinde bildirimleri yeniden kurar.
Future<void> rescheduleNotifications(WidgetRef ref) => ref
    .read(notificationServiceProvider)
    .reschedule(ref.read(repositoryProvider));

final medicationsProvider = StreamProvider.family<List<Medication>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchMedications(profileId),
);

final doseEventsProvider = StreamProvider.family<List<DoseEvent>, String>((
  ref,
  profileId,
) {
  final since = DateTime.now().subtract(const Duration(days: 30));
  return ref
      .watch(repositoryProvider)
      .watchDoseEvents(profileId, DateTime(since.year, since.month, since.day));
});

final immunizationsProvider = StreamProvider.family<List<Immunization>, String>(
  (ref, profileId) =>
      ref.watch(repositoryProvider).watchImmunizations(profileId),
);

final dueVaccinesProvider = StreamProvider.family<List<DueVaccine>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchDueVaccines(profileId),
);

final observationsProvider = StreamProvider.family<List<Observation>, String>(
  (ref, profileId) =>
      ref.watch(repositoryProvider).watchObservations(profileId),
);

final appointmentsProvider = StreamProvider.family<List<Appointment>, String>(
  (ref, profileId) =>
      ref.watch(repositoryProvider).watchAppointments(profileId),
);

final allergiesProvider = StreamProvider.family<List<Allergy>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchAllergies(profileId),
);

final conditionsProvider = StreamProvider.family<List<Condition>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchConditions(profileId),
);

final encountersProvider = StreamProvider.family<List<Encounter>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchEncounters(profileId),
);

final diagnosesProvider = StreamProvider.family<List<Diagnosis>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchDiagnoses(profileId),
);

final recordCountsProvider = StreamProvider.family<Map<String, int>, String>(
  (ref, profileId) => ref.watch(repositoryProvider).watchCounts(profileId),
);

final importHistoryProvider = StreamProvider<List<ImportRecord>>(
  (ref) => ref.watch(repositoryProvider).watchImportHistory(),
);

final lastFullExportProvider = StreamProvider<DateTime?>(
  (ref) => ref
      .watch(repositoryProvider)
      .watchSetting(SettingKeys.lastFullExport)
      .map((v) => v == null ? null : DateTime.tryParse(v)),
);

/// Her dakika yenilenen "şimdi" (Bugün ekranı saat geçince güncellensin).
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});
