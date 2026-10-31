import 'package:go_router/go_router.dart';
import 'package:sleep_buddy/features/home_screen.dart';
import 'package:sleep_buddy/features/overview/presentation/screens/overview_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
  ],
);