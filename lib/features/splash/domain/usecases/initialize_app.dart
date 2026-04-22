import 'package:the_movie_db/features/splash/domain/repositories/splash_repository.dart';

// SRP: single responsibility — orchestrate app initialization on launch
class InitializeApp {
  const InitializeApp(this._repository);

  final SplashRepository _repository;

  Future<({String welcomeMessage, bool isMaintenanceMode})> call() async {
    await _repository.initializeRemoteConfig();
    return (
      welcomeMessage: _repository.welcomeMessage,
      isMaintenanceMode: _repository.isMaintenanceMode,
    );
  }
}
