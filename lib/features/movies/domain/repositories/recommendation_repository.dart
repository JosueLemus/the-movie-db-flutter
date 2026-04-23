import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

abstract interface class RecommendationRepository {
  Future<List<Recommendation>> getRecommendations(int movieId);
  Future<void> addRecommendation({
    required int movieId,
    required String movieTitle,
    required String comment,
    required List<String> tags,
  });
}
