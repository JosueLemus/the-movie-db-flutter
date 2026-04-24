import 'package:the_movie_db/features/movies/data/datasources/movie_local_datasource.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

// SOLID – O: Open/Closed Principle
// MovieRepositoryImpl is open for extension but closed for modification.
// The caching and offline-fallback strategy lives entirely here in the data
// layer. Swapping Hive for SQLite, or adding a new remote source, only
// requires a new implementation of MovieRepository — the domain use-cases
// and presentation layer never need to change.
class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._remote, this._local);

  final MovieRemoteDataSource _remote;
  final MovieLocalDataSource _local;

  @override
  Future<List<Genre>> getGenres() async {
    try {
      final genres = await _remote.getGenres();
      await _local.cacheGenres(genres);
      return genres;
    } on Exception {
      final cached = _local.getCachedGenres();
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final movies = await _remote.getMoviesByGenre(genreId, page: page);
      if (page == 1) await _local.cacheMoviesByGenre(genreId, movies);
      return movies
          .map((m) => m.copyWith(isFavorite: _local.isFavorite(m.id)))
          .toList();
    } on Exception {
      if (page > 1) rethrow;
      final cached = _local.getCachedMoviesByGenre(genreId);
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  @override
  Future<List<Movie>> getPopularMovies() => _remote.getPopularMovies();

  @override
  Future<MovieDetail> getMovieDetail(int movieId) async {
    try {
      final detail = await _remote.getMovieDetail(movieId);
      await _local.cacheMovieDetail(detail);
      return detail;
    } on Exception {
      final cached = _local.getCachedMovieDetail(movieId);
      if (cached == null) rethrow;
      return cached;
    }
  }

  @override
  Future<List<CastMember>> getMovieCredits(int movieId) =>
      _remote.getMovieCredits(movieId);

  @override
  Future<void> toggleFavorite(Movie movie) => _local.toggleFavorite(
    MovieModel.fromJson({
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate,
    }),
  );

  @override
  Future<bool> isFavorite(int movieId) async => _local.isFavorite(movieId);

  @override
  Future<List<Movie>> getCachedMoviesByGenre(int genreId) async =>
      _local.getCachedMoviesByGenre(genreId);

  @override
  Future<List<Genre>> getCachedGenres() async => _local.getCachedGenres();
}
