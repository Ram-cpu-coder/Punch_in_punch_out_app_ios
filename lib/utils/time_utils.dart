part of '../main.dart';

String mondayOf(DateTime date) {
  final monday = DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: date.weekday - 1));
  return DateFormat('yyyy-MM-dd').format(monday);
}

String addDays(String date, int days) {
  return DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.parse(date).add(Duration(days: days)));
}

WeekRecord createWeek([String? weekStart]) {
  final start = weekStart ?? mondayOf(DateTime.now());
  const labels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  return WeekRecord(
    weekStart: start,
    days: List.generate(
      7,
      (index) => WorkDay(
        key: keys[index],
        label: labels[index],
        date: addDays(start, index),
      ),
    ),
  );
}

int? timeToMinutes(String value) {
  if (value.isEmpty || !value.contains(':')) return null;
  final parts = value.split(':');
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

double calculateDayHours(WorkDay day) {
  final start = timeToMinutes(day.start);
  final end = timeToMinutes(day.end);
  if (start == null || end == null) return 0;
  final adjustedEnd = end < start ? end + 24 * 60 : end;
  final minutes =
      math.max(adjustedEnd - start - day.breakMinutes, 0).toDouble();
  return double.parse((minutes / 60).toStringAsFixed(2));
}

double calculateLiveHours(WorkDay day, ActiveTimer? timer, DateTime now) {
  if (timer == null) return calculateDayHours(day);
  final elapsed =
      now.difference(timer.startedAt).inSeconds - day.breakMinutes * 60;
  return double.parse(
    (math.max(elapsed, 0).toDouble() / 3600).toStringAsFixed(4),
  );
}

String formatClock(DateTime date) => DateFormat('HH:mm').format(date);

String formatTime(String value) {
  if (value.isEmpty) return '--:--';
  final parts = value.split(':');
  final date = DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  return DateFormat('h:mm a').format(date);
}

String durationText(int seconds) {
  final safe = math.max(seconds, 0).toInt();
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String money(double value) =>
    NumberFormat.currency(symbol: r'$', decimalDigits: 2).format(value);
