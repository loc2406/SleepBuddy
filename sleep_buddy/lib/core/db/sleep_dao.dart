import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

class SleepDao {
  static Future<SleepData> getLatest() async {
    final db = await AppDatabase.instance.database;
    final settingsRows = await db.query(
      'sleep_settings',
      where: 'id = 1',
      limit: 1,
    );
    final logRows = await db.query(
      'sleep_logs',
      orderBy: 'log_date DESC',
      limit: 1,
    );

    final settings = settingsRows.isNotEmpty
        ? settingsRows.first
        : <String, Object?>{};
    final log = logRows.isNotEmpty ? logRows.first : <String, Object?>{};

    final fallbackBedtime = _timeFromText(
      settings['target_bedtime'] as String? ?? '22:45',
    );
    final reminder = _timeFromText(
      settings['reminder_time'] as String? ?? '22:15',
    );
    final targetMinutes =
        log['target_sleep_minutes'] as int? ??
        settings['target_sleep_minutes'] as int? ??
        480;
    final recordedMinutes = log['recorded_sleep_minutes'] as int? ?? 465;
    final bedTime =
        _dateTimeFromText(log['sleep_start'] as String?) ??
        DateTime.now().subtract(const Duration(hours: 7, minutes: 45));
    final wakeTime =
        _dateTimeFromText(log['sleep_end'] as String?) ?? DateTime.now();

    return SleepData(
      periodLabel: log.isEmpty
          ? 'Đêm gần nhất'
          : 'Đêm qua · ${_dateLabel(bedTime)} – ${_dateLabel(wakeTime)}',
      bedTime: bedTime,
      wakeTime: wakeTime,
      recordedDuration: Duration(minutes: recordedMinutes),
      targetDuration: Duration(minutes: targetMinutes),
      targetBedtime: fallbackBedtime,
      reminderTime: reminder,
      reminderEnabled:
          settings['reminder_enabled'] == null ||
          settings['reminder_enabled'] == 1,
      mood: _sleepMood(log['mood'] as String?),
      recommendation:
          log['recommendation'] as String? ??
          'Bắt đầu nhẹ nhàng và nghỉ đều giữa các phiên.',
    );
  }

  static SleepMood _sleepMood(String? mood) =>
      SleepMood.values.byName(mood ?? 'normal');

  static TimeOfDay _timeFromText(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static DateTime? _dateTimeFromText(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  static String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}';
}
