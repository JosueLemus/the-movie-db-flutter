import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_shimmer.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_widget.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('MovieCardShimmer', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpApp(const MovieCardShimmer());

      expect(find.byType(MovieCardShimmer), findsOneWidget);
    });

    testWidgets('renders a SizedBox with the correct card width', (
      tester,
    ) async {
      await tester.pumpApp(const MovieCardShimmer());

      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((sb) => sb.width == MovieCardWidget.cardWidth)
          .toList();

      expect(sizedBoxes, isNotEmpty);
    });

    testWidgets('renders multiple Container placeholders', (tester) async {
      await tester.pumpApp(const MovieCardShimmer());

      // Expect at least the poster container and the two text-line containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(body: MovieCardShimmer()),
        ),
      );

      expect(find.byType(MovieCardShimmer), findsOneWidget);
    });

    testWidgets('renders correctly in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: const Scaffold(body: MovieCardShimmer()),
        ),
      );

      expect(find.byType(MovieCardShimmer), findsOneWidget);
    });
  });
}
