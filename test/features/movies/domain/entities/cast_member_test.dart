import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';

void main() {
  group('CastMember', () {
    const tCast = CastMember(
      id: 100,
      name: 'John Doe',
      character: 'Hero',
      profilePath: '/profile.jpg',
    );

    test('supports value equality', () {
      const other = CastMember(
        id: 100,
        name: 'John Doe',
        character: 'Hero',
        profilePath: '/profile.jpg',
      );
      expect(tCast, equals(other));
    });

    test('cast members with different ids are not equal', () {
      const other = CastMember(
        id: 200,
        name: 'John Doe',
        character: 'Hero',
        profilePath: '/profile.jpg',
      );
      expect(tCast, isNot(equals(other)));
    });

    test('cast members with different names are not equal', () {
      const other = CastMember(
        id: 100,
        name: 'Jane Doe',
        character: 'Hero',
        profilePath: '/profile.jpg',
      );
      expect(tCast, isNot(equals(other)));
    });

    test('cast members with different characters are not equal', () {
      const other = CastMember(
        id: 100,
        name: 'John Doe',
        character: 'Villain',
        profilePath: '/profile.jpg',
      );
      expect(tCast, isNot(equals(other)));
    });

    test('props contains all fields', () {
      expect(tCast.props, [100, 'John Doe', 'Hero', '/profile.jpg']);
    });

    test('fields are assigned correctly', () {
      expect(tCast.id, equals(100));
      expect(tCast.name, equals('John Doe'));
      expect(tCast.character, equals('Hero'));
      expect(tCast.profilePath, equals('/profile.jpg'));
    });
  });
}
