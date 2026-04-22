import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_movie_db/core/network/dio_client.dart';
import 'package:the_movie_db/core/services/remote_config_service.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_local_datasource.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';
import 'package:the_movie_db/features/movies/domain/usecases/is_favorite.dart';
import 'package:the_movie_db/features/movies/domain/usecases/toggle_favorite.dart';
import 'package:the_movie_db/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:the_movie_db/features/splash/domain/repositories/splash_repository.dart';
import 'package:the_movie_db/features/splash/domain/usecases/initialize_app.dart';

final GetIt sl = GetIt.instance;

// DIP: all modules register abstractions, not concrete types
Future<void> initDependencies({required String tmdbApiKey}) async {
  await _initCore(tmdbApiKey: tmdbApiKey);
  _initSplash();
  await _initMovies();
}

Future<void> _initCore({required String tmdbApiKey}) async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<Dio>(createDioClient(tmdbApiKey))
    ..registerSingleton<FirebaseRemoteConfig>(FirebaseRemoteConfig.instance)
    ..registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance)
    ..registerSingleton<RemoteConfigService>(
      RemoteConfigService(
        sl<FirebaseRemoteConfig>(),
        sl<SharedPreferences>(),
      ),
    );
}

Future<void> _initMovies() async {
  final moviesBox = await Hive.openBox<String>('movies_cache');
  final favoritesBox = await Hive.openBox<bool>('favorites');

  sl
    ..registerSingleton<MovieLocalDataSource>(
      MovieLocalDataSourceImpl(moviesBox, favoritesBox),
    )
    ..registerSingleton<MovieRemoteDataSource>(
      MovieRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerSingleton<MovieRepository>(
      MovieRepositoryImpl(
        sl<MovieRemoteDataSource>(),
        sl<MovieLocalDataSource>(),
      ),
    )
    ..registerFactory<GetGenres>(() => GetGenres(sl<MovieRepository>()))
    ..registerFactory<GetMoviesByGenre>(
      () => GetMoviesByGenre(sl<MovieRepository>()),
    )
    ..registerFactory<GetMovieDetail>(
      () => GetMovieDetail(sl<MovieRepository>()),
    )
    ..registerFactory<ToggleFavorite>(
      () => ToggleFavorite(sl<MovieRepository>()),
    )
    ..registerFactory<IsFavorite>(() => IsFavorite(sl<MovieRepository>()));
}

void _initSplash() {
  sl
    ..registerFactory<SplashRepository>(
      () => SplashRepositoryImpl(sl<RemoteConfigService>()),
    )
    ..registerFactory<InitializeApp>(
      () => InitializeApp(sl<SplashRepository>()),
    );
}
