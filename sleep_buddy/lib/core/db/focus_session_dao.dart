import 'package:sleep_buddy/core/db/app_db.dart';

typedef FocusTaskInfo = ({
  int id,
  int subjectId,
  String title,
  String lessonDate,
  String scheduledStart,
  String scheduledEnd,
  String status,
  String updatedAt,
});

typedef FocusSessionSegment = ({
  int id,
  String sessionType,
  DateTime startedAt,
  DateTime? endedAt,
  int actualDurationSeconds,
});

class FocusSessionDao {
  static Future<FocusTaskInfo?> getTaskInfo(int taskId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT id, subject_id, title, lesson_date, scheduled_start,
             scheduled_end, status, updated_at
      FROM study_tasks
      WHERE id = ?
      LIMIT 1
    ''',
      [taskId],
    );
    return rows.isEmpty ? null : _taskInfo(rows.first);
  }

  static Future<FocusTaskInfo?> getInProgressTaskInfo() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT id, subject_id, title, lesson_date, scheduled_start,
             scheduled_end, status, updated_at
      FROM study_tasks
      WHERE status = 'inProgress'
      ORDER BY updated_at DESC
      LIMIT 1
    ''');
    return rows.isEmpty ? null : _taskInfo(rows.first);
  }

  static Future<List<FocusSessionSegment>> getTaskSegments(int taskId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'focus_sessions',
      columns: [
        'id',
        'session_type',
        'started_at',
        'ended_at',
        'actual_duration_seconds',
      ],
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'started_at ASC, id ASC',
    );
    return rows.map(_sessionSegment).toList();
  }

  static Future<FocusSessionSegment> getOrCreateOpenSegment({
    required int taskId,
    required int subjectId,
    required String sessionType,
    required DateTime startedAt,
  }) async {
    final db = await AppDatabase.instance.database;
    return db.transaction((transaction) async {
      final rows = await transaction.query(
        'focus_sessions',
        columns: [
          'id',
          'session_type',
          'started_at',
          'ended_at',
          'actual_duration_seconds',
        ],
        where: 'task_id = ? AND ended_at IS NULL',
        whereArgs: [taskId],
        orderBy: 'started_at DESC, id DESC',
        limit: 1,
      );
      if (rows.isNotEmpty) return _sessionSegment(rows.first);

      final id = await transaction.insert('focus_sessions', {
        'task_id': taskId,
        'subject_id': subjectId,
        'session_type': sessionType,
        'mode': sessionType,
        'planned_duration_seconds': 0,
        'actual_duration_seconds': 0,
        'started_at': startedAt.toIso8601String(),
        'ended_at': null,
        'completed': 0,
      });

      return (
        id: id,
        sessionType: sessionType,
        startedAt: startedAt,
        endedAt: null,
        actualDurationSeconds: 0,
      );
    });
  }

  static Future<FocusSessionSegment> switchSegment({
    required int taskId,
    required int subjectId,
    required int currentSegmentId,
    required DateTime changedAt,
    required int actualDurationSeconds,
    required String nextSessionType,
  }) async {
    final db = await AppDatabase.instance.database;
    return db.transaction((transaction) async {
      final updated = await transaction.update(
        'focus_sessions',
        {
          'ended_at': changedAt.toIso8601String(),
          'actual_duration_seconds': actualDurationSeconds,
          'completed': 1,
        },
        where: 'id = ? AND task_id = ? AND ended_at IS NULL',
        whereArgs: [currentSegmentId, taskId],
      );
      if (updated != 1) {
        throw StateError('The active focus session segment was not found.');
      }

      final id = await transaction.insert('focus_sessions', {
        'task_id': taskId,
        'subject_id': subjectId,
        'session_type': nextSessionType,
        'mode': nextSessionType,
        'planned_duration_seconds': 0,
        'actual_duration_seconds': 0,
        'started_at': changedAt.toIso8601String(),
        'ended_at': null,
        'completed': 0,
      });

      return (
        id: id,
        sessionType: nextSessionType,
        startedAt: changedAt,
        endedAt: null,
        actualDurationSeconds: 0,
      );
    });
  }

  static Future<void> finishTask({
    required int taskId,
    required int currentSegmentId,
    required DateTime endedAt,
    required int actualDurationSeconds,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((transaction) async {
      final segmentUpdated = await transaction.update(
        'focus_sessions',
        {
          'ended_at': endedAt.toIso8601String(),
          'actual_duration_seconds': actualDurationSeconds,
          'completed': 1,
        },
        where: 'id = ? AND task_id = ? AND ended_at IS NULL',
        whereArgs: [currentSegmentId, taskId],
      );
      if (segmentUpdated != 1) {
        throw StateError('The active focus session segment was not found.');
      }

      final taskExists = await transaction.query(
        'study_tasks',
        columns: ['id', 'status'],
        where: 'id = ?',
        whereArgs: [taskId],
        limit: 1,
      );
      if (taskExists.isEmpty) {
        throw StateError('The task for this focus session no longer exists.');
      }
      if (taskExists.first['status'] != 'inProgress') {
        throw StateError('The task is no longer in progress.');
      }

      final taskUpdated = await transaction.update(
        'study_tasks',
        {
          'status': 'completed',
          'completed_at': endedAt.toIso8601String(),
          'updated_at': endedAt.toIso8601String(),
        },
        where: 'id = ? AND status = ?',
        whereArgs: [taskId, 'inProgress'],
      );
      if (taskUpdated != 1) {
        throw StateError('The task could not be completed.');
      }
    });
  }

  static FocusTaskInfo _taskInfo(Map<String, Object?> row) => (
    id: (row['id'] as num).toInt(),
    subjectId: (row['subject_id'] as num).toInt(),
    title: row['title'] as String,
    lessonDate: row['lesson_date'] as String,
    scheduledStart: row['scheduled_start'] as String,
    scheduledEnd: row['scheduled_end'] as String,
    status: row['status'] as String,
    updatedAt: row['updated_at'] as String,
  );

  static FocusSessionSegment _sessionSegment(Map<String, Object?> row) => (
    id: (row['id'] as num).toInt(),
    sessionType: row['session_type'] as String,
    startedAt: DateTime.parse(row['started_at'] as String),
    endedAt: (row['ended_at'] as String?) == null
        ? null
        : DateTime.parse(row['ended_at'] as String),
    actualDurationSeconds: (row['actual_duration_seconds'] as num).toInt(),
  );
}
