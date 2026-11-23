import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0B0F0E);
  static const card = Color(0xFF151B19);
  static const border = Color(0xFF232B28);
  static const accent = Color(0xFF8CC63F);
  static const up = Color(0xFF3DDC84);
  static const down = Color(0xFFFF5252);
  static const muted = Color(0xFF8A9691);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.bg,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
    ),
    dividerColor: AppColors.border,
  );
}
