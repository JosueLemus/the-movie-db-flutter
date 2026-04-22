import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

// SRP: renders a single movie card — no state, no business logic
class MovieCardWidget extends StatelessWidget {
  const MovieCardWidget({
    required this.movie,
    required this.onTap,
    super.key,
  });

  final Movie movie;
  final VoidCallback onTap;

  static const double cardWidth = 120;
  static const double cardHeight = 180;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: movie.posterPath.isNotEmpty
                    ? '${AppConfig.tmdbImageBaseUrl}${movie.posterPath}'
                    : '',
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) => const _PosterPlaceholder(
                  width: cardWidth,
                  height: cardHeight,
                ),
                errorWidget: (context, url, error) => const _PosterPlaceholder(
                  width: cardWidth,
                  height: cardHeight,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }
}
