import 'package:flutter/material.dart';

/// App theme configurations providing Material 3 styling for Light and Dark modes.
class AppTheme {
  // Light Palette
  static const Color primaryLight = Color(0xFF2563EB); // Royal Blue
  static const Color onPrimaryLight = Colors.white;
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color cardBorderLight = Color(0xFFE2E8F0); // Slate 200

  // Dark Palette
  static const Color primaryDark = Color(0xFF60A5FA); // Sky Blue
  static const Color onPrimaryDark = Color(0xFF0F172A);
  static const Color backgroundDark = Color(0xFF0B1120); // Dark Navy Slate
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color cardBorderDark = Color(0xFF334155); // Slate 700

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      outline: cardBorderLight,
      outlineVariant: const Color(0xFFF1F5F9),
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorderLight, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: surfaceLight,
      indicatorColor: primaryLight.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryLight);
        }
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryLight);
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      outline: cardBorderDark,
      outlineVariant: const Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorderDark, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      iconTheme: IconThemeData(color: textPrimaryDark),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: surfaceDark,
      indicatorColor: primaryDark.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryDark);
        }
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryDark);
      }),
    ),
  );
}
