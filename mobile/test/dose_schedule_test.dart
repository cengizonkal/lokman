import 'package:flutter_test/flutter_test.dart';
import 'package:lokman/data/db/database.dart';
import 'package:lokman/domain/dose_schedule.dart';
import 'package:lokman/notifications/planner.dart';

Medication med({
  String times = '08:00,20:00',
  int? days,
  DateTime? start,
  DateTime? stopped,
}) => Medication(
  id: 'm1',
  profileId: 'p1',
  source: RecordSource.self,
  createdAt: DateTime(2026),
  name: 'Ramipril',
  dose: '1 tablet',
  timesOfDay: times,
  startDate: start ?? DateTime(2026, 10, 1),
  durationDays: days,
  stoppedAt: stopped,
);

void main() {
  test('saatler ayrıştırılır ve sıralanır', () {
    expect(DoseTime.parseList('20:00, 8:05,bozuk,20:00').map((t) => t.label), [
      '08:05',
      '20:00',
    ]);
  });

  test('sonlu süreli ilaç son gün dahil kullanılır', () {
    final m = med(days: 3);
    expect(lastDay(m), DateTime(2026, 10, 3));
    expect(dosesOn(m, DateTime(2026, 10, 3)), [
      DateTime(2026, 10, 3, 8),
      DateTime(2026, 10, 3, 20),
    ]);
    expect(dosesOn(m, DateTime(2026, 10, 4)), isEmpty);
    expect(dosesOn(m, DateTime(2026, 9, 30)), isEmpty);
    expect(isCurrent(m, DateTime(2026, 10, 4)), isFalse);
  });

  test('sürekli ilaç bırakılınca biter', () {
    expect(lastDay(med()), isNull);
    final stopped = med(stopped: DateTime(2026, 10, 10, 15));
    expect(isActiveOn(stopped, DateTime(2026, 10, 10)), isTrue);
    expect(isActiveOn(stopped, DateTime(2026, 10, 11)), isFalse);
  });

  test('uyum oranı geçmiş dozlardan hesaplanır', () {
    final m = med(start: DateTime(2026, 10, 1));
    final now = DateTime(2026, 10, 2, 12);
    // 1 Ekim 08:00, 20:00 ve 2 Ekim 08:00 → 3 doz; 2'si alındı.
    final events = [
      DoseEvent(
        id: 'a',
        medicationId: 'm1',
        scheduledAt: DateTime(2026, 10, 1, 8),
        status: 'taken',
        markedAt: now,
      ),
      DoseEvent(
        id: 'b',
        medicationId: 'm1',
        scheduledAt: DateTime(2026, 10, 2, 8),
        status: 'taken',
        markedAt: now,
      ),
      DoseEvent(
        id: 'c',
        medicationId: 'm1',
        scheduledAt: DateTime(2026, 10, 1, 20),
        status: 'skipped',
        markedAt: now,
      ),
    ];
    expect(adherence(m, events, now), closeTo(2 / 3, 0.001));
  });

  group('bildirim planı', () {
    final profile = Profile(
      id: 'p1',
      firstName: 'Ayşe',
      lastName: '',
      colorIndex: 0,
      createdAt: DateTime(2026),
    );
    final now = DateTime(2026, 10, 2, 12);

    test('sürekli ilaç her saat için günlük tekrar eder', () {
      final plan = planNotifications(
        now: now,
        profiles: {'p1': profile},
        medications: [med()],
        dueVaccines: const [],
        appointments: const [],
      );
      expect(plan.map((n) => (n.at, n.daily)), [
        (DateTime(2026, 10, 2, 20), true),
        (DateTime(2026, 10, 3, 8), true),
      ]);
      expect(plan.first.title, 'Ramipril');
    });

    test('sonlu ilaç yalnızca son güne kadar zamanlanır', () {
      final plan = planNotifications(
        now: now,
        profiles: {'p1': profile},
        medications: [med(days: 3)],
        dueVaccines: const [],
        appointments: const [],
      );
      expect(plan.map((n) => n.at), [
        DateTime(2026, 10, 2, 20),
        DateTime(2026, 10, 3, 8),
        DateTime(2026, 10, 3, 20),
      ]);
      expect(plan.every((n) => !n.daily), isTrue);
    });

    test('aşı ve randevu hatırlatmaları, kapalı tercihler', () {
      final due = DueVaccine(
        id: 'v1',
        profileId: 'p1',
        source: RecordSource.clinic,
        createdAt: now,
        vaccineName: 'Td',
        dueDate: DateTime(2026, 10, 10),
        done: false,
      );
      final appt = Appointment(
        id: 'a1',
        profileId: 'p1',
        source: RecordSource.self,
        createdAt: now,
        start: DateTime(2026, 10, 5, 14, 30),
        title: 'Kontrol',
      );
      final plan = planNotifications(
        now: now,
        profiles: {'p1': profile},
        medications: [med()],
        dueVaccines: [due],
        appointments: [appt],
        prefs: const NotificationPrefs(doses: false),
      );
      expect(plan.map((n) => n.key), [
        'appointment:a1:before',
        'appointment:a1:soon',
        'vaccine:v1:before',
        'vaccine:v1:day',
      ]);
      expect(plan.first.title, 'Yarın saat 14:30 randevunuz var');
    });

    test('kimlikler kararlı ve pozitif', () {
      expect(notificationId('dose:x'), notificationId('dose:x'));
      expect(notificationId('dose:x'), isNot(notificationId('dose:y')));
      expect(notificationId('dose:x'), greaterThanOrEqualTo(0));
    });
  });
}
