import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_metric_card.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/impact_fact_card.dart';
import 'package:zer0_waste_ai/features/impact/presentation/widgets/latest_badges_section.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart';

/// Widget para la pestaña "Mi Impacto" del panel de impacto ambiental
class ImpactDashboardTab extends ConsumerWidget {
  const ImpactDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final metrics = ref.watch(impactMetricsProvider);
    final fact = ref.watch(impactFactProvider);
    final equivalence = ref.watch(impactEquivalenceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nivel y progreso circular
          _buildLevelIndicator(metrics, primaryColor, textColor),
          const SizedBox(height: 24),

          // Métricas principales
          _buildMetricsGrid(context, metrics),
          const SizedBox(height: 20),

          // Sección de EcoCoins
          _buildEcoCoinsSection(context, ref),
          const SizedBox(height: 20),

          // Equivalencia basada en métricas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              equivalence,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dato curioso del día
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ImpactFactCard(factText: fact),
          ),
          const SizedBox(height: 24),

          // Insignias recientes
          const LatestBadgesSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(
    ImpactMetrics metrics,
    Color primaryColor,
    Color textColor,
  ) {
    final levelTitles = [
      'Principiante',
      'Aprendiz Verde',
      'Eco Consciente',
      'Salvavidas',
      'Protector Ambiental',
      'Eco Guerrero',
      'Campeón Verde',
      'Maestro del Reciclaje',
      'Defensor del Planeta',
      'Leyenda Ecológica',
    ];

    final levelTitle =
        metrics.level <= levelTitles.length
            ? levelTitles[metrics.level - 1]
            : 'Nivel Máximo';

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 70.0,
          lineWidth: 12.0,
          percent: metrics.levelProgress,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nivel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              Text(
                '${metrics.level}',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          progressColor: primaryColor,
          backgroundColor: primaryColor.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1200,
        ),
        const SizedBox(height: 10),
        Text(
          levelTitle,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (metrics.level < levelTitles.length) ...[
          const SizedBox(height: 4),
          Text(
            'Próximo nivel: ${levelTitles[metrics.level]}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ImpactMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ImpactMetricCard(
            title: 'Alimentos Salvados',
            value: '${metrics.foodSavedKg.toStringAsFixed(1)} kg',
            icon: Icons.restaurant,
            color: Colors.green,
          ),
          ImpactMetricCard(
            title: 'CO2 Evitado',
            value: '${metrics.co2AvoidedKg.toStringAsFixed(1)} kg',
            icon: Icons.cloud_outlined,
            color: Colors.blue,
          ),
          ImpactMetricCard(
            title: 'Agua Ahorrada',
            value: '${metrics.waterSavedLiters.toStringAsFixed(0)} L',
            icon: Icons.water_drop_outlined,
            color: Colors.lightBlue,
          ),
          ImpactMetricCard(
            title: 'EcoCoins Ganados',
            value: '120',
            icon: Icons.eco,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
          ),
        ],
      ),
    );
  }

  // Sección que explica la relación entre acciones ambientales y EcoCoins
  Widget _buildEcoCoinsSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final ecoCoins = ref.watch(ecoCoinsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/home/eco_coin.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'EcoCoins y tu impacto',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo ganar EcoCoins?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildEcoCoinRewardItem(
                  'Salvar alimentos',
                  '${EcoCoinRewards.foodSaved} monedas por kg',
                  Icons.restaurant,
                  Colors.green,
                ),
                _buildEcoCoinRewardItem(
                  'Completar objetivos',
                  'De ${EcoCoinRewards.dailyGoalCompleted} a ${EcoCoinRewards.monthlyGoalCompleted} monedas',
                  Icons.flag,
                  Colors.orange,
                ),
                _buildEcoCoinRewardItem(
                  'Conseguir insignias',
                  '${EcoCoinRewards.badgeEarned} monedas por insignia',
                  Icons.emoji_events,
                  Colors.amber,
                ),
                _buildEcoCoinRewardItem(
                  'Subir de nivel',
                  '${EcoCoinRewards.levelUp} monedas por nivel',
                  Icons.trending_up,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                Divider(color: primaryColor.withOpacity(0.2)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tu saldo actual:',
                      style: GoogleFonts.inter(fontSize: 14, color: textColor),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/home/eco_coin.png',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$ecoCoins',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoCoinRewardItem(
    String title,
    String reward,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            reward,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
