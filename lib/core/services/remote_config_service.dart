import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SRP: owns the full lifecycle of Remote Config values — fetch, cache, read
class RemoteConfigService {
  RemoteConfigService(this._remoteConfig, this._prefs);

  final FirebaseRemoteConfig _remoteConfig;
  final SharedPreferences _prefs;

  static const _keyWelcomeMessage = 'welcome_message';
  static const _keyMaintenanceMode = 'maintenance_mode';
  static const _keyAppConfig = 'app_config';

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      _keyWelcomeMessage: 'Welcome to The Movie DB',
      _keyMaintenanceMode: false,
      _keyAppConfig: '{}',
    });

    try {
      await _remoteConfig.fetchAndActivate();
      await _persistToLocal();
    } on Exception {
      // Falls back to cached local values if fetch fails (offline scenario)
    }
  }

  Future<void> _persistToLocal() async {
    await _prefs.setString(_keyWelcomeMessage, welcomeMessage);
    await _prefs.setBool(_keyMaintenanceMode, maintenanceMode);
    await _prefs.setString(
      _keyAppConfig,
      _remoteConfig.getString(_keyAppConfig),
    );
  }

  String get welcomeMessage =>
      _prefs.getString(_keyWelcomeMessage) ??
      _remoteConfig.getString(_keyWelcomeMessage);

  bool get maintenanceMode =>
      _prefs.getBool(_keyMaintenanceMode) ??
      _remoteConfig.getBool(_keyMaintenanceMode);

  Map<String, dynamic> get appConfig {
    final raw = _prefs.getString(_keyAppConfig) ?? '{}';
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
