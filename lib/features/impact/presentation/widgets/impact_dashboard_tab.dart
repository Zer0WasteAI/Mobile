import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';

/// Widget para la pestaña "Mi Impacto" del panel de impacto ambiental
class ImpactDashboardTab extends ConsumerWidget {
  const ImpactDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(impactMetricsProvider);
    final equivalences = ref.watch(impactEquivalenceProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          Text(
            'Tu Impacto Ambiental',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada acción cuenta para un planeta más sostenible',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Métricas principales
          _buildMainMetrics(metrics, primaryColor, textColor),
          const SizedBox(height: 24),

          // Equivalencias
          _buildEquivalences(equivalences, primaryColor, textColor),
          const SizedBox(height: 24),

          // Mensaje motivacional
          _buildMotivationalMessage(metrics, primaryColor, textColor),
        ],
      ),
    );
  }

  Widget _buildMainMetrics(
    ImpactMetrics metrics,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Alimentos Salvados',
                value: '${metrics.foodSavedKg.toStringAsFixed(1)} kg',
                icon: Icons.restaurant,
                color: Colors.green,
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'CO₂ Evitado',
                value: '${metrics.co2AvoidedKg.toStringAsFixed(1)} kg',
                icon: Icons.cloud_off,
                color: Colors.blue,
                textColor: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          title: 'Agua Ahorrada',
          value: '${metrics.waterSavedLiters.toStringAsFixed(0)} L',
          icon: Icons.water_drop,
          color: Colors.cyan,
          textColor: textColor,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isWide ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalences(
    Map<String, String> equivalences,
    Color primaryColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equivalencias',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildEquivalenceItem(
            '🌳 ${equivalences['trees']}',
            'plantados para compensar el CO₂',
            textColor,
          ),
          const SizedBox(height: 8),
          _buildEquivalenceItem(
            '🚗 ${equivalences['cars']}',
            'no recorridos en automóvil',
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalenceItem(
    String value,
    String description,
    Color textColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextSpan(
                  text: ' $description',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage(
    ImpactMetrics metrics,
    Color primaryColor,
    Color textColor,
  ) {
    String message;
    if (metrics.foodSavedKg > 10) {
      message =
          "¡Increíble! Has salvado más de 10kg de alimentos. Eres un verdadero héroe ambiental.";
    } else if (metrics.co2AvoidedKg > 15) {
      message =
          "Tu esfuerzo está marcando la diferencia. Sigue evitando emisiones de CO₂.";
    } else if (metrics.waterSavedLiters > 1000) {
      message =
          "Has ahorrado más de 1000 litros de agua. ¡El planeta te lo agradece!";
    } else {
      message =
          "Cada pequeña acción cuenta. ¡Sigue adelante con tu impacto positivo!";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: primaryColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
