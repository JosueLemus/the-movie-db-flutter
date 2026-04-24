import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';

void main() {
  group('MovieDetail', () {
    const tMovie = Movie(
      id: 1,
      title: 'Test Movie',
      overview: 'An overview',
      posterPath: '/poster.jpg',
      backdropPath: '/backdrop.jpg',
      voteAverage: 7.5,
      releaseDate: '2024-01-01',
    );

    const tCast = [
      CastMember(
        id: 100,
        name: 'John Doe',
        character: 'Hero',
        profilePath: '/profile.jpg',
      ),
    ];

    const tMovieDetail = MovieDetail(
      movie: tMovie,
      tagline: 'A great tagline',
      runtime: 120,
      backdropPaths: ['/backdrop1.jpg', '/backdrop2.jpg'],
      cast: tCast,
      genreNames: ['Action', 'Adventure'],
    );

    test('supports value equality', () {
      const other = MovieDetail(
        movie: tMovie,
        tagline: 'A great tagline',
        runtime: 120,
        backdropPaths: ['/backdrop1.jpg', '/backdrop2.jpg'],
        cast: tCast,
        genreNames: ['Action', 'Adventure'],
      );
      expect(tMovieDetail, equals(other));
    });

    test('details with different runtimes are not equal', () {
      const other = MovieDetail(
        movie: tMovie,
        tagline: 'A great tagline',
        runtime: 90,
        backdropPaths: ['/backdrop1.jpg', '/backdrop2.jpg'],
        cast: tCast,
        genreNames: ['Action', 'Adventure'],
      );
      expect(tMovieDetail, isNot(equals(other)));
    });

    test('details with different taglines are not equal', () {
      const other = MovieDetail(
        movie: tMovie,
        tagline: 'Different tagline',
        runtime: 120,
        backdropPaths: ['/backdrop1.jpg', '/backdrop2.jpg'],
        cast: tCast,
        genreNames: ['Action', 'Adventure'],
      );
      expect(tMovieDetail, isNot(equals(other)));
    });

    test('props contains all fields', () {
      expect(tMovieDetail.props, [
        tMovie,
        'A great tagline',
        120,
        ['/backdrop1.jpg', '/backdrop2.jpg'],
        tCast,
        ['Action', 'Adventure'],
      ]);
    });

    test('fields are assigned correctly', () {
      expect(tMovieDetail.movie, equals(tMovie));
      expect(tMovieDetail.tagline, equals('A great tagline'));
      expect(tMovieDetail.runtime, equals(120));
      expect(
        tMovieDetail.backdropPaths,
        equals(['/backdrop1.jpg', '/backdrop2.jpg']),
      );
      expect(tMovieDetail.cast, equals(tCast));
      expect(tMovieDetail.genreNames, equals(['Action', 'Adventure']));
    });
  });
}
