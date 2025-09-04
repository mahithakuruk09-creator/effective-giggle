import 'package:flutter/material.dart';
class ScredexTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF000000),
          primary: Color(0xFFBFBFC8),
          secondary: Color(0xFF6E7689),
        ),
      );
}
