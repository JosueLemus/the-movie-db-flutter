import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/router/app_router.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_genres.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movies_by_genre.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_bloc.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_event.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_state.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/genre_section_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        getGenres: sl<GetGenres>(),
        getMoviesByGenre: sl<GetMoviesByGenre>(),
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
      appBar: AppBar(
        title: const Text(
          'The Movie DB',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state.status) {
            HomeStatus.initial || HomeStatus.loading => const _LoadingView(),
            HomeStatus.error => _ErrorView(message: state.error),
            HomeStatus.loaded => _GenreListView(
                state: state,
                onMovieTap: (movie) => _onMovieTap(context, movie),
              ),
          };
        },
      ),
    );
  }
}

class _GenreListView extends StatelessWidget {
  const _GenreListView({required this.state, required this.onMovieTap});

  final HomeState state;
  final void Function(Movie) onMovieTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.genres.length,
      itemBuilder: (_, index) {
        final genre = state.genres[index];
        final movies = state.moviesByGenre[genre.id] ?? [];
        final status = state.genreMoviesStatus[genre.id] ??
            GenreMoviesStatus.loading;

        return GenreSectionWidget(
          key: ValueKey(genre.id),
          genre: genre,
          movies: movies,
          status: status,
          onMovieTap: onMovieTap,
        );
      },
    );
  }
}

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
