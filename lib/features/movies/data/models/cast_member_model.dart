import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.id,
    required super.name,
    required super.character,
    required super.profilePath,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) =>
      CastMemberModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        character: json['character'] as String? ?? '',
        profilePath: json['profile_path'] as String? ?? '',
      );
}
