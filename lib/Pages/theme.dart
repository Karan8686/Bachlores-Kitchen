import 'package:flutter/material.dart';

class AppTheme {
  static const Color cream = Color(0xFFFEFAE0);
  static const Color darkBrown = Color(0xFFBC6C25);
  static const Color darkGreen = Color(0xFF283618);
  static const Color lightBrown = Color(0xFFDDA15E);
  // Define color constants
  static const Color lightGreen = Color(0xFF606C38);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: lightGreen,
      onPrimary: Colors.white,
      secondary: darkGreen,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: cream,
      onSurface: darkGreen,
      tertiary: lightBrown,
      onTertiary: Colors.black,
      primaryContainer: lightGreen.withValues(alpha: .8),
      secondaryContainer: darkGreen.withValues(alpha: .8),
      tertiaryContainer: lightBrown.withValues(alpha: .8),
    ),
    scaffoldBackgroundColor: cream,
    
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontFamily: "poppins", color: darkGreen),
      displayLarge:  TextStyle(fontFamily: "poppins", ),
      displayMedium:  TextStyle(fontFamily: "poppins", ),
      headlineLarge: TextStyle(
        fontFamily: "poppins",
          fontSize: 32, fontWeight: FontWeight.bold, color: darkGreen),
      headlineMedium: TextStyle(
          fontFamily: "poppins",
          fontSize: 28, fontWeight: FontWeight.w600, color: darkGreen),
      bodyLarge: TextStyle(fontFamily: "poppins",fontSize: 16, color: darkGreen),
      bodyMedium: TextStyle(fontFamily: "poppins",fontSize: 14, color: Colors.black54),
      labelLarge: TextStyle(
          fontFamily: "poppins",
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGreen,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightBrown,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: cream,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );

  static TextStyle poppins = const TextStyle(fontFamily: "poppins");
}
