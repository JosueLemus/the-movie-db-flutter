import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/core/services/remote_config_service.dart';
import 'package:the_movie_db/features/splash/data/repositories/splash_repository_impl.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  late MockRemoteConfigService mockService;
  late SplashRepositoryImpl repository;

  setUp(() {
    mockService = MockRemoteConfigService();
    repository = SplashRepositoryImpl(mockService);
  });

  group('SplashRepositoryImpl', () {
    test('initializeRemoteConfig delegates to service', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});

      await repository.initializeRemoteConfig();

      verify(() => mockService.initialize()).called(1);
    });

    test('welcomeMessage returns service value', () {
      when(() => mockService.welcomeMessage).thenReturn('Welcome!');

      expect(repository.welcomeMessage, equals('Welcome!'));
    });

    test('isMaintenanceMode returns service value', () {
      when(() => mockService.maintenanceMode).thenReturn(true);

      expect(repository.isMaintenanceMode, isTrue);
    });
  });
}
