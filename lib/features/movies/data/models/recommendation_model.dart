import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.movieId,
    required super.movieTitle,
    required super.comment,
    required super.tags,
    required super.createdAt,
  });

  factory RecommendationModel.fromDoc(DocumentSnapshot doc, int movieId) {
    final data = doc.data()! as Map<String, dynamic>;
    return RecommendationModel(
      id: doc.id,
      movieId: movieId,
      movieTitle: data['movieTitle'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'movieTitle': movieTitle,
        'comment': comment,
        'tags': tags,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
