import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/toggle_favorite.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late ToggleFavorite useCase;

  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'Overview',
    posterPath: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.4,
    releaseDate: '1999-10-15',
  );

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = ToggleFavorite(mockRepository);
    registerFallbackValue(tMovie);
  });

  group('ToggleFavorite', () {
    test('calls repository toggleFavorite with correct movie', () async {
      when(
        () => mockRepository.toggleFavorite(any()),
      ).thenAnswer((_) async {});

      await useCase(tMovie);

      verify(() => mockRepository.toggleFavorite(tMovie)).called(1);
    });

    test('returns void on success', () async {
      when(
        () => mockRepository.toggleFavorite(any()),
      ).thenAnswer((_) async {});

      expect(useCase(tMovie), completes);
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.toggleFavorite(any()),
      ).thenThrow(Exception('Storage error'));

      expect(() => useCase(tMovie), throwsA(isA<Exception>()));
    });

    test('passes isFavorite=true movie correctly', () async {
      const favoriteMovie = Movie(
        id: 550,
        title: 'Fight Club',
        overview: 'Overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 8.4,
        releaseDate: '1999-10-15',
        isFavorite: true,
      );
      when(
        () => mockRepository.toggleFavorite(any()),
      ).thenAnswer((_) async {});

      await useCase(favoriteMovie);

      verify(() => mockRepository.toggleFavorite(favoriteMovie)).called(1);
    });
  });
}
