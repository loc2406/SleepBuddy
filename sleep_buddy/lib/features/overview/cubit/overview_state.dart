import 'package:flutter/foundation.dart';

enum OverviewChartPeriod { today, yesterday, week, month }

extension OverviewChartPeriodLabel on OverviewChartPeriod {
  String get label => switch (this) {
    OverviewChartPeriod.today => 'Hôm nay',
    OverviewChartPeriod.yesterday => 'Hôm qua',
    OverviewChartPeriod.week => 'Tuần này',
    OverviewChartPeriod.month => 'Tháng này',
  };
}

@immutable
class OverviewState {
  const OverviewState({
    required this.currentTime,
    required this.timeUntilEndOfDay,
    this.isLoading = true,
    this.studyMinutes = 0,
    this.restMinutes = 0,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.nextTask,
    this.subjectMinutes = const {},
    this.chartPeriod = OverviewChartPeriod.today,
    this.chartStudyMinutes = 0,
    this.chartRestMinutes = 0,
    this.isChartLoading = false,
    this.loadError,
    this.chartError,
  });

  final bool isLoading;
  final int studyMinutes;
  final int restMinutes;
  final int completedTasks;
  final int totalTasks;
  final Map<String, dynamic>? nextTask;
  final Map<String, int> subjectMinutes;
  final OverviewChartPeriod chartPeriod;
  final int chartStudyMinutes;
  final int chartRestMinutes;
  final bool isChartLoading;
  final DateTime currentTime;
  final Duration timeUntilEndOfDay;
  final Object? loadError;
  final Object? chartError;

  OverviewState copyWith({
    bool? isLoading,
    int? studyMinutes,
    int? restMinutes,
    int? completedTasks,
    int? totalTasks,
    Map<String, dynamic>? nextTask,
    bool clearNextTask = false,
    Map<String, int>? subjectMinutes,
    OverviewChartPeriod? chartPeriod,
    int? chartStudyMinutes,
    int? chartRestMinutes,
    bool? isChartLoading,
    DateTime? currentTime,
    Duration? timeUntilEndOfDay,
    Object? loadError,
    bool clearLoadError = false,
    Object? chartError,
    bool clearChartError = false,
  }) => OverviewState(
    isLoading: isLoading ?? this.isLoading,
    studyMinutes: studyMinutes ?? this.studyMinutes,
    restMinutes: restMinutes ?? this.restMinutes,
    completedTasks: completedTasks ?? this.completedTasks,
    totalTasks: totalTasks ?? this.totalTasks,
    nextTask: clearNextTask ? null : nextTask ?? this.nextTask,
    subjectMinutes: subjectMinutes ?? this.subjectMinutes,
    chartPeriod: chartPeriod ?? this.chartPeriod,
    chartStudyMinutes: chartStudyMinutes ?? this.chartStudyMinutes,
    chartRestMinutes: chartRestMinutes ?? this.chartRestMinutes,
    isChartLoading: isChartLoading ?? this.isChartLoading,
    currentTime: currentTime ?? this.currentTime,
    timeUntilEndOfDay: timeUntilEndOfDay ?? this.timeUntilEndOfDay,
    loadError: clearLoadError ? null : loadError ?? this.loadError,
    chartError: clearChartError ? null : chartError ?? this.chartError,
  );
}
