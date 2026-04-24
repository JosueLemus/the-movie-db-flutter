import 'package:flutter/material.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/presentation/bloc/home_state.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_shimmer.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/movie_card_widget.dart';

// ISP: receives only what it needs — genre + movies + status
class GenreSectionWidget extends StatelessWidget {
  const GenreSectionWidget({
    required this.genre,
    required this.movies,
    required this.status,
    required this.onMovieTap,
    super.key,
  });

  final Genre genre;
  final List<Movie> movies;
  final GenreMoviesStatus status;
  final void Function(Movie) onMovieTap;

  static const double listHeight = 240;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            genre.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: listHeight,
          child: switch (status) {
            GenreMoviesStatus.loading => _ShimmerRow(),
            GenreMoviesStatus.error => const _ErrorRow(),
            GenreMoviesStatus.loaded => _MovieRow(
              movies: movies,
              onMovieTap: onMovieTap,
            ),
          },
        ),
      ],
    );
  }
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({required this.movies, required this.onMovieTap});

  final List<Movie> movies;
  final void Function(Movie) onMovieTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movies.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) => MovieCardWidget(
        movie: movies[index],
        onTap: () => onMovieTap(movies[index]),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) => const MovieCardShimmer(),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Error al cargar películas',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
