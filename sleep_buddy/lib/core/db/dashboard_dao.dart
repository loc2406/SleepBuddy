import 'package:sleep_buddy/core/db/app_db.dart';

class DashboardDao {
  // 1. Tính tổng số phút học và nghỉ trong ngày hôm nay
  static Future<Map<String, int>> getStudyAndBreakDuration(
    DateTime date,
  ) async {
    final db = await AppDatabase.instance.database;
    final day = _dateText(date);

    final result = await db.rawQuery(
      '''
      SELECT 
        session_type, 
        SUM(actual_duration_seconds) as total_seconds
      FROM focus_sessions
      WHERE substr(started_at, 1, 10) = ?
      GROUP BY session_type
    ''',
      [day],
    );

    int focusSeconds = 0;
    int breakSeconds = 0;

    for (var row in result) {
      final type = row['session_type'] as String;
      final seconds = (row['total_seconds'] as int?) ?? 0;
      if (type == 'study' || type == 'focus') {
        focusSeconds += seconds;
      } else {
        breakSeconds += seconds;
      }
    }

    return {
      'focus_minutes': focusSeconds ~/ 60,
      'break_minutes': breakSeconds ~/ 60,
    };
  }

  // 2. Lấy công việc tiếp theo trong lịch trình
  static Future<Map<String, dynamic>?> getNextTask(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final dateText = _dateText(date);
    final timeText =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    final result = await db.rawQuery(
      '''
      SELECT t.*, s.name as subject_name, s.color_hex 
      FROM study_tasks t
      JOIN subjects s ON t.subject_id = s.id
      WHERE t.status != 'completed'
        AND (t.lesson_date > ? OR (t.lesson_date = ? AND t.scheduled_start >= ?))
      ORDER BY t.lesson_date ASC, t.scheduled_start ASC
      LIMIT 1
    ''',
      [dateText, dateText, timeText],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  static Future<Map<String, int>> getStudyMinutesBySubject(
    DateTime start,
    DateTime end,
  ) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT s.name, SUM(f.actual_duration_seconds) AS total_seconds
      FROM focus_sessions f
      JOIN subjects s ON s.id = f.subject_id
      WHERE f.session_type = 'study'
        AND substr(f.started_at, 1, 10) BETWEEN ? AND ?
      GROUP BY s.id, s.name
      ORDER BY total_seconds DESC
    ''',
      [_dateText(start), _dateText(end)],
    );

    return {
      for (final row in result)
        row['name'] as String: ((row['total_seconds'] as int? ?? 0) ~/ 60),
    };
  }

  static String _dateText(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
