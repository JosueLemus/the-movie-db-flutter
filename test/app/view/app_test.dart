import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/app/view/app.dart';

void main() {
  group('App', () {
    test('themeNotifier defaults to dark mode', () {
      expect(themeNotifier.value, equals(ThemeMode.dark));
    });

    test('themeNotifier can be toggled to light mode', () {
      themeNotifier.value = ThemeMode.light;
      expect(themeNotifier.value, equals(ThemeMode.light));
      // restore
      themeNotifier.value = ThemeMode.dark;
    });
  });
}
