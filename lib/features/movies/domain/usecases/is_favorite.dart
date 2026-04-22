import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

class IsFavorite {
  const IsFavorite(this._repository);

  final MovieRepository _repository;

  Future<bool> call(int movieId) => _repository.isFavorite(movieId);
}
