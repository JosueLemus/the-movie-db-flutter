import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';

class GetMovieDetail {
  const GetMovieDetail(this._repository);

  final MovieRepository _repository;

  Future<MovieDetail> call(int movieId) => _repository.getMovieDetail(movieId);
}
