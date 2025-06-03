import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Widget para mostrar una métrica de impacto en una tarjeta
class ImpactMetricCard extends StatelessWidget {
  /// Título de la métrica
  final String title;

  /// Valor de la métrica a mostrar
  final String value;

  /// Icono para la métrica
  final IconData icon;

  /// Color para el icono y acentos
  final Color color;

  const ImpactMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      color: cardBgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                // Pequeño círculo decorativo
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
