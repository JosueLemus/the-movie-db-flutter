import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_widget.dart';

class MovieCardShimmer extends StatelessWidget {
  const MovieCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2035) : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF2A2B45) : Colors.grey.shade100,
      child: SizedBox(
        width: MovieCardWidget.cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MovieCardWidget.cardWidth,
              height: MovieCardWidget.cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 70,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
