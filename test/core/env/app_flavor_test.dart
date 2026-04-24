import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';

void main() {
  group('AppConfig', () {
    test('tmdbBaseUrl returns correct URL', () {
      expect(AppConfig.tmdbBaseUrl, equals('https://api.themoviedb.org/3'));
    });

    test('tmdbImageBaseUrl returns correct URL', () {
      expect(
        AppConfig.tmdbImageBaseUrl,
        equals('https://image.tmdb.org/t/p/w500'),
      );
    });

    test('tmdbBackdropBaseUrl returns correct URL', () {
      expect(
        AppConfig.tmdbBackdropBaseUrl,
        equals('https://image.tmdb.org/t/p/w1280'),
      );
    });

    test('isDevelopment returns true for development flavor', () {
      AppConfig.flavor = AppFlavor.development;
      expect(AppConfig.isDevelopment, isTrue);
      expect(AppConfig.isProduction, isFalse);
    });

    test('isProduction returns true for production flavor', () {
      AppConfig.flavor = AppFlavor.production;
      expect(AppConfig.isProduction, isTrue);
      expect(AppConfig.isDevelopment, isFalse);
    });

    test('flavorName returns DEV for development', () {
      AppConfig.flavor = AppFlavor.development;
      expect(AppConfig.flavorName, equals('DEV'));
    });

    test('flavorName returns STG for staging', () {
      AppConfig.flavor = AppFlavor.staging;
      expect(AppConfig.flavorName, equals('STG'));
    });

    test('flavorName returns PROD for production', () {
      AppConfig.flavor = AppFlavor.production;
      expect(AppConfig.flavorName, equals('PROD'));
    });
  });
}
