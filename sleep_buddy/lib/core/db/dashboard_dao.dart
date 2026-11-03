import 'package:sleep_buddy/core/db/app_db.dart';

class DashboardDao {
  // 1. Tính tổng số phút học và nghỉ trong ngày hôm nay
  static Future<Map<String, int>> getTodayStudyAndBreakDuration() async {
    final db = await AppDatabase.instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    final result = await db.rawQuery('''
      SELECT 
        session_type, 
        SUM(actual_duration_seconds) as total_seconds
      FROM focus_sessions
      WHERE started_at LIKE '$today%'
      GROUP BY session_type
    ''');

    int focusSeconds = 0;
    int breakSeconds = 0;

    for (var row in result) {
      final type = row['session_type'] as String;
      final seconds = (row['total_seconds'] as int?) ?? 0;
      if (type == 'focus') {
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
  static Future<Map<String, dynamic>?> getNextTask() async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();

    final result = await db.rawQuery('''
      SELECT t.*, s.name as subject_name, s.color_hex 
      FROM study_tasks t
      JOIN subjects s ON t.subject_id = s.id
      WHERE t.status != 'completed' AND t.scheduled_start_time >= '$now'
      ORDER BY t.scheduled_start_time ASC
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}