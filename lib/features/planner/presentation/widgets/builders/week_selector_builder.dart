import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';

class WeekSelectorBuilder {
  static Widget buildWeekSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime currentWeek,
    Color textColor,
    Color primaryColor,
    Function(BuildContext, WidgetRef) showMonthPicker,
  ) {
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
              _buildPreviousWeekButton(
                context,
                ref,
                currentWeek,
                textColor,
                thisMonday,
              ),
              Expanded(
                child: _buildWeekDisplay(
                  context,
                  ref,
                  isCurrentWeek,
                  weekText,
                  primaryColor,
                  isPastWeek,
                  isFutureWeek,
                  showMonthPicker,
                ),
              ),
              _buildNextWeekButton(ref, currentWeek, textColor),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildPreviousWeekButton(
    BuildContext context,
    WidgetRef ref,
    DateTime currentWeek,
    Color textColor,
    DateTime thisMonday,
  ) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: 18, color: textColor),
      onPressed: () {
        // Obtener la semana anterior
        final newWeek = currentWeek.subtract(const Duration(days: 7));

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
      },
    );
  }

  static Widget _buildWeekDisplay(
    BuildContext context,
    WidgetRef ref,
    bool isCurrentWeek,
    String weekText,
    Color primaryColor,
    bool isPastWeek,
    bool isFutureWeek,
    Function(BuildContext, WidgetRef) showMonthPicker,
  ) {
    return GestureDetector(
      onTap: () => showMonthPicker(context, ref),
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
              Icon(Icons.calendar_today, size: 14, color: primaryColor),
            ],
          ),
          if (isPastWeek && !isCurrentWeek) _buildPastWeekBadge(),
          if (isFutureWeek && !isCurrentWeek) _buildFutureWeekBadge(),
        ],
      ),
    );
  }

  static Widget _buildPastWeekBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  static Widget _buildFutureWeekBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  static Widget _buildNextWeekButton(
    WidgetRef ref,
    DateTime currentWeek,
    Color textColor,
  ) {
    return IconButton(
      icon: Icon(Icons.arrow_forward_ios, size: 18, color: textColor),
      onPressed: () {
        final newWeek = currentWeek.add(const Duration(days: 7));
        ref.read(currentWeekProvider.notifier).state = newWeek;
      },
    );
  }

  // Método auxiliar para comprobar si dos fechas pertenecen a la misma semana
  static bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = date1.subtract(Duration(days: date1.weekday - 1));
    final monday2 = date2.subtract(Duration(days: date2.weekday - 1));
    return monday1.year == monday2.year &&
        monday1.month == monday2.month &&
        monday1.day == monday2.day;
  }
}
