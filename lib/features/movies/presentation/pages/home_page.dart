// coverage:ignore-file
import 'dart:async';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:the_movie_db/app/view/app.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/router/app_router.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_bloc.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_event.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_state.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/featured_movie_card.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/genre_section_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        getGenres: sl<GetGenres>(),
        getMoviesByGenre: sl<GetMoviesByGenre>(),
        getPopularMovies: sl<GetPopularMovies>(),
      )..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _onMovieTap(BuildContext context, Movie movie) {
    unawaited(
      context.push(AppRoutes.movieDetail.replaceFirst(':id', '${movie.id}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state.status) {
            HomeStatus.initial || HomeStatus.loading => const _LoadingView(),
            HomeStatus.error => _ErrorView(message: state.error),
            HomeStatus.loaded => _LoadedView(
              state: state,
              onMovieTap: (movie) => _onMovieTap(context, movie),
            ),
          };
        },
      ),
    );
  }
}

// ─── Loaded ──────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state, required this.onMovieTap});

  final HomeState state;
  final void Function(Movie) onMovieTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _HomeAppBar(),
        // Featured popular carousel
        if (state.popularMovies.isNotEmpty)
          SliverToBoxAdapter(
            child: _FeaturedSection(
              movies: state.popularMovies,
              onTap: onMovieTap,
            ),
          ),
        // Genre sections
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverList.builder(
            itemCount: state.genres.length,
            itemBuilder: (_, index) {
              final genre = state.genres[index];
              final movies = state.moviesByGenre[genre.id] ?? [];
              final status =
                  state.genreMoviesStatus[genre.id] ??
                  GenreMoviesStatus.loading;
              return GenreSectionWidget(
                key: ValueKey(genre.id),
                genre: genre,
                movies: movies,
                status: status,
                onMovieTap: onMovieTap,
              );
            },
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }
}

// ─── AppBar──

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: const Text(
        'The Movie DB',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {},
          tooltip: 'Search',
        ),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, mode, _) => IconButton(
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => themeNotifier.value = mode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark,
            tooltip: 'Toggle theme',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── Featured carousel

class _FeaturedSection extends StatefulWidget {
  const _FeaturedSection({required this.movies, required this.onTap});

  final List<Movie> movies;
  final void Function(Movie) onTap;

  @override
  State<_FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<_FeaturedSection> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Popular Now',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 240,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 240,
              viewportFraction: 0.88,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayCurve: Curves.easeInOutCubic,
              enlargeCenterPage: true,
              enlargeFactor: 0.12,
              onPageChanged: (i, _) => setState(() => _current = i),
            ),
            items: widget.movies.map((movie) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FeaturedMovieCard(
                  movie: movie,
                  onTap: () => widget.onTap(movie),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.movies.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Loading / Error ──────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message ?? 'Something went wrong'),
        ],
      ),
    );
  }
}
