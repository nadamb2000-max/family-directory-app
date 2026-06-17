import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF8B5CF6);
  static const background = Color(0xFFF5F7FF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Almarai',
    colorScheme: ColorScheme.fromSeed(seedColor: primary, secondary: secondary),
    scaffoldBackgroundColor: background,
    cardColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Almarai',
    colorScheme: ColorScheme.fromSeed(seedColor: primary, secondary: secondary, brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardColor: const Color(0xFF111827),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0),
  );
}