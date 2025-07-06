// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_impact.dart';

/// Widget para la pestaña "Progreso" del panel de impacto ambiental
class ImpactProgressTab extends ConsumerWidget {
  const ImpactProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(impactHistoryFilterProvider);
    final calculationsAsync = switch (activeFilter) {
      ImpactHistoryFilter.all => ref.watch(allImpactCalculationsProvider),
      ImpactHistoryFilter.cooked => ref.watch(
        impactCalculationsByStatusProvider(true),
      ),
      ImpactHistoryFilter.notCooked => ref.watch(
        impactCalculationsByStatusProvider(false),
      ),
    };

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? AppColors.darkSurface : Colors.white;

    return Column(
      children: [
        _buildFilterButtons(context, ref),
        const SizedBox(height: 24),
        Expanded(
          child: calculationsAsync.when(
            data:
                (calculations) =>
                    calculations.calculations.isEmpty
                        ? _buildEmptyState(context)
                        : _buildCalculationsList(
                          calculations.calculations,
                          context,
                          ref,
                        ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Text(
                    'Error al cargar los cálculos: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no has realizado ningún cálculo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza cocinando recetas para ver su impacto ambiental',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(impactHistoryFilterProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Center(
      child: SegmentedButton<ImpactHistoryFilter>(
        selected: {activeFilter},
        onSelectionChanged: (Set<ImpactHistoryFilter> newSelection) {
          ref.read(impactHistoryFilterProvider.notifier).state =
              newSelection.first;
        },
        segments: [
          ButtonSegment<ImpactHistoryFilter>(
            value: ImpactHistoryFilter.all,
            label: Text('Todos', style: GoogleFonts.inter()),
            icon: const Icon(Icons.all_inclusive),
          ),
          ButtonSegment<ImpactHistoryFilter>(
            value: ImpactHistoryFilter.cooked,
            label: Text('Cocinados', style: GoogleFonts.inter()),
            icon: const Icon(Icons.restaurant),
          ),
          ButtonSegment<ImpactHistoryFilter>(
            value: ImpactHistoryFilter.notCooked,
            label: Text('Pendientes', style: GoogleFonts.inter()),
            icon: const Icon(Icons.pending),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationsList(
    List<EnvironmentalImpact> calculations,
    BuildContext context,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: calculations.length,
      itemBuilder: (context, index) {
        final item = calculations[index];
        return _buildCalculationCard(item, context, ref);
      },
    );
  }

  Widget _buildCalculationCard(
    EnvironmentalImpact item,
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final titleColor = isDarkMode ? Colors.white : AppColors.lightPrimary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.recipeTitle,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.formattedDate,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(item.isCooked, context),
              ],
            ),
            const Divider(height: 24),
            _buildImpactGrid(item, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isCooked, BuildContext context) {
    return Chip(
      label: Text(
        isCooked ? 'Cocinado' : 'Pendiente',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isCooked ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: (isCooked ? Colors.green : Colors.orange).withValues(
        alpha: 0.1,
      ),
      side: BorderSide(
        color: (isCooked ? Colors.green : Colors.orange).withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildImpactGrid(EnvironmentalImpact item, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildImpactItem(
                title: 'Ahorro',
                value: item.formattedCost,
                icon: Icons.monetization_on,
                color: Colors.green,
                context: context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildImpactItem(
                title: 'CO₂ Evitado',
                value: item.formattedCarbonFootprint,
                icon: Icons.cloud_off,
                color: Colors.blue,
                context: context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildImpactItem(
                title: 'Agua',
                value: item.formattedWaterFootprint,
                icon: Icons.water_drop,
                color: Colors.cyan,
                context: context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildImpactItem(
                title: 'Energía',
                value: item.formattedEnergyFootprint,
                icon: Icons.flash_on,
                color: Colors.orange,
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.8),
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
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
