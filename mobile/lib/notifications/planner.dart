import '../data/db/database.dart';
import '../domain/dose_schedule.dart';

enum NotificationChannel { dose, vaccine, appointment }

class PlannedNotification {
  const PlannedNotification({
    required this.key,
    required this.at,
    required this.title,
    required this.body,
    required this.channel,
    this.daily = false,
  });

  /// Kararlı anahtar; bildirim kimliği bundan türetilir.
  final String key;
  final DateTime at;
  final String title;
  final String body;
  final NotificationChannel channel;

  /// Her gün aynı saatte tekrarlar (sürekli kullanılan ilaçlar).
  final bool daily;

  int get id => notificationId(key);
}

/// 31 bitlik pozitif, kararlı kimlik (FNV-1a).
int notificationId(String key) {
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h & 0x7FFFFFFF;
}

class NotificationPrefs {
  const NotificationPrefs({
    this.doses = true,
    this.vaccines = true,
    this.appointments = true,
  });

  final bool doses;
  final bool vaccines;
  final bool appointments;
}

/// Android'in zamanlanmış alarm sınırının altında kalmak için üst sınır.
const maxPlanned = 400;

/// Sonlu süreli ilaçlar için kaç gün ilerisi zamanlanır. Uygulama her
/// açıldığında plan yenilenir.
const finiteHorizonDays = 14;

/// Veritabanındaki kayıtlardan cihazda kurulacak bildirimleri hesaplar.
List<PlannedNotification> planNotifications({
  required DateTime now,
  required Map<String, Profile> profiles,
  required List<Medication> medications,
  required List<DueVaccine> dueVaccines,
  required List<Appointment> appointments,
  NotificationPrefs prefs = const NotificationPrefs(),
}) {
  final showName = profiles.length > 1;
  String who(String profileId) {
    final p = profiles[profileId];
    return showName && p != null ? '${p.firstName}: ' : '';
  }

  final result = <PlannedNotification>[];

  if (prefs.doses) {
    for (final m in medications) {
      if (!profiles.containsKey(m.profileId) || !isCurrent(m, now)) continue;
      final times = DoseTime.parseList(m.timesOfDay);
      final body = m.dose.isEmpty ? 'İlaç saatiniz geldi' : m.dose;
      final continuous = lastDay(m) == null;
      if (continuous) {
        for (final t in times) {
          var at = t.on(now);
          if (at.isBefore(m.startDate)) at = t.on(m.startDate);
          while (!at.isAfter(now)) {
            at = DateTime(at.year, at.month, at.day + 1, t.hour, t.minute);
          }
          result.add(
            PlannedNotification(
              key: 'dose:${m.id}:${t.label}',
              at: at,
              title: '${who(m.profileId)}${m.name}',
              body: '$body · ${t.label}',
              channel: NotificationChannel.dose,
              daily: true,
            ),
          );
        }
      } else {
        final until = now.add(const Duration(days: finiteHorizonDays));
        for (final at in dosesBetween(m, now, until)) {
          if (!at.isAfter(now)) continue;
          result.add(
            PlannedNotification(
              key: 'dose:${m.id}:${at.toIso8601String()}',
              at: at,
              title: '${who(m.profileId)}${m.name}',
              body: '$body · ${DoseTime(at.hour, at.minute).label}',
              channel: NotificationChannel.dose,
            ),
          );
        }
      }
    }
  }

  if (prefs.vaccines) {
    for (final v in dueVaccines) {
      if (v.done || !profiles.containsKey(v.profileId)) continue;
      final day = dateOnly(v.dueDate);
      final dayBefore = DateTime(day.year, day.month, day.day - 1, 19);
      final onDay = DateTime(day.year, day.month, day.day, 9);
      if (dayBefore.isAfter(now)) {
        result.add(
          PlannedNotification(
            key: 'vaccine:${v.id}:before',
            at: dayBefore,
            title: '${who(v.profileId)}Yarın aşı günü',
            body: v.vaccineName,
            channel: NotificationChannel.vaccine,
          ),
        );
      }
      if (onDay.isAfter(now)) {
        result.add(
          PlannedNotification(
            key: 'vaccine:${v.id}:day',
            at: onDay,
            title: '${who(v.profileId)}Bugün aşı günü',
            body: v.vaccineName,
            channel: NotificationChannel.vaccine,
          ),
        );
      }
    }
  }

  if (prefs.appointments) {
    for (final a in appointments) {
      if (!profiles.containsKey(a.profileId) || !a.start.isAfter(now)) continue;
      final time = DoseTime(a.start.hour, a.start.minute).label;
      final what = [
        if (a.title.isNotEmpty) a.title,
        a.practitioner,
        a.location,
      ].nonNulls.join(' · ');
      final dayBefore = DateTime(
        a.start.year,
        a.start.month,
        a.start.day - 1,
        19,
      );
      final hoursBefore = a.start.subtract(const Duration(hours: 2));
      if (dayBefore.isAfter(now)) {
        result.add(
          PlannedNotification(
            key: 'appointment:${a.id}:before',
            at: dayBefore,
            title: '${who(a.profileId)}Yarın saat $time randevunuz var',
            body: what,
            channel: NotificationChannel.appointment,
          ),
        );
      }
      if (hoursBefore.isAfter(now)) {
        result.add(
          PlannedNotification(
            key: 'appointment:${a.id}:soon',
            at: hoursBefore,
            title: '${who(a.profileId)}Saat $time randevunuz var',
            body: what,
            channel: NotificationChannel.appointment,
          ),
        );
      }
    }
  }

  result.sort((a, b) => a.at.compareTo(b.at));
  return result.length > maxPlanned ? result.sublist(0, maxPlanned) : result;
}
