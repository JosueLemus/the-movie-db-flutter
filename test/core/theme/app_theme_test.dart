import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('light', () {
      test('returns a ThemeData instance', () {
        expect(AppTheme.light, isA<ThemeData>());
      });

      test('has light brightness', () {
        expect(AppTheme.light.brightness, equals(Brightness.light));
      });

      test('uses Material 3', () {
        expect(AppTheme.light.useMaterial3, isTrue);
      });

      test('has correct scaffoldBackgroundColor', () {
        expect(
          AppTheme.light.scaffoldBackgroundColor,
          equals(const Color(0xFFF4F5FC)),
        );
      });

      test('has white card color', () {
        expect(AppTheme.light.cardColor, equals(Colors.white));
      });

      test('has white AppBar background', () {
        expect(
          AppTheme.light.appBarTheme.backgroundColor,
          equals(Colors.white),
        );
      });
    });

    group('dark', () {
      test('returns a ThemeData instance', () {
        expect(AppTheme.dark, isA<ThemeData>());
      });

      test('has dark brightness', () {
        expect(AppTheme.dark.brightness, equals(Brightness.dark));
      });

      test('uses Material 3', () {
        expect(AppTheme.dark.useMaterial3, isTrue);
      });

      test('has correct scaffoldBackgroundColor', () {
        expect(
          AppTheme.dark.scaffoldBackgroundColor,
          equals(const Color(0xFF0A0B14)),
        );
      });

      test('has correct card color', () {
        expect(
          AppTheme.dark.cardColor,
          equals(const Color(0xFF14162A)),
        );
      });

      test('has correct AppBar background color', () {
        expect(
          AppTheme.dark.appBarTheme.backgroundColor,
          equals(const Color(0xFF0A0B14)),
        );
      });

      test('has white AppBar foreground color', () {
        expect(
          AppTheme.dark.appBarTheme.foregroundColor,
          equals(Colors.white),
        );
      });

      test('has white12 divider color', () {
        expect(AppTheme.dark.dividerColor, equals(Colors.white12));
      });

      test('dark colorScheme has dark brightness', () {
        expect(
          AppTheme.dark.colorScheme.brightness,
          equals(Brightness.dark),
        );
      });
    });
  });
}
