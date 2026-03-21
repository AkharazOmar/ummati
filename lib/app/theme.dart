import 'package:flutter/material.dart';

class UmmatiTheme {
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFC9A84C);
  static const Color backgroundParchment = Color(0xFFFAF7F0);
  static const Color darkText = Color(0xFF2D2D2D);
  static const Color lightText = Color(0xFF6B6B6B);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static const String fontFamilyArabic = 'Amiri';
  static const String fontFamilyLatin = 'Nunito';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamilyLatin,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGold,
        surface: backgroundParchment,
        onPrimary: Colors.white,
        onSecondary: darkText,
        onSurface: darkText,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundParchment,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 2,
        shadowColor: primaryGreen.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilyLatin,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamilyLatin,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 16,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamilyLatin,
          fontSize: 14,
          color: lightText,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamilyArabic,
          fontSize: 24,
          color: darkText,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: primaryGreen.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}
