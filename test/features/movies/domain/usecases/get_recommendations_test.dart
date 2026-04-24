import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';
import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_recommendations.dart';

class MockRecommendationRepository extends Mock
    implements RecommendationRepository {}

void main() {
  late MockRecommendationRepository mockRepository;
  late GetRecommendations useCase;

  final tDate = DateTime(2024);
  final tRecommendations = [
    Recommendation(
      id: 'rec1',
      movieId: 550,
      movieTitle: 'Fight Club',
      comment: 'Great movie!',
      tags: const ['drama'],
      createdAt: tDate,
    ),
    Recommendation(
      id: 'rec2',
      movieId: 550,
      movieTitle: 'Fight Club',
      comment: 'Loved it',
      tags: const ['thriller'],
      createdAt: tDate,
    ),
  ];

  setUp(() {
    mockRepository = MockRecommendationRepository();
    useCase = GetRecommendations(mockRepository);
  });

  group('GetRecommendations', () {
    test('calls repository getRecommendations with correct movieId', () async {
      when(
        () => mockRepository.getRecommendations(any()),
      ).thenAnswer((_) async => tRecommendations);

      await useCase(550);

      verify(() => mockRepository.getRecommendations(550)).called(1);
    });

    test('returns list of recommendations from repository', () async {
      when(
        () => mockRepository.getRecommendations(any()),
      ).thenAnswer((_) async => tRecommendations);

      final result = await useCase(550);

      expect(result, equals(tRecommendations));
      expect(result.length, equals(2));
    });

    test('returns empty list when no recommendations exist', () async {
      when(
        () => mockRepository.getRecommendations(any()),
      ).thenAnswer((_) async => []);

      final result = await useCase(550);

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.getRecommendations(any()),
      ).thenThrow(Exception('Firestore error'));

      expect(() => useCase(550), throwsA(isA<Exception>()));
    });
  });
}
