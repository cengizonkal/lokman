import 'package:intl/intl.dart';

import '../domain/dose_schedule.dart';
import '../fhir/fhir_common.dart' show codeSystemLabel, fmtNumber;
import '../data/db/database.dart';

final _day = DateFormat('d MMMM y', 'tr');
final _dayShort = DateFormat('d MMM', 'tr');
final _weekday = DateFormat('d MMMM EEEE', 'tr');
final _time = DateFormat('HH:mm', 'tr');

String formatDay(DateTime d) => _day.format(d);

String formatDayShort(DateTime d) => _dayShort.format(d);

String formatDayTime(DateTime d) => '${_day.format(d)}, ${_time.format(d)}';

String formatTime(DateTime d) => _time.format(d);

String formatWeekday(DateTime d) => _weekday.format(d);

/// "Bugün", "Yarın", "3 gün sonra", "2 gün önce" gibi göreli gün.
String relativeDay(DateTime d, DateTime now) {
  final diff = dateOnly(d).difference(dateOnly(now)).inDays;
  return switch (diff) {
    0 => 'Bugün',
    1 => 'Yarın',
    -1 => 'Dün',
    > 1 && < 7 => '$diff gün sonra',
    < -1 && > -7 => '${-diff} gün önce',
    _ => _day.format(d),
  };
}

/// Kodu sistemiyle gösterir: "ICD-11 BA00". Kod yoksa null, sistem
/// tanınmıyorsa yalnızca kod.
String? formatCode(String? code, String? system) =>
    code == null ? null : [?codeSystemLabel(system), code].join(' ');

String profileName(Profile p) =>
    [p.firstName, p.lastName].where((s) => s.isNotEmpty).join(' ');

String initials(Profile p) {
  final a = p.firstName.isNotEmpty ? p.firstName.characters.first : '?';
  final b = p.lastName.isNotEmpty ? p.lastName.characters.first : '';
  return (a + b).toUpperCase();
}

String ageText(DateTime birth, DateTime now) {
  var years = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    years--;
  }
  if (years >= 2) return '$years yaş';
  final months =
      (now.year - birth.year) * 12 +
      now.month -
      birth.month -
      (now.day < birth.day ? 1 : 0);
  return months <= 0 ? 'Yenidoğan' : '$months aylık';
}

String observationValue(Observation o) {
  if (o.value == null) return o.note ?? '';
  final v = o.value2 != null
      ? '${fmtNumber(o.value!)}/${fmtNumber(o.value2!)}'
      : fmtNumber(o.value!);
  return '$v ${o.unit}'.trim();
}

extension on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
