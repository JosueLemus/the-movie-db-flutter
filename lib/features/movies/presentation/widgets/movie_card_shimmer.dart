import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_widget.dart';

class MovieCardShimmer extends StatelessWidget {
  const MovieCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            Container(width: 100, height: 10, color: Colors.white),
            const SizedBox(height: 4),
            Container(width: 60, height: 10, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
