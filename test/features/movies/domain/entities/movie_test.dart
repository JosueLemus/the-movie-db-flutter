import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

void main() {
  const tMovie = Movie(
    id: 1,
    title: 'Test Movie',
    overview: 'An overview',
    posterPath: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 7.5,
    releaseDate: '2024-01-01',
  );

  group('Movie', () {
    test('supports value equality', () {
      const movie1 = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'An overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
      );
      const movie2 = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'An overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
      );
      expect(movie1, equals(movie2));
    });

    test('two movies with different ids are not equal', () {
      const other = Movie(
        id: 2,
        title: 'Test Movie',
        overview: 'An overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
      );
      expect(tMovie, isNot(equals(other)));
    });

    test('isFavorite defaults to false', () {
      expect(tMovie.isFavorite, isFalse);
    });

    test('copyWith returns new instance with updated isFavorite', () {
      final updated = tMovie.copyWith(isFavorite: true);
      expect(updated.isFavorite, isTrue);
      expect(updated.id, equals(tMovie.id));
      expect(updated.title, equals(tMovie.title));
      expect(updated.overview, equals(tMovie.overview));
      expect(updated.posterPath, equals(tMovie.posterPath));
      expect(updated.backdropPath, equals(tMovie.backdropPath));
      expect(updated.voteAverage, equals(tMovie.voteAverage));
      expect(updated.releaseDate, equals(tMovie.releaseDate));
    });

    test('copyWith with null isFavorite keeps original value', () {
      const favorite = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'An overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
        isFavorite: true,
      );
      final copied = favorite.copyWith();
      expect(copied.isFavorite, isTrue);
    });

    test('props contains all fields', () {
      expect(tMovie.props, [
        1,
        'Test Movie',
        'An overview',
        '/poster.jpg',
        '/backdrop.jpg',
        7.5,
        '2024-01-01',
        false,
      ]);
    });

    test('copyWith does not mutate original', () {
      final updated = tMovie.copyWith(isFavorite: true);
      expect(tMovie.isFavorite, isFalse);
      expect(updated.isFavorite, isTrue);
    });
  });
}
