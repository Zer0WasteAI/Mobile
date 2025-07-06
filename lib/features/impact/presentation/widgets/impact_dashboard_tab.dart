import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_summary.dart';

/// Widget para la pestaña "Mi Impacto" del panel de impacto ambiental
class ImpactDashboardTab extends ConsumerWidget {
  const ImpactDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(impactSummaryProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (summary) {
        // final equivalences = _calculateEquivalences(summary); // You can create a helper for this
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
              _buildMainMetrics(summary, primaryColor, textColor),
              const SizedBox(height: 24),

              _buildEquivalences(summary, primaryColor, textColor),
              const SizedBox(height: 24),

              // Mensaje motivacional
              _buildMotivationalMessage(summary, primaryColor, textColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainMetrics(
    EnvironmentalSummary summary,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Ahorro Económico',
                value:
                    '${summary.totalEconomicCost.toStringAsFixed(2)} ${summary.unitCost}',
                icon: Icons.monetization_on,
                color: Colors.green,
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'CO₂ Evitado',
                value:
                    '${summary.totalCarbonFootprint.toStringAsFixed(1)} ${summary.unitCarbon}',
                icon: Icons.cloud_off,
                color: Colors.blue,
                textColor: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Agua Ahorrada',
                value:
                    '${summary.totalWaterFootprint.toStringAsFixed(0)} ${summary.unitWater}',
                icon: Icons.water_drop,
                color: Colors.cyan,
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Energía Ahorrada',
                value:
                    '${summary.totalEnergyFootprint.toStringAsFixed(1)} ${summary.unitEnergy}',
                icon: Icons.flash_on,
                color: Colors.orange,
                textColor: textColor,
              ),
            ),
          ],
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
              fontSize: isWide ? 28 : 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalences(
    EnvironmentalSummary summary,
    Color primaryColor,
    Color textColor,
  ) {
    final treesEquivalent = (summary.totalCarbonFootprint / 22).toStringAsFixed(
      1,
    );
    // Assuming 1 kg of CO2 is roughly 4.6 km in an average car
    final carKmEquivalent = (summary.totalCarbonFootprint / 0.217)
        .toStringAsFixed(1); // 1km = 0.217 kg CO2

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
            'Equivalencias de tu Ahorro',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildEquivalenceItem(
            '🌳 $treesEquivalent árboles',
            'plantados para absorber el CO₂ que evitaste.',
            textColor,
          ),
          const SizedBox(height: 8),
          _buildEquivalenceItem(
            '🚗 $carKmEquivalent km',
            'que un coche promedio no tuvo que recorrer.',
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
    EnvironmentalSummary summary,
    Color primaryColor,
    Color textColor,
  ) {
    String message;
    if (summary.totalCarbonFootprint > 100) {
      message =
          "¡Increíble! Has evitado más de 100kg de CO2. Eres un verdadero héroe ambiental.";
    } else if (summary.totalWaterFootprint > 10000) {
      message =
          "Tu esfuerzo está marcando la diferencia. Sigue ahorrando agua.";
    } else if (summary.totalEconomicCost > 50) {
      message =
          "Has ahorrado más de \$50. ¡Tu bolsillo y el planeta te lo agradecen!";
    } else {
      message =
          "Cada pequeña acción cuenta. ¡Sigue adelante con tu impacto positivo!";
    }

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
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 30, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
