import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:the_movie_db/features/movies/data/models/genre_model.dart';
import 'package:the_movie_db/features/movies/data/models/movie_model.dart';

// SRP: owns all local persistence for movies
abstract interface class MovieLocalDataSource {
  Future<void> cacheGenres(List<GenreModel> genres);
  List<GenreModel> getCachedGenres();
  Future<void> cacheMoviesByGenre(int genreId, List<MovieModel> movies);
  List<MovieModel> getCachedMoviesByGenre(int genreId);
  Future<void> toggleFavorite(MovieModel movie);
  bool isFavorite(int movieId);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  MovieLocalDataSourceImpl(this._box, this._favoritesBox);

  final Box<String> _box;
  final Box<bool> _favoritesBox;

  static const _genresKey = 'genres';
  static String _moviesKey(int genreId) => 'movies_$genreId';

  @override
  Future<void> cacheGenres(List<GenreModel> genres) async {
    final encoded = jsonEncode(genres.map((g) => g.toJson()).toList());
    await _box.put(_genresKey, encoded);
  }

  @override
  List<GenreModel> getCachedGenres() {
    final raw = _box.get(_genresKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheMoviesByGenre(
    int genreId,
    List<MovieModel> movies,
  ) async {
    final encoded = jsonEncode(
      movies.map((m) => m.toCacheJson()).toList(),
    );
    await _box.put(_moviesKey(genreId), encoded);
  }

  @override
  List<MovieModel> getCachedMoviesByGenre(int genreId) {
    final raw = _box.get(_moviesKey(genreId));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MovieModel.fromCacheJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> toggleFavorite(MovieModel movie) async {
    final key = movie.id.toString();
    if (_favoritesBox.get(key) == true) {
      await _favoritesBox.delete(key);
    } else {
      await _favoritesBox.put(key, true);
    }
  }

  @override
  bool isFavorite(int movieId) => _favoritesBox.get(movieId.toString()) == true;
}
