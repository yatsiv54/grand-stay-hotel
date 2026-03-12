import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFD71920);
  static const Color primaryRedDark = Color(0xFFC01018);
  static const Color textPrimary = Color(0xFF191919);
  static const Color textSecondary = Color(0xFF555555);
  static const Color surface = Color(0xFFF6F6F6);
  static const Color card = Colors.white;

  static ThemeData buildTheme(TextStyle font) {
    final base = ThemeData.light();
    return base.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w900,
            );
          }
          return const TextStyle(color: Color.fromRGBO(169, 187, 198, 1));
        }),
      ),
      scaffoldBackgroundColor: surface,
      colorScheme: base.colorScheme.copyWith(
        primary: Color.fromRGBO(83, 177, 87, 1),
        surface: surface,
      ),
      textTheme: _buildTextTheme(base.textTheme, font),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: card,
        foregroundColor: textPrimary,
      ),
      useMaterial3: true,
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, TextStyle font) {
    return base.copyWith(
      headlineLarge: font.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        color: textPrimary,
      ),
      headlineMedium: font.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: textPrimary,
      ),
      headlineSmall: font.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: textPrimary,
      ),
      titleMedium: font.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: textPrimary,
      ),
      titleSmall: font.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: textPrimary,
      ),
      bodyLarge: font.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: textSecondary,
      ),
      bodyMedium: font.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: textSecondary,
      ),
      labelLarge: font.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.white,
      ),
    );
  }
}
