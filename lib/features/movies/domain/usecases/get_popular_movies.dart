import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

class GetPopularMovies {
  const GetPopularMovies(this._repository);

  final MovieRepository _repository;

  Future<List<Movie>> call() => _repository.getPopularMovies();
}
