// coverage:ignore-file
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/add_recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_recommendations.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_cubit.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_state.dart';

const List<(String, IconData)> _kTags = [
  ('Must Watch', Icons.star),
  ('Great Story', Icons.menu_book_outlined),
  ('Stunning Visuals', Icons.movie_outlined),
  ('Amazing Soundtrack', Icons.headphones),
  ('Action-Packed', Icons.local_fire_department_outlined),
  ('Emotional', Icons.favorite_border),
  ('Funny', Icons.sentiment_very_satisfied_outlined),
  ('Disappointing', Icons.thumb_down_outlined),
];

Future<void> showRecommendModal(
  BuildContext context, {
  required Movie movie,
}) async {
  final success = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider(
      create: (_) {
        final cubit = RecommendCubit(
          getRecommendations: sl<GetRecommendations>(),
          addRecommendation: sl<AddRecommendation>(),
        );
        unawaited(cubit.load(movie.id));
        return cubit;
      },
      child: _RecommendModalContent(movie: movie),
    ),
  );
  if ((success ?? false) && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Recommendation sent!'),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _RecommendModalContent extends StatefulWidget {
  const _RecommendModalContent({required this.movie});

  final Movie movie;

  @override
  State<_RecommendModalContent> createState() => _RecommendModalContentState();
}

class _RecommendModalContentState extends State<_RecommendModalContent> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _selectedTags = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submit(RecommendCubit cubit) {
    unawaited(
      cubit.submit(
        movieId: widget.movie.id,
        movieTitle: widget.movie.title,
        comment: _controller.text,
        tags: _selectedTags.toList(),
      ),
    );
    _controller.clear();
    _focusNode.unfocus();
    setState(_selectedTags.clear);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<RecommendCubit, RecommendState>(
      listenWhen: (prev, curr) =>
          curr.status == RecommendStatus.error ||
          (prev.status == RecommendStatus.submitting &&
              curr.status == RecommendStatus.submitted),
      listener: (context, state) {
        if (state.status == RecommendStatus.submitted) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Something went wrong')),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            _DragHandle(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                children: [
                  _MovieInfoHeader(movie: widget.movie),
                  const SizedBox(height: 20),
                  _TagsSection(
                    selected: _selectedTags,
                    onToggle: _toggleTag,
                  ),
                  const SizedBox(height: 16),
                  _CommentField(
                    controller: _controller,
                    focusNode: _focusNode,
                  ),
                  const SizedBox(height: 12),
                  _SubmitButton(
                    onSubmit: () => _submit(context.read<RecommendCubit>()),
                    hasContent:
                        _selectedTags.isNotEmpty ||
                        _controller.text.trim().isNotEmpty,
                  ),
                  const Divider(height: 32),
                  _PastRecommendations(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _MovieInfoHeader extends StatelessWidget {
  const _MovieInfoHeader({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: movie.posterPath.isNotEmpty
                ? '${AppConfig.tmdbImageBaseUrl}${movie.posterPath}'
                : '',
            width: 72,
            height: 108,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => Container(
              width: 72,
              height: 108,
              color: Colors.grey[200],
              child: const Icon(Icons.movie, color: Colors.grey),
            ),
            placeholder: (_, _) => Container(
              width: 72,
              height: 108,
              color: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommend',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                movie.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (movie.releaseDate.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.releaseDate.length >= 4
                          ? movie.releaseDate.substring(0, 4)
                          : movie.releaseDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              if (movie.overview.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  movie.overview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  const _TagsSection({required this.selected, required this.onToggle});

  final Set<String> selected;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you describe it?',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kTags.map(((String label, IconData icon) tag) {
            final isSelected = selected.contains(tag.$1);
            return FilterChip(
              label: Text(tag.$1),
              avatar: Icon(tag.$2, size: 16),
              selected: isSelected,
              onSelected: (_) => onToggle(tag.$1),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 3,
      maxLength: 280,
      decoration: const InputDecoration(
        hintText: 'Add a comment (optional)…',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onSubmit, required this.hasContent});

  final VoidCallback onSubmit;
  final bool hasContent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendCubit, RecommendState>(
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: hasContent && !isSubmitting ? onSubmit : null,
            icon: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(isSubmitting ? 'Sending…' : 'Send Recommendation'),
          ),
        );
      },
    );
  }
}

class _PastRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendCubit, RecommendState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations (${state.recommendations.length})',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (state.recommendations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No recommendations yet. Be the first!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            else
              ...state.recommendations.map(
                (r) => _RecommendationTile(item: r),
              ),
          ],
        );
      },
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.item});

  final Recommendation item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  )
                  .toList(),
            ),
          if (item.comment.isNotEmpty) ...[
            if (item.tags.isNotEmpty) const SizedBox(height: 4),
            Text(item.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 4),
          Text(
            _formatDate(item.createdAt),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
