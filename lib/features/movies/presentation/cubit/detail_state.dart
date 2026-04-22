import 'package:equatable/equatable.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';

enum DetailStatus { loading, loaded, error }

class DetailState extends Equatable {
  const DetailState({
    this.status = DetailStatus.loading,
    this.movieDetail,
    this.isFavorite = false,
    this.error,
  });

  final DetailStatus status;
  final MovieDetail? movieDetail;
  final bool isFavorite;
  final String? error;

  DetailState copyWith({
    DetailStatus? status,
    MovieDetail? movieDetail,
    bool? isFavorite,
    String? error,
  }) {
    return DetailState(
      status: status ?? this.status,
      movieDetail: movieDetail ?? this.movieDetail,
      isFavorite: isFavorite ?? this.isFavorite,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, movieDetail, isFavorite, error];
}
