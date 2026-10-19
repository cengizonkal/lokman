import '../data/db/database.dart';

/// Günün saati (dakika hassasiyetinde).
class DoseTime implements Comparable<DoseTime> {
  const DoseTime(this.hour, this.minute);

  final int hour;
  final int minute;

  static DoseTime? tryParse(String s) {
    final parts = s.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return DoseTime(h, m);
  }

  static List<DoseTime> parseList(String csv) {
    final list = csv
        .split(',')
        .map(tryParse)
        .whereType<DoseTime>()
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  static String formatList(Iterable<DoseTime> times) {
    final list = times.toSet().toList()..sort();
    return list.map((t) => t.label).join(',');
  }

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(DoseTime other) =>
      (hour * 60 + minute).compareTo(other.hour * 60 + other.minute);

  @override
  bool operator ==(Object other) =>
      other is DoseTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => hour * 60 + minute;

  @override
  String toString() => label;
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// İlacın son kullanım günü (dahil). Sürekli kullanımda `null`.
DateTime? lastDay(Medication m) {
  final stopped = m.stoppedAt == null ? null : dateOnly(m.stoppedAt!);
  final byDuration = m.durationDays == null
      ? null
      : dateOnly(m.startDate).add(Duration(days: m.durationDays! - 1));
  if (stopped == null) return byDuration;
  if (byDuration == null) return stopped;
  return stopped.isBefore(byDuration) ? stopped : byDuration;
}

/// İlaç verilen günde kullanılıyor mu?
bool isActiveOn(Medication m, DateTime day) {
  final d = dateOnly(day);
  if (d.isBefore(dateOnly(m.startDate))) return false;
  final last = lastDay(m);
  return last == null || !d.isAfter(last);
}

/// İlaç bugün ya da ileride kullanılacak mı?
bool isCurrent(Medication m, DateTime now) {
  final last = lastDay(m);
  return last == null || !dateOnly(now).isAfter(last);
}

/// Verilen gündeki planlı doz zamanları.
List<DateTime> dosesOn(Medication m, DateTime day) {
  if (!isActiveOn(m, day)) return const [];
  return DoseTime.parseList(m.timesOfDay).map((t) => t.on(day)).toList();
}

/// [from] ile [to] arasındaki (ikisi dahil) planlı doz zamanları.
List<DateTime> dosesBetween(Medication m, DateTime from, DateTime to) {
  final result = <DateTime>[];
  for (
    var d = dateOnly(from);
    !d.isAfter(dateOnly(to));
    d = DateTime(d.year, d.month, d.day + 1)
  ) {
    for (final t in dosesOn(m, d)) {
      if (!t.isBefore(from) && !t.isAfter(to)) result.add(t);
    }
  }
  return result;
}

/// Uyum oranı: geçmiş dozlardan "aldım" işaretlenenlerin oranı (0–1).
/// Henüz geçmiş doz yoksa `null`.
double? adherence(Medication m, List<DoseEvent> events, DateTime now) {
  final windowStart = dateOnly(now).subtract(const Duration(days: 29));
  final start = m.startDate.isAfter(windowStart) ? m.startDate : windowStart;
  final due = dosesBetween(m, start, now);
  if (due.isEmpty) return null;
  final taken = events
      .where((e) => e.status == 'taken' && due.contains(e.scheduledAt))
      .length;
  return taken / due.length;
}
