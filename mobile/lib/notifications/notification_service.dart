import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/repository.dart';
import 'planner.dart';

/// Cihazda zamanlanan bildirimler. Testlerde ve Android dışı platformlarda
/// hiçbir şey yapmaz.
class NotificationService {
  NotificationService({this.enabled = true});

  final bool enabled;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  bool get _supported =>
      enabled && !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    if (!_supported || _ready) return;
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
    _ready = true;
  }

  Future<bool> areEnabled() async {
    if (!_supported) return false;
    await init();
    return await _android?.areNotificationsEnabled() ?? false;
  }

  /// Bildirim iznini (Android 13+) ve tam zamanlı alarm iznini ister.
  Future<bool> requestPermissions() async {
    if (!_supported) return false;
    await init();
    final granted = await _android?.requestNotificationsPermission() ?? false;
    if (granted && !(await _android?.canScheduleExactNotifications() ?? true)) {
      await _android?.requestExactAlarmsPermission();
    }
    return granted;
  }

  /// Tüm bildirimleri kayıtlardan yeniden kurar.
  Future<void> reschedule(Repository repo) async {
    if (!_supported) return;
    try {
      await init();
      final profiles = {for (final p in await repo.profiles()) p.id: p};
      final planned = planNotifications(
        now: DateTime.now(),
        profiles: profiles,
        medications: await repo.allMedications(),
        dueVaccines: await repo.allDueVaccines(),
        appointments: await repo.allAppointments(),
        prefs: NotificationPrefs(
          doses: await repo.getFlag(SettingKeys.notifyDoses),
          vaccines: await repo.getFlag(SettingKeys.notifyVaccines),
          appointments: await repo.getFlag(SettingKeys.notifyAppointments),
        ),
      );
      final exact = await _android?.canScheduleExactNotifications() ?? false;
      await _plugin.cancelAllPendingNotifications();
      for (final n in planned) {
        await _plugin.zonedSchedule(
          id: n.id,
          scheduledDate: tz.TZDateTime.from(n.at, tz.local),
          notificationDetails: NotificationDetails(
            android: _details(n.channel),
          ),
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          title: n.title,
          body: n.body,
          matchDateTimeComponents: n.daily ? DateTimeComponents.time : null,
        );
      }
    } catch (e, s) {
      debugPrint('Bildirimler kurulamadı: $e\n$s');
    }
  }

  AndroidNotificationDetails _details(NotificationChannel c) => switch (c) {
    NotificationChannel.dose => const AndroidNotificationDetails(
      'doses',
      'İlaç hatırlatmaları',
      channelDescription: 'İlaç saatleri geldiğinde hatırlatır',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
    NotificationChannel.vaccine => const AndroidNotificationDetails(
      'vaccines',
      'Aşı hatırlatmaları',
      channelDescription: 'Planlanan aşılardan önce hatırlatır',
      category: AndroidNotificationCategory.reminder,
    ),
    NotificationChannel.appointment => const AndroidNotificationDetails(
      'appointments',
      'Randevu hatırlatmaları',
      channelDescription: 'Randevulardan önce hatırlatır',
      category: AndroidNotificationCategory.event,
    ),
  };
}
