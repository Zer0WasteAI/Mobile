import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

    return calculationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (calculations) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial de Impacto',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Revisa y filtra tus cálculos y acciones pasadas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterButtons(context, ref),
              const SizedBox(height: 24),
              _buildCalculationsList(calculations.calculations, context, ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButtons(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(impactHistoryFilterProvider);

    return Center(
      child: ToggleButtons(
        isSelected: [
          activeFilter == ImpactHistoryFilter.all,
          activeFilter == ImpactHistoryFilter.cooked,
          activeFilter == ImpactHistoryFilter.notCooked,
        ],
        onPressed: (index) {
          ref.read(impactHistoryFilterProvider.notifier).state =
              ImpactHistoryFilter.values[index];
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: AppColors.lightPrimary,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Todos'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Cocinados'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No Cocinados'),
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
    if (calculations.isEmpty) {
      return const Center(child: Text('Aún no has realizado ningún cálculo.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              'Calculado el: ${DateFormat.yMMMd().add_jm().format(item.savedAt ?? DateTime.now())}',
              style: GoogleFonts.inter(fontSize: 12, color: textColor),
            ),
            const Divider(height: 24),
            _buildImpactRow(
              Icons.cloud_off,
              '${item.carbonFootprint.toStringAsFixed(2)} ${item.unitCarbon}',
              'CO2 Evitado',
              context,
            ),
            const SizedBox(height: 8),
            _buildImpactRow(
              Icons.water_drop,
              '${item.waterFootprint.toStringAsFixed(2)} ${item.unitWater}',
              'Agua Ahorrada',
              context,
            ),
            const SizedBox(height: 8),
            _buildImpactRow(
              Icons.flash_on,
              '${item.energyFootprint.toStringAsFixed(2)} ${item.unitEnergy}',
              'Energía Ahorrada',
              context,
            ),
            const SizedBox(height: 8),
            _buildImpactRow(
              Icons.monetization_on,
              '${item.economicCost.toStringAsFixed(2)} ${item.unitCost}',
              'Coste Económico',
              context,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child:
                  item.isCooked
                      ? const Chip(
                        label: Text('Cocinada'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                      : ElevatedButton(
                        onPressed: () async {
                          try {
                            final service = ref.read(
                              impactCalculationServiceProvider,
                            );
                            await service.updateStatus(item.recipeUid, true);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Receta marcada como cocinada!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Refresh providers
                            ref.invalidate(allImpactCalculationsProvider);
                            ref.invalidate(impactSummaryProvider);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Marcar como Cocinada'),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactRow(
    IconData icon,
    String value,
    String label,
    BuildContext context,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
