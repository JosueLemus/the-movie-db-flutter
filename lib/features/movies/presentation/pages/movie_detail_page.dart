import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
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

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.detail, required this.isFavorite});

  final MovieDetail detail;
  final bool isFavorite;

  static const double _carouselHeight = 280;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DetailCubit>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _carouselHeight,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: cubit.toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarouselWidget(paths: detail.backdropPaths),
            ),
          ),
          SliverToBoxAdapter(
            child: _DetailContent(detail: detail),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    final movie = detail.movie;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _MetaRow(movie: movie, runtime: detail.runtime),
          if (detail.tagline.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '"${detail.tagline}"',
              style: textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (movie.overview.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Overview',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            HtmlWidget(movie.overview),
          ],
          if (detail.cast.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Cast',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _CastRow(cast: detail.cast),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.movie, required this.runtime});

  final Movie movie;
  final int runtime;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    final runtimeStr =
        runtime > 0 ? '${runtime ~/ 60}h ${runtime % 60}m' : '';

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: labelStyle,
            ),
          ],
        ),
        if (runtimeStr.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(runtimeStr, style: labelStyle),
            ],
          ),
        if (movie.releaseDate.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(movie.releaseDate, style: labelStyle),
            ],
          ),
      ],
    );
  }
}

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
