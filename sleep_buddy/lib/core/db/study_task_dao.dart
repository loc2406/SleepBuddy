import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/models.dart';

class StudyTaskDao {
  static Future<List<StudyLesson>> getByDate(
    DateTime date, {
    LessonFilter filter = LessonFilter.all,
  }) async {
    final db = await AppDatabase.instance.database;
    final dateText = _dateText(date);
    final where = filter == LessonFilter.all
        ? 't.lesson_date = ?'
        : 't.lesson_date = ? AND t.status = ?';
    final args = filter == LessonFilter.all
        ? <Object?>[dateText]
        : <Object?>[dateText, filter.name];

    final rows = await db.rawQuery('''
      SELECT t.*, s.name AS subject_name
      FROM study_tasks t
      JOIN subjects s ON s.id = t.subject_id
      WHERE $where
      ORDER BY t.scheduled_start ASC
    ''', args);

    return rows.map(_fromRow).toList();
  }

  static Future<Map<String, dynamic>?> getNextTask(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final dateTimeText = date.toIso8601String();
    final rows = await db.rawQuery(
      '''
      SELECT t.*, s.name AS subject_name, s.color_hex
      FROM study_tasks t
      JOIN subjects s ON s.id = t.subject_id
      WHERE t.status != 'completed'
        AND (t.lesson_date > ? OR (t.lesson_date = ? AND t.scheduled_start >= ?))
      ORDER BY t.lesson_date ASC, t.scheduled_start ASC
      LIMIT 1
    ''',
      [_dateText(date), _dateText(date), dateTimeText.substring(11, 16)],
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<StudyLesson>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT t.*, s.name AS subject_name
      FROM study_tasks t
      JOIN subjects s ON s.id = t.subject_id
      ORDER BY t.lesson_date ASC, t.scheduled_start ASC
    ''');
    return rows.map(_fromRow).toList();
  }

  static Future<List<PlannerFilterItem>> getFilterItems(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final dateText = _dateText(date);
    final rows = await db.rawQuery(
      '''
      SELECT status, COUNT(*) AS count
      FROM study_tasks
      WHERE lesson_date = ?
      GROUP BY status
    ''',
      [dateText],
    );
    final counts = <LessonStatus, int>{};
    for (final row in rows) {
      final status = LessonStatus.values.byName(row['status'] as String);
      counts[status] = row['count'] as int;
    }

    return [
      PlannerFilterItem(
        value: LessonFilter.all,
        label: 'Tất cả',
        count: counts.values.fold(0, (sum, count) => sum + count),
      ),
      PlannerFilterItem(
        value: LessonFilter.notStarted,
        label: 'Chưa học',
        count: counts[LessonStatus.notStarted] ?? 0,
      ),
      PlannerFilterItem(
        value: LessonFilter.inProgress,
        label: 'Đang học',
        count: counts[LessonStatus.inProgress] ?? 0,
      ),
      PlannerFilterItem(
        value: LessonFilter.completed,
        label: 'Hoàn thành',
        count: counts[LessonStatus.completed] ?? 0,
      ),
    ];
  }

  static Future<int> getCompletedCount(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count FROM study_tasks
      WHERE lesson_date = ? AND status = 'completed'
    ''',
      [_dateText(date)],
    );
    return result.first['count'] as int;
  }

  static StudyLesson _fromRow(Map<String, Object?> row) {
    return StudyLesson(
      id: row['id'].toString(),
      subject: row['subject_name'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      startTime: _timeOfDay(row['scheduled_start'] as String),
      endTime: _timeOfDay(row['scheduled_end'] as String),
      priority: LessonPriority.values.byName(row['priority'] as String),
      status: LessonStatus.values.byName(row['status'] as String),
      image: AssetImage(
        row['image_path'] as String? ?? 'assets/images/book.png',
      ),
    );
  }

  static TimeOfDay _timeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _dateText(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
