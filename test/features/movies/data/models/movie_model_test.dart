import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

void main() {
  group('MovieModel', () {
    final tJson = <String, dynamic>{
      'id': 550,
      'title': 'Fight Club',
      'overview': 'A ticking-time-bomb insomniac...',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'backdrop_path': '/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg',
      'vote_average': 8.438,
      'release_date': '1999-10-15',
    };

    test('fromJson parses all fields correctly', () {
      final model = MovieModel.fromJson(tJson);
      expect(model.id, equals(550));
      expect(model.title, equals('Fight Club'));
      expect(model.overview, equals('A ticking-time-bomb insomniac...'));
      expect(model.posterPath, equals('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(model.backdropPath, equals('/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg'));
      expect(model.voteAverage, closeTo(8.438, 0.001));
      expect(model.releaseDate, equals('1999-10-15'));
      expect(model.isFavorite, isFalse);
    });

    test('fromJson uses empty string defaults for nullable string fields', () {
      final model = MovieModel.fromJson(const {'id': 1});
      expect(model.title, equals(''));
      expect(model.overview, equals(''));
      expect(model.posterPath, equals(''));
      expect(model.backdropPath, equals(''));
      expect(model.voteAverage, equals(0.0));
      expect(model.releaseDate, equals(''));
    });

    test('fromJson handles integer vote_average', () {
      final json = <String, dynamic>{...tJson, 'vote_average': 8};
      final model = MovieModel.fromJson(json);
      expect(model.voteAverage, equals(8.0));
    });

    test('fromCacheJson parses all fields including isFavorite', () {
      final cacheJson = <String, dynamic>{
        'id': 550,
        'title': 'Fight Club',
        'overview': 'A ticking-time-bomb insomniac...',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 8.4,
        'release_date': '1999-10-15',
        'is_favorite': true,
      };
      final model = MovieModel.fromCacheJson(cacheJson);
      expect(model.id, equals(550));
      expect(model.isFavorite, isTrue);
    });

    test('fromCacheJson defaults isFavorite to false when missing', () {
      final cacheJson = <String, dynamic>{
        'id': 550,
        'title': 'Fight Club',
        'overview': 'Overview',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 8.4,
        'release_date': '1999-10-15',
      };
      final model = MovieModel.fromCacheJson(cacheJson);
      expect(model.isFavorite, isFalse);
    });

    test('toCacheJson serializes all fields', () {
      final model = MovieModel.fromJson(tJson);
      final json = model.toCacheJson();
      expect(json['id'], equals(550));
      expect(json['title'], equals('Fight Club'));
      expect(json['overview'], equals('A ticking-time-bomb insomniac...'));
      expect(json['poster_path'], equals('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(json['backdrop_path'], equals('/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg'));
      expect(json['vote_average'], closeTo(8.438, 0.001));
      expect(json['release_date'], equals('1999-10-15'));
      expect(json['is_favorite'], isFalse);
    });

    test('MovieModel is a Movie', () {
      final model = MovieModel.fromJson(tJson);
      expect(model, isA<Movie>());
    });

    test('MovieModel supports value equality via Equatable', () {
      final model1 = MovieModel.fromJson(tJson);
      final model2 = MovieModel.fromJson(tJson);
      expect(model1, equals(model2));
    });
  });
}
