import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

class WeekSelectorWidget extends ConsumerWidget {
  final DateTime currentWeek;
  final Color textColor;
  final Color primaryColor;

  const WeekSelectorWidget({
    super.key,
    required this.currentWeek,
    required this.textColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monday = currentWeek;
    final sunday = currentWeek.add(const Duration(days: 6));

    final monthFormat = DateFormat('MMMM', 'es_ES');
    final dayFormat = DateFormat('d');

    String weekText;
    if (monday.month == sunday.month) {
      weekText =
          '${dayFormat.format(monday)} - ${dayFormat.format(sunday)} de ${monthFormat.format(monday)}';
    } else {
      weekText =
          '${dayFormat.format(monday)} ${monthFormat.format(monday)} - ${dayFormat.format(sunday)} ${monthFormat.format(sunday)}';
    }

    // Determinar si estamos en una semana pasada o futura
    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final isPastWeek = monday.isBefore(thisMonday);
    final isFutureWeek = monday.isAfter(thisMonday);
    final isCurrentWeek =
        monday.year == thisMonday.year &&
        monday.month == thisMonday.month &&
        monday.day == thisMonday.day;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color:
            isCurrentWeek
                ? primaryColor.withValues(alpha: 0.08)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 18, color: textColor),
                onPressed: () => _onPreviousWeek(context, ref),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMonthPicker(context, ref),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isCurrentWeek ? 'Esta semana' : weekText,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: primaryColor,
                          ),
                        ],
                      ),
                      if (isPastWeek && !isCurrentWeek)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Semana pasada',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (isFutureWeek && !isCurrentWeek)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Planificación futura',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18, color: textColor),
                onPressed: () => _onNextWeek(ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onPreviousWeek(BuildContext context, WidgetRef ref) {
    // Obtener la semana anterior
    final newWeek = currentWeek.subtract(const Duration(days: 7));

    // Calcular el lunes de la semana actual
    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));

    // Verificar si la nueva semana es anterior a la semana actual
    if (newWeek.isBefore(thisMonday) && !_isSameWeek(newWeek, thisMonday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No puedes retroceder a semanas pasadas. Usa el historial para ver semanas anteriores.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Si no es semana pasada, permitir cambiar
    ref.read(currentWeekProvider.notifier).state = newWeek;
  }

  void _onNextWeek(WidgetRef ref) {
    final newWeek = currentWeek.add(const Duration(days: 7));
    ref.read(currentWeekProvider.notifier).state = newWeek;
  }

  // Método auxiliar para comprobar si dos fechas pertenecen a la misma semana
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = date1.subtract(Duration(days: date1.weekday - 1));
    final monday2 = date2.subtract(Duration(days: date2.weekday - 1));
    return monday1.year == monday2.year &&
        monday1.month == monday2.month &&
        monday1.day == monday2.day;
  }

  // Mostrar un selector de mes/semana
  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));

    // Verificar si es primera vez
    final isFirstTime = ref.read(isFirstPlanningProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                Text(
                  'Seleccionar semana',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                if (isFirstTime)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Comienza planificando esta semana para establecer tus hábitos',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.today, color: primaryColor),
                  title: Text(
                    'Esta semana',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _getWeekText(thisMonday),
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  onTap: () {
                    ref.read(currentWeekProvider.notifier).state = thisMonday;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.next_week, color: textColor),
                  title: Text(
                    'Próxima semana',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _getWeekText(thisMonday.add(const Duration(days: 7))),
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  onTap: () {
                    ref.read(currentWeekProvider.notifier).state = thisMonday
                        .add(const Duration(days: 7));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  String _getWeekText(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    final monthFormat = DateFormat('MMMM', 'es_ES');
    final dayFormat = DateFormat('d');

    if (monday.month == sunday.month) {
      return '${dayFormat.format(monday)} - ${dayFormat.format(sunday)} de ${monthFormat.format(monday)}';
    } else {
      return '${dayFormat.format(monday)} ${monthFormat.format(monday)} - ${dayFormat.format(sunday)} ${monthFormat.format(sunday)}';
    }
  }
}
 