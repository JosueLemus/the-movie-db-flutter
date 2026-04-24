import 'package:the_movie_db/features/movies/data/models/cast_member_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';

class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.movie,
    required super.tagline,
    required super.runtime,
    required super.backdropPaths,
    required super.cast,
    required super.genreNames,
  });

  factory MovieDetailModel.fromJson(
    Map<String, dynamic> detailJson,
    List<dynamic> creditsJson,
  ) {
    final movie = MovieModel.fromJson(detailJson);
    final images = detailJson['images'] as Map<String, dynamic>?;
    final backdrops = images?['backdrops'] as List<dynamic>? ?? [];

    final backdropPaths = [
      if ((detailJson['backdrop_path'] as String?) != null)
        detailJson['backdrop_path'] as String,
      ...backdrops
          .take(5)
          .map((dynamic e) {
            final map = e as Map<String, dynamic>;
            return map['file_path'] as String? ?? '';
          })
          .where((p) => p.isNotEmpty),
    ];

    final cast = creditsJson
        .take(15)
        .map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final genres = detailJson['genres'] as List<dynamic>? ?? [];
    final genreNames = genres
        .map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    return MovieDetailModel(
      movie: movie,
      tagline: detailJson['tagline'] as String? ?? '',
      runtime: detailJson['runtime'] as int? ?? 0,
      backdropPaths: backdropPaths.isEmpty
          ? [movie.backdropPath]
          : backdropPaths,
      cast: cast,
      genreNames: genreNames,
    );
  }

  factory MovieDetailModel.fromCacheJson(Map<String, dynamic> json) {
    final castList = json['cast'] as List<dynamic>;
    return MovieDetailModel(
      movie: MovieModel.fromCacheJson(
        json['movie'] as Map<String, dynamic>,
      ),
      tagline: json['tagline'] as String,
      runtime: json['runtime'] as int,
      backdropPaths: (json['backdrop_paths'] as List<dynamic>)
          .cast<String>()
          .toList(),
      cast: castList
          .map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      genreNames: (json['genre_names'] as List<dynamic>)
          .cast<String>()
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'movie': (movie as MovieModel).toCacheJson(),
    'tagline': tagline,
    'runtime': runtime,
    'backdrop_paths': backdropPaths,
    'cast': cast.map((c) => (c as CastMemberModel).toJson()).toList(),
    'genre_names': genreNames,
  };
}
