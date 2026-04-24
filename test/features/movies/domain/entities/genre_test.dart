import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/domain/entities/genre.dart';

void main() {
  group('Genre', () {
    const tGenre = Genre(id: 28, name: 'Action');

    test('supports value equality', () {
      const other = Genre(id: 28, name: 'Action');
      expect(tGenre, equals(other));
    });

    test('genres with different ids are not equal', () {
      const other = Genre(id: 12, name: 'Adventure');
      expect(tGenre, isNot(equals(other)));
    });

    test('genres with same id but different name are not equal', () {
      const other = Genre(id: 28, name: 'Drama');
      expect(tGenre, isNot(equals(other)));
    });

    test('props contains id and name', () {
      expect(tGenre.props, [28, 'Action']);
    });

    test('id is assigned correctly', () {
      expect(tGenre.id, equals(28));
    });

    test('name is assigned correctly', () {
      expect(tGenre.name, equals('Action'));
    });
  });
}
