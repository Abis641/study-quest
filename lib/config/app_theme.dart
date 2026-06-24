// lib/config/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  // Deep space background with vibrant game-world accents
  static const Color background = Color(0xFF0D0F1A);
  static const Color surface = Color(0xFF161929);
  static const Color surfaceVariant = Color(0xFF1E2235);
  static const Color cardBase = Color(0xFF1A1E30);

  static const Color primary = Color(0xFF6C63FF);      // Electric indigo
  static const Color primaryLight = Color(0xFF9D96FF);
  static const Color secondary = Color(0xFFFFD166);    // Golden coin
  static const Color tertiary = Color(0xFF06D6A0);     // Mint green XP

  static const Color mathColor = Color(0xFF6C63FF);
  static const Color scienceColor = Color(0xFF06D6A0);
  static const Color englishColor = Color(0xFFFF6B6B);
  static const Color geographyColor = Color(0xFFFFD166);
  static const Color achievementColor = Color(0xFFFF9F1C);
  static const Color gamesColor = Color(0xFFCB3CFF);

  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFFAAB0CC);
  static const Color textMuted = Color(0xFF5A607A);

  static const Color correct = Color(0xFF06D6A0);
  static const Color incorrect = Color(0xFFFF6B6B);
  static const Color focusBorder = Color(0xFFFFD166);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D50BB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mathGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scienceGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF1A9E78)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient englishGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient geographyGradient = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0F1A), Color(0xFF121628)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme get textTheme => GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -1,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      );

  // ── Material Theme ─────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          surface: surface,
          error: incorrect,
          onPrimary: Colors.white,
          onSecondary: background,
          onSurface: textPrimary,
        ),
        textTheme: textTheme,
       cardTheme: CardThemeData(
          color: cardBase,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        focusColor: focusBorder.withOpacity(0.2),
      );
}

// ── Spacing constants ─────────────────────────────────────────────────────
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

// ── TV-specific sizes ──────────────────────────────────────────────────────
class TVSizes {
  static const double cardWidth = 280;
  static const double cardHeight = 200;
  static const double iconSize = 48;
  static const double avatarSize = 100;
  static const double buttonHeight = 64;
  static const double focusBorderWidth = 3;
}
