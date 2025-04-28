import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider

class ImpactSummaryCard extends ConsumerWidget {
  const ImpactSummaryCard({super.key});

  // Define colors locally
  static const Color _primaryColor = Color(0xFF00B894);
  static const Color _mainTextColor = Color(0xFF3A3A3A);
  static const Color _secondaryTextColor = Color(0xFF70605A);
  // Define a slightly lighter green for the background track, based on image
  static final Color _progressBackgroundColor = _primaryColor.withOpacity(0.25);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impact = ref.watch(impactSummaryProvider);

    final String foodSavedFormatted = impact.foodSavedKg.toStringAsFixed(1);
    final String co2ReducedFormatted = impact.co2ReducedG.toStringAsFixed(0);

    // --- Define Progress Value and Text ---
    // TODO: Replace with actual progress calculation if needed
    const double progressValue = 0.75; // Example: 75%
    const String progressText = "75%";
    // --- End Progress Value and Text ---

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _primaryColor.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
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
                      color: _mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Redujiste ${co2ReducedFormatted}g de CO₂ 🌱',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _mainTextColor,
                    ),
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
                        color: _primaryColor, // Darker green for progress
                        backgroundColor:
                            _progressBackgroundColor, // Lighter green background track
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
                            color: _primaryColor, // Use primary green color
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
    );
  }
}
