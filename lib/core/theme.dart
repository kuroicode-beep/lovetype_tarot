import 'package:flutter/material.dart';

/// LoveType-Tarot 앱 테마 상수
class AppTheme {
  AppTheme._();

  // ── 색상 ──────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF1A1028);
  static const Color backgroundCard = Color(0xFF2A1F3D);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE4C878);
  static const Color lavender = Color(0xFFB39DDB);
  static const Color lavenderDark = Color(0xFF7E57C2);
  static const Color textPrimary = Color(0xFFF0E6FF);
  static const Color textSecondary = Color(0xFF9E8FBB);
  static const Color textMuted = Color(0xFF6B5D80);
  static const Color divider = Color(0xFF3A2850);
  static const Color error = Color(0xFFCF6679);

  // 고대비 모드 색상
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcGold = Color(0xFFFFD700);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcAccent = Color(0xFFFFFF00);

  // ── 그림자 / 글로우 ────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: lavenderDark.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: gold.withValues(alpha: 0.4),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];

  // ── 테마 오브젝트 ──────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: lavender,
          surface: backgroundCard,
          error: error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundDark,
          elevation: 0,
          iconTheme: IconThemeData(color: gold),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: gold,
            side: const BorderSide(color: gold, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: lavender),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(color: textPrimary, fontSize: 16),
          bodyLarge: TextStyle(color: textSecondary, fontSize: 15),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
          labelSmall: TextStyle(color: textMuted, fontSize: 11),
        ),
        dividerColor: divider,
        useMaterial3: true,
      );

  static ThemeData get highContrastTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: hcBackground,
        colorScheme: const ColorScheme.dark(
          primary: hcGold,
          secondary: hcAccent,
          surface: Color(0xFF111111),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: hcText,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: hcText,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(color: hcText, fontSize: 16),
          bodyLarge: TextStyle(color: hcText, fontSize: 15),
          bodyMedium: TextStyle(color: hcText, fontSize: 13),
          labelSmall: TextStyle(color: hcText, fontSize: 11),
        ),
        useMaterial3: true,
      );
}
