// coverage:ignore-file
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
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
      child: _DetailView(movieId: movieId),
    );
  }
}

// ─── State views

class _DetailView extends StatelessWidget {
  const _DetailView({required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, DetailState>(
      builder: (context, state) => switch (state.status) {
        DetailStatus.loading => const _LoadingScaffold(),
        DetailStatus.error => _ErrorScaffold(
          message: state.error,
          onRetry: () => unawaited(context.read<DetailCubit>().load(movieId)),
        ),
        DetailStatus.loaded => _LoadedScaffold(
          detail: state.movieDetail!,
          isFavorite: state.isFavorite,
        ),
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.onRetry, this.message});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No se pudo cargar la película',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    'Verificá tu conexión a internet e intentá de nuevo.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main loaded scaffold

class _LoadedScaffold extends StatelessWidget {
  const _LoadedScaffold({
    required this.detail,
    required this.isFavorite,
  });

  final MovieDetail detail;
  final bool isFavorite;

  // Portrait poster fills ~55% of screen height on average phone.
  static const double _expandedHeight = 460;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DetailCubit>();
    final movie = detail.movie;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedHeight,
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
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _PosterHeroHeader(
                movie: movie,
                backdropPaths: detail.backdropPaths,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _DetailBody(detail: detail),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(
          showRecommendModal(context, movie: movie),
        ),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Recomendar'),
      ),
    );
  }
}

// ─── Hero poster header

class _PosterHeroHeader extends StatefulWidget {
  const _PosterHeroHeader({
    required this.movie,
    required this.backdropPaths,
  });

  final Movie movie;
  final List<String> backdropPaths;

  @override
  State<_PosterHeroHeader> createState() => _PosterHeroHeaderState();
}

class _PosterHeroHeaderState extends State<_PosterHeroHeader> {
  int _current = 0;

  List<String> get _imageUrls {
    final posterFallback = widget.movie.posterPath.isNotEmpty
        ? '${AppConfig.tmdbImageBaseUrl}${widget.movie.posterPath}'
        : null;

    final urls = widget.backdropPaths
        .where((p) => p.isNotEmpty)
        .map((p) => '${AppConfig.tmdbBackdropBaseUrl}$p')
        .toList();

    if (urls.isEmpty && posterFallback != null) return [posterFallback];
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _imageUrls;
    final cs = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1,
            autoPlay: urls.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.easeInOutCubic,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          items: List.generate(urls.length, (i) {
            final child = CachedNetworkImage(
              imageUrl: urls[i],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, _) => ColoredBox(
                color: cs.surfaceContainerHighest,
              ),
              errorWidget: (_, _, _) => ColoredBox(
                color: cs.surfaceContainerHighest,
                child: const Icon(Icons.movie_outlined, size: 48),
              ),
            );
            // Wrap only the first slide with Hero so the transition works
            return i == 0
                ? Hero(tag: 'movie-poster-${widget.movie.id}', child: child)
                : child;
          }),
        ),
        // Bottom gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.4, 0.72, 1.0],
              ),
            ),
          ),
        ),
        // Title overlay + dot indicators
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeaderTitleOverlay(movie: widget.movie),
              if (urls.length > 1) ...[
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    urls.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(right: 5),
                      width: _current == i ? 18 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _current == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderTitleOverlay extends StatelessWidget {
  const _HeaderTitleOverlay({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
            shadows: [
              Shadow(blurRadius: 8, color: Colors.black54),
            ],
          ),
        ),
        const SizedBox(height: 6),
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
            if (movie.releaseDate.length >= 4) ...[
              const SizedBox(width: 12),
              const _Dot(),
              const SizedBox(width: 12),
              Text(
                movie.releaseDate.substring(0, 4),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.circle, size: 4, color: Colors.white54);
  }
}

// ─── Body content

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    final movie = detail.movie;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tagline
          if (detail.tagline.isNotEmpty) ...[
            Text(
              '"${detail.tagline}"',
              style: tt.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Stats row
          _StatsRow(detail: detail),

          // Genre chips
          if (detail.genreNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            _GenreChips(genres: detail.genreNames),
          ],

          // Storyline
          if (movie.overview.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Historia',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _ExpandableOverview(text: movie.overview),
          ],

          // Cast
          if (detail.cast.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Elenco',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
    final rt = detail.runtime;
    final runtimeStr = rt > 0 ? '${rt ~/ 60}h ${rt % 60}m' : '—';
    final year = detail.movie.releaseDate.length >= 4
        ? detail.movie.releaseDate.substring(0, 4)
        : '—';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _StatCell(
            value: detail.movie.voteAverage.toStringAsFixed(1),
            label: 'IMDB Score',
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
          ),
          _Divider(),
          _StatCell(
            value: runtimeStr,
            label: 'Duración',
            icon: Icons.access_time_rounded,
          ),
          _Divider(),
          _StatCell(
            value: year,
            label: 'Estreno',
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
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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

class _Divider extends StatelessWidget {
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
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: cs.onSurface.withValues(alpha: 0.8),
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: HtmlWidget(widget.text, textStyle: bodyStyle),
          secondChild: Text(
            widget.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: bodyStyle,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _expanded ? 'Ver menos' : 'Leer más →',
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
        itemBuilder: (_, i) => CastCardWidget(member: cast[i]),
      ),
    );
  }
}
