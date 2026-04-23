import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/is_favorite.dart';
import 'package:the_movie_db/features/movies/domain/usecases/toggle_favorite.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/detail_cubit.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/detail_state.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/cast_card_widget.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/image_carousel_widget.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/recommend_modal.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({required this.movieId, super.key});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = DetailCubit(
          getMovieDetail: sl<GetMovieDetail>(),
          isFavorite: sl<IsFavorite>(),
          toggleFavorite: sl<ToggleFavorite>(),
        );
        unawaited(cubit.load(movieId));
        return cubit;
      },
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, DetailState>(
      builder: (context, state) {
        return switch (state.status) {
          DetailStatus.loading => const _LoadingView(),
          DetailStatus.error => _ErrorView(message: state.error),
          DetailStatus.loaded => _LoadedView(
              detail: state.movieDetail!,
              isFavorite: state.isFavorite,
            ),
        };
      },
    );
  }
}

// ─── States

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message ?? 'Something went wrong'),
          ],
        ),
      ),
    );
  }
}

// ─── Loaded

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.detail, required this.isFavorite});

  final MovieDetail detail;
  final bool isFavorite;

  static const double _carouselHeight = 320;
  static const double _posterWidth = 100;
  static const double _posterHeight = 150;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DetailCubit>();
    final movie = detail.movie;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing backdrop ──
          SliverAppBar(
            expandedHeight: _carouselHeight,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: cubit.toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImageCarouselWidget(paths: detail.backdropPaths),
                  // Bottom gradient so title area is readable
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: _DetailContent(
              detail: detail,
              posterWidth: _posterWidth,
              posterHeight: _posterHeight,
              movieId: movie.id,
              movieTitle: movie.title,
              movie: movie,
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),

      // ── Recommend FAB ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(
          showRecommendModal(context, movie: detail.movie),
        ),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Recommend'),
      ),
    );
  }
}

// ─── Content body

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.posterWidth,
    required this.posterHeight,
    required this.movieId,
    required this.movieTitle,
    required this.movie,
  });

  final MovieDetail detail;
  final double posterWidth;
  final double posterHeight;
  final int movieId;
  final String movieTitle;
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Poster + title row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Hero poster
              Hero(
                tag: 'movie-poster-$movieId',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterPath.isNotEmpty
                        ? '${AppConfig.tmdbImageBaseUrl}${movie.posterPath}'
                        : '',
                    width: posterWidth,
                    height: posterHeight,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: posterWidth,
                      height: posterHeight,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: posterWidth,
                      height: posterHeight,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(Icons.movie_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                    ),
                    if (detail.tagline.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '"${detail.tagline}"',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _QuickMeta(movie: movie, runtime: detail.runtime),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Stats row ──
          _StatsRow(detail: detail),

          // ── Genre chips ──
          if (detail.genreNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            _GenreChips(genres: detail.genreNames),
          ],

          // ── Overview ──
          if (movie.overview.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Storyline',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _ExpandableOverview(text: movie.overview),
          ],

          // ── Cast ──
          if (detail.cast.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cast & Crew',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _CastRow(cast: detail.cast),
          ],
        ],
      ),
    );
  }
}

// ─── Stats row

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    final runtime = detail.runtime;
    final runtimeStr =
        runtime > 0 ? '${runtime ~/ 60}h ${runtime % 60}m' : '—';
    final year = detail.movie.releaseDate.length >= 4
        ? detail.movie.releaseDate.substring(0, 4)
        : '—';
    final score = detail.movie.voteAverage;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _StatCell(
            value: score.toStringAsFixed(1),
            label: 'IMDB Score',
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
          ),
          _StatDivider(),
          _StatCell(
            value: runtimeStr,
            label: 'Runtime',
            icon: Icons.access_time_rounded,
          ),
          _StatDivider(),
          _StatCell(
            value: year,
            label: 'Released',
            icon: Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor ?? cs.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).dividerColor,
    );
  }
}

// ─── Genre chips

class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: genres
          .map(
            (g) => Chip(
              label: Text(g),
              labelStyle: Theme.of(context).textTheme.labelMedium,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }
}

// ─── Expandable overview

class _ExpandableOverview extends StatefulWidget {
  const _ExpandableOverview({required this.text});

  final String text;

  @override
  State<_ExpandableOverview> createState() => _ExpandableOverviewState();
}

class _ExpandableOverviewState extends State<_ExpandableOverview> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.8),
          height: 1.6,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: HtmlWidget(
            widget.text,
            textStyle: textStyle,
          ),
          secondChild: HtmlWidget(
            widget.text,
            textStyle: textStyle,
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 250),
        ),
        if (!_expanded)
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Read more →',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _expanded = false),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Show less',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Quick meta (below title)

class _QuickMeta extends StatelessWidget {
  const _QuickMeta({required this.movie, required this.runtime});

  final Movie movie;
  final int runtime;

  @override
  Widget build(BuildContext context) {
    final year = movie.releaseDate.length >= 4
        ? movie.releaseDate.substring(0, 4)
        : '';
    final runtimeStr =
        runtime > 0 ? '${runtime ~/ 60}h ${runtime % 60}m' : '';
    final color = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.6);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
            const SizedBox(width: 3),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (year.isNotEmpty)
          Text(year, style: TextStyle(fontSize: 13, color: color)),
        if (runtimeStr.isNotEmpty)
          Text(runtimeStr, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}

// ─── Cast row

class _CastRow extends StatelessWidget {
  const _CastRow({required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => CastCardWidget(member: cast[index]),
      ),
    );
  }
}
