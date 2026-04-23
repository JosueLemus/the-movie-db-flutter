import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.movieId,
    required super.movieTitle,
    required super.comment,
    required super.createdAt,
  });

  factory RecommendationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return RecommendationModel(
      id: doc.id,
      movieId: data['movieId'] as int,
      movieTitle: data['movieTitle'] as String,
      comment: data['comment'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'movieTitle': movieTitle,
        'comment': comment,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
