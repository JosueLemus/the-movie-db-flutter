import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_movie_db/core/network/dio_client.dart';
import 'package:the_movie_db/core/services/remote_config_service.dart';

final GetIt sl = GetIt.instance;

// DIP: all modules register abstractions, not concrete types
Future<void> initDependencies({required String tmdbApiKey}) async {
  await _initCore(tmdbApiKey: tmdbApiKey);
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
