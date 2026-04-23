import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

// SOLID – S: Single Responsibility Principle
// Each use-case class owns exactly one business operation.
// GetMovieDetail only fetches movie detail; caching, favorites, and
// recommendations are handled by separate use-case classes. New behaviour
// is added by creating a new class, never by modifying this one.
class GetMovieDetail {
  const GetMovieDetail(this._repository);

  final MovieRepository _repository;

  Future<MovieDetail> call(int movieId) => _repository.getMovieDetail(movieId);
}
