import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/data/datasources/recommendation_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/models/recommendation_model.dart';
import 'package:the_movie_db/features/movies/data/repositories/recommendation_repository_impl.dart';

class MockRecommendationRemoteDataSource extends Mock
    implements RecommendationRemoteDataSource {}

void main() {
  late MockRecommendationRemoteDataSource mockRemote;
  late RecommendationRepositoryImpl repository;

  final fakeModel = RecommendationModel(
    id: '1',
    movieId: 42,
    movieTitle: 'Inception',
    comment: 'Great',
    tags: const ['Must Watch'],
    createdAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(fakeModel);
  });

  setUp(() {
    mockRemote = MockRecommendationRemoteDataSource();
    repository = RecommendationRepositoryImpl(mockRemote);
  });

  group('RecommendationRepositoryImpl', () {
    test('getRecommendations delegates to remote', () async {
      when(
        () => mockRemote.getRecommendations(42),
      ).thenAnswer((_) async => [fakeModel]);

      final result = await repository.getRecommendations(42);

      expect(result, equals([fakeModel]));
      verify(() => mockRemote.getRecommendations(42)).called(1);
    });

    test(
      'addRecommendation delegates to remote with a RecommendationModel',
      () async {
        when(
          () => mockRemote.addRecommendation(any(), any()),
        ).thenAnswer((_) async {});

        await repository.addRecommendation(
          movieId: 42,
          movieTitle: 'Inception',
          comment: 'Great film',
          tags: ['Must Watch'],
        );

        verify(
          () => mockRemote.addRecommendation(
            42,
            any(
              that: isA<RecommendationModel>()
                  .having((m) => m.movieId, 'movieId', 42)
                  .having((m) => m.movieTitle, 'movieTitle', 'Inception')
                  .having((m) => m.comment, 'comment', 'Great film')
                  .having((m) => m.tags, 'tags', ['Must Watch']),
            ),
          ),
        ).called(1);
      },
    );
  });
}
