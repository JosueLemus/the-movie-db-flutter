import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/router/app_router.dart';
import 'package:the_movie_db/features/splash/domain/usecases/initialize_app.dart';
import 'package:the_movie_db/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:the_movie_db/features/splash/presentation/cubit/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = SplashCubit(sl<InitializeApp>());
        unawaited(cubit.initialize());
        return cubit;
      },
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashReady) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie, color: Colors.white, size: 80),
              const SizedBox(height: 24),
              Text(
                'The Movie DB',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              BlocBuilder<SplashCubit, SplashState>(
                builder: (context, state) {
                  if (state is SplashMaintenanceMode) {
                    return const _MaintenanceBanner();
                  }
                  return const CircularProgressIndicator(color: Colors.white);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceBanner extends StatelessWidget {
  const _MaintenanceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'App under maintenance.\nPlease try again later.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
