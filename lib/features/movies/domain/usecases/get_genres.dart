import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

// SRP: single use case, single responsibility
class GetGenres {
  const GetGenres(this._repository);

  final MovieRepository _repository;

  Future<List<Genre>> call() => _repository.getGenres();
}
