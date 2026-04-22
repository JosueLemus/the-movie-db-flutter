import 'package:the_movie_db/app/app.dart';
import 'package:the_movie_db/bootstrap.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/firebase/firebase_options_dev.dart';

Future<void> main() async {
  AppConfig.flavor = AppFlavor.staging;
  await bootstrap(
    () => const App(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    tmdbApiKey: const String.fromEnvironment('TMDB_API_KEY'),
  );
}
