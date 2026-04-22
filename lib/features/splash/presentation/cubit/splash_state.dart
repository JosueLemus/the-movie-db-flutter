import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashReady extends SplashState {
  const SplashReady({required this.welcomeMessage});

  final String welcomeMessage;

  @override
  List<Object?> get props => [welcomeMessage];
}

final class SplashMaintenanceMode extends SplashState {
  const SplashMaintenanceMode();
}
