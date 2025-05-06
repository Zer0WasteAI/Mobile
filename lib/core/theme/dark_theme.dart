import 'package:flutter/material.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/core/theme/app_typography.dart';

/// Dark theme configuration for the app
class DarkTheme {
  /// Creates the dark theme
  static ThemeData get theme {
    final ColorScheme colorScheme = ColorScheme(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkMainText,
      onError: Colors.white,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.createTextTheme(
        AppColors.darkMainText,
        AppColors.darkSecondaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkFormBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkError),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkLabel,
        labelStyle: TextStyle(color: AppColors.darkMainText),
      ),
      cardTheme: CardTheme(color: AppColors.darkSurface),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: AppColors.darkMainText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.darkSecondaryText,
          fontSize: 16,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
      ),
    );
  }
}
