import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

void main() {
  group('Recommendation', () {
    final tDate = DateTime(2024, 1, 1, 12);

    late Recommendation tRecommendation;

    setUp(() {
      tRecommendation = Recommendation(
        id: 'rec123',
        movieId: 1,
        movieTitle: 'Test Movie',
        comment: 'Great movie!',
        tags: const ['action', 'fun'],
        createdAt: tDate,
      );
    });

    test('supports value equality', () {
      final other = Recommendation(
        id: 'rec123',
        movieId: 1,
        movieTitle: 'Test Movie',
        comment: 'Great movie!',
        tags: const ['action', 'fun'],
        createdAt: tDate,
      );
      expect(tRecommendation, equals(other));
    });

    test('recommendations with different ids are not equal', () {
      final other = Recommendation(
        id: 'rec456',
        movieId: 1,
        movieTitle: 'Test Movie',
        comment: 'Great movie!',
        tags: const ['action', 'fun'],
        createdAt: tDate,
      );
      expect(tRecommendation, isNot(equals(other)));
    });

    test('recommendations with different comments are not equal', () {
      final other = Recommendation(
        id: 'rec123',
        movieId: 1,
        movieTitle: 'Test Movie',
        comment: 'Bad movie!',
        tags: const ['action', 'fun'],
        createdAt: tDate,
      );
      expect(tRecommendation, isNot(equals(other)));
    });

    test('recommendations with different dates are not equal', () {
      final other = Recommendation(
        id: 'rec123',
        movieId: 1,
        movieTitle: 'Test Movie',
        comment: 'Great movie!',
        tags: const ['action', 'fun'],
        createdAt: DateTime(2025, 6, 15),
      );
      expect(tRecommendation, isNot(equals(other)));
    });

    test('props contains all fields', () {
      expect(tRecommendation.props, [
        'rec123',
        1,
        'Test Movie',
        'Great movie!',
        ['action', 'fun'],
        tDate,
      ]);
    });

    test('fields are assigned correctly', () {
      expect(tRecommendation.id, equals('rec123'));
      expect(tRecommendation.movieId, equals(1));
      expect(tRecommendation.movieTitle, equals('Test Movie'));
      expect(tRecommendation.comment, equals('Great movie!'));
      expect(tRecommendation.tags, equals(['action', 'fun']));
      expect(tRecommendation.createdAt, equals(tDate));
    });
  });
}
