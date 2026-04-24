import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

RequestOptions _opts(String path) => RequestOptions(path: path);

void main() {
  late MockDio mockDio;
  late MovieRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = MovieRemoteDataSourceImpl(mockDio);
  });

  // ---- getGenres
  group('getGenres', () {
    test('returns list of GenreModels on success', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/genre/movie/list',
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'genres': [
              {'id': 28, 'name': 'Action'},
              {'id': 12, 'name': 'Adventure'},
            ],
          },
          statusCode: 200,
          requestOptions: _opts('/genre/movie/list'),
        ),
      );

      final result = await dataSource.getGenres();

      expect(result.length, equals(2));
      expect(result.first.id, equals(28));
      expect(result.first.name, equals('Action'));
    });
  });

  // ---- getMoviesByGenre
  group('getMoviesByGenre', () {
    final tMovieJson = {
      'id': 1,
      'title': 'Die Hard',
      'overview': 'Classic.',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.2,
      'release_date': '1988-07-15',
    };

    test('returns list of MovieModels with default page', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/discover/movie',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'results': [tMovieJson],
          },
          statusCode: 200,
          requestOptions: _opts('/discover/movie'),
        ),
      );

      final result = await dataSource.getMoviesByGenre(28);

      expect(result.length, equals(1));
      expect(result.first.title, equals('Die Hard'));
    });

    test('passes page parameter in queryParameters', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/discover/movie',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'results': <dynamic>[]},
          statusCode: 200,
          requestOptions: _opts('/discover/movie'),
        ),
      );

      await dataSource.getMoviesByGenre(28, page: 3);

      final captured = verify(
        () => mockDio.get<Map<String, dynamic>>(
          '/discover/movie',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;

      final params = captured.first as Map<String, dynamic>;
      expect(params['page'], equals(3));
      expect(params['with_genres'], equals(28));
    });
  });

  // ---- getPopularMovies
  group('getPopularMovies', () {
    test('returns up to 10 MovieModels', () async {
      final manyMovies = List<Map<String, dynamic>>.generate(
        15,
        (i) => {
          'id': i,
          'title': 'Movie $i',
          'overview': '',
          'poster_path': '',
          'backdrop_path': '',
          'vote_average': 7.0,
          'release_date': '2024-01-01',
        },
      );

      when(
        () => mockDio.get<Map<String, dynamic>>('/movie/popular'),
      ).thenAnswer(
        (_) async => Response(
          data: {'results': manyMovies},
          statusCode: 200,
          requestOptions: _opts('/movie/popular'),
        ),
      );

      final result = await dataSource.getPopularMovies();

      expect(result.length, equals(10));
    });

    test('returns fewer than 10 when API returns fewer', () async {
      final fewMovies = List<Map<String, dynamic>>.generate(
        3,
        (i) => {
          'id': i,
          'title': 'Movie $i',
          'overview': '',
          'poster_path': '',
          'backdrop_path': '',
          'vote_average': 7.0,
          'release_date': '2024-01-01',
        },
      );

      when(
        () => mockDio.get<Map<String, dynamic>>('/movie/popular'),
      ).thenAnswer(
        (_) async => Response(
          data: {'results': fewMovies},
          statusCode: 200,
          requestOptions: _opts('/movie/popular'),
        ),
      );

      final result = await dataSource.getPopularMovies();

      expect(result.length, equals(3));
    });
  });

  // ---- getMovieDetail
  group('getMovieDetail', () {
    final tDetailJson = {
      'id': 550,
      'title': 'Fight Club',
      'overview': 'Insomniac meets soap salesman.',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
      'tagline': 'Mischief. Mayhem. Soap.',
      'runtime': 139,
      'genres': [
        {'id': 18, 'name': 'Drama'},
      ],
      'images': {
        'backdrops': <dynamic>[],
      },
    };

    final tCreditsJson = {
      'cast': [
        {
          'id': 819,
          'name': 'Edward Norton',
          'character': 'The Narrator',
          'profile_path': '/profile.jpg',
        },
      ],
    };

    test(
      'calls both detail and credits endpoints and returns MovieDetailModel',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/movie/550',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: tDetailJson,
            statusCode: 200,
            requestOptions: _opts('/movie/550'),
          ),
        );

        when(
          () => mockDio.get<Map<String, dynamic>>('/movie/550/credits'),
        ).thenAnswer(
          (_) async => Response(
            data: tCreditsJson,
            statusCode: 200,
            requestOptions: _opts('/movie/550/credits'),
          ),
        );

        final result = await dataSource.getMovieDetail(550);

        expect(result.movie.id, equals(550));
        expect(result.tagline, equals('Mischief. Mayhem. Soap.'));
        expect(result.cast.first.name, equals('Edward Norton'));
      },
    );
  });

  // ---- getMovieCredits
  group('getMovieCredits', () {
    test('returns up to 15 CastMemberModels', () async {
      final manyCast = List<Map<String, dynamic>>.generate(
        20,
        (i) => {
          'id': i,
          'name': 'Actor $i',
          'character': 'Role $i',
          'profile_path': '',
        },
      );

      when(
        () => mockDio.get<Map<String, dynamic>>('/movie/1/credits'),
      ).thenAnswer(
        (_) async => Response(
          data: {'cast': manyCast},
          statusCode: 200,
          requestOptions: _opts('/movie/1/credits'),
        ),
      );

      final result = await dataSource.getMovieCredits(1);

      expect(result.length, equals(15));
      expect(result.first.name, equals('Actor 0'));
    });
  });
}
