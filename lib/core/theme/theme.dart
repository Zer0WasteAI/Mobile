import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/theme/dark_theme.dart';
import 'package:zer0_waste_ai/core/theme/light_theme.dart';

/// Theme mode provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// App theme class that provides access to light and dark themes
class AppTheme {
  /// Get the light theme
  static ThemeData get lightTheme => LightTheme.theme;

  /// Get the dark theme
  static ThemeData get darkTheme => DarkTheme.theme;

  /// Get the current theme based on the theme mode
  static ThemeData getTheme(ThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }
}

/// Extension to get the current theme from BuildContext
extension ThemeExtension on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Check if the current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}