import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

class CustomLoadingScreen extends StatelessWidget {
  final String message;
  final String? subMessage;

  // Evitar que Key se genere cada vez para prevenir conflictos
  static const Key _containerKey1 = Key('loadingContainer1');
  static const Key _containerKey2 = Key('loadingContainer2');
  static const Key _containerKey3 = Key('loadingContainer3');

  const CustomLoadingScreen({
    super.key,
    this.message = 'Cargando...',
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use appropriate colors based on theme
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondaryColor =
        isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;
    final textColor =
        isDarkMode ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              key: _containerKey1,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -30,
            child: Container(
              key: _containerKey2,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation container
                Container(
                  key: _containerKey3,
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/food-loading.json',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      frameRate: FrameRate.max,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Main message
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Sub message if provided
                if (subMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      subMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 32),

                // Animated progress indicator
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    backgroundColor: primaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
