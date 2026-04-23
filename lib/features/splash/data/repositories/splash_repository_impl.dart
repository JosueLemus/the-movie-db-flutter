import 'package:the_movie_db/core/services/remote_config_service.dart';
import 'package:the_movie_db/features/splash/domain/repositories/splash_repository.dart';

// DIP: implements the domain interface — domain knows nothing about Firebase
class SplashRepositoryImpl implements SplashRepository {
  const SplashRepositoryImpl(this._remoteConfigService);

  final RemoteConfigService _remoteConfigService;

  @override
  Future<void> initializeRemoteConfig() => _remoteConfigService.initialize();

  @override
  String get welcomeMessage => _remoteConfigService.welcomeMessage;

  @override
  bool get isMaintenanceMode => _remoteConfigService.maintenanceMode;
}
