import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';
import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';

class GetRecommendations {
  const GetRecommendations(this._repository);

  final RecommendationRepository _repository;

  Future<List<Recommendation>> call(int movieId) =>
      _repository.getRecommendations(movieId);
}
