import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/cubit/minute_ticker_cubit.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';
import 'package:sleep_buddy/core/db/demo_data_dao.dart';
import 'package:sleep_buddy/core/router/app_router.dart';
import 'package:sleep_buddy/core/theme/app_theme.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/features/analytics/cubit/library_cubit.dart';
import 'package:sleep_buddy/features/overview/cubit/overview_cubit.dart';
import 'package:sleep_buddy/features/analytics/cubit/analytics_cubit.dart';
import 'package:sleep_buddy/features/analytics/cubit/setting_state.dart';
import 'package:sleep_buddy/features/analytics/cubit/settting_cubit.dart';
import 'package:sleep_buddy/features/study_plan/cubit/add_new_study_plan_cubit.dart';
import 'package:sleep_buddy/features/study_plan/cubit/study_planner_cubit.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_cubit.dart';
import 'package:sleep_buddy/features/sleep/cubit/sleep_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrap();
  runApp(const MyApp());
}

/// Khởi tạo các dịch vụ nền trước khi hiển thị giao diện.
///
/// Mỗi bước được bọc riêng để một lỗi cục bộ (múi giờ lạ, dữ liệu cũ, quyền
/// thông báo bị từ chối...) không chặn `runApp`, tránh trường hợp bản release
/// chỉ hiện splash rồi tự tắt trên một số thiết bị.
Future<void> _bootstrap() async {
  await _runStartupStep('preferences', SharedPref.init);
  await _runStartupStep('database', () => AppDatabase.instance.database);
  await _runStartupStep('guide articles', GuideArticleDao.seedIfEmpty);
  await _runStartupStep(
    'demo data',
    () => DemoDataDao.applyMode(DemoDataMode.populated),
  );

  final notificationsReady = await _runStartupStep(
    'notifications',
    () => TaskReminderNotifications.instance.initialize(
      onStartTask: (taskId) async {
        appRouter.go('/?tab=2&taskId=$taskId');
      },
      onOpenFocusTask: (taskId) async {
        appRouter.go('/?tab=2&taskId=$taskId');
      },
      onOpenPlanner: () => appRouter.go('/?tab=1'),
      onOpenSleep: () => appRouter.go('/?tab=3'),
      onTaskStartRejected: () => appRouter.go('/?tab=1&startRejected=true'),
    ),
  );
  if (!notificationsReady) return;

  await _runStartupStep(
    'notification launch details',
    TaskReminderNotifications.instance.handleLaunchDetails,
  );
  await _runStartupStep(
    'notification schedule',
    TaskReminderNotifications.instance.syncScheduledReminders,
  );
}

Future<bool> _runStartupStep(String name, Future<void> Function() step) async {
  try {
    await step();
    return true;
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'sleep_buddy startup',
        context: ErrorDescription('while initializing $name'),
      ),
    );
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MinuteTickerCubit(), lazy: false),
        BlocProvider(
          create: (context) =>
              OverviewCubit(minuteTicker: context.read<MinuteTickerCubit>()),
        ),
        BlocProvider(create: (_) => AddNewStudyPlanCubit()),
        BlocProvider(create: (_) => StudyPlannerCubit(), lazy: false),
        BlocProvider(
          create: (context) =>
              FocusRestCubit(minuteTicker: context.read<MinuteTickerCubit>()),
          lazy: false,
        ),
        BlocProvider(create: (_) => SleepCubit(), lazy: false),
        BlocProvider(create: (_) => AnalyticsCubit()),
        BlocProvider(create: (_) => SettingCubit()),
        BlocProvider(create: (_) => LibraryCubit()),
      ],
      child: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) => MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.themeMode,
        ),
      ),
    );
  }
}
