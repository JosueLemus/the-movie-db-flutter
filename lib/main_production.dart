import 'package:the_movie_db/app/app.dart';
import 'package:the_movie_db/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
