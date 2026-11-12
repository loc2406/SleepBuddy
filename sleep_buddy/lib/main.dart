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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  await AppDatabase.instance.database;
  await GuideArticleDao.seedIfEmpty();
  await DemoDataDao.applyMode(DemoDataMode.populated);
  await TaskReminderNotifications.instance.initialize(
    onStartTask: (taskId) async {
      appRouter.go('/?tab=2&taskId=$taskId');
    },
    onOpenPlanner: () => appRouter.go('/?tab=1'),
  );
  await TaskReminderNotifications.instance.handleLaunchDetails();
  await TaskReminderNotifications.instance.syncScheduledReminders();
  runApp(const MyApp());
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
        BlocProvider(
          create: (context) => StudyPlannerCubit(
            minuteTicker: context.read<MinuteTickerCubit>(),
          ),
          lazy: false,
        ),
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
