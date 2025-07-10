import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_card.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_chart.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_stats_card.dart';

class ImpactDashboardTab extends ConsumerWidget {
  const ImpactDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener datos de impacto acumulados
    final impactData = ref.watch(impactDataProvider);
    final recipesCooked = impactData['recipesCooked'] as int? ?? 0;
    final lastRecipeScore = impactData['lastRecipeScore'] as double? ?? 0.0;
    final totalScore = impactData['totalScore'] as double? ?? 0.0;
    final avgScore = recipesCooked > 0 ? totalScore / recipesCooked : 0.0;
    final co2Emissions = impactData['co2Emissions'] as double? ?? 0.0;
    final waterUsage = impactData['waterUsage'] as double? ?? 0.0;
    // ignore: unused_local_variable
    final wastePreventionScore =
        impactData['wastePreventionScore'] as double? ?? 0.0;

    final timestamp =
        impactData['timestamp'] as int? ??
        DateTime.now().millisecondsSinceEpoch;
    final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de última actualización
          if (recipesCooked > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.update, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Text(
                        'Última actualización',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: ${dateFormatter.format(lastUpdateDate)}',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Receta completada con puntuación: ${lastRecipeScore.toStringAsFixed(0)}/100',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Resumen de impacto
          Text(
            'Resumen de Impacto',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Tarjetas de estadísticas
          Row(
            children: [
              Expanded(
                child: ImpactStatsCard(
                  title: 'Recetas\nCocinadas',
                  value: recipesCooked.toString(),
                  icon: Icons.restaurant,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ImpactStatsCard(
                  title: 'Puntuación\nPromedio',
                  value: avgScore.toStringAsFixed(1),
                  icon: Icons.eco,
                  color: const Color(0xFF8BC34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ImpactStatsCard(
                  title: 'CO₂\nAhorrado',
                  value: '${co2Emissions.toStringAsFixed(1)} kg',
                  icon: Icons.cloud_outlined,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ImpactStatsCard(
                  title: 'Agua\nAhorrada',
                  value: '${waterUsage.toStringAsFixed(0)} L',
                  color: const Color(0xFF03A9F4),
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de impacto
          if (recipesCooked > 0) ...[
            const ImpactCard(
              title: 'Tendencia de Sostenibilidad',
              child: ImpactChart(),
            ),
            const SizedBox(height: 16),
          ],

          // Tarjeta de consejos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8BC34A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8BC34A).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Color(0xFF8BC34A)),
                    const SizedBox(width: 8),
                    Text(
                      'Consejos para mejorar',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8BC34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTipItem(
                  '1. Usa ingredientes locales y de temporada para reducir la huella de carbono.',
                ),
                _buildTipItem(
                  '2. Aprovecha al máximo los ingredientes de tu inventario para evitar desperdicios.',
                ),
                _buildTipItem(
                  '3. Reduce el consumo de carne, especialmente de res, que tiene mayor impacto ambiental.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
