import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Import AppColors

class ImpactSummaryCard extends ConsumerWidget {
  const ImpactSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get colors from theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color progressBackgroundColor = primaryColor.withOpacity(0.25);
    final Color cardBorderColor = primaryColor.withOpacity(0.3);

    final impact = ref.watch(impactSummaryProvider);

    final String foodSavedFormatted = impact.foodSavedKg.toStringAsFixed(1);
    final String co2ReducedFormatted = impact.co2ReducedG.toStringAsFixed(0);

    // --- Define Progress Value and Text ---
    // TODO: Replace with actual progress calculation if needed
    const double progressValue = 0.75; // Example: 75%
    const String progressText = "75%";
    // --- End Progress Value and Text ---

    return InkWell(
      onTap: () {
        // Navegar al panel de impacto al tocar la tarjeta
        context.push('/impact');
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Card(
        elevation: isDark ? 1 : 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: cardBorderColor,
            width: 1,
          ), // Use theme border color
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: cardBackgroundColor, // Use theme card color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Has salvado ${foodSavedFormatted}kg de alimentos 🥦',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: mainTextColor, // Use theme text color
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Redujiste ${co2ReducedFormatted}g de CO₂ 🌱',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: mainTextColor, // Use theme text color
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.eco_outlined, color: primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Ver detalles de impacto',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: primaryColor, // Use theme primary color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // --- Updated Progress Indicator Section ---
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background + Progress Ring
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 8, // Adjust thickness like the image
                          color: primaryColor, // Use theme primary color
                          backgroundColor:
                              progressBackgroundColor, // Use theme progress background
                          strokeCap: StrokeCap.round, // Rounded ends
                        ),
                      ),
                      // Centered Content (Text + Icon)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            progressText,
                            style: GoogleFonts.inter(
                              fontSize: 18, // Adjust size as needed
                              fontWeight: FontWeight.bold,
                              color: primaryColor, // Use theme primary color
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // --- End Updated Progress Indicator Section ---
            ],
          ),
        ),
      ),
    );
  }
}
