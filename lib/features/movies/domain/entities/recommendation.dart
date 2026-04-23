import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  const Recommendation({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final int movieId;
  final String movieTitle;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, movieId, movieTitle, comment, createdAt];
}
