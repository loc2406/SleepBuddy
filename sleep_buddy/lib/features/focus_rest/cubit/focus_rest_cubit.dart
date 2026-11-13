import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/cubit/minute_ticker_cubit.dart';
import 'package:sleep_buddy/core/db/focus_session_dao.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_state.dart';
import 'package:sleep_buddy/features/focus_rest/screens/models.dart';

class FocusRestCubit extends Cubit<FocusRestState> {
  FocusRestCubit({required MinuteTickerCubit minuteTicker})
    : super(const FocusRestState()) {
    _tickerSubscription = minuteTicker.stream.listen(_handleTick);
    unawaited(_restoreActiveSession());
  }

  late final StreamSubscription<DateTime> _tickerSubscription;
  Timer? _secondTimer;
  FocusTaskInfo? _task;
  List<FocusSessionSegment> _segments = [];
  FocusSessionSegment? _activeSegment;
  DateTime? _taskStartsAt;
  DateTime? _taskEndsAt;
  int _loadGeneration = 0;
  bool _isSwitching = false;
  bool _isFinishing = false;

  Future<void> loadTaskSession(int? taskId) async {
    if (_isFinishing && (taskId == null || taskId == _task?.id)) return;
    if (taskId == null && state.summaryPending) return;
    if (taskId != null &&
        state.status == FocusRestStatus.completed &&
        !state.summaryPending &&
        state.taskId == taskId) {
      return;
    }

    final generation = ++_loadGeneration;
    _stopSecondTimer();
    emit(const FocusRestState(status: FocusRestStatus.loading));

    try {
      final task = taskId == null
          ? await FocusSessionDao.getInProgressTaskInfo()
          : await FocusSessionDao.getTaskInfo(taskId);
      if (isClosed || generation != _loadGeneration) return;
      if (task == null) {
        _clearSession();
        emit(const FocusRestState());
        return;
      }

      final startsAt = _dateTime(task.lessonDate, task.scheduledStart);
      final endsAt = _dateTime(task.lessonDate, task.scheduledEnd);
      final plannedDuration = endsAt.difference(startsAt);
      if (plannedDuration <= Duration.zero) {
        throw StateError('Khung giờ của nhiệm vụ không hợp lệ.');
      }

      final segments = await FocusSessionDao.getTaskSegments(task.id);
      if (isClosed || generation != _loadGeneration) return;

      if (task.status == 'completed') {
        _task = task;
        _taskStartsAt = startsAt;
        _taskEndsAt = endsAt;
        _segments = segments;
        _activeSegment = null;
        final totals = _calculateTotals(endsAt);
        emit(
          FocusRestState(
            status: FocusRestStatus.completed,
            taskId: task.id,
            taskTitle: task.title,
            taskEndsAt: endsAt,
            remaining: Duration.zero,
            plannedDuration: plannedDuration,
            studyDuration: totals.study,
            restDuration: totals.rest,
            summaryPending: false,
          ),
        );
        return;
      }

      if (task.status != 'inProgress') {
        _clearSession();
        emit(
          FocusRestState(
            error: taskId == null
                ? null
                : StateError('Nhiệm vụ chưa được bắt đầu.'),
          ),
        );
        return;
      }

      final openSegments = segments.where((segment) => segment.endedAt == null);
      if (openSegments.length > 1) {
        throw StateError('Nhiệm vụ có nhiều phiên tập trung chưa đóng.');
      }
      final segment = openSegments.isEmpty
          ? await FocusSessionDao.getOrCreateOpenSegment(
              taskId: task.id,
              subjectId: task.subjectId,
              sessionType: 'study',
              startedAt: DateTime.parse(task.updatedAt),
            )
          : openSegments.single;
      if (isClosed || generation != _loadGeneration) return;

      _task = task;
      _taskStartsAt = startsAt;
      _taskEndsAt = endsAt;
      _activeSegment = segment;
      _segments = segments.any((item) => item.id == segment.id)
          ? segments
          : [...segments, segment];

      if (!DateTime.now().isBefore(endsAt)) {
        await _finishTask();
        return;
      }

      final initialMode = segment.sessionType == 'study'
          ? FocusMode.study
          : FocusMode.relax;
      _emitRunning(DateTime.now(), initialMode);
      _startSecondTimer();
      await _scheduleEndReminder(task, endsAt);
    } on Object catch (error, stackTrace) {
      if (isClosed || generation != _loadGeneration) return;
      _stopSecondTimer();
      addError(error, stackTrace);
      emit(FocusRestState(taskId: taskId, error: error));
    }
  }

  Future<void> changeMode(FocusMode mode) async {
    final task = _task;
    final segment = _activeSegment;
    final endsAt = _taskEndsAt;
    if (!state.isRunning ||
        task == null ||
        segment == null ||
        endsAt == null ||
        mode == state.currentMode ||
        _isSwitching ||
        _isFinishing) {
      return;
    }

    final now = DateTime.now();
    if (!now.isBefore(endsAt)) {
      await _finishTask();
      return;
    }

    _isSwitching = true;
    try {
      final nextSegment = await FocusSessionDao.switchSegment(
        taskId: task.id,
        subjectId: task.subjectId,
        currentSegmentId: segment.id,
        changedAt: now,
        actualDurationSeconds: _elapsedSeconds(segment.startedAt, now),
        nextSessionType: mode == FocusMode.study ? 'study' : 'break',
      );
      _segments = await FocusSessionDao.getTaskSegments(task.id);
      _activeSegment = nextSegment;
      _emitRunning(now, mode);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(error: error));
    } finally {
      _isSwitching = false;
    }
  }

  void acknowledgeSummary() {
    if (!state.summaryPending) return;
    _clearSession();
    emit(const FocusRestState());
  }

  Future<void> _restoreActiveSession() => loadTaskSession(null);

  void _handleTick(DateTime now) {
    if (!state.isRunning || _isSwitching || _isFinishing) return;
    final endsAt = _taskEndsAt;
    if (endsAt == null) return;
    if (!now.isBefore(endsAt)) {
      unawaited(_finishTask());
      return;
    }
    _emitRunning(now, state.currentMode, error: state.error);
  }

  void _emitRunning(DateTime now, FocusMode mode, {Object? error}) {
    final task = _task;
    final startsAt = _taskStartsAt;
    final endsAt = _taskEndsAt;
    if (task == null || startsAt == null || endsAt == null) return;
    final totals = _calculateTotals(now);
    emit(
      FocusRestState(
        status: FocusRestStatus.running,
        taskId: task.id,
        taskTitle: task.title,
        taskEndsAt: endsAt,
        currentMode: mode,
        remaining: endsAt.difference(now),
        plannedDuration: endsAt.difference(startsAt),
        studyDuration: totals.study,
        restDuration: totals.rest,
        error: error,
      ),
    );
  }

  ({Duration study, Duration rest}) _calculateTotals(DateTime now) {
    var studySeconds = 0;
    var restSeconds = 0;
    final endsAt = _taskEndsAt;

    for (final segment in _segments) {
      final segmentEnd =
          segment.endedAt ??
          (endsAt != null && now.isAfter(endsAt) ? endsAt : now);
      final seconds = segment.endedAt == null
          ? _elapsedSeconds(segment.startedAt, segmentEnd)
          : segment.actualDurationSeconds;
      if (segment.sessionType == 'study' || segment.sessionType == 'focus') {
        studySeconds += seconds;
      } else {
        restSeconds += seconds;
      }
    }

    return (
      study: Duration(seconds: studySeconds),
      rest: Duration(seconds: restSeconds),
    );
  }

  Future<void> _finishTask() async {
    if (_isFinishing) return;
    final task = _task;
    final segment = _activeSegment;
    final endsAt = _taskEndsAt;
    final startsAt = _taskStartsAt;
    if (task == null || segment == null || endsAt == null || startsAt == null) {
      return;
    }

    _isFinishing = true;
    _stopSecondTimer();
    try {
      final totals = _calculateTotals(endsAt);
      await FocusSessionDao.finishTask(
        taskId: task.id,
        currentSegmentId: segment.id,
        endedAt: endsAt,
        actualDurationSeconds: _elapsedSeconds(segment.startedAt, endsAt),
      );

      _segments = _segments
          .map(
            (item) => item.id == segment.id
                ? (
                    id: item.id,
                    sessionType: item.sessionType,
                    startedAt: item.startedAt,
                    endedAt: endsAt,
                    actualDurationSeconds: _elapsedSeconds(
                      segment.startedAt,
                      endsAt,
                    ),
                  )
                : item,
          )
          .toList();
      _activeSegment = null;
      emit(
        FocusRestState(
          status: FocusRestStatus.completed,
          taskId: task.id,
          taskTitle: task.title,
          taskEndsAt: endsAt,
          currentMode: segment.sessionType == 'study'
              ? FocusMode.study
              : FocusMode.relax,
          remaining: Duration.zero,
          plannedDuration: endsAt.difference(startsAt),
          studyDuration: totals.study,
          restDuration: totals.rest,
          summaryPending: true,
        ),
      );

      try {
        await TaskReminderNotifications.instance.cancelTask(task.id);
      } on Object catch (error, stackTrace) {
        addError(error, stackTrace);
        emit(state.copyWith(error: error));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      final totals = _calculateTotals(endsAt);
      emit(
        FocusRestState(
          status: FocusRestStatus.running,
          taskId: task.id,
          taskTitle: task.title,
          taskEndsAt: endsAt,
          currentMode: segment.sessionType == 'study'
              ? FocusMode.study
              : FocusMode.relax,
          remaining: Duration.zero,
          plannedDuration: endsAt.difference(startsAt),
          studyDuration: totals.study,
          restDuration: totals.rest,
          error: error,
        ),
      );
    } finally {
      _isFinishing = false;
    }
  }

  Future<void> _scheduleEndReminder(FocusTaskInfo task, DateTime endsAt) async {
    try {
      await TaskReminderNotifications.instance.scheduleTaskEnd(
        id: task.id,
        title: task.title,
        endsAt: endsAt,
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(error: error));
    }
  }

  void _startSecondTimer() {
    _secondTimer?.cancel();
    _secondTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _handleTick(DateTime.now()),
    );
  }

  void _stopSecondTimer() {
    _secondTimer?.cancel();
    _secondTimer = null;
  }

  void _clearSession() {
    _task = null;
    _segments = [];
    _activeSegment = null;
    _taskStartsAt = null;
    _taskEndsAt = null;
  }

  static DateTime _dateTime(String date, String time) =>
      DateTime.parse('${date}T$time:00');

  static int _elapsedSeconds(DateTime start, DateTime end) =>
      math.max(0, end.difference(start).inSeconds).toInt();

  @override
  Future<void> close() async {
    _stopSecondTimer();
    await _tickerSubscription.cancel();
    await super.close();
  }
}
