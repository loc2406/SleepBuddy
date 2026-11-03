import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/router/app_router.dart';
import 'package:sleep_buddy/core/theme/app_theme.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_cubit.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_state.dart';

Future<void> main() async {
  await SharedPref.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => OverviewCubit())],
      child: BlocBuilder<OverviewCubit, OverviewState>(
        builder: (context, state) => MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.isNightMode ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
  }
}
