import 'package:flutter/foundation.dart';
import 'package:sleep_buddy/features/focus_rest/screens/models.dart';

enum FocusRestStatus { idle, loading, running, completed }

@immutable
class FocusRestState {
  const FocusRestState({
    this.status = FocusRestStatus.idle,
    this.taskId,
    this.taskTitle,
    this.taskEndsAt,
    this.currentMode = FocusMode.study,
    this.remaining = Duration.zero,
    this.plannedDuration = Duration.zero,
    this.studyDuration = Duration.zero,
    this.restDuration = Duration.zero,
    this.summaryPending = false,
    this.error,
  });

  final FocusRestStatus status;
  final int? taskId;
  final String? taskTitle;
  final DateTime? taskEndsAt;
  final FocusMode currentMode;
  final Duration remaining;
  final Duration plannedDuration;
  final Duration studyDuration;
  final Duration restDuration;
  final bool summaryPending;
  final Object? error;

  bool get isRunning => status == FocusRestStatus.running;

  double get progress {
    if (plannedDuration <= Duration.zero) return 0;
    final elapsed = plannedDuration - remaining;
    return (elapsed.inMilliseconds / plannedDuration.inMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  FocusRestState copyWith({
    FocusRestStatus? status,
    int? taskId,
    bool clearTaskId = false,
    String? taskTitle,
    bool clearTaskTitle = false,
    DateTime? taskEndsAt,
    bool clearTaskEndsAt = false,
    FocusMode? currentMode,
    Duration? remaining,
    Duration? plannedDuration,
    Duration? studyDuration,
    Duration? restDuration,
    bool? summaryPending,
    Object? error,
    bool clearError = false,
  }) => FocusRestState(
    status: status ?? this.status,
    taskId: clearTaskId ? null : taskId ?? this.taskId,
    taskTitle: clearTaskTitle ? null : taskTitle ?? this.taskTitle,
    taskEndsAt: clearTaskEndsAt ? null : taskEndsAt ?? this.taskEndsAt,
    currentMode: currentMode ?? this.currentMode,
    remaining: remaining ?? this.remaining,
    plannedDuration: plannedDuration ?? this.plannedDuration,
    studyDuration: studyDuration ?? this.studyDuration,
    restDuration: restDuration ?? this.restDuration,
    summaryPending: summaryPending ?? this.summaryPending,
    error: clearError ? null : error ?? this.error,
  );
}
