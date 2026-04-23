import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';

class FeaturedMovieCard extends StatelessWidget {
  const FeaturedMovieCard({
    required this.movie,
    required this.onTap,
    super.key,
  });

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = movie.backdropPath.isNotEmpty
        ? '${AppConfig.tmdbBackdropBaseUrl}${movie.backdropPath}'
        : movie.posterPath.isNotEmpty
        ? '${AppConfig.tmdbImageBaseUrl}${movie.posterPath}'
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop image
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => const _BackdropPlaceholder(),
            errorWidget: (_, _, _) => const _BackdropPlaceholder(),
          ),
          // Gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.35, 0.65, 1.0],
              ),
            ),
          ),
          // Content overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _FeaturedCardContent(movie: movie),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCardContent extends StatelessWidget {
  const _FeaturedCardContent({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final year = movie.releaseDate.length >= 4
        ? movie.releaseDate.substring(0, 4)
        : '';
    final isNew = _isRecentRelease(movie.releaseDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNew)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'NEW RELEASE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (year.isNotEmpty) ...[
              const SizedBox(width: 12),
              const Icon(Icons.circle, size: 4, color: Colors.white54),
              const SizedBox(width: 12),
              Text(
                year,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ],
        ),
      ],
    );
  }

  bool _isRecentRelease(String releaseDate) {
    if (releaseDate.isEmpty) return false;
    try {
      final date = DateTime.parse(releaseDate);
      return DateTime.now().difference(date).inDays < 180;
    } on FormatException {
      return false;
    }
  }
}

class _BackdropPlaceholder extends StatelessWidget {
  const _BackdropPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? const Color(0xFF14162A) : Colors.grey.shade300,
    );
  }
}
