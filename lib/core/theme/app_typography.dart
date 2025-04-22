import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography styles using Google Fonts Inter
class AppTypography {
  /// Creates text themes for both light and dark modes
  static TextTheme createTextTheme(Color mainTextColor, Color secondaryTextColor) {
    return TextTheme(
      // H1: 22px Bold
      displayLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: mainTextColor,
      ),
      // H2: 17px Bold
      displayMedium: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: mainTextColor,
      ),
      // H3: 15px Bold
      displaySmall: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: mainTextColor,
      ),
      // BodyText1: 17px Medium
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      // BodyText2: 15px Medium
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      // Caption: 12px Regular
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
    );
  }
}