import 'package:flutter/material.dart';

class ScredexTypography {
  static const TextStyle heading =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const TextStyle body =
      TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

  static const TextTheme textTheme = TextTheme(
    titleLarge: heading,
    bodyMedium: body,
  );
}
