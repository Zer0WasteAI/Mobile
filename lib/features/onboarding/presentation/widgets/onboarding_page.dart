import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Onboarding page widget
class OnboardingPage extends StatelessWidget {
  /// Image path
  final String imagePath;
  
  /// Title
  final String title;
  
  /// Description
  final String description;
  
  /// Constructor
  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            imagePath,
            height: size.height * 0.35,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}