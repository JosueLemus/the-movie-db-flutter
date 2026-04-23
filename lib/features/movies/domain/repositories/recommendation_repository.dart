import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

// SOLID – I: Interface Segregation Principle
// RecommendationRepository is intentionally separate from MovieRepository.
// Consumers that only deal with recommendations (RecommendCubit) depend solely
// on this narrow interface and are not forced to know about genres, cast, or
// favorites — operations they never use.
abstract interface class RecommendationRepository {
  Future<List<Recommendation>> getRecommendations(int movieId);
  Future<void> addRecommendation({
    required int movieId,
    required String movieTitle,
    required String comment,
    required List<String> tags,
  });
}
