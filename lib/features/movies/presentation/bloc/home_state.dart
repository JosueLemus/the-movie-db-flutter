import 'package:equatable/equatable.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

enum HomeStatus { initial, loading, loaded, error }

enum GenreMoviesStatus { loading, loaded, error }

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.genres = const [],
    this.popularMovies = const [],
    this.moviesByGenre = const {},
    this.genreMoviesStatus = const {},
    this.error,
  });

  final HomeStatus status;
  final List<Genre> genres;
  final List<Movie> popularMovies;

  // OCP: extend with more per-genre data without changing existing consumers
  final Map<int, List<Movie>> moviesByGenre;
  final Map<int, GenreMoviesStatus> genreMoviesStatus;
  final String? error;

  HomeState copyWith({
    HomeStatus? status,
    List<Genre>? genres,
    List<Movie>? popularMovies,
    Map<int, List<Movie>>? moviesByGenre,
    Map<int, GenreMoviesStatus>? genreMoviesStatus,
    String? error,
  }) => HomeState(
    status: status ?? this.status,
    genres: genres ?? this.genres,
    popularMovies: popularMovies ?? this.popularMovies,
    moviesByGenre: moviesByGenre ?? this.moviesByGenre,
    genreMoviesStatus: genreMoviesStatus ?? this.genreMoviesStatus,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [
    status,
    genres,
    popularMovies,
    moviesByGenre,
    genreMoviesStatus,
    error,
  ];
}
