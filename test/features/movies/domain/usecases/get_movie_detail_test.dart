import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movie_detail.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late GetMovieDetail useCase;

  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'Overview',
    posterPath: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.4,
    releaseDate: '1999-10-15',
  );

  const tMovieDetail = MovieDetail(
    movie: tMovie,
    tagline: 'Mischief. Mayhem. Soap.',
    runtime: 139,
    backdropPaths: ['/backdrop.jpg'],
    cast: [
      CastMember(
        id: 819,
        name: 'Edward Norton',
        character: 'Narrator',
        profilePath: '/profile.jpg',
      ),
    ],
    genreNames: ['Drama', 'Thriller'],
  );

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetMovieDetail(mockRepository);
  });

  group('GetMovieDetail', () {
    test('calls repository getMovieDetail with correct id', () async {
      when(
        () => mockRepository.getMovieDetail(any()),
      ).thenAnswer((_) async => tMovieDetail);

      await useCase(550);

      verify(() => mockRepository.getMovieDetail(550)).called(1);
    });

    test('returns MovieDetail from repository', () async {
      when(
        () => mockRepository.getMovieDetail(any()),
      ).thenAnswer((_) async => tMovieDetail);

      final result = await useCase(550);

      expect(result, equals(tMovieDetail));
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.getMovieDetail(any()),
      ).thenThrow(Exception('Not found'));

      expect(() => useCase(999), throwsA(isA<Exception>()));
    });
  });
}
