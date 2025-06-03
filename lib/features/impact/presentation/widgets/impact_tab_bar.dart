import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';

/// Widget que muestra la barra de pestañas para el panel de impacto
class ImpactTabBar extends ConsumerWidget {
  final TabController tabController;

  const ImpactTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final unselectedColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 50,
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: unselectedColor,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          ref.read(impactTabIndexProvider.notifier).state = index;
        },
        tabs: const [
          Tab(text: 'Mi Impacto'),
          Tab(text: 'Progreso'),
          Tab(text: 'Objetivos'),
        ],
      ),
    );
  }
}
