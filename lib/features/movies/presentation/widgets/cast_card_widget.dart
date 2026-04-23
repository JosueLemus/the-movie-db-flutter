import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';

class CastCardWidget extends StatelessWidget {
  const CastCardWidget({required this.member, super.key});

  final CastMember member;

  static const double _avatarSize = 64;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_avatarSize / 2),
            child: CachedNetworkImage(
              imageUrl: member.profilePath.isNotEmpty
                  ? '${AppConfig.tmdbImageBaseUrl}${member.profilePath}'
                  : '',
              width: _avatarSize,
              height: _avatarSize,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const _AvatarPlaceholder(size: _avatarSize),
              errorWidget: (context, url, _) =>
                  const _AvatarPlaceholder(size: _avatarSize),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }
}
