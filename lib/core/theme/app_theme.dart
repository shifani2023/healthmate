import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F9D8A);
  static const Color primaryDark = Color(0xFF0B6E7F);
  static const Color background = Color(0xFFF4F7FA);
  static const Color textDark = Color(0xFF1F2A37);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color steps = Color(0xFF22C55E);
  static const Color calories = Color(0xFFEF4444);
  static const Color water = Color(0xFF3B82F6);
}

class AppStyles {
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(14),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

class Formatters {
  // 7850 -> 7,850
  static String number(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
  }
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      );
}