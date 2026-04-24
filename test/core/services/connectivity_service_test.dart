import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/core/services/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityController =
        StreamController<List<ConnectivityResult>>.broadcast();
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() async {
    await connectivityController.close();
  });

  group('ConnectivityService', () {
    test('isConnected returns true when wifi connected', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);

      final service = ConnectivityService(mockConnectivity);
      final result = await service.isConnected;

      expect(result, isTrue);
    });

    test('isConnected returns false when no connectivity', () async {
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      final service = ConnectivityService(mockConnectivity);
      final result = await service.isConnected;

      expect(result, isFalse);
    });

    test(
      'isConnectedStream emits true when connectivity_plus reports wifi',
      () async {
        final service = ConnectivityService(mockConnectivity);

        final future = service.isConnectedStream.first;
        connectivityController.add([ConnectivityResult.wifi]);
        final emitted = await future;

        expect(emitted, isTrue);
      },
    );

    test(
      'isConnectedStream emits false when connectivity_plus reports none',
      () async {
        final service = ConnectivityService(mockConnectivity);

        final future = service.isConnectedStream.first;
        connectivityController.add([ConnectivityResult.none]);
        final emitted = await future;

        expect(emitted, isFalse);
      },
    );

    test('markOnline adds true to the stream', () async {
      final service = ConnectivityService(mockConnectivity);

      final future = service.isConnectedStream.first;
      service.markOnline();
      final emitted = await future;

      expect(emitted, isTrue);
    });

    test('multiple markOnline calls each emit true', () async {
      final service = ConnectivityService(mockConnectivity);

      final emitted = <bool>[];
      final subscription = service.isConnectedStream.listen(emitted.add);

      service
        ..markOnline()
        ..markOnline();

      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(emitted, equals([true, true]));
    });
  });
}
