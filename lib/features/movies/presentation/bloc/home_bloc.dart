import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_event.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_state.dart';

// SRP: orchestrates home screen data, delegates fetching to use cases
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetGenres getGenres,
    required GetMoviesByGenre getMoviesByGenre,
    required GetPopularMovies getPopularMovies,
  }) : _getGenres = getGenres,
       _getMoviesByGenre = getMoviesByGenre,
       _getPopularMovies = getPopularMovies,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted, transformer: droppable());
    on<HomeMoviesRequested>(_onMoviesRequested, transformer: concurrent());
  }

  final GetGenres _getGenres;
  final GetMoviesByGenre _getMoviesByGenre;
  final GetPopularMovies _getPopularMovies;

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Kick off both futures simultaneously, await each result
      final genresFuture = _getGenres();
      final popularFuture = _getPopularMovies();
      final genres = await genresFuture;
      final popular = await popularFuture;

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          genres: genres,
          popularMovies: popular,
          genreMoviesStatus: {
            for (final g in genres) g.id: GenreMoviesStatus.loading,
          },
        ),
      );

      // concurrent() transformer lets all genre requests run in parallel
      for (final genre in genres) {
        add(HomeMoviesRequested(genre.id));
      }
    } on Exception catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e.toString()));
    }
  }

  Future<void> _onMoviesRequested(
    HomeMoviesRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final movies = await _getMoviesByGenre(event.genreId);

      final updatedMovies = Map<int, dynamic>.from(state.moviesByGenre)
        ..[event.genreId] = movies;

      final updatedStatus = Map<int, GenreMoviesStatus>.from(
        state.genreMoviesStatus,
      )..[event.genreId] = GenreMoviesStatus.loaded;

      emit(
        state.copyWith(
          moviesByGenre: Map<int, dynamic>.from(
            updatedMovies,
          ).cast<int, List<dynamic>>().map((k, v) => MapEntry(k, List.from(v))),
          genreMoviesStatus: updatedStatus,
        ),
      );
    } on Exception {
      final updatedStatus = Map<int, GenreMoviesStatus>.from(
        state.genreMoviesStatus,
      )..[event.genreId] = GenreMoviesStatus.error;
      emit(state.copyWith(genreMoviesStatus: updatedStatus));
    }
  }
}
