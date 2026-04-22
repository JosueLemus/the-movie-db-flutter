import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final MovieRepository _repository;

  Future<void> call(Movie movie) => _repository.toggleFavorite(movie);
}
