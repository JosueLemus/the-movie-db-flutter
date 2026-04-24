import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_movie_db/core/services/remote_config_service.dart';

// FirebaseRemoteConfig is a sealed class and cannot be mocked directly with
// mocktail. We use a hand-written fake instead.
class FakeFirebaseRemoteConfig extends Fake implements FirebaseRemoteConfig {
  FakeFirebaseRemoteConfig(this._values);

  final Map<String, dynamic> _values;

  @override
  String getString(String key) => _values[key] as String? ?? '';

  @override
  bool getBool(String key) => _values[key] as bool? ?? false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteConfigService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('welcomeMessage returns prefs value when available', () async {
      SharedPreferences.setMockInitialValues({
        'welcome_message': 'Hello from prefs!',
      });

      final prefs = await SharedPreferences.getInstance();
      final remoteConfig = FakeFirebaseRemoteConfig({
        'welcome_message': 'Hello from remote',
      });
      final service = RemoteConfigService(remoteConfig, prefs);

      expect(service.welcomeMessage, equals('Hello from prefs!'));
    });

    test(
      'welcomeMessage falls back to remote config when prefs has no value',
      () async {
        // Empty prefs
        SharedPreferences.setMockInitialValues({});

        final prefs = await SharedPreferences.getInstance();
        final remoteConfig = FakeFirebaseRemoteConfig({
          'welcome_message': 'Hello from remote',
        });
        final service = RemoteConfigService(remoteConfig, prefs);

        expect(service.welcomeMessage, equals('Hello from remote'));
      },
    );

    test('maintenanceMode returns prefs value when available', () async {
      SharedPreferences.setMockInitialValues({'maintenance_mode': true});

      final prefs = await SharedPreferences.getInstance();
      final remoteConfig = FakeFirebaseRemoteConfig({
        'maintenance_mode': false,
      });
      final service = RemoteConfigService(remoteConfig, prefs);

      expect(service.maintenanceMode, isTrue);
    });

    test(
      'maintenanceMode falls back to remote config when prefs has no value',
      () async {
        SharedPreferences.setMockInitialValues({});

        final prefs = await SharedPreferences.getInstance();
        final remoteConfig = FakeFirebaseRemoteConfig({
          'maintenance_mode': true,
        });
        final service = RemoteConfigService(remoteConfig, prefs);

        expect(service.maintenanceMode, isTrue);
      },
    );

    test('appConfig parses JSON from prefs', () async {
      SharedPreferences.setMockInitialValues({
        'app_config': '{"feature_x": true, "max_items": 10}',
      });

      final prefs = await SharedPreferences.getInstance();
      final remoteConfig = FakeFirebaseRemoteConfig({'app_config': '{}'});
      final service = RemoteConfigService(remoteConfig, prefs);

      final config = service.appConfig;

      expect(config['feature_x'], isTrue);
      expect(config['max_items'], equals(10));
    });

    test('appConfig returns empty map when prefs has no value', () async {
      SharedPreferences.setMockInitialValues({});

      final prefs = await SharedPreferences.getInstance();
      final remoteConfig = FakeFirebaseRemoteConfig({'app_config': '{}'});
      final service = RemoteConfigService(remoteConfig, prefs);

      expect(service.appConfig, isEmpty);
    });
  });
}
