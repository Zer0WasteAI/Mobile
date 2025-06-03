import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/impact_metrics.dart';

/// Widget para mostrar las insignias recientes del usuario
class LatestBadgesSection extends ConsumerWidget {
  const LatestBadgesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(impactMetricsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;

    // Mostramos solo las 3 insignias más recientes
    final recentBadges = metrics.badges.take(3).toList();

    if (recentBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Insignias recientes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (metrics.badges.length > 3)
                TextButton(
                  onPressed: () {
                    // Podría navegar a una pantalla de todas las insignias
                  },
                  child: Text(
                    'Ver todas',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentBadges.length,
              itemBuilder: (context, index) {
                return _BadgeItem(badge: recentBadges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar una insignia individual
class _BadgeItem extends StatelessWidget {
  final UserBadge badge;

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    // Color distinto para cada insignia según su id
    final badgeColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final badgeColor = badgeColors[int.parse(badge.id) % badgeColors.length];

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          // Icono de la insignia
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: badgeColor, width: 2),
            ),
            child: Icon(_getBadgeIcon(), color: badgeColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getTimeAgo(badge.obtainedAt),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  /// Obtiene el icono según el tipo de insignia
  IconData _getBadgeIcon() {
    switch (badge.id) {
      case '1':
        return Icons.eco;
      case '2':
        return Icons.cloud_outlined;
      case '3':
        return Icons.water_drop_outlined;
      default:
        return Icons.star;
    }
  }

  /// Calcula cuánto tiempo ha pasado desde que se obtuvo la insignia
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
