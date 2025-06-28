import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

/// Widget para seleccionar semana en el planificador
class WeekSelector extends ConsumerWidget {
  const WeekSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.calendar_view_week),
      onPressed: () => _showWeekPicker(context, ref),
    );
  }

  /// Mostrar selector de semana
  void _showWeekPicker(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.read(currentWeekProvider);
    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));

    // Verificar si es primera vez
    final isFirstTime = ref.read(isFirstPlanningProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Mensaje informativo para primera vez
            if (isFirstTime) _buildFirstTimeWarning(),
            
            // Lista de semanas
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: 12, // Mostrar semanas para los próximos 3 meses
                itemBuilder: (context, index) => _buildWeekItem(
                  context,
                  ref,
                  thisMonday,
                  index,
                  currentWeek,
                  isFirstTime,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir header del selector
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Seleccionar semana',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige la semana que quieres planificar',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Construir advertencia para primera vez
  Widget _buildFirstTimeWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber.shade800,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'En tu primera planificación, solo puedes planificar la semana actual y futuras',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir item de semana
  Widget _buildWeekItem(
    BuildContext context,
    WidgetRef ref,
    DateTime thisMonday,
    int index,
    DateTime currentWeek,
    bool isFirstTime,
  ) {
    final weekOffset = index;
    final weekDate = thisMonday.add(Duration(days: weekOffset * 7));
    final monday = weekDate;
    final sunday = monday.add(const Duration(days: 6));

    final isCurrentWeek = _isSameWeek(monday, thisMonday);
    final isPastWeek = monday.isBefore(thisMonday);
    final isSelectedWeek = _isSameWeek(monday, currentWeek);

    // No mostrar semanas pasadas
    if (isPastWeek) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectWeek(context, ref, monday),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelectedWeek
                  ? AppColors.lightPrimary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelectedWeek
                    ? AppColors.lightPrimary
                    : Colors.grey.shade300,
                width: isSelectedWeek ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Indicador de semana
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentWeek
                        ? AppColors.lightPrimary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información de la semana
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isCurrentWeek ? 'Esta semana' : 'Semana del',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelectedWeek
                                  ? AppColors.lightPrimary
                                  : Colors.grey[800],
                            ),
                          ),
                          if (isCurrentWeek) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'HOY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('d MMM', 'es_ES').format(monday)} - ${DateFormat('d MMM', 'es_ES').format(sunday)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indicador de selección
                if (isSelectedWeek)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.lightPrimary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Seleccionar una semana
  void _selectWeek(BuildContext context, WidgetRef ref, DateTime monday) {
    ref.read(currentWeekProvider.notifier).state = monday;
    Navigator.of(context).pop();
  }

  /// Verificar si dos fechas están en la misma semana
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = date1.subtract(Duration(days: date1.weekday - 1));
    final monday2 = date2.subtract(Duration(days: date2.weekday - 1));
    
    return monday1.year == monday2.year &&
           monday1.month == monday2.month &&
           monday1.day == monday2.day;
  }
}