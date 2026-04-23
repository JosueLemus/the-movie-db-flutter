import 'package:the_movie_db/features/movies/data/datasources/recommendation_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/models/recommendation_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';
import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  const RecommendationRepositoryImpl(this._remote);

  final RecommendationRemoteDataSource _remote;

  @override
  Future<List<Recommendation>> getRecommendations(int movieId) =>
      _remote.getRecommendations(movieId);

  @override
  Future<void> addRecommendation({
    required int movieId,
    required String movieTitle,
    required String comment,
  }) =>
      _remote.addRecommendation(
        RecommendationModel(
          id: '',
          movieId: movieId,
          movieTitle: movieTitle,
          comment: comment,
          createdAt: DateTime.now(),
        ),
      );
}
