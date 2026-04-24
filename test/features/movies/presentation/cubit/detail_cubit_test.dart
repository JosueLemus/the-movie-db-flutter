import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/is_favorite.dart';
import 'package:the_movie_db/features/movies/domain/usecases/toggle_favorite.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/detail_cubit.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/detail_state.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;
  late GetMovieDetail getMovieDetail;
  late IsFavorite isFavorite;
  late ToggleFavorite toggleFavorite;

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
    getMovieDetail = GetMovieDetail(mockRepository);
    isFavorite = IsFavorite(mockRepository);
    toggleFavorite = ToggleFavorite(mockRepository);
    registerFallbackValue(tMovie);
  });

  DetailCubit buildCubit() => DetailCubit(
    getMovieDetail: getMovieDetail,
    isFavorite: isFavorite,
    toggleFavorite: toggleFavorite,
  );

  group('DetailCubit', () {
    test('initial state is DetailState with loading status', () {
      expect(buildCubit().state, equals(const DetailState()));
      expect(buildCubit().state.status, equals(DetailStatus.loading));
    });

    blocTest<DetailCubit, DetailState>(
      'load emits loading then loaded on success',
      build: () {
        when(
          () => mockRepository.getMovieDetail(any()),
        ).thenAnswer((_) async => tMovieDetail);
        when(
          () => mockRepository.isFavorite(any()),
        ).thenAnswer((_) async => false);
        return buildCubit();
      },
      act: (cubit) => cubit.load(550),
      expect: () => [
        const DetailState(),
        const DetailState(
          status: DetailStatus.loaded,
          movieDetail: tMovieDetail,
        ),
      ],
    );

    blocTest<DetailCubit, DetailState>(
      'load emits loading then loaded with isFavorite=true',
      build: () {
        when(
          () => mockRepository.getMovieDetail(any()),
        ).thenAnswer((_) async => tMovieDetail);
        when(
          () => mockRepository.isFavorite(any()),
        ).thenAnswer((_) async => true);
        return buildCubit();
      },
      act: (cubit) => cubit.load(550),
      expect: () => [
        const DetailState(),
        const DetailState(
          status: DetailStatus.loaded,
          movieDetail: tMovieDetail,
          isFavorite: true,
        ),
      ],
    );

    blocTest<DetailCubit, DetailState>(
      'load emits loading then error on exception',
      build: () {
        when(
          () => mockRepository.getMovieDetail(any()),
        ).thenThrow(Exception('Network error'));
        when(
          () => mockRepository.isFavorite(any()),
        ).thenAnswer((_) async => false);
        return buildCubit();
      },
      act: (cubit) => cubit.load(550),
      expect: () => [
        const DetailState(),
        isA<DetailState>().having(
          (s) => s.status,
          'status',
          DetailStatus.error,
        ),
      ],
    );

    blocTest<DetailCubit, DetailState>(
      'toggleFavorite does nothing when movieDetail is null',
      build: buildCubit,
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => <DetailState>[],
    );

    blocTest<DetailCubit, DetailState>(
      'toggleFavorite flips isFavorite from false to true',
      build: () {
        when(
          () => mockRepository.getMovieDetail(any()),
        ).thenAnswer((_) async => tMovieDetail);
        when(
          () => mockRepository.isFavorite(any()),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.toggleFavorite(any()),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => const DetailState(
        status: DetailStatus.loaded,
        movieDetail: tMovieDetail,
      ),
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => [
        const DetailState(
          status: DetailStatus.loaded,
          movieDetail: tMovieDetail,
          isFavorite: true,
        ),
      ],
    );

    blocTest<DetailCubit, DetailState>(
      'toggleFavorite flips isFavorite from true to false',
      build: () {
        when(
          () => mockRepository.toggleFavorite(any()),
        ).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => const DetailState(
        status: DetailStatus.loaded,
        movieDetail: tMovieDetail,
        isFavorite: true,
      ),
      act: (cubit) => cubit.toggleFavorite(),
      expect: () => [
        const DetailState(
          status: DetailStatus.loaded,
          movieDetail: tMovieDetail,
        ),
      ],
    );
  });

  group('DetailState', () {
    test('copyWith updates status', () {
      const state = DetailState();
      final updated = state.copyWith(status: DetailStatus.loaded);
      expect(updated.status, equals(DetailStatus.loaded));
    });

    test('copyWith updates movieDetail', () {
      const state = DetailState();
      final updated = state.copyWith(movieDetail: tMovieDetail);
      expect(updated.movieDetail, equals(tMovieDetail));
    });

    test('copyWith updates isFavorite', () {
      const state = DetailState();
      final updated = state.copyWith(isFavorite: true);
      expect(updated.isFavorite, isTrue);
    });

    test('copyWith updates error', () {
      const state = DetailState();
      final updated = state.copyWith(error: 'Something went wrong');
      expect(updated.error, equals('Something went wrong'));
    });

    test('supports value equality', () {
      expect(const DetailState(), equals(const DetailState()));
    });
  });
}
