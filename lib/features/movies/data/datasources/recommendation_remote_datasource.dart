import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_movie_db/features/movies/data/models/recommendation_model.dart';

abstract interface class RecommendationRemoteDataSource {
  Future<List<RecommendationModel>> getRecommendations(int movieId);
  Future<void> addRecommendation(RecommendationModel recommendation);
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  RecommendationRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('recommendations');

  @override
  Future<List<RecommendationModel>> getRecommendations(int movieId) async {
    final snapshot = await _collection
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(RecommendationModel.fromDoc).toList();
  }

  @override
  Future<void> addRecommendation(RecommendationModel recommendation) =>
      _collection.add(recommendation.toJson());
}
