import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

class ReportDao {
  static Future<ReportData> getReport(ReportPeriod period, DateTime now) async {
    final range = _range(period, now);
    final db = await AppDatabase.instance.database;
    final startText = _dateText(range.start);
    final endText = _dateText(range.end);

    final durationRows = await db.rawQuery(
      '''
      SELECT session_type,
             SUM(actual_duration_seconds) AS total_seconds
      FROM focus_sessions
      WHERE substr(started_at, 1, 10) BETWEEN ? AND ?
      GROUP BY session_type
    ''',
      [startText, endText],
    );

    var studySeconds = 0;
    var restSeconds = 0;
    for (final row in durationRows) {
      final type = row['session_type'] as String;
      final seconds = (row['total_seconds'] as num?)?.round() ?? 0;
      if (type == 'study' || type == 'focus') {
        studySeconds += seconds;
      } else {
        restSeconds += seconds;
      }
    }

    final lessonRow = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed,
        COUNT(*) AS total
      FROM study_tasks
      WHERE lesson_date BETWEEN ? AND ?
    ''',
      [startText, endText],
    );

    final subjectRows = await db.rawQuery(
      '''
      SELECT s.name, s.color_hex,
             SUM(f.actual_duration_seconds) AS total_seconds
      FROM focus_sessions f
      JOIN subjects s ON s.id = f.subject_id
      WHERE f.session_type IN ('study', 'focus')
        AND substr(f.started_at, 1, 10) BETWEEN ? AND ?
      GROUP BY s.id, s.name, s.color_hex
      ORDER BY total_seconds DESC
    ''',
      [startText, endText],
    );

    final dailyRows = await db.rawQuery(
      '''
      SELECT substr(started_at, 1, 10) AS activity_date,
             SUM(actual_duration_seconds) AS total_seconds
      FROM focus_sessions
      WHERE session_type IN ('study', 'focus')
        AND substr(started_at, 1, 10) BETWEEN ? AND ?
      GROUP BY activity_date
      ORDER BY activity_date ASC
    ''',
      [startText, endText],
    );
    final dailyMap = {
      for (final row in dailyRows)
        row['activity_date'] as String:
            ((row['total_seconds'] as num?)?.toDouble() ?? 0) / 3600,
    };

    final dailyBars = period == ReportPeriod.day
        ? [StudyBar(label: 'Hôm nay', hours: dailyMap[startText] ?? 0)]
        : period == ReportPeriod.month
        ? monthBars(range.start, dailyMap)
        : _weekBars(range.start, dailyMap);

    return ReportData(
      period: period,
      rangeLabel: _rangeLabel(period, range.start, range.end),
      chartTitle: switch (period) {
        ReportPeriod.day => 'Nhịp học trong ngày',
        ReportPeriod.week => 'Nhịp học trong tuần',
        ReportPeriod.month => 'Nhịp học trong tháng',
      },
      metricCaption: switch (period) {
        ReportPeriod.day => 'Trong ngày đã chọn',
        ReportPeriod.week => 'Trong tuần đã chọn',
        ReportPeriod.month => 'Trong tháng đã chọn',
      },
      studyTime: Duration(seconds: studySeconds),
      restTime: Duration(seconds: restSeconds),
      dailyBars: dailyBars,
      subjects: subjectRows.map((row) {
        return SubjectDuration(
          name: row['name'] as String,
          duration: Duration(
            seconds: (row['total_seconds'] as num?)?.round() ?? 0,
          ),
          color: _hexColor(row['color_hex'] as String),
        );
      }).toList(),
      completedLessons: (lessonRow.first['completed'] as num?)?.toInt() ?? 0,
      totalLessons: (lessonRow.first['total'] as num?)?.toInt() ?? 0,
    );
  }

  static List<StudyBar> _weekBars(
    DateTime weekStart,
    Map<String, double> dailyMap,
  ) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return StudyBar(
        label: labels[index],
        hours: dailyMap[_dateText(date)] ?? 0,
      );
    });
  }

  @visibleForTesting
  static List<StudyBar> monthBars(
    DateTime monthStart,
    Map<String, double> dailyMap,
  ) {
    final result = <StudyBar>[];
    final firstWeekStart = monthStart.subtract(
      Duration(days: monthStart.weekday - 1),
    );
    final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0);
    final lastWeekStart = lastDay.subtract(Duration(days: lastDay.weekday - 1));
    final weekCount = lastWeekStart.difference(firstWeekStart).inDays ~/ 7 + 1;

    for (var week = 0; week < weekCount; week++) {
      var hours = 0.0;
      for (var day = 0; day < 7; day++) {
        final date = firstWeekStart.add(Duration(days: week * 7 + day));
        if (date.month != monthStart.month) continue;
        hours += dailyMap[_dateText(date)] ?? 0;
      }
      result.add(StudyBar(label: 'Tuần ${week + 1}', hours: hours));
    }
    return result;
  }

  static ({DateTime start, DateTime end}) _range(
    ReportPeriod period,
    DateTime now,
  ) {
    final day = DateTime(now.year, now.month, now.day);
    return switch (period) {
      ReportPeriod.day => (start: day, end: day),
      ReportPeriod.week => (
        start: day.subtract(Duration(days: day.weekday - 1)),
        end: day.add(Duration(days: 7 - day.weekday)),
      ),
      ReportPeriod.month => (
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      ),
    };
  }

  static String _rangeLabel(
    ReportPeriod period,
    DateTime start,
    DateTime end,
  ) => switch (period) {
    ReportPeriod.day => '${start.day}/${start.month}/${start.year}',
    ReportPeriod.week => '${_shortDate(start)} – ${_shortDate(end)}',
    ReportPeriod.month => 'Tháng ${start.month}/${start.year}',
  };

  static String _shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}';

  static String _dateText(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static Color _hexColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
