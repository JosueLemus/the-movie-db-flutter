// coverage:ignore-file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_movie_db/core/network/dio_client.dart';
import 'package:the_movie_db/core/services/connectivity_service.dart';
import 'package:the_movie_db/core/services/remote_config_service.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_local_datasource.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/datasources/recommendation_remote_datasource.dart';
import 'package:the_movie_db/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:the_movie_db/features/movies/data/repositories/recommendation_repository_impl.dart';
import 'package:the_movie_db/features/movies/domain/repositories/movie_repository.dart';
import 'package:the_movie_db/features/movies/domain/repositories/recommendation_repository.dart';
import 'package:the_movie_db/features/movies/domain/usecases/add_recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_recommendations.dart';
import 'package:the_movie_db/features/movies/domain/usecases/is_favorite.dart';
import 'package:the_movie_db/features/movies/domain/usecases/toggle_favorite.dart';
import 'package:the_movie_db/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:the_movie_db/features/splash/domain/repositories/splash_repository.dart';
import 'package:the_movie_db/features/splash/domain/usecases/initialize_app.dart';

final GetIt sl = GetIt.instance;

// SOLID – D: Dependency Inversion Principle
// High-level modules (use-cases, cubits) depend on abstractions such as
// MovieRepository, not on MovieRepositoryImpl. Concrete types are only
// referenced here at the composition root, keeping the domain layer
// completely decoupled from framework and infrastructure details.
Future<void> initDependencies({required String tmdbApiKey}) async {
  await _initCore(tmdbApiKey: tmdbApiKey);
  _initSplash();
  await _initMovies();
}

Future<void> _initCore({required String tmdbApiKey}) async {
  final prefs = await SharedPreferences.getInstance();

  final connectivityService = ConnectivityService(Connectivity());

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<ConnectivityService>(connectivityService)
    ..registerSingleton<Dio>(createDioClient(tmdbApiKey, connectivityService))
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
    ..registerFactory<GetPopularMovies>(
      () => GetPopularMovies(sl<MovieRepository>()),
    )
    ..registerFactory<GetMoviesByGenre>(
      () => GetMoviesByGenre(sl<MovieRepository>()),
    )
    ..registerFactory<GetMovieDetail>(
      () => GetMovieDetail(sl<MovieRepository>()),
    )
    ..registerFactory<ToggleFavorite>(
      () => ToggleFavorite(sl<MovieRepository>()),
    )
    ..registerFactory<IsFavorite>(() => IsFavorite(sl<MovieRepository>()))
    ..registerSingleton<RecommendationRemoteDataSource>(
      RecommendationRemoteDataSourceImpl(sl<FirebaseFirestore>()),
    )
    ..registerFactory<RecommendationRepository>(
      () => RecommendationRepositoryImpl(
        sl<RecommendationRemoteDataSource>(),
      ),
    )
    ..registerFactory<GetRecommendations>(
      () => GetRecommendations(sl<RecommendationRepository>()),
    )
    ..registerFactory<AddRecommendation>(
      () => AddRecommendation(sl<RecommendationRepository>()),
    );
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
