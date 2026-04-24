import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_state.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/genre_section_widget.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_shimmer.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_widget.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    AppConfig.flavor = AppFlavor.development;
  });

  const tGenre = Genre(id: 28, name: 'Action');

  const tMovies = [
    Movie(
      id: 1,
      title: 'Die Hard',
      overview: 'An action classic.',
      posterPath: '/diehard.jpg',
      backdropPath: '/diehard_bg.jpg',
      voteAverage: 8.2,
      releaseDate: '1988-07-15',
    ),
    Movie(
      id: 2,
      title: 'Mad Max',
      overview: 'Post-apocalyptic action.',
      posterPath: '/madmax.jpg',
      backdropPath: '/madmax_bg.jpg',
      voteAverage: 7.6,
      releaseDate: '2015-05-15',
    ),
  ];

  group('GenreSectionWidget', () {
    testWidgets('renders genre name', (tester) async {
      await tester.pumpApp(
        GenreSectionWidget(
          genre: tGenre,
          movies: tMovies,
          status: GenreMoviesStatus.loaded,
          onMovieTap: (_) {},
        ),
      );

      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('shows MovieCardShimmer widgets when status is loading', (
      tester,
    ) async {
      await tester.pumpApp(
        GenreSectionWidget(
          genre: tGenre,
          movies: const [],
          status: GenreMoviesStatus.loading,
          onMovieTap: (_) {},
        ),
      );

      expect(find.byType(MovieCardShimmer), findsWidgets);
    });

    testWidgets('shows MovieCardWidget for each movie when status is loaded', (
      tester,
    ) async {
      await tester.pumpApp(
        GenreSectionWidget(
          genre: tGenre,
          movies: tMovies,
          status: GenreMoviesStatus.loaded,
          onMovieTap: (_) {},
        ),
      );

      expect(find.byType(MovieCardWidget), findsNWidgets(tMovies.length));
    });

    testWidgets('shows movie titles when status is loaded', (tester) async {
      await tester.pumpApp(
        GenreSectionWidget(
          genre: tGenre,
          movies: tMovies,
          status: GenreMoviesStatus.loaded,
          onMovieTap: (_) {},
        ),
      );

      expect(find.text('Die Hard'), findsOneWidget);
      expect(find.text('Mad Max'), findsOneWidget);
    });

    testWidgets('shows error message when status is error', (tester) async {
      await tester.pumpApp(
        GenreSectionWidget(
          genre: tGenre,
          movies: const [],
          status: GenreMoviesStatus.error,
          onMovieTap: (_) {},
        ),
      );

      expect(find.text('Error al cargar películas'), findsOneWidget);
    });

    testWidgets('calls onMovieTap when a movie card is tapped', (tester) async {
      Movie? tappedMovie;

      await tester.pumpApp(
        GenreSectionWidget(
          genre: tGenre,
          movies: tMovies,
          status: GenreMoviesStatus.loaded,
          onMovieTap: (movie) => tappedMovie = movie,
        ),
      );

      await tester.tap(find.byType(MovieCardWidget).first);
      expect(tappedMovie, equals(tMovies.first));
    });
  });
}
