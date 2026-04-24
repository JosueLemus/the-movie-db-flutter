import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/add_recommendation.dart';

class MockRecommendationRepository extends Mock
    implements RecommendationRepository {}

void main() {
  late MockRecommendationRepository mockRepository;
  late AddRecommendation useCase;

  setUp(() {
    mockRepository = MockRecommendationRepository();
    useCase = AddRecommendation(mockRepository);
  });

  group('AddRecommendation', () {
    test('calls repository addRecommendation with all params', () async {
      when(
        () => mockRepository.addRecommendation(
          movieId: any(named: 'movieId'),
          movieTitle: any(named: 'movieTitle'),
          comment: any(named: 'comment'),
          tags: any(named: 'tags'),
        ),
      ).thenAnswer((_) async {});

      await useCase(
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Great movie!',
        tags: ['drama', 'thriller'],
      );

      verify(
        () => mockRepository.addRecommendation(
          movieId: 550,
          movieTitle: 'Fight Club',
          comment: 'Great movie!',
          tags: ['drama', 'thriller'],
        ),
      ).called(1);
    });

    test('returns void on success', () async {
      when(
        () => mockRepository.addRecommendation(
          movieId: any(named: 'movieId'),
          movieTitle: any(named: 'movieTitle'),
          comment: any(named: 'comment'),
          tags: any(named: 'tags'),
        ),
      ).thenAnswer((_) async {});

      expect(
        useCase(
          movieId: 550,
          movieTitle: 'Fight Club',
          comment: 'Good',
          tags: [],
        ),
        completes,
      );
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.addRecommendation(
          movieId: any(named: 'movieId'),
          movieTitle: any(named: 'movieTitle'),
          comment: any(named: 'comment'),
          tags: any(named: 'tags'),
        ),
      ).thenThrow(Exception('Firestore error'));

      expect(
        () => useCase(
          movieId: 550,
          movieTitle: 'Fight Club',
          comment: 'Good',
          tags: [],
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
