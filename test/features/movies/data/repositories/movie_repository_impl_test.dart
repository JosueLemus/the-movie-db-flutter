import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_local_datasource.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/models/cast_member_model.dart';
import 'package:the_movie_db/features/movies/data/models/genre_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_detail_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';
import 'package:the_movie_db/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

class FakeMovieModel extends Fake implements MovieModel {}

class FakeMovieDetailModel extends Fake implements MovieDetailModel {}

void main() {
  late MockMovieRemoteDataSource mockRemote;
  late MockMovieLocalDataSource mockLocal;
  late MovieRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeMovieModel());
    registerFallbackValue(FakeMovieDetailModel());
  });

  setUp(() {
    mockRemote = MockMovieRemoteDataSource();
    mockLocal = MockMovieLocalDataSource();
    repository = MovieRepositoryImpl(mockRemote, mockLocal);
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

  // ---- getGenres
  group('getGenres', () {
    test('returns genres from remote and caches them on success', () async {
      when(() => mockRemote.getGenres()).thenAnswer((_) async => tGenreModels);
      when(() => mockLocal.cacheGenres(tGenreModels)).thenAnswer((_) async {});

      final result = await repository.getGenres();

      expect(result, equals(tGenreModels));
      verify(() => mockLocal.cacheGenres(tGenreModels)).called(1);
    });

    test(
      'falls back to cache when remote throws and cache is non-empty',
      () async {
        when(
          () => mockRemote.getGenres(),
        ).thenThrow(Exception('network error'));
        when(() => mockLocal.getCachedGenres()).thenReturn(tGenreModels);

        final result = await repository.getGenres();

        expect(result, equals(tGenreModels));
      },
    );

    test('rethrows when remote throws and cache is empty', () async {
      when(() => mockRemote.getGenres()).thenThrow(Exception('network error'));
      when(() => mockLocal.getCachedGenres()).thenReturn([]);

      expect(() => repository.getGenres(), throwsException);
    });
  });

  // ---- getMoviesByGenre
  group('getMoviesByGenre', () {
    test(
      'returns movies from remote and caches them on page 1 success',
      () async {
        when(
          () => mockRemote.getMoviesByGenre(28),
        ).thenAnswer((_) async => tMovieModels);
        when(
          () => mockLocal.cacheMoviesByGenre(28, tMovieModels),
        ).thenAnswer((_) async {});
        when(() => mockLocal.isFavorite(1)).thenReturn(false);

        final result = await repository.getMoviesByGenre(28);

        expect(result.length, equals(1));
        expect(result.first.title, equals('Die Hard'));
        verify(() => mockLocal.cacheMoviesByGenre(28, tMovieModels)).called(1);
      },
    );

    test('does not cache when page > 1', () async {
      when(
        () => mockRemote.getMoviesByGenre(28, page: 2),
      ).thenAnswer((_) async => tMovieModels);
      when(() => mockLocal.isFavorite(1)).thenReturn(false);

      await repository.getMoviesByGenre(28, page: 2);

      verifyNever(() => mockLocal.cacheMoviesByGenre(any(), any()));
    });

    test('marks movie as favorite when isFavorite returns true', () async {
      when(
        () => mockRemote.getMoviesByGenre(28),
      ).thenAnswer((_) async => tMovieModels);
      when(
        () => mockLocal.cacheMoviesByGenre(28, tMovieModels),
      ).thenAnswer((_) async {});
      when(() => mockLocal.isFavorite(1)).thenReturn(true);

      final result = await repository.getMoviesByGenre(28);

      expect(result.first.isFavorite, isTrue);
    });

    test('falls back to cache when remote throws on page 1', () async {
      when(
        () => mockRemote.getMoviesByGenre(28),
      ).thenThrow(Exception('network error'));
      when(() => mockLocal.getCachedMoviesByGenre(28)).thenReturn(tMovieModels);

      final result = await repository.getMoviesByGenre(28);

      expect(result, equals(tMovieModels));
    });

    test('rethrows when remote throws on page 1 and cache is empty', () async {
      when(
        () => mockRemote.getMoviesByGenre(28),
      ).thenThrow(Exception('network error'));
      when(() => mockLocal.getCachedMoviesByGenre(28)).thenReturn([]);

      expect(() => repository.getMoviesByGenre(28), throwsException);
    });

    test('rethrows when remote throws on page > 1', () async {
      when(
        () => mockRemote.getMoviesByGenre(28, page: 2),
      ).thenThrow(Exception('network error'));

      expect(() => repository.getMoviesByGenre(28, page: 2), throwsException);
    });
  });

  // ---- getPopularMovies
  group('getPopularMovies', () {
    test('fetches from remote, caches, and returns movies', () async {
      when(
        () => mockRemote.getPopularMovies(),
      ).thenAnswer((_) async => tMovieModels);
      when(
        () => mockLocal.cachePopularMovies(tMovieModels),
      ).thenAnswer((_) async {});

      final result = await repository.getPopularMovies();

      expect(result, equals(tMovieModels));
      verify(() => mockLocal.cachePopularMovies(tMovieModels)).called(1);
    });

    test('falls back to cache when remote throws', () async {
      when(
        () => mockRemote.getPopularMovies(),
      ).thenThrow(Exception('network error'));
      when(
        () => mockLocal.getCachedPopularMovies(),
      ).thenReturn(tMovieModels);

      final result = await repository.getPopularMovies();

      expect(result, equals(tMovieModels));
    });

    test('rethrows when remote throws and cache is empty', () async {
      when(
        () => mockRemote.getPopularMovies(),
      ).thenThrow(Exception('network error'));
      when(
        () => mockLocal.getCachedPopularMovies(),
      ).thenReturn([]);

      expect(() => repository.getPopularMovies(), throwsException);
    });
  });

  // ---- getMovieDetail
  group('getMovieDetail', () {
    const tDetail = MovieDetailModel(
      movie: MovieModel(
        id: 1,
        title: 'Die Hard',
        overview: 'Action classic.',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 8.2,
        releaseDate: '1988-07-15',
      ),
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

    test('fetches from remote, caches, and returns detail', () async {
      when(
        () => mockRemote.getMovieDetail(1),
      ).thenAnswer((_) async => tDetail);
      when(
        () => mockLocal.cacheMovieDetail(any()),
      ).thenAnswer((_) async {});

      final result = await repository.getMovieDetail(1);

      expect(result, equals(tDetail));
      verify(() => mockLocal.cacheMovieDetail(any())).called(1);
    });

    test('falls back to cache when remote throws', () async {
      when(
        () => mockRemote.getMovieDetail(1),
      ).thenThrow(Exception('network error'));
      when(
        () => mockLocal.getCachedMovieDetail(1),
      ).thenReturn(tDetail);

      final result = await repository.getMovieDetail(1);

      expect(result, equals(tDetail));
    });

    test('rethrows when remote throws and cache is null', () async {
      when(
        () => mockRemote.getMovieDetail(1),
      ).thenThrow(Exception('network error'));
      when(
        () => mockLocal.getCachedMovieDetail(1),
      ).thenReturn(null);

      expect(() => repository.getMovieDetail(1), throwsException);
    });
  });

  // ---- isFavorite
  group('isFavorite', () {
    test('delegates to local datasource and returns true', () async {
      when(() => mockLocal.isFavorite(1)).thenReturn(true);

      final result = await repository.isFavorite(1);

      expect(result, isTrue);
      verify(() => mockLocal.isFavorite(1)).called(1);
    });

    test('delegates to local datasource and returns false', () async {
      when(() => mockLocal.isFavorite(2)).thenReturn(false);

      final result = await repository.isFavorite(2);

      expect(result, isFalse);
    });
  });

  // ---- toggleFavorite
  group('toggleFavorite', () {
    test('delegates to local datasource with correct MovieModel', () async {
      when(() => mockLocal.toggleFavorite(any())).thenAnswer((_) async {});

      const movie = Movie(
        id: 1,
        title: 'Die Hard',
        overview: 'Action classic.',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 8.2,
        releaseDate: '1988-07-15',
      );

      await repository.toggleFavorite(movie);

      verify(() => mockLocal.toggleFavorite(any())).called(1);
    });
  });

  // ---- getMovieCredits
  group('getMovieCredits', () {
    test('delegates to remote datasource', () async {
      const tCastMember = CastMemberModel(
        id: 10,
        name: 'Bruce Willis',
        character: 'John McClane',
        profilePath: '/bruce.jpg',
      );
      when(
        () => mockRemote.getMovieCredits(1),
      ).thenAnswer((_) async => [tCastMember]);

      final result = await repository.getMovieCredits(1);

      expect(result.length, equals(1));
      expect(result.first.name, equals('Bruce Willis'));
      verify(() => mockRemote.getMovieCredits(1)).called(1);
    });
  });

  // ---- getCachedMoviesByGenre
  group('getCachedMoviesByGenre', () {
    test('delegates to local datasource', () async {
      when(
        () => mockLocal.getCachedMoviesByGenre(28),
      ).thenReturn(tMovieModels);

      final result = await repository.getCachedMoviesByGenre(28);

      expect(result, equals(tMovieModels));
      verify(() => mockLocal.getCachedMoviesByGenre(28)).called(1);
    });
  });

  // ---- getCachedGenres
  group('getCachedGenres', () {
    test('delegates to local datasource', () async {
      when(() => mockLocal.getCachedGenres()).thenReturn(tGenreModels);

      final result = await repository.getCachedGenres();

      expect(result, equals(tGenreModels));
      verify(() => mockLocal.getCachedGenres()).called(1);
    });
  });
}
