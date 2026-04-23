import 'package:dio/dio.dart';
import 'package:the_movie_db/features/movies/data/models/cast_member_model.dart';
import 'package:the_movie_db/features/movies/data/models/genre_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_detail_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';

// SRP: only responsible for raw HTTP calls to TMDB
abstract interface class MovieRemoteDataSource {
  Future<List<GenreModel>> getGenres();
  Future<List<MovieModel>> getMoviesByGenre(int genreId, {int page = 1});
  Future<List<MovieModel>> getPopularMovies();
  Future<MovieDetailModel> getMovieDetail(int movieId);
  Future<List<CastMemberModel>> getMovieCredits(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  const MovieRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<GenreModel>> getGenres() async {
    final response = await _dio.get<Map<String, dynamic>>('/genre/movie/list');
    final genres = response.data!['genres'] as List<dynamic>;
    return genres
        .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MovieModel>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/discover/movie',
      queryParameters: {
        'with_genres': genreId,
        'page': page,
        'sort_by': 'popularity.desc',
      },
    );
    final results = response.data!['results'] as List<dynamic>;
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/movie/popular');
    final results = response.data!['results'] as List<dynamic>;
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .take(10)
        .toList();
  }

  @override
  Future<MovieDetailModel> getMovieDetail(int movieId) async {
    final results = await Future.wait([
      _dio.get<Map<String, dynamic>>(
        '/movie/$movieId',
        queryParameters: {'append_to_response': 'images'},
      ),
      _dio.get<Map<String, dynamic>>('/movie/$movieId/credits'),
    ]);

    final detailJson = results[0].data!;
    final cast = results[1].data!['cast'] as List<dynamic>;

    return MovieDetailModel.fromJson(detailJson, cast);
  }

  @override
  Future<List<CastMemberModel>> getMovieCredits(int movieId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/movie/$movieId/credits');
    final cast = response.data!['cast'] as List<dynamic>;
    return cast
        .take(15)
        .map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
