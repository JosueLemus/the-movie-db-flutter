import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/core/services/remote_config_service.dart';
import 'package:the_movie_db/features/movies/data/datasources/movie_remote_datasource.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required FirebaseOptions firebaseOptions,
  required String tmdbApiKey,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  await Hive.initFlutter();

  await initDependencies(tmdbApiKey: tmdbApiKey);

  Bloc.observer = const AppBlocObserver();

  if (AppConfig.isDevelopment) await _testConnections();

  runApp(await builder());
}

Future<void> _testConnections() async {
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  log('🔥 [Firebase] Testing Remote Config...');
  try {
    final remoteConfig = sl<RemoteConfigService>();
    await remoteConfig.initialize();
    log('✅ [Firebase] Remote Config OK');
    log('   welcome_message  → "${remoteConfig.welcomeMessage}"');
    log('   maintenance_mode → ${remoteConfig.maintenanceMode}');
    log('   app_config       → ${remoteConfig.appConfig}');
  } on Exception catch (e) {
    log('❌ [Firebase] Remote Config FAILED: $e');
  }

  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  log('🎬 [TMDB] Testing API connection...');
  try {
    final remote = sl<MovieRemoteDataSource>();
    final genres = await remote.getGenres();
    log('✅ [TMDB] API OK — ${genres.length} genres fetched');
    for (final g in genres.take(5)) {
      log('   ${g.id}: ${g.name}');
    }
    log('   ...(${genres.length - 5} more)');
  } on Exception catch (e) {
    log('❌ [TMDB] API FAILED: $e');
  }
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
