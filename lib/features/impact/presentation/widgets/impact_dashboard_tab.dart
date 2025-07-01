import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Impacto',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu contribución al medio ambiente',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          summaryAsync.when(
            data: (summary) => _buildMetricsGrid(summary, textColor),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Text(
                    'Error al cargar las métricas: $error',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
          ),
          const SizedBox(height: 24),
          _buildTipsSection(context, textColor),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(EnvironmentalSummary summary, Color textColor) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Ahorro Económico',
                value: currencyFormat.format(summary.totalEconomicCost),
                icon: Icons.monetization_on,
                color: Colors.green,
                textColor: textColor,
                tooltip:
                    'Dinero ahorrado al evitar el desperdicio de alimentos',
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
                tooltip:
                    'Emisiones de CO₂ evitadas al no desperdiciar alimentos',
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
                tooltip:
                    'Agua ahorrada en la producción de alimentos no desperdiciados',
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
                tooltip:
                    'Energía ahorrada en la producción y transporte de alimentos',
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
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, Color textColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Tips para Maximizar tu Impacto',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              icon: Icons.calendar_today,
              text: 'Planifica tus comidas semanalmente',
              textColor: textColor,
            ),
            _buildTipItem(
              icon: Icons.inventory_2,
              text: 'Mantén tu inventario actualizado',
              textColor: textColor,
            ),
            _buildTipItem(
              icon: Icons.local_offer,
              text: 'Aprovecha los alimentos próximos a vencer',
              textColor: textColor,
            ),
            _buildTipItem(
              icon: Icons.eco,
              text: 'Prioriza ingredientes de temporada',
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String text,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
