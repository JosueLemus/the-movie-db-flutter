import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    super.isFavorite,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    overview: json['overview'] as String? ?? '',
    posterPath: json['poster_path'] as String? ?? '',
    backdropPath: json['backdrop_path'] as String? ?? '',
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    releaseDate: json['release_date'] as String? ?? '',
  );

  factory MovieModel.fromCacheJson(Map<String, dynamic> json) => MovieModel(
    id: json['id'] as int,
    title: json['title'] as String,
    overview: json['overview'] as String,
    posterPath: json['poster_path'] as String,
    backdropPath: json['backdrop_path'] as String,
    voteAverage: (json['vote_average'] as num).toDouble(),
    releaseDate: json['release_date'] as String,
    isFavorite: json['is_favorite'] as bool? ?? false,
  );

  Map<String, dynamic> toCacheJson() => {
    'id': id,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'vote_average': voteAverage,
    'release_date': releaseDate,
    'is_favorite': isFavorite,
  };
}
