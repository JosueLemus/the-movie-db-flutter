import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/featured_movie_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    AppConfig.flavor = AppFlavor.development;
  });

  group('FeaturedMovieCard', () {
    const tMovie = Movie(
      id: 1,
      title: 'Inception',
      overview: 'A mind-bending thriller.',
      posterPath: '/poster.jpg',
      backdropPath: '/backdrop.jpg',
      voteAverage: 8.8,
      releaseDate: '2010-07-16',
    );

    testWidgets('renders movie title', (tester) async {
      await tester.pumpApp(
        SizedBox(
          height: 300,
          child: FeaturedMovieCard(movie: tMovie, onTap: () {}),
        ),
      );

      expect(find.text('Inception'), findsOneWidget);
    });

    testWidgets('renders vote average', (tester) async {
      await tester.pumpApp(
        SizedBox(
          height: 300,
          child: FeaturedMovieCard(movie: tMovie, onTap: () {}),
        ),
      );

      expect(find.text('8.8'), findsOneWidget);
    });

    testWidgets('shows NEW RELEASE badge for recent release', (tester) async {
      final recentDate = DateTime.now().subtract(const Duration(days: 30));
      final recentMovie = Movie(
        id: 2,
        title: 'New Movie',
        overview: 'Brand new.',
        posterPath: '/poster2.jpg',
        backdropPath: '/backdrop2.jpg',
        voteAverage: 7.5,
        releaseDate: [
          recentDate.year.toString(),
          recentDate.month.toString().padLeft(2, '0'),
          recentDate.day.toString().padLeft(2, '0'),
        ].join('-'),
      );

      await tester.pumpApp(
        SizedBox(
          height: 300,
          child: FeaturedMovieCard(movie: recentMovie, onTap: () {}),
        ),
      );

      expect(find.text('NEW RELEASE'), findsOneWidget);
    });

    testWidgets('does not show NEW RELEASE badge for old movies', (
      tester,
    ) async {
      await tester.pumpApp(
        SizedBox(
          height: 300,
          child: FeaturedMovieCard(movie: tMovie, onTap: () {}),
        ),
      );

      expect(find.text('NEW RELEASE'), findsNothing);
    });

    testWidgets('renders placeholder when imageUrl is empty', (tester) async {
      const noImageMovie = Movie(
        id: 3,
        title: 'No Image Movie',
        overview: 'No images here.',
        posterPath: '',
        backdropPath: '',
        voteAverage: 5,
        releaseDate: '2020-01-01',
      );

      await tester.pumpApp(
        SizedBox(
          height: 300,
          child: FeaturedMovieCard(movie: noImageMovie, onTap: () {}),
        ),
      );

      // Widget renders without error and shows title
      expect(find.text('No Image Movie'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpApp(
        SizedBox(
          height: 300,
          child: FeaturedMovieCard(movie: tMovie, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });
}
