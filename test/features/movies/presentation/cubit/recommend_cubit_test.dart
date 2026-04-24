import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';
import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/add_recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_recommendations.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_cubit.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_state.dart';

class MockRecommendationRepository extends Mock
    implements RecommendationRepository {}

void main() {
  late MockRecommendationRepository mockRepository;
  late GetRecommendations getRecommendations;
  late AddRecommendation addRecommendation;

  final tDate = DateTime(2024);
  final tRecommendations = [
    Recommendation(
      id: 'rec1',
      movieId: 550,
      movieTitle: 'Fight Club',
      comment: 'Great!',
      tags: const ['drama'],
      createdAt: tDate,
    ),
  ];

  setUp(() {
    mockRepository = MockRecommendationRepository();
    getRecommendations = GetRecommendations(mockRepository);
    addRecommendation = AddRecommendation(mockRepository);
  });

  RecommendCubit buildCubit() => RecommendCubit(
    getRecommendations: getRecommendations,
    addRecommendation: addRecommendation,
  );

  group('RecommendCubit', () {
    test('initial state has initial status and empty recommendations', () {
      final cubit = buildCubit();
      expect(cubit.state.status, equals(RecommendStatus.initial));
      expect(cubit.state.recommendations, isEmpty);
      expect(cubit.state.error, isNull);
    });

    test('initial state isLoading returns false', () {
      expect(buildCubit().state.isLoading, isFalse);
    });

    test('initial state isSubmitting returns false', () {
      expect(buildCubit().state.isSubmitting, isFalse);
    });

    blocTest<RecommendCubit, RecommendState>(
      'load emits loading then loaded on success',
      build: () {
        when(
          () => mockRepository.getRecommendations(any()),
        ).thenAnswer((_) async => tRecommendations);
        return buildCubit();
      },
      act: (cubit) => cubit.load(550),
      expect: () => [
        const RecommendState(status: RecommendStatus.loading),
        RecommendState(
          status: RecommendStatus.loaded,
          recommendations: tRecommendations,
        ),
      ],
    );

    blocTest<RecommendCubit, RecommendState>(
      'load emits loading then error on exception',
      build: () {
        when(
          () => mockRepository.getRecommendations(any()),
        ).thenThrow(Exception('Firestore error'));
        return buildCubit();
      },
      act: (cubit) => cubit.load(550),
      expect: () => [
        const RecommendState(status: RecommendStatus.loading),
        isA<RecommendState>().having(
          (s) => s.status,
          'status',
          RecommendStatus.error,
        ),
      ],
    );

    blocTest<RecommendCubit, RecommendState>(
      'submit does nothing when comment is empty and tags are empty',
      build: buildCubit,
      act: (cubit) => cubit.submit(
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: '   ',
        tags: [],
      ),
      expect: () => <RecommendState>[],
    );

    blocTest<RecommendCubit, RecommendState>(
      'submit emits submitting then submitted on success',
      build: () {
        when(
          () => mockRepository.addRecommendation(
            movieId: any(named: 'movieId'),
            movieTitle: any(named: 'movieTitle'),
            comment: any(named: 'comment'),
            tags: any(named: 'tags'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getRecommendations(any()),
        ).thenAnswer((_) async => tRecommendations);
        return buildCubit();
      },
      act: (cubit) => cubit.submit(
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Great movie!',
        tags: ['drama'],
      ),
      expect: () => [
        const RecommendState(status: RecommendStatus.submitting),
        RecommendState(
          status: RecommendStatus.submitted,
          recommendations: tRecommendations,
        ),
      ],
    );

    blocTest<RecommendCubit, RecommendState>(
      'submit emits submitting then error on exception',
      build: () {
        when(
          () => mockRepository.addRecommendation(
            movieId: any(named: 'movieId'),
            movieTitle: any(named: 'movieTitle'),
            comment: any(named: 'comment'),
            tags: any(named: 'tags'),
          ),
        ).thenThrow(Exception('Firestore error'));
        return buildCubit();
      },
      act: (cubit) => cubit.submit(
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Great movie!',
        tags: [],
      ),
      expect: () => [
        const RecommendState(status: RecommendStatus.submitting),
        isA<RecommendState>().having(
          (s) => s.status,
          'status',
          RecommendStatus.error,
        ),
      ],
    );

    blocTest<RecommendCubit, RecommendState>(
      'submit with non-empty tags but empty comment still submits',
      build: () {
        when(
          () => mockRepository.addRecommendation(
            movieId: any(named: 'movieId'),
            movieTitle: any(named: 'movieTitle'),
            comment: any(named: 'comment'),
            tags: any(named: 'tags'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getRecommendations(any()),
        ).thenAnswer((_) async => []);
        return buildCubit();
      },
      act: (cubit) => cubit.submit(
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: '',
        tags: ['action'],
      ),
      expect: () => [
        const RecommendState(status: RecommendStatus.submitting),
        const RecommendState(status: RecommendStatus.submitted),
      ],
    );
  });

  group('RecommendState', () {
    test('isLoading returns true when status is loading', () {
      const state = RecommendState(status: RecommendStatus.loading);
      expect(state.isLoading, isTrue);
    });

    test('isSubmitting returns true when status is submitting', () {
      const state = RecommendState(status: RecommendStatus.submitting);
      expect(state.isSubmitting, isTrue);
    });

    test('copyWith updates status', () {
      const state = RecommendState();
      final updated = state.copyWith(status: RecommendStatus.loaded);
      expect(updated.status, equals(RecommendStatus.loaded));
    });

    test('copyWith updates recommendations', () {
      const state = RecommendState();
      final updated = state.copyWith(recommendations: tRecommendations);
      expect(updated.recommendations, equals(tRecommendations));
    });

    test('copyWith updates error', () {
      const state = RecommendState();
      final updated = state.copyWith(error: 'Some error');
      expect(updated.error, equals('Some error'));
    });

    test('supports value equality', () {
      expect(const RecommendState(), equals(const RecommendState()));
    });
  });
}
