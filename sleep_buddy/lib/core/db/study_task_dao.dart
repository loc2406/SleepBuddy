import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/study_plan/presentation/model/models.dart';

class StudyTaskDao {
  static Future<List<StudySubject>> getSubjects() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'subjects',
      columns: ['id', 'name', 'color_hex', 'image_path'],
      orderBy: 'display_order ASC, name ASC',
    );

    return rows
        .map(
          (row) => StudySubject(
            id: row['id'] as int,
            name: row['name'] as String,
            colorHex: row['color_hex'] as String,
            imagePath: row['image_path'] as String?,
          ),
        )
        .toList();
  }

  static Future<StudySubject> createSubject({
    required String name,
    String colorHex = '#9470F4',
    String imagePath = 'assets/images/book.png',
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('Tên môn học không được để trống.');
    }

    final db = await AppDatabase.instance.database;
    final existing = await db.query(
      'subjects',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [normalizedName],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw StateError('Môn học "$normalizedName" đã tồn tại.');
    }

    final orderRow = await db.rawQuery(
      'SELECT COALESCE(MAX(display_order), -1) + 1 AS next_order FROM subjects',
    );
    final nextOrder = (orderRow.first['next_order'] as num).toInt();
    final id = await db.insert('subjects', {
      'name': normalizedName,
      'color_hex': colorHex,
      'icon_name': null,
      'image_path': imagePath,
      'display_order': nextOrder,
    });

    return StudySubject(
      id: id,
      name: normalizedName,
      colorHex: colorHex,
      imagePath: imagePath,
    );
  }

  static Future<int> create(CreateStudyTaskInput input) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();

    return db.insert('study_tasks', {
      'subject_id': input.subjectId,
      'title': input.title.trim(),
      'description': input.description.trim(),
      'lesson_date': _dateText(input.lessonDate),
      'scheduled_start': _timeText(input.startTime),
      'scheduled_end': _timeText(input.endTime),
      'priority': input.priority.name,
      'status': LessonStatus.notStarted.name,
      'image_path': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  static Future<List<({int id, String title, DateTime startsAt})>>
  getPendingTaskReminders() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT id, title, lesson_date, scheduled_start
      FROM study_tasks
      WHERE status = ?
      ORDER BY lesson_date ASC, scheduled_start ASC
    ''',
      [LessonStatus.notStarted.name],
    );

    return rows.map((row) {
      final date = row['lesson_date'] as String;
      final time = row['scheduled_start'] as String;
      return (
        id: row['id'] as int,
        title: row['title'] as String,
        startsAt: DateTime.parse('${date}T$time'),
      );
    }).toList();
  }

  static Future<bool> startTaskFromReminder(int id) async {
    final db = await AppDatabase.instance.database;
    final updated = await db.update(
      'study_tasks',
      {
        'status': LessonStatus.inProgress.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND status = ?',
      whereArgs: [id, LessonStatus.notStarted.name],
    );
    return updated > 0;
  }

  static Future<bool> hasTimeConflict(
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT id
      FROM study_tasks
      WHERE lesson_date = ?
        AND scheduled_start < ?
        AND scheduled_end > ?
      LIMIT 1
    ''',
      [_dateText(date), _timeText(endTime), _timeText(startTime)],
    );
    return rows.isNotEmpty;
  }

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

  static Future<StudyLesson?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT t.*, s.name AS subject_name
      FROM study_tasks t
      JOIN subjects s ON s.id = t.subject_id
      WHERE t.id = ?
      LIMIT 1
    ''',
      [id],
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
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

  static Future<int> completeExpiredInProgressTasks(DateTime now) async {
    final db = await AppDatabase.instance.database;
    final dateText = _dateText(now);
    final timeText = _timeText(TimeOfDay.fromDateTime(now));

    return db.update(
      'study_tasks',
      {
        'status': LessonStatus.completed.name,
        'completed_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      where: '''
        status = ? AND (
          lesson_date < ? OR (lesson_date = ? AND scheduled_end <= ?)
        )
      ''',
      whereArgs: [LessonStatus.inProgress.name, dateText, dateText, timeText],
    );
  }

  static Future<({int completed, int total})> getTaskProgressByDate(
    DateTime date,
  ) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        COALESCE(SUM(CASE WHEN status = ? THEN 1 ELSE 0 END), 0) AS completed
      FROM study_tasks
      WHERE lesson_date = ?
    ''',
      [LessonStatus.completed.name, _dateText(date)],
    );
    final row = result.single;
    return (
      completed: (row['completed'] as num).toInt(),
      total: (row['total'] as num).toInt(),
    );
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

  static String _timeText(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
