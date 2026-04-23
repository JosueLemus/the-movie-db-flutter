import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF8B5CF6);
const _kDarkBg = Color(0xFF0A0B14);
const _kDarkSurface = Color(0xFF14162A);
const _kDarkCard = Color(0xFF1E2035);

abstract final class AppTheme {
  static ThemeData get light {
    final cs = ColorScheme.fromSeed(seedColor: _kPrimary);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFFF4F5FC),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: cs.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        selectedColor: _kPrimary.withValues(alpha: 0.15),
        checkmarkColor: _kPrimary,
      ),
    );
  }

  static ThemeData get dark {
    final cs = ColorScheme.fromSeed(
      seedColor: _kPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: _kDarkSurface,
      surfaceContainerHighest: _kDarkCard,
      surfaceContainerLow: _kDarkBg,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: _kDarkBg,
      cardColor: _kDarkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _kDarkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _kDarkCard,
        selectedColor: _kPrimary.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: Colors.white70),
        checkmarkColor: _kPrimary,
      ),
      dividerColor: Colors.white12,
    );
  }
}
