// ISP: only exposes what the splash feature needs from remote config
abstract interface class SplashRepository {
  Future<void> initializeRemoteConfig();
  String get welcomeMessage;
  bool get isMaintenanceMode;
}
