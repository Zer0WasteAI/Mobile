import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Import AppColors
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:zer0_waste_ai/features/scan/presentation/widgets/scan_options_modal.dart'; // Import Modal
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart'; // Import Provider

// Change to ConsumerWidget to use ref
class MotivationalCard extends ConsumerWidget {
  const MotivationalCard({super.key});

  // Remove hardcoded colors
  // static const Color _primaryColor = Color(0xFF00B894);
  // static const Color _accentColor = Color(0xFFF07548); // Alternative color

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get screen width for responsive layout if needed, though fixed layout for now
    // final screenWidth = MediaQuery.of(context).size.width;

    // Get colors from theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color onPrimaryColor =
        isDark
            ? AppColors
                .darkMainText // Fallback for dark: Use main dark text
            : Colors.white; // Fallback for light: Use white
    final Color cardBackgroundColor =
        isDark
            ? AppColors.darkSurface
            : primaryColor; // Dark uses surface, light uses primary
    final Color textColor =
        isDark
            ? AppColors.darkMainText
            : onPrimaryColor; // Text color contrasts with background
    final Color buttonBackgroundColor =
        isDark
            ? AppColors
                .darkPrimary // Dark: Primary button color
            : Colors.white; // Light: White button
    final Color buttonForegroundColor =
        isDark
            ? AppColors
                .darkMainText // Fallback for dark: Use main dark text
            : primaryColor; // Light: Primary text color

    return Container(
      width: double.infinity,
      // Adjust vertical padding if needed
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Use theme-aware background
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: cardBackgroundColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Use Row for side-by-side layout
      child: Row(
        // Align items vertically in the center of the row
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Illustration
          Expanded(
            flex: 2, // Give illustration slightly less space than text maybe
            child: Image.asset(
              'assets/icons/home/image_motivational.png', // Use the provided image path
              height: 160, // Adjust height as needed
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16), // Spacing between image and text column
          // Right side: Text and Button
          Expanded(
            flex: 3, // Give text/button more space
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // Align text and button to the start (left) of the column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Recuerda escanear tus ingredientes y evitar desperdicios hoy!',
                  // Adjust text alignment if needed, start is default for Column
                  // textAlign: TextAlign.start,
                  style: GoogleFonts.inter(
                    fontSize: 16, // Keep font size reasonable
                    fontWeight: FontWeight.w600, // Slightly bolder maybe
                    color: textColor, // Use theme-aware text color
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16), // Space between text and button
                ElevatedButton(
                  onPressed: () {
                    // Set the modal state to open
                    ref.read(isScanModalOpenProvider.notifier).state = true;
                    // Show the modal bottom sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (_) => ScanOptionsModal(
                            onClose: () {
                              // Reset the provider state when closing via the close button
                              ref.read(isScanModalOpenProvider.notifier).state =
                                  false;
                              Navigator.of(
                                context,
                              ).pop(); // Close the bottom sheet
                            },
                          ),
                    ).whenComplete(() {
                      // Ensure the state is reset if the modal is dismissed by dragging
                      // Check if it wasn't already reset by button press
                      if (ref.read(isScanModalOpenProvider)) {
                        ref.read(isScanModalOpenProvider.notifier).state =
                            false;
                      }
                    });
                    /* // Previous navigation code
                    context.pushNamed(
                      'addScanItem',
                      pathParameters: {'itemType': 'ingredient'},
                    );
                    */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        buttonBackgroundColor, // Use theme-aware button bg
                    foregroundColor:
                        buttonForegroundColor, // Use theme-aware button text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    // Ensure button doesn't stretch full width unless needed
                    // fixedSize: Size(width, height)
                  ),
                  child: Text(
                    'Escanear Ahora',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
