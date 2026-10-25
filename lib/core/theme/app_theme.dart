import 'package:flutter/material.dart';

class AppColors {
  static const Color steps = Colors.green;
  static const Color calories = Colors.red;
  static const Color water = Colors.blue;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}