import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/is_favorite.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late IsFavorite useCase;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = IsFavorite(mockRepository);
  });

  group('IsFavorite', () {
    test('calls repository isFavorite with correct movieId', () async {
      when(
        () => mockRepository.isFavorite(any()),
      ).thenAnswer((_) async => false);

      await useCase(550);

      verify(() => mockRepository.isFavorite(550)).called(1);
    });

    test('returns true when movie is favorite', () async {
      when(
        () => mockRepository.isFavorite(any()),
      ).thenAnswer((_) async => true);

      final result = await useCase(550);

      expect(result, isTrue);
    });

    test('returns false when movie is not favorite', () async {
      when(
        () => mockRepository.isFavorite(any()),
      ).thenAnswer((_) async => false);

      final result = await useCase(550);

      expect(result, isFalse);
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.isFavorite(any()),
      ).thenThrow(Exception('Storage error'));

      expect(() => useCase(550), throwsA(isA<Exception>()));
    });
  });
}
