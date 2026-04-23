import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/features/movies/domain/entities/recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/add_recommendation.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_recommendations.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_cubit.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/recommend_state.dart';

Future<void> showRecommendModal(
  BuildContext context, {
  required int movieId,
  required String movieTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider(
      create: (_) {
        final cubit = RecommendCubit(
          getRecommendations: sl<GetRecommendations>(),
          addRecommendation: sl<AddRecommendation>(),
        );
        unawaited(cubit.load(movieId));
        return cubit;
      },
      child: _RecommendModalContent(
        movieId: movieId,
        movieTitle: movieTitle,
      ),
    ),
  );
}

class _RecommendModalContent extends StatefulWidget {
  const _RecommendModalContent({
    required this.movieId,
    required this.movieTitle,
  });

  final int movieId;
  final String movieTitle;

  @override
  State<_RecommendModalContent> createState() => _RecommendModalContentState();
}

class _RecommendModalContentState extends State<_RecommendModalContent> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(RecommendCubit cubit) {
    unawaited(
      cubit.submit(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        comment: _controller.text,
      ),
    );
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<RecommendCubit, RecommendState>(
      listenWhen: (prev, curr) => curr.status == RecommendStatus.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error ?? 'Something went wrong')),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModalHeader(movieTitle: widget.movieTitle),
            const SizedBox(height: 16),
            _RecommendationsList(),
            const SizedBox(height: 12),
            _InputRow(
              controller: _controller,
              focusNode: _focusNode,
              onSubmit: () =>
                  _submit(context.read<RecommendCubit>()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.movieTitle});

  final String movieTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommend',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                movieTitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _RecommendationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendCubit, RecommendState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.recommendations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No recommendations yet. Be the first!',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: state.recommendations.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) =>
                _RecommendationTile(item: state.recommendations[index]),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.comment,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(item.createdAt),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey),
          ),
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

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendCubit, RecommendState>(
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isSubmitting,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write your recommendation…',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: 8),
            if (isSubmitting)
              const SizedBox(
                width: 48,
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              IconButton.filled(
                icon: const Icon(Icons.send),
                onPressed: onSubmit,
              ),
          ],
        );
      },
    );
  }
}
