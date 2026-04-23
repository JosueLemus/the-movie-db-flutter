import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_movie_db/features/movies/data/models/recommendation_model.dart';

abstract interface class RecommendationRemoteDataSource {
  Future<List<RecommendationModel>> getRecommendations(int movieId);
  Future<void> addRecommendation(int movieId, RecommendationModel model);
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  RecommendationRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  // Subcollection: recommendations/{movieId}/entries/{docId}
  // No composite index needed — single-field createdAt index is auto-created.
  CollectionReference<Map<String, dynamic>> _entries(int movieId) => _firestore
      .collection('recommendations')
      .doc('$movieId')
      .collection('entries');

  @override
  Future<List<RecommendationModel>> getRecommendations(int movieId) async {
    final snapshot = await _entries(
      movieId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => RecommendationModel.fromDoc(doc, movieId))
        .toList();
  }

  @override
  Future<void> addRecommendation(int movieId, RecommendationModel model) =>
      _entries(movieId).add(model.toJson());
}
