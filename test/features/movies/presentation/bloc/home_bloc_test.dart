import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_bloc.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_event.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_state.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late GetGenres getGenres;
  late GetMoviesByGenre getMoviesByGenre;
  late GetPopularMovies getPopularMovies;

  const tGenres = [
    Genre(id: 28, name: 'Action'),
    Genre(id: 12, name: 'Adventure'),
  ];

  const tPopular = [
    Movie(
      id: 550,
      title: 'Fight Club',
      overview: 'Overview',
      posterPath: '/poster.jpg',
      backdropPath: '/backdrop.jpg',
      voteAverage: 8.4,
      releaseDate: '1999-10-15',
    ),
  ];

  const tActionMovies = [
    Movie(
      id: 100,
      title: 'Action Movie',
      overview: 'Bang bang',
      posterPath: '/a.jpg',
      backdropPath: '/ab.jpg',
      voteAverage: 7,
      releaseDate: '2020-06-01',
    ),
  ];

  const tAdventureMovies = [
    Movie(
      id: 200,
      title: 'Adventure Movie',
      overview: 'Explore',
      posterPath: '/b.jpg',
      backdropPath: '/bb.jpg',
      voteAverage: 6.5,
      releaseDate: '2021-03-15',
    ),
  ];

  setUp(() {
    mockRepository = MockMovieRepository();
    getGenres = GetGenres(mockRepository);
    getMoviesByGenre = GetMoviesByGenre(mockRepository);
    getPopularMovies = GetPopularMovies(mockRepository);
  });

  HomeBloc buildBloc() => HomeBloc(
    getGenres: getGenres,
    getMoviesByGenre: getMoviesByGenre,
    getPopularMovies: getPopularMovies,
  );

  group('HomeBloc', () {
    test('initial state has initial status', () {
      expect(buildBloc().state.status, equals(HomeStatus.initial));
      expect(buildBloc().state.genres, isEmpty);
      expect(buildBloc().state.popularMovies, isEmpty);
    });

    blocTest<HomeBloc, HomeState>(
      'HomeStarted emits loading then loaded with genres and popular movies',
      build: () {
        when(() => mockRepository.getGenres()).thenAnswer((_) async => tGenres);
        when(
          () => mockRepository.getPopularMovies(),
        ).thenAnswer((_) async => tPopular);
        when(
          () => mockRepository.getMoviesByGenre(28),
        ).thenAnswer((_) async => tActionMovies);
        when(
          () => mockRepository.getMoviesByGenre(12),
        ).thenAnswer((_) async => tAdventureMovies);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.loaded)
            .having((s) => s.genres, 'genres', tGenres)
            .having((s) => s.popularMovies, 'popularMovies', tPopular),
        // genre movies states follow (concurrent)
        isA<HomeState>(),
        isA<HomeState>(),
      ],
      wait: const Duration(milliseconds: 300),
    );

    blocTest<HomeBloc, HomeState>(
      'HomeStarted emits error when getGenres throws',
      build: () {
        when(
          () => mockRepository.getGenres(),
        ).thenThrow(Exception('Network error'));
        when(
          () => mockRepository.getPopularMovies(),
        ).thenAnswer((_) async => tPopular);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>().having(
          (s) => s.status,
          'status',
          HomeStatus.error,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'HomeStarted emits error when getPopularMovies throws',
      build: () {
        when(
          () => mockRepository.getGenres(),
        ).thenAnswer((_) async => tGenres);
        when(
          () => mockRepository.getPopularMovies(),
        ).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.status,
          'status',
          HomeStatus.loading,
        ),
        isA<HomeState>().having(
          (s) => s.status,
          'status',
          HomeStatus.error,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'HomeMoviesRequested updates moviesByGenre and genreMoviesStatus',
      build: () {
        when(
          () => mockRepository.getMoviesByGenre(28),
        ).thenAnswer((_) async => tActionMovies);
        return buildBloc();
      },
      seed: () => const HomeState(
        status: HomeStatus.loaded,
        genres: tGenres,
        popularMovies: tPopular,
        genreMoviesStatus: {28: GenreMoviesStatus.loading},
      ),
      act: (bloc) => bloc.add(const HomeMoviesRequested(28)),
      expect: () => [
        isA<HomeState>()
            .having(
              (s) => s.moviesByGenre[28],
              'moviesByGenre[28]',
              tActionMovies,
            )
            .having(
              (s) => s.genreMoviesStatus[28],
              'genreMoviesStatus[28]',
              GenreMoviesStatus.loaded,
            ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'HomeMoviesRequested emits error status for genre when throws',
      build: () {
        when(
          () => mockRepository.getMoviesByGenre(28),
        ).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      seed: () => const HomeState(
        status: HomeStatus.loaded,
        genres: tGenres,
        popularMovies: tPopular,
        genreMoviesStatus: {28: GenreMoviesStatus.loading},
      ),
      act: (bloc) => bloc.add(const HomeMoviesRequested(28)),
      expect: () => [
        isA<HomeState>().having(
          (s) => s.genreMoviesStatus[28],
          'genreMoviesStatus[28]',
          GenreMoviesStatus.error,
        ),
      ],
    );
  });

  group('HomeEvent', () {
    test('HomeStarted props are empty', () {
      expect(const HomeStarted().props, isEmpty);
    });

    test('HomeMoviesRequested props contains genreId', () {
      expect(const HomeMoviesRequested(28).props, equals([28]));
    });

    test('two HomeMoviesRequested with same genreId are equal', () {
      expect(
        const HomeMoviesRequested(28),
        equals(const HomeMoviesRequested(28)),
      );
    });
  });

  group('HomeState', () {
    test('copyWith updates status', () {
      const state = HomeState();
      final updated = state.copyWith(status: HomeStatus.loaded);
      expect(updated.status, equals(HomeStatus.loaded));
    });

    test('copyWith updates genres', () {
      const state = HomeState();
      final updated = state.copyWith(genres: tGenres);
      expect(updated.genres, equals(tGenres));
    });

    test('copyWith updates popularMovies', () {
      const state = HomeState();
      final updated = state.copyWith(popularMovies: tPopular);
      expect(updated.popularMovies, equals(tPopular));
    });

    test('copyWith updates error', () {
      const state = HomeState();
      final updated = state.copyWith(error: 'Something went wrong');
      expect(updated.error, equals('Something went wrong'));
    });

    test('supports value equality', () {
      expect(const HomeState(), equals(const HomeState()));
    });
  });
}
