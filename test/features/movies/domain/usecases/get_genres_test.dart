import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late GetGenres useCase;

  const tGenres = [
    Genre(id: 28, name: 'Action'),
    Genre(id: 12, name: 'Adventure'),
  ];

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetGenres(mockRepository);
  });

  group('GetGenres', () {
    test('calls repository getGenres', () async {
      when(() => mockRepository.getGenres()).thenAnswer((_) async => tGenres);

      await useCase();

      verify(() => mockRepository.getGenres()).called(1);
    });

    test('returns list of genres from repository', () async {
      when(() => mockRepository.getGenres()).thenAnswer((_) async => tGenres);

      final result = await useCase();

      expect(result, equals(tGenres));
    });

    test('returns empty list when repository returns empty', () async {
      when(
        () => mockRepository.getGenres(),
      ).thenAnswer((_) async => const []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.getGenres(),
      ).thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
