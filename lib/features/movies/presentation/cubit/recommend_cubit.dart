import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_movie_db/features/movies/domain/usecases/add_recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_recommendations.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_state.dart';

class RecommendCubit extends Cubit<RecommendState> {
  RecommendCubit({
    required GetRecommendations getRecommendations,
    required AddRecommendation addRecommendation,
  })  : _getRecommendations = getRecommendations,
        _addRecommendation = addRecommendation,
        super(const RecommendState());

  final GetRecommendations _getRecommendations;
  final AddRecommendation _addRecommendation;

  Future<void> load(int movieId) async {
    emit(state.copyWith(status: RecommendStatus.loading));
    try {
      final items = await _getRecommendations(movieId);
      emit(
        state.copyWith(
          status: RecommendStatus.loaded,
          recommendations: items,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: RecommendStatus.error, error: e.toString()));
    }
  }

  Future<void> submit({
    required int movieId,
    required String movieTitle,
    required String comment,
  }) async {
    if (comment.trim().isEmpty) return;
    emit(state.copyWith(status: RecommendStatus.submitting));
    try {
      await _addRecommendation(
        movieId: movieId,
        movieTitle: movieTitle,
        comment: comment.trim(),
      );
      // Reload to include the new entry
      final items = await _getRecommendations(movieId);
      emit(
        state.copyWith(
          status: RecommendStatus.submitted,
          recommendations: items,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: RecommendStatus.error, error: e.toString()));
    }
  }
}
