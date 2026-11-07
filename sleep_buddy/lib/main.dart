import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';
import 'package:sleep_buddy/core/router/app_router.dart';
import 'package:sleep_buddy/core/theme/app_theme.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/features/analytics/presentation/cubit/library_cubit.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_cubit.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_state.dart';
import 'package:sleep_buddy/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:sleep_buddy/features/analytics/presentation/cubit/setting_state.dart';
import 'package:sleep_buddy/features/analytics/presentation/cubit/settting_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  await AppDatabase.instance.database;
  await GuideArticleDao.seedIfEmpty();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OverviewCubit()),
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
