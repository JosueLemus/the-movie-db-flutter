import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/data/models/genre_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';

void main() {
  group('GenreModel', () {
    const tJson = <String, dynamic>{'id': 28, 'name': 'Action'};

    test('fromJson parses id and name correctly', () {
      final model = GenreModel.fromJson(tJson);
      expect(model.id, equals(28));
      expect(model.name, equals('Action'));
    });

    test('is a Genre entity', () {
      final model = GenreModel.fromJson(tJson);
      expect(model, isA<Genre>());
    });

    test('toJson serializes id and name correctly', () {
      const model = GenreModel(id: 28, name: 'Action');
      final json = model.toJson();
      expect(json['id'], equals(28));
      expect(json['name'], equals('Action'));
    });

    test('round-trip fromJson -> toJson', () {
      final model = GenreModel.fromJson(tJson);
      final json = model.toJson();
      expect(json, equals(tJson));
    });

    test('supports value equality via Equatable', () {
      final model1 = GenreModel.fromJson(tJson);
      final model2 = GenreModel.fromJson(tJson);
      expect(model1, equals(model2));
    });

    test('different ids produce different instances', () {
      final model1 = GenreModel.fromJson(const {'id': 28, 'name': 'Action'});
      final model2 = GenreModel.fromJson(const {'id': 12, 'name': 'Action'});
      expect(model1, isNot(equals(model2)));
    });
  });
}
