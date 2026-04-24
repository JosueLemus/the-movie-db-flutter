import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_widget.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    AppConfig.flavor = AppFlavor.development;
  });

  group('MovieCardWidget', () {
    const tMovie = Movie(
      id: 42,
      title: 'The Dark Knight',
      overview: 'Batman fights the Joker.',
      posterPath: '/dark_knight.jpg',
      backdropPath: '/dark_knight_backdrop.jpg',
      voteAverage: 9,
      releaseDate: '2008-07-18',
    );

    testWidgets('renders movie title', (tester) async {
      await tester.pumpApp(
        MovieCardWidget(movie: tMovie, onTap: () {}),
      );

      expect(find.text('The Dark Knight'), findsOneWidget);
    });

    testWidgets('renders rating badge with formatted vote average', (
      tester,
    ) async {
      await tester.pumpApp(
        MovieCardWidget(movie: tMovie, onTap: () {}),
      );

      expect(find.text('9.0'), findsOneWidget);
    });

    testWidgets('contains a GestureDetector for tap handling', (tester) async {
      await tester.pumpApp(
        MovieCardWidget(movie: tMovie, onTap: () {}),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('renders without error when posterPath is empty', (
      tester,
    ) async {
      const noImageMovie = Movie(
        id: 99,
        title: 'No Poster',
        overview: 'No poster image.',
        posterPath: '',
        backdropPath: '',
        voteAverage: 6.5,
        releaseDate: '2021-05-01',
      );

      await tester.pumpApp(
        MovieCardWidget(movie: noImageMovie, onTap: () {}),
      );

      expect(find.text('No Poster'), findsOneWidget);
    });
  });
}
