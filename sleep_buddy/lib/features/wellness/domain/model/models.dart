import 'package:flutter/material.dart';

enum AnalyticsSection { report, library, settings }

enum ReportPeriod { day, week, month }

enum SleepMood { refreshed, normal, tired }

enum GuideCategory { all, study, relax, sleep }

@immutable
class SleepData {
  const SleepData(
      {required this.bedTime,
      required this.wakeTime,
      required this.recordedDuration,
      required this.targetDuration,
      required this.targetBedtime,
      required this.reminderTime,
      required this.reminderEnabled,
      required this.mood,
      this.periodLabel = 'Đêm qua · 02 – 03/11',
      this.recommendation = 'Bắt đầu nhẹ nhàng và nghỉ đều giữa các phiên.'});
  final DateTime bedTime, wakeTime;

  /// May be calculated externally from recorded timestamps, less awakenings.
  final Duration recordedDuration, targetDuration;
  final TimeOfDay targetBedtime, reminderTime;
  final bool reminderEnabled;
  final SleepMood mood;
  final String periodLabel, recommendation;
}

@immutable
class StudyBar {
  const StudyBar({required this.label, required this.hours});
  final String label;
  final double hours;
  double get safeHours => hours.isFinite && hours > 0 ? hours : 0;
}

@immutable
class SubjectDuration {
  const SubjectDuration(
      {required this.name, required this.duration, required this.color});
  final String name;
  final Duration duration;
  final Color color;
}

@immutable
class ReportData {
  const ReportData(
      {required this.period,
      required this.rangeLabel,
      required this.studyTime,
      required this.restTime,
      required this.dailyBars,
      required this.subjects,
      required this.completedLessons,
      required this.totalLessons,
      this.chartTitle = 'Nhịp học trong tuần',
      this.metricCaption = 'Trong tuần đã chọn'});
  final ReportPeriod period;
  final String rangeLabel, chartTitle, metricCaption;
  final Duration studyTime, restTime;
  final List<StudyBar> dailyBars;
  final List<SubjectDuration> subjects;
  final int completedLessons, totalLessons;
}

@immutable
class GuideArticle {
  const GuideArticle(
      {required this.id,
      required this.category,
      required this.title,
      required this.readTimeLabel,
      required this.image,
      this.coverImage = false});
  final String id, title, readTimeLabel;
  final GuideCategory category;
  final ImageProvider image;
  final bool coverImage;
}

@immutable
class WellnessSettings {
  const WellnessSettings(
      {required this.studyDuration,
      required this.shortBreak,
      required this.longBreak,
      required this.notificationsEnabled,
      required this.soundEnabled,
      required this.themeMode});
  final Duration studyDuration, shortBreak, longBreak;
  final bool notificationsEnabled, soundEnabled;
  final ThemeMode themeMode;
  WellnessSettings copyWith(
          {Duration? studyDuration,
          Duration? shortBreak,
          Duration? longBreak,
          bool? notificationsEnabled,
          bool? soundEnabled,
          ThemeMode? themeMode}) =>
      WellnessSettings(
          studyDuration: studyDuration ?? this.studyDuration,
          shortBreak: shortBreak ?? this.shortBreak,
          longBreak: longBreak ?? this.longBreak,
          notificationsEnabled:
              notificationsEnabled ?? this.notificationsEnabled,
          soundEnabled: soundEnabled ?? this.soundEnabled,
          themeMode: themeMode ?? this.themeMode);
}

String durationLabel(Duration duration) {
  final minutes = duration.isNegative ? 0 : duration.inMinutes;
  if (minutes < 60) return '${minutes}m';
  return minutes % 60 == 0
      ? '${minutes ~/ 60}h'
      : '${minutes ~/ 60}h ${minutes % 60}m';
}

String timeLabel(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String categoryLabel(GuideCategory category) => switch (category) {
      GuideCategory.all => 'Tất cả',
      GuideCategory.study => 'Học tập',
      GuideCategory.relax => 'Thư giãn',
      GuideCategory.sleep => 'Giấc ngủ',
    };
double safeFraction(num completed, num total) =>
    !completed.isFinite || !total.isFinite || total <= 0
        ? 0
        : (completed / total).clamp(0.0, 1.0);
