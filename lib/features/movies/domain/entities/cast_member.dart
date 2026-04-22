import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String profilePath;

  @override
  List<Object?> get props => [id, name, character, profilePath];
}
