import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';

// ISP: one interface for the entire movies domain — split if it grows
abstract interface class MovieRepository {
  Future<List<Genre>> getGenres();
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1});
  Future<MovieDetail> getMovieDetail(int movieId);
  Future<List<CastMember>> getMovieCredits(int movieId);
  Future<void> toggleFavorite(Movie movie);
  Future<bool> isFavorite(int movieId);
  Future<List<Movie>> getCachedMoviesByGenre(int genreId);
  Future<List<Genre>> getCachedGenres();
}
