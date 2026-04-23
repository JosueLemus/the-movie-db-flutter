import 'package:equatable/equatable.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

enum RecommendStatus { initial, loading, loaded, submitting, submitted, error }

class RecommendState extends Equatable {
  const RecommendState({
    this.status = RecommendStatus.initial,
    this.recommendations = const [],
    this.error,
  });

  final RecommendStatus status;
  final List<Recommendation> recommendations;
  final String? error;

  bool get isLoading => status == RecommendStatus.loading;
  bool get isSubmitting => status == RecommendStatus.submitting;

  RecommendState copyWith({
    RecommendStatus? status,
    List<Recommendation>? recommendations,
    String? error,
  }) {
    return RecommendState(
      status: status ?? this.status,
      recommendations: recommendations ?? this.recommendations,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, recommendations, error];
}
