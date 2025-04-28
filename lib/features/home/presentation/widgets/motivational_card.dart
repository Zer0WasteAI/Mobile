import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MotivationalCard extends StatelessWidget {
  const MotivationalCard({super.key});

  // Define colors locally
  static const Color _primaryColor = Color(0xFF00B894);
  // static const Color _accentColor = Color(0xFFF07548); // Alternative color

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout if needed, though fixed layout for now
    // final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      // Adjust vertical padding if needed
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
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
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16), // Space between text and button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement navigation to scan screen
                    print("Navigate to Scan Screen");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _primaryColor,
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
