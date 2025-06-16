import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';

/// Widget para la pestaña "Progreso" del panel de impacto ambiental
class ImpactProgressTab extends ConsumerWidget {
  const ImpactProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(impactMetricsProvider);
    final goals = ref.watch(impactGoalsProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Tu Progreso',
              style: GoogleFonts.inter(
              fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sigue tu evolución hacia un estilo de vida más sostenible',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
          ),
          ),
          const SizedBox(height: 24),

          // Progreso de métricas
          _buildMetricsProgress(metrics, primaryColor, textColor),
          const SizedBox(height: 24),

          // Objetivos activos
          _buildActiveGoals(goals, primaryColor, textColor),
          const SizedBox(height: 24),

          // Tendencias
          _buildTrends(metrics, primaryColor, textColor),
        ],
      ),
    );
  }

  Widget _buildMetricsProgress(
    ImpactMetrics metrics,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas de Impacto',
              style: GoogleFonts.inter(
            fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
            ),
          ),
          const SizedBox(height: 16),
        _buildProgressCard(
          title: 'Alimentos Salvados',
          value: metrics.foodSavedKg,
          unit: 'kg',
          target: 50.0,
          icon: Icons.restaurant,
                  color: Colors.green,
          textColor: textColor,
                ),
        const SizedBox(height: 12),
        _buildProgressCard(
          title: 'CO₂ Evitado',
          value: metrics.co2AvoidedKg,
          unit: 'kg',
          target: 100.0,
          icon: Icons.cloud_off,
                  color: Colors.blue,
          textColor: textColor,
                ),
        const SizedBox(height: 12),
        _buildProgressCard(
          title: 'Agua Ahorrada',
          value: metrics.waterSavedLiters,
          unit: 'L',
          target: 5000.0,
          icon: Icons.water_drop,
          color: Colors.cyan,
          textColor: textColor,
                ),
              ],
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double value,
    required String unit,
    required double target,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    final progress = (value / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
            child: Text(
                  title,
              style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
              Text(
                '${value.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% completado',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoals(
    List<dynamic> goals,
    Color primaryColor,
    Color textColor,
  ) {
    final activeGoals =
        goals.where((goal) => goal.isActive && !goal.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objetivos Activos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        if (activeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
        ),
            ),
          child: Row(
            children: [
                Icon(Icons.flag_outlined, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No tienes objetivos activos. ¡Crea uno nuevo para seguir tu progreso!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...activeGoals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGoalCard(goal, primaryColor, textColor),
            ),
          ),
      ],
    );
  }

  Widget _buildGoalCard(dynamic goal, Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
            goal.title,
                      style: GoogleFonts.inter(
              fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
          const SizedBox(height: 4),
                    Text(
            goal.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: primaryColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(primaryColor),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(goal.progress * 100).toStringAsFixed(1)}% completado',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrends(
    ImpactMetrics metrics,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          'Tendencias',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
            ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildTrendItem(
                'Esta semana',
                '+2.3 kg alimentos salvados',
                Icons.trending_up,
                Colors.green,
                textColor,
              ),
              const SizedBox(height: 12),
              _buildTrendItem(
                'Este mes',
                '+8.7 kg CO₂ evitados',
                Icons.trending_up,
                Colors.blue,
                textColor,
              ),
              const SizedBox(height: 12),
              _buildTrendItem(
                'Promedio diario',
                '450 L agua ahorrados',
                Icons.water_drop,
                Colors.cyan,
                textColor,
            ),
          ],
        ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(
    String period,
    String value,
    IconData icon,
    Color color,
    Color textColor,
  ) {
    return Row(
        children: [
          Container(
          padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            ),
          child: Icon(icon, color: color, size: 16),
          ),
        const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                period,
                  style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                value,
                  style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}
