import 'package:equatable/equatable.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

class MovieDetail extends Equatable {
  const MovieDetail({
    required this.movie,
    required this.tagline,
    required this.runtime,
    required this.backdropPaths,
    required this.cast,
    required this.genreNames,
  });

  final Movie movie;
  final String tagline;
  final int runtime;
  final List<String> backdropPaths;
  final List<CastMember> cast;
  final List<String> genreNames;

  @override
  List<Object?> get props =>
      [movie, tagline, runtime, backdropPaths, cast, genreNames];
}
