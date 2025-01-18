import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFF7F50),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFFFF7F50),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFF7F50)),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFFF7F50).withOpacity(0.1),
      labelStyle: const TextStyle(color: Color(0xFFFF7F50)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF7F50),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Color(0xFFFF7F50),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.grey[300]),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFF7F50)),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFFF7F50).withOpacity(0.3),
      labelStyle: const TextStyle(color: Color(0xFFFF7F50)),
    ),
  );
}
