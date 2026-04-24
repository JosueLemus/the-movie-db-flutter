import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/splash/domain/repositories/splash_repository.dart';
import 'package:the_movie_db/features/splash/domain/usecases/initialize_app.dart';
import 'package:the_movie_db/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:the_movie_db/features/splash/presentation/cubit/splash_state.dart';

class MockSplashRepository extends Mock implements SplashRepository {}

void main() {
  late MockSplashRepository mockRepository;
  late InitializeApp initializeApp;

  setUp(() {
    mockRepository = MockSplashRepository();
    initializeApp = InitializeApp(mockRepository);
  });

  SplashCubit buildCubit() => SplashCubit(initializeApp);

  group('SplashCubit', () {
    test('initial state is SplashInitial', () {
      expect(buildCubit().state, isA<SplashInitial>());
    });

    blocTest<SplashCubit, SplashState>(
      'initialize emits SplashLoading then SplashReady when not in maintenance',
      build: () {
        when(
          () => mockRepository.initializeRemoteConfig(),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.welcomeMessage,
        ).thenReturn('Welcome to MovieDB!');
        when(() => mockRepository.isMaintenanceMode).thenReturn(false);
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<SplashLoading>(),
        isA<SplashReady>().having(
          (s) => s.welcomeMessage,
          'welcomeMessage',
          'Welcome to MovieDB!',
        ),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'initialize emits loading then maintenance when in maintenance mode',
      build: () {
        when(
          () => mockRepository.initializeRemoteConfig(),
        ).thenAnswer((_) async {});
        when(() => mockRepository.welcomeMessage).thenReturn('');
        when(() => mockRepository.isMaintenanceMode).thenReturn(true);
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<SplashLoading>(),
        isA<SplashMaintenanceMode>(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'initialize with empty welcome message still emits SplashReady',
      build: () {
        when(
          () => mockRepository.initializeRemoteConfig(),
        ).thenAnswer((_) async {});
        when(() => mockRepository.welcomeMessage).thenReturn('');
        when(() => mockRepository.isMaintenanceMode).thenReturn(false);
        return buildCubit();
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<SplashLoading>(),
        isA<SplashReady>().having(
          (s) => s.welcomeMessage,
          'welcomeMessage',
          '',
        ),
      ],
    );
  });

  group('SplashState', () {
    test('SplashInitial props are empty', () {
      expect(const SplashInitial().props, isEmpty);
    });

    test('SplashLoading props are empty', () {
      expect(const SplashLoading().props, isEmpty);
    });

    test('SplashMaintenanceMode props are empty', () {
      expect(const SplashMaintenanceMode().props, isEmpty);
    });

    test('SplashReady props contains welcomeMessage', () {
      const state = SplashReady(welcomeMessage: 'Hello!');
      expect(state.props, equals(['Hello!']));
    });

    test('two SplashReady with same message are equal', () {
      const s1 = SplashReady(welcomeMessage: 'Hello!');
      const s2 = SplashReady(welcomeMessage: 'Hello!');
      expect(s1, equals(s2));
    });

    test('two SplashReady with different messages are not equal', () {
      const s1 = SplashReady(welcomeMessage: 'Hello!');
      const s2 = SplashReady(welcomeMessage: 'Bye!');
      expect(s1, isNot(equals(s2)));
    });

    test('SplashInitial and SplashLoading are not equal', () {
      expect(
        const SplashInitial(),
        isNot(equals(const SplashLoading())),
      );
    });
  });
}
