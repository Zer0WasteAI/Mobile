import 'package:flutter/material.dart';

/// App color palette for both light and dark themes
class AppColors {
  // Light Theme Colors
  static const lightPrimary = Color(0xFF00B894);
  static const lightSecondary = Color(0xFFF07548);
  static const lightLabel = Color(0xFFFFE066);
  static const lightMainText = Color(0xFF3A3A3A);
  static const lightSecondaryText = Color(0xFF70605A);
  static const lightOutline = Color(0xFF629B8F);
  static const lightFormBackground = Color(0xFFEDF2F4);
  static const lightError = Color(0xFFEF233C);
  static const lightBackground = Color(0xFFFAF9F6);

  // General Semantic Colors (can be used directly or mapped from theme colors)
  static const Color error = Color(0xFFEF233C);
  static const Color warning = Color(
    0xFFFFE066,
  ); // Original light yellow (e.g., for badges)
  static const Color warningTextLight = Color(
    0xFFBC6C00,
  ); // Darker amber for light theme text
  static const Color warningTextDark = Color(
    0xFFFFD54F,
  ); // Readable yellow for dark theme text

  // --- Component Specific Colors ---
  // Bottom Nav Bar
  static const lightBottomNavBackground = Color(
    0xFFFFFFFF,
  ); // Example: White for light
  static const darkBottomNavBackground = Color(
    0xFF1E1E1E,
  ); // Example: Surface color for dark
  static const unselectedNavColorScanActive =
      Colors.white70; // White with opacity

  // Floating Action Button
  static const lightFabBackground = Color(
    0xFF5A5A5A,
  ); // Dark Grey for light theme FAB
  static const darkFabBackground = Color(
    0xFF3A3A3A,
  ); // Lighter Grey for dark theme FAB
  static const fabIcon = Colors.white; // Icon is always white

  // OTP Input
  static const lightOtpFill = Color(0xFFEAEAEA); // Light grey fill
  static const darkOtpFill = Color(0xFF2D2D2D); // Dark grey fill

  // Dark Theme Colors
  static const darkPrimary = Color(0xFF00B894);
  static const darkSecondary = Color(0xFFF07548);
  static const darkLabel = Color(0xFFFFE066);
  static const darkMainText = Color(0xFFFAF9F6);
  static const darkSecondaryText = Color(0xFFDCDCDC);
  static const darkOutline = Color(0xFF80B7AB);
  static const darkFormBackground = Color(0xFF2E2E2E);
  static const darkError = Color(0xFFEF233C);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);

  // --- Meal Type Colors ---
  static const breakfastColor = Color(0xFFFF9800); // Orange
  static const lunchColor = Color(0xFF4CAF50); // Green
  static const dinnerColor = Color(0xFF9C27B0); // Purple
  static const snackColor = Color(0xFF2196F3); // Blue
  static const genericMealColor = Color(0xFF607D8B); // Blue Grey

  // --- Quick Actions Colors ---
  static const mealPlanningColor = Color(0xFF4CAF50); // Green
  static const weeklyPlannerColor = lightPrimary; // Use primary color
  static const smartRecipesColor = Color(0xFF9C27B0); // Purple
  static const environmentalImpactColor = Color(0xFF009688); // Teal
}
