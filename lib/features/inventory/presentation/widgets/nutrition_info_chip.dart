import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable chip widget for displaying nutrition information
/// with an icon and label in a styled container
class NutritionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const NutritionInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Fit content
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
