import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';

/// Widget para la pestaña "Progreso" del panel de impacto ambiental
class ImpactProgressTab extends ConsumerWidget {
  const ImpactProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(impactMetricsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    // Ordenar logros por fecha, más recientes primero
    final achievements = List<UserAchievement>.from(metrics.achievements)
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de comparativas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tu impacto equivale a:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Comparativas visuales
          _buildComparisonCard(
            context: context,
            title: 'Viajes en coche',
            value: '${(metrics.co2AvoidedKg * 6).toStringAsFixed(0)} km',
            description: 'Emisiones de CO₂ evitadas',
            icon: Icons.directions_car,
            color: Colors.blue,
          ),
          _buildComparisonCard(
            context: context,
            title: 'Duchas completas',
            value: '${(metrics.waterSavedLiters / 50).toStringAsFixed(0)}',
            description: 'Agua ahorrada',
            icon: Icons.shower,
            color: Colors.lightBlue,
          ),
          _buildComparisonCard(
            context: context,
            title: 'Comidas completas',
            value: '${(metrics.foodSavedKg * 2).toStringAsFixed(0)}',
            description: 'Alimentos salvados',
            icon: Icons.restaurant,
            color: Colors.green,
          ),

          const SizedBox(height: 24),

          // Progreso mensual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Progreso mensual',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildProgressBar(
                  context: context,
                  label: 'Alimentos salvados',
                  currentValue: metrics.foodSavedKg,
                  targetValue: 20.0,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  context: context,
                  label: 'CO₂ evitado',
                  currentValue: metrics.co2AvoidedKg,
                  targetValue: 30.0,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  context: context,
                  label: 'Agua ahorrada',
                  currentValue: metrics.waterSavedLiters / 1000,
                  targetValue: 2.0,
                  suffix: ' m³',
                  color: Colors.lightBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Logros recientes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Logros alcanzados',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lista de logros
          if (achievements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Todavía no has alcanzado ningún logro. ¡Sigue usando la app!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementItem(
                  context: context,
                  achievement: achievement,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                );
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required BuildContext context,
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required BuildContext context,
    required String label,
    required double currentValue,
    required double targetValue,
    String suffix = '',
    required Color color,
  }) {
    final percent = (currentValue / targetValue).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: textColor),
            ),
            Text(
              '${currentValue.toStringAsFixed(1)}$suffix / ${targetValue.toStringAsFixed(1)}$suffix',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 10.0,
          percent: percent,
          backgroundColor: color.withOpacity(0.2),
          progressColor: color,
          barRadius: const Radius.circular(5),
          animation: true,
          animationDuration: 1000,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAchievementItem({
    required BuildContext context,
    required UserAchievement achievement,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  achievement.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(achievement.achievedAt),
            style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return 'hace ${(difference.inDays / 30).floor()} meses';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} horas';
    } else {
      return 'hace poco';
    }
  }
}
