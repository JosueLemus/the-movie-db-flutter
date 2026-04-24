import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_popular_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late GetPopularMovies useCase;

  const tMovies = [
    Movie(
      id: 550,
      title: 'Fight Club',
      overview: 'Overview',
      posterPath: '/poster.jpg',
      backdropPath: '/backdrop.jpg',
      voteAverage: 8.4,
      releaseDate: '1999-10-15',
    ),
    Movie(
      id: 680,
      title: 'Pulp Fiction',
      overview: 'Overview 2',
      posterPath: '/poster2.jpg',
      backdropPath: '/backdrop2.jpg',
      voteAverage: 8.9,
      releaseDate: '1994-10-14',
    ),
  ];

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetPopularMovies(mockRepository);
  });

  group('GetPopularMovies', () {
    test('calls repository getPopularMovies', () async {
      when(
        () => mockRepository.getPopularMovies(),
      ).thenAnswer((_) async => tMovies);

      await useCase();

      verify(() => mockRepository.getPopularMovies()).called(1);
    });

    test('returns list of movies from repository', () async {
      when(
        () => mockRepository.getPopularMovies(),
      ).thenAnswer((_) async => tMovies);

      final result = await useCase();

      expect(result, equals(tMovies));
      expect(result.length, equals(2));
    });

    test('returns empty list when repository returns empty', () async {
      when(
        () => mockRepository.getPopularMovies(),
      ).thenAnswer((_) async => const []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.getPopularMovies(),
      ).thenThrow(Exception('Timeout'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
