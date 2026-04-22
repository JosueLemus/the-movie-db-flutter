import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_movie_db/features/splash/presentation/pages/splash_page.dart';

// OCP: add routes without touching existing ones
abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const movieDetail = '/movie/:id';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const Placeholder(),
    ),
    GoRoute(
      path: AppRoutes.movieDetail,
      builder: (context, state) {
        final movieId = int.parse(state.pathParameters['id']!);
        return Placeholder(key: ValueKey(movieId));
      },
    ),
  ],
);
