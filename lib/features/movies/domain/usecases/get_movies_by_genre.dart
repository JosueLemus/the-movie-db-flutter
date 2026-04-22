import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

class GetMoviesByGenre {
  const GetMoviesByGenre(this._repository);

  final MovieRepository _repository;

  Future<List<Movie>> call(int genreId, {int page = 1}) =>
      _repository.getMoviesByGenre(genreId, page: page);
}
