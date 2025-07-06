import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Widget para mostrar un dato curioso sobre el impacto ambiental
class ImpactFactCard extends StatelessWidget {
  /// Texto del dato curioso
  final String factText;

  const ImpactFactCard({super.key, required this.factText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardColor = isDark ? AppColors.darkSurface : Colors.white;

    final Color accentColor =
        isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50);

    final Color textColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: accentColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "¿Sabías que?",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              factText,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
