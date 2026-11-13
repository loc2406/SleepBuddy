import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/cubit/minute_ticker_cubit.dart';
import 'package:sleep_buddy/core/db/dashboard_dao.dart';
import 'package:sleep_buddy/core/db/report_dao.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/overview/cubit/overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit({required MinuteTickerCubit minuteTicker})
    : super(_initialState()) {
    _tickSubscription = minuteTicker.stream.listen(_updateClock);
  }

  late final StreamSubscription<DateTime> _tickSubscription;
  int _chartRequestToken = 0;

  static OverviewState _initialState() {
    final now = DateTime.now();
    return OverviewState(
      currentTime: now,
      timeUntilEndOfDay: _timeUntilEndOfDay(now),
    );
  }

  Future<void> loadData() async {
    _chartRequestToken++;
    emit(
      state.copyWith(
        isLoading: true,
        clearLoadError: true,
        isChartLoading: false,
        clearChartError: true,
      ),
    );

    final now = DateTime.now();
    try {
      final durations = await DashboardDao.getStudyAndBreakDuration(now);
      final nextTask = await DashboardDao.getNextTask(now);
      final taskProgress = await StudyTaskDao.getTaskProgressByDate(now);
      final subjectMinutes = await DashboardDao.getStudyMinutesBySubject(
        now.subtract(const Duration(days: 1)),
        now,
      );
      if (isClosed) return;
      final studyMinutes = durations['focus_minutes'] ?? 0;
      final restMinutes = durations['break_minutes'] ?? 0;

      emit(
        OverviewState(
          isLoading: false,
          studyMinutes: studyMinutes,
          restMinutes: restMinutes,
          chartStudyMinutes: studyMinutes,
          chartRestMinutes: restMinutes,
          completedTasks: taskProgress.completed,
          totalTasks: taskProgress.total,
          nextTask: nextTask,
          subjectMinutes: subjectMinutes,
          currentTime: now,
          timeUntilEndOfDay: _timeUntilEndOfDay(now),
        ),
      );
    } on Exception catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(state.copyWith(isLoading: false, loadError: error));
    }
  }

  Future<void> selectChartPeriod(OverviewChartPeriod period) async {
    if (period == state.chartPeriod || state.isChartLoading) return;

    final requestToken = ++_chartRequestToken;
    emit(state.copyWith(isChartLoading: true, clearChartError: true));

    try {
      final totals = await _loadChartTotals(period, DateTime.now());
      if (isClosed || requestToken != _chartRequestToken) return;
      emit(
        state.copyWith(
          chartPeriod: period,
          chartStudyMinutes: totals.studyMinutes,
          chartRestMinutes: totals.restMinutes,
          isChartLoading: false,
        ),
      );
    } on Exception catch (error, stackTrace) {
      if (isClosed || requestToken != _chartRequestToken) return;
      addError(error, stackTrace);
      emit(state.copyWith(isChartLoading: false, chartError: error));
    }
  }

  Future<({int studyMinutes, int restMinutes})> _loadChartTotals(
    OverviewChartPeriod period,
    DateTime now,
  ) async {
    final reportPeriod = switch (period) {
      OverviewChartPeriod.today => null,
      OverviewChartPeriod.yesterday => ReportPeriod.day,
      OverviewChartPeriod.week => ReportPeriod.week,
      OverviewChartPeriod.month => ReportPeriod.month,
    };

    if (reportPeriod == null) {
      final durations = await DashboardDao.getStudyAndBreakDuration(now);
      return (
        studyMinutes: durations['focus_minutes'] ?? 0,
        restMinutes: durations['break_minutes'] ?? 0,
      );
    }

    final reportDate = period == OverviewChartPeriod.yesterday
        ? DateTime(now.year, now.month, now.day - 1)
        : now;
    final report = await ReportDao.getReport(reportPeriod, reportDate);
    return (
      studyMinutes: report.studyTime.inMinutes,
      restMinutes: report.restTime.inMinutes,
    );
  }

  void clearChartError() {
    if (state.chartError != null) {
      emit(state.copyWith(clearChartError: true));
    }
  }

  void _updateClock(DateTime now) {
    final dayChanged =
        now.year != state.currentTime.year ||
        now.month != state.currentTime.month ||
        now.day != state.currentTime.day;

    emit(
      state.copyWith(
        currentTime: now,
        timeUntilEndOfDay: _timeUntilEndOfDay(now),
      ),
    );
    if (dayChanged) unawaited(loadData());
  }

  static Duration _timeUntilEndOfDay(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1).difference(now);

  @override
  Future<void> close() async {
    await _tickSubscription.cancel();
    await super.close();
  }
}
