part of '../main.dart';

class AppUser {
  AppUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

class WorkDay {
  WorkDay({
    required this.key,
    required this.label,
    required this.date,
    this.start = '',
    this.end = '',
    this.breakMinutes = 0,
    this.notes = '',
  });

  final String key;
  final String label;
  final String date;
  String start;
  String end;
  int breakMinutes;
  String notes;

  factory WorkDay.fromJson(Map<String, dynamic> json) {
    return WorkDay(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      breakMinutes: int.tryParse(json['breakMinutes']?.toString() ?? '0') ?? 0,
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'date': date,
        'start': start,
        'end': end,
        'breakMinutes': breakMinutes,
        'notes': notes,
      };

  WorkDay copy() => WorkDay(
        key: key,
        label: label,
        date: date,
        start: start,
        end: end,
        breakMinutes: breakMinutes,
        notes: notes,
      );
}

class WeekRecord {
  WeekRecord({
    required this.weekStart,
    required this.days,
    this.isPaid = false,
  });

  String weekStart;
  List<WorkDay> days;
  bool isPaid;

  factory WeekRecord.fromJson(Map<String, dynamic> json) {
    return WeekRecord(
      weekStart: json['weekStart']?.toString() ?? mondayOf(DateTime.now()),
      isPaid: json['isPaid'] == true,
      days: (json['days'] as List? ?? [])
          .map((day) => WorkDay.fromJson(Map<String, dynamic>.from(day)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'weekStart': weekStart,
        'isPaid': isPaid,
        'hourlyRate': null,
        'days': days.map((day) => day.toJson()).toList(),
      };
}

class ActiveTimer {
  ActiveTimer({
    required this.weekStart,
    required this.dayIndex,
    required this.startedAt,
    required this.startTime,
  });

  final String weekStart;
  final int dayIndex;
  final DateTime startedAt;
  final String startTime;

  factory ActiveTimer.fromJson(Map<String, dynamic> json) {
    return ActiveTimer(
      weekStart: json['weekStart']?.toString() ?? '',
      dayIndex: int.tryParse(json['dayIndex']?.toString() ?? '0') ?? 0,
      startedAt:
          DateTime.tryParse(json['startedAt']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      startTime: json['startTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'weekStart': weekStart,
        'dayIndex': dayIndex,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'startTime': startTime,
      };
}
