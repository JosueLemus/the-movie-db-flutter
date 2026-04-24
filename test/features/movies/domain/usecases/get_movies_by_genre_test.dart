import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late GetMoviesByGenre useCase;

  const tGenreId = 28;
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
  ];

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetMoviesByGenre(mockRepository);
  });

  group('GetMoviesByGenre', () {
    test('calls repository getMoviesByGenre with correct genreId', () async {
      when(
        () => mockRepository.getMoviesByGenre(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => tMovies);

      await useCase(tGenreId);

      verify(
        () => mockRepository.getMoviesByGenre(tGenreId),
      ).called(1);
    });

    test('passes page parameter to repository', () async {
      when(
        () => mockRepository.getMoviesByGenre(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => tMovies);

      await useCase(tGenreId, page: 2);

      verify(
        () => mockRepository.getMoviesByGenre(tGenreId, page: 2),
      ).called(1);
    });

    test('defaults to page 1 when not specified', () async {
      when(
        () => mockRepository.getMoviesByGenre(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => tMovies);

      await useCase(tGenreId);

      verify(
        () => mockRepository.getMoviesByGenre(tGenreId),
      ).called(1);
    });

    test('returns list of movies from repository', () async {
      when(
        () => mockRepository.getMoviesByGenre(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => tMovies);

      final result = await useCase(tGenreId);

      expect(result, equals(tMovies));
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.getMoviesByGenre(any(), page: any(named: 'page')),
      ).thenThrow(Exception('Network error'));

      expect(() => useCase(tGenreId), throwsA(isA<Exception>()));
    });
  });
}
