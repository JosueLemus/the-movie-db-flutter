import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/data/models/recommendation_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

void main() {
  group('RecommendationModel', () {
    final tDate = DateTime(2024, 1, 1, 12);
    final tTimestamp = Timestamp.fromDate(tDate);

    test('constructor assigns all fields correctly', () {
      final model = RecommendationModel(
        id: 'doc123',
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Amazing film!',
        tags: const ['drama', 'thriller'],
        createdAt: tDate,
      );
      expect(model.id, equals('doc123'));
      expect(model.movieId, equals(550));
      expect(model.movieTitle, equals('Fight Club'));
      expect(model.comment, equals('Amazing film!'));
      expect(model.tags, equals(const ['drama', 'thriller']));
      expect(model.createdAt, equals(tDate));
    });

    test('is a Recommendation entity', () {
      final model = RecommendationModel(
        id: 'doc123',
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Amazing film!',
        tags: const ['drama', 'thriller'],
        createdAt: tDate,
      );
      expect(model, isA<Recommendation>());
    });

    test('toJson serializes movieTitle, comment, tags and createdAt', () {
      final model = RecommendationModel(
        id: 'doc123',
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Amazing film!',
        tags: const ['drama', 'thriller'],
        createdAt: tDate,
      );
      final json = model.toJson();
      expect(json['movieTitle'], equals('Fight Club'));
      expect(json['comment'], equals('Amazing film!'));
      expect(json['tags'], equals(const ['drama', 'thriller']));
      expect(json['createdAt'], isA<Timestamp>());
      final ts = json['createdAt'] as Timestamp;
      expect(ts.toDate(), equals(tDate));
    });

    test('toJson does not include id or movieId', () {
      final model = RecommendationModel(
        id: 'doc123',
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Amazing film!',
        tags: const ['drama'],
        createdAt: tDate,
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('movieId'), isFalse);
    });

    test('supports value equality via Equatable', () {
      final model1 = RecommendationModel(
        id: 'doc123',
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Amazing film!',
        tags: const ['drama', 'thriller'],
        createdAt: tDate,
      );
      final model2 = RecommendationModel(
        id: 'doc123',
        movieId: 550,
        movieTitle: 'Fight Club',
        comment: 'Amazing film!',
        tags: const ['drama', 'thriller'],
        createdAt: tDate,
      );
      expect(model1, equals(model2));
    });

    // Keep tTimestamp referenced to avoid unused warning
    test('toJson createdAt round-trips through Timestamp', () {
      final model = RecommendationModel(
        id: 'x',
        movieId: 1,
        movieTitle: 'T',
        comment: 'C',
        tags: const [],
        createdAt: tDate,
      );
      final json = model.toJson();
      final ts = json['createdAt'] as Timestamp;
      expect(ts, equals(tTimestamp));
    });
  });
}
