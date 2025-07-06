import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

class WeekDaysWidget extends ConsumerWidget {
  final List<DateTime> weekDays;
  final Color textColor;

  const WeekDaysWidget({
    super.key,
    required this.weekDays,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayFormat = DateFormat(
      'E',
      'es_ES',
    ); // Formato corto para el día (Lun, Mar, etc.)
    final today = DateTime.now();

    // Día seleccionado (por defecto el día actual si está en la semana actual)
    final selectedDay = ref.watch(selectedDayProvider);

    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final isToday =
              day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;

          final isSelected =
              selectedDay != null &&
              day.year == selectedDay.year &&
              day.month == selectedDay.month &&
              day.day == selectedDay.day;

          // Determinar si este día tiene comidas planificadas
          final dateKey = DateFormat('yyyy-MM-dd').format(day);
          final mealPlans = ref.watch(mealPlansProvider);
          final hasMeals =
              mealPlans[dateKey] != null && mealPlans[dateKey]!.isNotEmpty;

          return GestureDetector(
            onTap: () {
              // Seleccionar este día
              ref.read(selectedDayProvider.notifier).state = day;
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 7,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isSelected
                            ? const Color(0xFF00BFA5)
                            : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayFormat.format(day).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight:
                              isSelected || isToday
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color:
                              isSelected
                                  ? const Color(0xFF00BFA5)
                                  : textColor.withValues(
                                    alpha: isToday ? 1.0 : 0.7,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? const Color(0xFF00BFA5)
                                  : isToday
                                  ? const Color(
                                    0xFF00BFA5,
                                  ).withValues(alpha: 0.2)
                                  : Colors.transparent,
                          border:
                              isToday && !isSelected
                                  ? Border.all(
                                    color: const Color(0xFF00BFA5),
                                    width: 1.5,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : isToday
                                      ? const Color(0xFF00BFA5)
                                      : textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Indicador de comidas planificadas
                  if (hasMeals)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF00BFA5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
