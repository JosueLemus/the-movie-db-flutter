import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/data/models/movie_detail_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';

void main() {
  group('MovieDetailModel', () {
    final tDetailJson = <String, dynamic>{
      'id': 550,
      'title': 'Fight Club',
      'overview': 'A ticking-time-bomb insomniac...',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
      'tagline': 'Mischief. Mayhem. Soap.',
      'runtime': 139,
      'genres': [
        {'id': 18, 'name': 'Drama'},
        {'id': 53, 'name': 'Thriller'},
      ],
      'images': {
        'backdrops': [
          {'file_path': '/img1.jpg'},
          {'file_path': '/img2.jpg'},
        ],
      },
    };

    final tCreditsJson = <dynamic>[
      {
        'id': 819,
        'name': 'Edward Norton',
        'character': 'The Narrator',
        'profile_path': '/profile1.jpg',
      },
      {
        'id': 287,
        'name': 'Brad Pitt',
        'character': 'Tyler Durden',
        'profile_path': '/profile2.jpg',
      },
    ];

    test('fromJson parses movie correctly', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.movie.id, equals(550));
      expect(model.movie.title, equals('Fight Club'));
    });

    test('fromJson parses tagline correctly', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.tagline, equals('Mischief. Mayhem. Soap.'));
    });

    test('fromJson parses runtime correctly', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.runtime, equals(139));
    });

    test('fromJson parses genre names correctly', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.genreNames, equals(['Drama', 'Thriller']));
    });

    test('fromJson parses cast correctly', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.cast.length, equals(2));
      expect(model.cast.first.name, equals('Edward Norton'));
      expect(model.cast.last.name, equals('Brad Pitt'));
    });

    test('fromJson includes backdrop_path in backdropPaths', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.backdropPaths, contains('/backdrop.jpg'));
    });

    test('fromJson includes images backdrops in backdropPaths', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model.backdropPaths, contains('/img1.jpg'));
      expect(model.backdropPaths, contains('/img2.jpg'));
    });

    test('fromJson uses empty tagline default when missing', () {
      final json = <String, dynamic>{...tDetailJson}..remove('tagline');
      final model = MovieDetailModel.fromJson(json, tCreditsJson);
      expect(model.tagline, equals(''));
    });

    test('fromJson uses zero runtime default when missing', () {
      final json = <String, dynamic>{...tDetailJson}..remove('runtime');
      final model = MovieDetailModel.fromJson(json, tCreditsJson);
      expect(model.runtime, equals(0));
    });

    test('fromJson falls back to movie backdropPath when no images', () {
      final json = <String, dynamic>{
        'id': 550,
        'title': 'Fight Club',
        'overview': 'Overview',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/only_backdrop.jpg',
        'vote_average': 8.0,
        'release_date': '1999-10-15',
        'tagline': '',
        'runtime': 139,
        'genres': <dynamic>[],
      };
      final model = MovieDetailModel.fromJson(json, const <dynamic>[]);
      expect(model.backdropPaths, equals(['/only_backdrop.jpg']));
    });

    test('fromJson with empty genres list returns empty genreNames', () {
      final json = <String, dynamic>{
        ...tDetailJson,
        'genres': <dynamic>[],
      };
      final model = MovieDetailModel.fromJson(json, tCreditsJson);
      expect(model.genreNames, isEmpty);
    });

    test('fromJson limits cast to 15 members', () {
      final manyCredits = List<dynamic>.generate(
        20,
        (i) => {
          'id': i,
          'name': 'Actor $i',
          'character': 'Character $i',
          'profile_path': '',
        },
      );
      final model = MovieDetailModel.fromJson(tDetailJson, manyCredits);
      expect(model.cast.length, equals(15));
    });

    test('is a MovieDetail entity', () {
      final model = MovieDetailModel.fromJson(tDetailJson, tCreditsJson);
      expect(model, isA<MovieDetail>());
    });
  });
}
