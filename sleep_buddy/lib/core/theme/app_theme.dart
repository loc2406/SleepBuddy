import 'package:flutter/material.dart';

import '../constants/color_constant.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorConstant.primary,
      brightness: Brightness.light,
      primary: ColorConstant.primary,
      secondary: ColorConstant.secondary,
      surface: ColorConstant.backgroundCard,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorConstant.background,
      primaryColor: ColorConstant.primary,
      canvasColor: ColorConstant.background,
      dividerColor: ColorConstant.border,
      splashColor: ColorConstant.primary.withOpacity(0.12),
      highlightColor: ColorConstant.primary.withOpacity(0.08),
      textTheme: _textTheme(
        primary: ColorConstant.textPrimary,
        secondary: ColorConstant.textSecondary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ColorConstant.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: ColorConstant.backgroundCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: ColorConstant.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorConstant.white,
        selectedItemColor: ColorConstant.primary,
        unselectedItemColor: ColorConstant.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: ColorConstant.white,
          backgroundColor: ColorConstant.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: ColorConstant.backgroundCard,
        borderColor: ColorConstant.border,
        textColor: ColorConstant.textPrimary,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorConstant.primary,
      brightness: Brightness.dark,
      primary: ColorConstant.primaryLight,
      secondary: const Color(0xFF7FA6F5),
      surface: const Color(0xFF171A32),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF101226),
      primaryColor: ColorConstant.primaryLight,
      canvasColor: const Color(0xFF101226),
      dividerColor: const Color(0xFF343957),
      splashColor: ColorConstant.primaryLight.withOpacity(0.16),
      highlightColor: ColorConstant.primaryLight.withOpacity(0.10),
      textTheme: _textTheme(
        primary: const Color(0xFFF5F6FF),
        secondary: const Color(0xFFB7BCD5),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF5F6FF),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF171A32),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF343957)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF171A32),
        selectedItemColor: ColorConstant.primaryLight,
        unselectedItemColor: Color(0xFFAEB4CD),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: ColorConstant.white,
          backgroundColor: ColorConstant.primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: const Color(0xFF171A32),
        borderColor: const Color(0xFF343957),
        textColor: const Color(0xFFF5F6FF),
      ),
    );
  }

  static TextTheme _textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: primary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: primary, fontSize: 16),
      bodyMedium: TextStyle(color: secondary, fontSize: 14),
      bodySmall: TextStyle(color: secondary, fontSize: 12),
      labelLarge: TextStyle(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static InputDecorationThemeData _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return InputDecorationThemeData(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: textColor.withOpacity(0.55)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: ColorConstant.primary,
          width: 2,
        ),
      ),
    );
  }
}
