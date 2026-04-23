import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

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
            Stack(
              children: [
                Hero(
                  tag: 'movie-poster-${movie.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterPath.isNotEmpty
                          ? '${AppConfig.tmdbImageBaseUrl}${movie.posterPath}'
                          : '',
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const _PosterPlaceholder(
                        width: cardWidth,
                        height: cardHeight,
                      ),
                      errorWidget: (_, _, _) => const _PosterPlaceholder(
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: _RatingBadge(rating: movie.voteAverage),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2035) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.movie_outlined,
        color: isDark ? Colors.white24 : Colors.grey,
      ),
    );
  }
}
