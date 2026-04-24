import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/splash/domain/repositories/splash_repository.dart';
import 'package:the_movie_db/features/splash/domain/usecases/initialize_app.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository mockRepository;
  late InitializeApp useCase;

  setUp(() {
    mockRepository = MockSplashRepository();
    useCase = InitializeApp(mockRepository);
  });

  group('InitializeApp', () {
    test(
      'calls initializeRemoteConfig and returns welcome/maintenance values',
      () async {
        when(
          () => mockRepository.initializeRemoteConfig(),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.welcomeMessage,
        ).thenReturn('Welcome to MovieDB!');
        when(() => mockRepository.isMaintenanceMode).thenReturn(false);

        final result = await useCase();

        verify(() => mockRepository.initializeRemoteConfig()).called(1);
        expect(result.welcomeMessage, equals('Welcome to MovieDB!'));
        expect(result.isMaintenanceMode, isFalse);
      },
    );

    test('returns isMaintenanceMode=true when under maintenance', () async {
      when(
        () => mockRepository.initializeRemoteConfig(),
      ).thenAnswer((_) async {});
      when(() => mockRepository.welcomeMessage).thenReturn('');
      when(() => mockRepository.isMaintenanceMode).thenReturn(true);

      final result = await useCase();

      expect(result.isMaintenanceMode, isTrue);
    });

    test('returns welcomeMessage from repository', () async {
      const tMessage = 'Hello, movie fan!';
      when(
        () => mockRepository.initializeRemoteConfig(),
      ).thenAnswer((_) async {});
      when(() => mockRepository.welcomeMessage).thenReturn(tMessage);
      when(() => mockRepository.isMaintenanceMode).thenReturn(false);

      final result = await useCase();

      expect(result.welcomeMessage, equals(tMessage));
    });

    test('propagates exception when initializeRemoteConfig throws', () async {
      when(
        () => mockRepository.initializeRemoteConfig(),
      ).thenThrow(Exception('Remote config error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
