import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_local_datasource.dart';
import 'package:the_movie_db/features/movies/data/models/cast_member_model.dart';
import 'package:the_movie_db/features/movies/data/models/genre_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_detail_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';

class MockStringBox extends Mock implements Box<String> {}

class MockBoolBox extends Mock implements Box<bool> {}

void main() {
  late MockStringBox mockBox;
  late MockBoolBox mockFavoritesBox;
  late MovieLocalDataSourceImpl dataSource;

  setUp(() {
    mockBox = MockStringBox();
    mockFavoritesBox = MockBoolBox();
    dataSource = MovieLocalDataSourceImpl(mockBox, mockFavoritesBox);
  });

  // ------------------------------------------------------------------ helpers
  const tGenreModel = GenreModel(id: 28, name: 'Action');
  const tGenreModels = [tGenreModel];

  const tMovieModel = MovieModel(
    id: 1,
    title: 'Die Hard',
    overview: 'Action classic.',
    posterPath: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.2,
    releaseDate: '1988-07-15',
  );
  const tMovieModels = [tMovieModel];

  const tDetail = MovieDetailModel(
    movie: tMovieModel,
    tagline: 'Yippee-ki-yay',
    runtime: 131,
    backdropPaths: ['/backdrop.jpg'],
    cast: [
      CastMemberModel(
        id: 10,
        name: 'Bruce Willis',
        character: 'John McClane',
        profilePath: '/bruce.jpg',
      ),
    ],
    genreNames: ['Action'],
  );

  // ---- cacheGenres / getCachedGenres
  group('cacheGenres', () {
    test('encodes genres to JSON and stores in box', () async {
      when(
        () => mockBox.put(any<Object?>(), any<String>()),
      ).thenAnswer((_) async {});

      await dataSource.cacheGenres(tGenreModels);

      final captured = verify(
        () => mockBox.put('genres', captureAny()),
      ).captured;
      final decoded = jsonDecode(captured.first as String) as List<dynamic>;
      expect(decoded.length, equals(1));
      expect((decoded.first as Map<String, dynamic>)['id'], equals(28));
    });
  });

  group('getCachedGenres', () {
    test('returns decoded genres when box has data', () {
      final encoded = jsonEncode([
        {'id': 28, 'name': 'Action'},
      ]);
      when(() => mockBox.get('genres')).thenReturn(encoded);

      final result = dataSource.getCachedGenres();

      expect(result.length, equals(1));
      expect(result.first.id, equals(28));
      expect(result.first.name, equals('Action'));
    });

    test('returns empty list when box has no data', () {
      when(() => mockBox.get('genres')).thenReturn(null);

      final result = dataSource.getCachedGenres();

      expect(result, isEmpty);
    });
  });

  // ---- cacheMoviesByGenre / getCachedMoviesByGenre
  group('cacheMoviesByGenre', () {
    test('encodes movies and stores with genre key', () async {
      when(
        () => mockBox.put(any<Object?>(), any<String>()),
      ).thenAnswer((_) async {});

      await dataSource.cacheMoviesByGenre(28, tMovieModels);

      final captured = verify(
        () => mockBox.put('movies_28', captureAny()),
      ).captured;
      final decoded = jsonDecode(captured.first as String) as List<dynamic>;
      expect(decoded.length, equals(1));
      expect((decoded.first as Map<String, dynamic>)['id'], equals(1));
    });
  });

  group('getCachedMoviesByGenre', () {
    test('returns decoded movies when box has data', () {
      final encoded = jsonEncode([tMovieModel.toCacheJson()]);
      when(() => mockBox.get('movies_28')).thenReturn(encoded);

      final result = dataSource.getCachedMoviesByGenre(28);

      expect(result.length, equals(1));
      expect(result.first.title, equals('Die Hard'));
    });

    test('returns empty list when box has no data', () {
      when(() => mockBox.get('movies_28')).thenReturn(null);

      final result = dataSource.getCachedMoviesByGenre(28);

      expect(result, isEmpty);
    });
  });

  // ---- cachePopularMovies / getCachedPopularMovies
  group('cachePopularMovies', () {
    test('encodes movies and stores with popular key', () async {
      when(
        () => mockBox.put(any<Object?>(), any<String>()),
      ).thenAnswer((_) async {});

      await dataSource.cachePopularMovies(tMovieModels);

      final captured = verify(
        () => mockBox.put('popular', captureAny()),
      ).captured;
      final decoded = jsonDecode(captured.first as String) as List<dynamic>;
      expect(decoded.length, equals(1));
    });
  });

  group('getCachedPopularMovies', () {
    test('returns decoded movies when box has data', () {
      final encoded = jsonEncode([tMovieModel.toCacheJson()]);
      when(() => mockBox.get('popular')).thenReturn(encoded);

      final result = dataSource.getCachedPopularMovies();

      expect(result.length, equals(1));
      expect(result.first.id, equals(1));
    });

    test('returns empty list when box has no data', () {
      when(() => mockBox.get('popular')).thenReturn(null);

      final result = dataSource.getCachedPopularMovies();

      expect(result, isEmpty);
    });
  });

  // ---- cacheMovieDetail / getCachedMovieDetail
  group('cacheMovieDetail', () {
    test('encodes detail and stores with detail key', () async {
      when(
        () => mockBox.put(any<Object?>(), any<String>()),
      ).thenAnswer((_) async {});

      await dataSource.cacheMovieDetail(tDetail);

      final captured = verify(
        () => mockBox.put('detail_1', captureAny()),
      ).captured;
      final decoded =
          jsonDecode(captured.first as String) as Map<String, dynamic>;
      expect((decoded['movie'] as Map<String, dynamic>)['id'], equals(1));
    });
  });

  group('getCachedMovieDetail', () {
    test('returns decoded detail when box has data', () {
      final encoded = jsonEncode(tDetail.toJson());
      when(() => mockBox.get('detail_1')).thenReturn(encoded);

      final result = dataSource.getCachedMovieDetail(1);

      expect(result, isNotNull);
      expect(result!.movie.id, equals(1));
      expect(result.tagline, equals('Yippee-ki-yay'));
    });

    test('returns null when box has no data', () {
      when(() => mockBox.get('detail_1')).thenReturn(null);

      final result = dataSource.getCachedMovieDetail(1);

      expect(result, isNull);
    });
  });

  // ---- toggleFavorite
  group('toggleFavorite', () {
    test('deletes key when movie is already a favorite', () async {
      when(() => mockFavoritesBox.get('1')).thenReturn(true);
      when(
        () => mockFavoritesBox.delete(any<Object?>()),
      ).thenAnswer((_) async {});

      await dataSource.toggleFavorite(tMovieModel);

      verify(() => mockFavoritesBox.delete('1')).called(1);
    });

    test('puts true when movie is not yet a favorite', () async {
      when(() => mockFavoritesBox.get('1')).thenReturn(null);
      when(
        () => mockFavoritesBox.put(any<Object?>(), any<bool>()),
      ).thenAnswer((_) async {});

      await dataSource.toggleFavorite(tMovieModel);

      verify(() => mockFavoritesBox.put('1', true)).called(1);
    });
  });

  // ---- isFavorite
  group('isFavorite', () {
    test('returns true when favorites box has true for id', () {
      when(() => mockFavoritesBox.get('1')).thenReturn(true);

      expect(dataSource.isFavorite(1), isTrue);
    });

    test('returns false when favorites box has no entry', () {
      when(() => mockFavoritesBox.get('2')).thenReturn(null);

      expect(dataSource.isFavorite(2), isFalse);
    });
  });
}
