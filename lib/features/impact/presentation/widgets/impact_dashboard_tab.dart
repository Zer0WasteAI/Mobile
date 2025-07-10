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
    // Obtener datos de impacto de recetas cocinadas
    final impactData = ref.watch(impactDataProvider);
    final recipesCooked = impactData['recipesCooked'] as int? ?? 0;
    final lastRecipeScore = impactData['lastRecipeScore'] as double? ?? 0.0;
    final totalScore = impactData['totalScore'] as double? ?? 0.0;
    final avgScore = recipesCooked > 0 ? totalScore / recipesCooked : 0.0;
    final recipeCO2 = impactData['co2Emissions'] as double? ?? 0.0;
    final recipeWater = impactData['waterUsage'] as double? ?? 0.0;
    final wastePreventionScore =
        impactData['wastePreventionScore'] as double? ?? 0.0;

    // Obtener datos de impacto del inventario
    final inventoryMetrics = ref.watch(impactMetricsProvider);
    final foodSaved = inventoryMetrics.foodSavedKg;
    final inventoryCO2 = inventoryMetrics.co2AvoidedKg;
    final inventoryWater = inventoryMetrics.waterSavedLiters;

    // Calcular totales combinados
    final totalCO2Saved = recipeCO2 + inventoryCO2;
    final totalWaterSaved = recipeWater + inventoryWater;
    // ignore: unused_local_variable
    final totalActivities = recipesCooked; // Podríamos añadir items consumidos del inventario

    final timestamp =
        impactData['timestamp'] as int? ??
        DateTime.now().millisecondsSinceEpoch;
    final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    // Estado vacío mejorado
    if (recipesCooked == 0 && foodSaved == 0) {
      return _buildEmptyState(context);
    }

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

          // Tarjetas de estadísticas principales (combinadas)
          Row(
            children: [
              Expanded(
                child: ImpactStatsCard(
                  title: 'CO₂ Total\nAhorrado',
                  value: '${totalCO2Saved.toStringAsFixed(1)} kg',
                  icon: Icons.cloud_outlined,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ImpactStatsCard(
                  title: 'Agua Total\nAhorrada',
                  value: '${totalWaterSaved.toStringAsFixed(0)} L',
                  color: const Color(0xFF2196F3),
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Desglose por actividad
          Text(
            'Desglose por Actividad',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Recetas cocinadas
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
                      const Icon(Icons.restaurant, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Text(
                        'Impacto de Recetas Cocinadas',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniMetric(
                          'Recetas',
                          recipesCooked.toString(),
                          Icons.restaurant,
                        ),
                      ),
                      Expanded(
                        child: _buildMiniMetric(
                          'Promedio',
                          '${avgScore.toStringAsFixed(1)}/100',
                          Icons.eco,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniMetric(
                          'CO₂',
                          '${recipeCO2.toStringAsFixed(1)} kg',
                          Icons.cloud_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildMiniMetric(
                          'Agua',
                          '${recipeWater.toStringAsFixed(0)} L',
                          Icons.water_drop_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Inventario consumido
          if (foodSaved > 0) ...[
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
                      const Icon(Icons.inventory_2, color: Color(0xFF8BC34A)),
                      const SizedBox(width: 8),
                      Text(
                        'Impacto del Inventario Consumido',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8BC34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniMetric(
                          'Alimentos',
                          '${foodSaved.toStringAsFixed(1)} kg',
                          Icons.restaurant,
                        ),
                      ),
                      Expanded(
                        child: _buildMiniMetric(
                          'Desperdicio evitado',
                          '${wastePreventionScore.toStringAsFixed(0)} pts',
                          Icons.recycling,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniMetric(
                          'CO₂',
                          '${inventoryCO2.toStringAsFixed(1)} kg',
                          Icons.cloud_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildMiniMetric(
                          'Agua',
                          '${inventoryWater.toStringAsFixed(0)} L',
                          Icons.water_drop_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),

          // Sección de equivalencias para dar contexto
          if (totalCO2Saved > 0 || totalWaterSaved > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00BCD4).withValues(alpha: 0.1),
                    const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: Color(0xFF00BCD4)),
                      const SizedBox(width: 8),
                      Text(
                        'Tu Impacto en Perspectiva',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (totalCO2Saved > 0) ...[
                    _buildEquivalenceItem(
                      'CO₂ ahorrado equivale a:',
                      [
                        '🌳 ${(totalCO2Saved / 22).toStringAsFixed(1)} árboles plantados',
                        '🚗 ${(totalCO2Saved * 4.5).toStringAsFixed(0)} km menos en auto',
                        '💡 ${(totalCO2Saved * 120).toStringAsFixed(0)} horas de bombilla LED',
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (totalWaterSaved > 0) ...[
                    _buildEquivalenceItem(
                      'Agua ahorrada equivale a:',
                      [
                        '🚿 ${(totalWaterSaved / 50).toStringAsFixed(0)} duchas de 5 minutos',
                        '🧺 ${(totalWaterSaved / 90).toStringAsFixed(0)} lavadoras completas',
                        '🥤 ${(totalWaterSaved / 0.25).toStringAsFixed(0)} vasos de agua',
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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

  Widget _buildMiniMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalenceItem(String title, List<String> equivalences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00BCD4),
          ),
        ),
        const SizedBox(height: 8),
        ...equivalences.map((equivalence) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            equivalence,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    const Color(0xFF8BC34A).withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Comienza tu viaje sostenible!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu impacto ambiental aparecerá aquí cuando:',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cocines recetas de la app',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Color(0xFF8BC34A)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Consumas alimentos de tu inventario',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🌍 Cada acción cuenta para cuidar el planeta',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
