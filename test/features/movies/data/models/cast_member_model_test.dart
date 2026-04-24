import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/features/movies/data/models/cast_member_model.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';

void main() {
  group('CastMemberModel', () {
    final tJson = <String, dynamic>{
      'id': 819,
      'name': 'Edward Norton',
      'character': 'The Narrator',
      'profile_path': '/eIkFHNlfretLS1spAcIoihKUS62.jpg',
    };

    test('fromJson parses all fields correctly', () {
      final model = CastMemberModel.fromJson(tJson);
      expect(model.id, equals(819));
      expect(model.name, equals('Edward Norton'));
      expect(model.character, equals('The Narrator'));
      expect(model.profilePath, equals('/eIkFHNlfretLS1spAcIoihKUS62.jpg'));
    });

    test('fromJson uses empty string defaults for nullable fields', () {
      final model = CastMemberModel.fromJson(const {'id': 100});
      expect(model.name, equals(''));
      expect(model.character, equals(''));
      expect(model.profilePath, equals(''));
    });

    test('is a CastMember entity', () {
      final model = CastMemberModel.fromJson(tJson);
      expect(model, isA<CastMember>());
    });

    test('supports value equality via Equatable', () {
      final model1 = CastMemberModel.fromJson(tJson);
      final model2 = CastMemberModel.fromJson(tJson);
      expect(model1, equals(model2));
    });

    test('different ids produce non-equal instances', () {
      final model1 = CastMemberModel.fromJson(tJson);
      final model2 = CastMemberModel.fromJson({...tJson, 'id': 999});
      expect(model1, isNot(equals(model2)));
    });

    test('null name falls back to empty string', () {
      final model = CastMemberModel.fromJson(const {'id': 100, 'name': null});
      expect(model.name, equals(''));
    });

    test('null profile_path falls back to empty string', () {
      final model = CastMemberModel.fromJson(const {
        'id': 100,
        'name': 'Actor',
        'character': 'Role',
        'profile_path': null,
      });
      expect(model.profilePath, equals(''));
    });

    test('toJson serializes all fields correctly', () {
      final model = CastMemberModel.fromJson(tJson);
      final json = model.toJson();
      expect(json['id'], equals(819));
      expect(json['name'], equals('Edward Norton'));
      expect(json['character'], equals('The Narrator'));
      expect(json['profile_path'], equals('/eIkFHNlfretLS1spAcIoihKUS62.jpg'));
    });

    test('toJson round-trips through fromJson', () {
      final original = CastMemberModel.fromJson(tJson);
      final roundTripped = CastMemberModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });
  });
}
