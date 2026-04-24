import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/features/movies/domain/entities/cast_member.dart';
import 'package:the_movie_db/features/movies/presentation/widgets/cast_card_widget.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    AppConfig.flavor = AppFlavor.development;
  });

  group('CastCardWidget', () {
    const tMember = CastMember(
      id: 10,
      name: 'Christian Bale',
      character: 'Bruce Wayne',
      profilePath: '/bale.jpg',
    );

    testWidgets('renders actor name', (tester) async {
      await tester.pumpApp(const CastCardWidget(member: tMember));

      expect(find.text('Christian Bale'), findsOneWidget);
    });

    testWidgets('renders character name', (tester) async {
      await tester.pumpApp(const CastCardWidget(member: tMember));

      expect(find.text('Bruce Wayne'), findsOneWidget);
    });

    testWidgets('renders without error when profilePath is empty', (
      tester,
    ) async {
      const noPhotoMember = CastMember(
        id: 11,
        name: 'Unknown Actor',
        character: 'Unknown Character',
        profilePath: '',
      );

      await tester.pumpApp(const CastCardWidget(member: noPhotoMember));

      expect(find.text('Unknown Actor'), findsOneWidget);
      expect(find.text('Unknown Character'), findsOneWidget);
    });
  });
}
