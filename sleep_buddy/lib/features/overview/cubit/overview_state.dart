import 'package:flutter/foundation.dart';

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
    this.loadError,
  });

  final bool isLoading;
  final int studyMinutes;
  final int restMinutes;
  final int completedTasks;
  final int totalTasks;
  final Map<String, dynamic>? nextTask;
  final Map<String, int> subjectMinutes;
  final DateTime currentTime;
  final Duration timeUntilEndOfDay;
  final Object? loadError;

  OverviewState copyWith({
    bool? isLoading,
    int? studyMinutes,
    int? restMinutes,
    int? completedTasks,
    int? totalTasks,
    Map<String, dynamic>? nextTask,
    bool clearNextTask = false,
    Map<String, int>? subjectMinutes,
    DateTime? currentTime,
    Duration? timeUntilEndOfDay,
    Object? loadError,
    bool clearLoadError = false,
  }) => OverviewState(
    isLoading: isLoading ?? this.isLoading,
    studyMinutes: studyMinutes ?? this.studyMinutes,
    restMinutes: restMinutes ?? this.restMinutes,
    completedTasks: completedTasks ?? this.completedTasks,
    totalTasks: totalTasks ?? this.totalTasks,
    nextTask: clearNextTask ? null : nextTask ?? this.nextTask,
    subjectMinutes: subjectMinutes ?? this.subjectMinutes,
    currentTime: currentTime ?? this.currentTime,
    timeUntilEndOfDay: timeUntilEndOfDay ?? this.timeUntilEndOfDay,
    loadError: clearLoadError ? null : loadError ?? this.loadError,
  );
}
