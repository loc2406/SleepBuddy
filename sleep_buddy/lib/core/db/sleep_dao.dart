import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/core/db/settings_dao.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sqflite/sqflite.dart';

typedef SleepReminderSettings = ({TimeOfDay reminderTime, bool enabled});

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

    final settings = settingsRows.isEmpty ? null : settingsRows.first;
    final log = logRows.isEmpty ? null : logRows.first;
    final appNotificationsEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    final bedTime = _dateTimeFromText(log?['sleep_start'] as String?);
    final wakeTime = _dateTimeFromText(log?['sleep_end'] as String?);
    final targetMinutes =
        (log?['target_sleep_minutes'] as num?)?.toInt() ??
        (settings?['target_sleep_minutes'] as num?)?.toInt() ??
        480;
    final recordedMinutes =
        (log?['recorded_sleep_minutes'] as num?)?.toInt() ?? 0;
    final targetBedtime = _timeFromText(
      settings?['target_bedtime'] as String? ?? '22:45',
    );
    final reminderTime = _timeFromText(
      settings?['reminder_time'] as String? ?? '22:15',
    );

    return SleepData(
      periodLabel: log == null
          ? 'Chưa ghi nhận'
          : 'Đêm ngủ gần nhất · ${_dateLabel(bedTime!)} – ${_dateLabel(wakeTime!)}',
      bedTime: bedTime,
      wakeTime: wakeTime,
      recordedDuration: Duration(minutes: recordedMinutes),
      targetDuration: Duration(minutes: targetMinutes),
      targetBedtime: targetBedtime,
      reminderTime: reminderTime,
      reminderEnabled: (settings?['reminder_enabled'] as num?)?.toInt() != 0,
      appNotificationsEnabled: appNotificationsEnabled,
      mood: _sleepMood(log?['mood'] as String?),
      notes: log?['notes'] as String?,
      recommendation:
          log?['recommendation'] as String? ??
          'Ghi nhận giấc ngủ để xem tóm tắt và gợi ý.',
    );
  }

  static Future<SleepReminderSettings> getReminderSettings() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'sleep_settings',
      columns: ['reminder_time', 'reminder_enabled'],
      where: 'id = 1',
      limit: 1,
    );
    final settings = rows.isEmpty ? null : rows.first;
    return (
      reminderTime: _timeFromText(
        settings?['reminder_time'] as String? ?? '22:15',
      ),
      enabled: (settings?['reminder_enabled'] as num?)?.toInt() != 0,
    );
  }

  static Future<int> getTargetSleepMinutes() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'sleep_settings',
      columns: ['target_sleep_minutes'],
      where: 'id = 1',
      limit: 1,
    );
    return rows.isEmpty
        ? 480
        : (rows.first['target_sleep_minutes'] as num).toInt();
  }

  static Future<void> saveSleepRecord({
    required DateTime bedTime,
    required DateTime wakeTime,
    required SleepMood mood,
    required String notes,
    DateTime? previousWakeTime,
  }) async {
    if (!wakeTime.isAfter(bedTime)) {
      throw ArgumentError('Giờ thức dậy phải sau giờ đi ngủ.');
    }

    final db = await AppDatabase.instance.database;
    final wakeDate = _dateText(wakeTime);
    final previousWakeDate = previousWakeTime == null
        ? null
        : _dateText(previousWakeTime);

    await db.transaction((transaction) async {
      final settingsRows = await transaction.query(
        'sleep_settings',
        columns: ['target_sleep_minutes'],
        where: 'id = 1',
        limit: 1,
      );
      final targetMinutes = settingsRows.isEmpty
          ? 480
          : (settingsRows.first['target_sleep_minutes'] as num).toInt();
      final matchingDate = await transaction.query(
        'sleep_logs',
        columns: ['log_date'],
        where: 'log_date = ?',
        whereArgs: [wakeDate],
        limit: 1,
      );
      if (matchingDate.isNotEmpty && wakeDate != previousWakeDate) {
        throw StateError('Ngày thức dậy này đã có nhật ký giấc ngủ.');
      }

      final values = {
        'log_date': wakeDate,
        'sleep_start': bedTime.toIso8601String(),
        'sleep_end': wakeTime.toIso8601String(),
        'recorded_sleep_minutes': wakeTime.difference(bedTime).inMinutes,
        'target_sleep_minutes': targetMinutes,
        'mood': mood.name,
        'notes': notes.trim().isEmpty ? null : notes.trim(),
      };

      if (previousWakeDate == null) {
        await transaction.insert('sleep_logs', values);
        return;
      }

      final updated = await transaction.update(
        'sleep_logs',
        values,
        where: 'log_date = ?',
        whereArgs: [previousWakeDate],
      );
      if (updated != 1) {
        throw StateError('Không tìm thấy nhật ký cần chỉnh sửa.');
      }
    });
  }

  static Future<void> updateMood(DateTime wakeTime, SleepMood mood) async {
    final db = await AppDatabase.instance.database;
    final updated = await db.update(
      'sleep_logs',
      {'mood': mood.name},
      where: 'log_date = ?',
      whereArgs: [_dateText(wakeTime)],
    );
    if (updated != 1) {
      throw StateError('Không tìm thấy nhật ký để cập nhật cảm nhận.');
    }
  }

  static Future<void> saveSettings({
    required TimeOfDay targetBedtime,
    required TimeOfDay reminderTime,
    required bool reminderEnabled,
    required int targetSleepMinutes,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.insert('sleep_settings', {
      'id': 1,
      'target_bedtime': _timeText(targetBedtime),
      'reminder_time': _timeText(reminderTime),
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'target_sleep_minutes': targetSleepMinutes,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static SleepMood _sleepMood(String? mood) =>
      SleepMood.values.byName(mood ?? 'normal');

  static TimeOfDay _timeFromText(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _timeText(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  static DateTime? _dateTimeFromText(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  static String _dateText(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}';
}
