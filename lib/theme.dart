import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFe9c349);
  static const Color primaryFixedDim = Color(0xFFe9c349);
  static const Color background = Color(0xFF0f131f);
  static const Color surface = Color(0xFF0f131f);
  static const Color surfaceContainerLow = Color(0xFF171b28);
  static const Color surfaceContainer = Color(0xFF1b1f2c);
  static const Color surfaceContainerHigh = Color(0xFF262a37);
  static const Color surfaceContainerHighest = Color(0xFF313442);
  static const Color surfaceBright = Color(0xFF353946);
  static const Color outline = Color(0xFF908f9d);
  static const Color outlineVariant = Color(0xFF454652);
  static const Color secondary = Color(0xFFa9c7ff);
  static const Color error = Color(0xFFffb4ab);
  static const Color onSurface = Color(0xFFdfe2f3);
  static const Color onSurfaceVariant = Color(0xFFc6c5d4);
  static const Color surfaceVariant = Color(0xFF454652);
  static const Color onPrimary = Color(0xFF3c2f00);
}

class AppTextStyles {
  // Noto Serif
  static TextStyle headline(BuildContext context) => GoogleFonts.notoSerif(
    textStyle: const TextStyle(
      color: AppColors.onSurface,
      fontWeight: FontWeight.bold,
    ),
  );

  // Manrope
  static TextStyle body(BuildContext context) => GoogleFonts.manrope(
    textStyle: const TextStyle(
      color: AppColors.onSurface,
      fontWeight: FontWeight.normal,
    ),
  );
}

ThemeData buildAppTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.onSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
