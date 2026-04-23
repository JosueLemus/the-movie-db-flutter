import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';

class AddRecommendation {
  const AddRecommendation(this._repository);

  final RecommendationRepository _repository;

  Future<void> call({
    required int movieId,
    required String movieTitle,
    required String comment,
    required List<String> tags,
  }) =>
      _repository.addRecommendation(
        movieId: movieId,
        movieTitle: movieTitle,
        comment: comment,
        tags: tags,
      );
}
