import 'package:go_router/go_router.dart';

import '../ui/home/home_view.dart';
import '../ui/solved/solved_view.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomeView();
      },
      routes: [
        GoRoute(
          path: 'solved',
          builder: (context, state) {
            return const SolvedView();
          },
        ),
      ]
    ),

  ],
);
