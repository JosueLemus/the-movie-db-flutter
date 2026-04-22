import 'package:the_movie_db/features/movies/domain/entities/genre.dart';

class GenreModel extends Genre {
  const GenreModel({required super.id, required super.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
