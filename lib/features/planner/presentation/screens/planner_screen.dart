// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/dialogs/add_meal_dialog.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/dialogs/move_meal_dialog.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/dialogs/custom_reminder_dialog.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/builders/day_planner_builder.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/builders/recipe_list_builder.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/builders/week_selector_builder.dart';
import 'package:flutter/services.dart';
import 'package:zer0_waste_ai/features/planner/presentation/screens/recipe_library_screen.dart';

// Extensión para capitalizar strings (con nombre único para evitar conflicto)
extension StringExtensionPlanner on String {
  String capitalizePlanner() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

// All providers and models are now imported from their proper locations

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar los datos de localización para español
    initializeDateFormatting('es_ES', null);

    // Verificar si hay una fecha seleccionada desde la home
    final selectedDate = ref.watch(selectedDateProvider);
    // Si hay una fecha seleccionada, usar esa fecha para el proveedor de la semana actual
    if (selectedDate != null) {
      // Obtener el lunes de la semana de la fecha seleccionada
      final monday = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      // Actualizar el proveedor de la semana actual y limpiar el proveedor de la fecha seleccionada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentWeekProvider.notifier).state = monday;
        ref.read(selectedDateProvider.notifier).state = null;
        // También seleccionar el día
        ref.read(selectedDayProvider.notifier).state = selectedDate;
      });
    }

    final currentWeek = ref.watch(currentWeekProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    // Estado de expansión del calendario
    final isCalendarExpanded = ref.watch(isCalendarExpandedProvider);

    // Verificar si es la primera vez que el usuario utiliza la app
    final isFirstTimeUser = ref.read(isFirstPlanningProvider);

    // Verificar si ya se mostró la guía de iconos
    final hasShownIconGuide = ref.watch(hasShownIconGuideProvider);

    // Mostrar el tutorial de onboarding si es la primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isFirstTimeUser) {
        _showOnboardingTutorial(context, ref);
      } else if (!hasShownIconGuide) {
        _showIconGuide(context, ref);
      }
    });

    // Calcular los días de la semana
    final weekDays = List.generate(
      7,
      (index) => currentWeek.add(Duration(days: index)),
    );

    // Obtener el día seleccionado
    final selectedDay = ref.watch(selectedDayProvider);

    // Si no hay día seleccionado, seleccionar el día actual si está en esta semana
    // o el primer día de la semana si no
    if (selectedDay == null) {
      final today = DateTime.now();
      final inCurrentWeek = weekDays.any(
        (day) =>
            day.year == today.year &&
            day.month == today.month &&
            day.day == today.day,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (inCurrentWeek) {
          ref.read(selectedDayProvider.notifier).state = today;
        } else {
          ref.read(selectedDayProvider.notifier).state = weekDays.first;
        }
      });
    }

    // Verificar si hay una comida seleccionada desde la home
    final selectedMeal = ref.watch(selectedMealProvider);
    // Si hay una comida seleccionada, mostrar sus detalles y limpiar el proveedor
    if (selectedMeal != null) {
      // Formatear la fecha actual para usarla como clave
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Asegurarse que el mapa del proveedor existe
      final mealPlans = ref.read(mealPlansProvider);
      // ignore: unnecessary_null_comparison
      if (mealPlans != null) {
        // Obtener las comidas planificadas para la fecha
        final mealsForDate = mealPlans[dateKey] ?? [];

        // Verificar si la comida seleccionada existe en el planificador
        final mealExists = mealsForDate.any(
          (meal) => meal.id == selectedMeal.id,
        );

        // Mostrar los detalles después de que se construya el widget solo si la comida existe
        if (mealExists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMealDetails(context, ref, selectedMeal, dateKey);
            // Limpiar el proveedor de la comida seleccionada
            ref.read(selectedMealProvider.notifier).state = null;
          });
        }
      }

      // Siempre limpiar el proveedor para evitar intentos repetidos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedMealProvider.notifier).state = null;
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Botón de ayuda para mostrar la guía de iconos
          IconButton(
            icon: Icon(Icons.help_outline, color: textColor),
            onPressed: () => _showIconGuide(context, ref, forceShow: true),
            tooltip: 'Guía de iconos',
          ),
          // Botón de historial
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.history_outlined, color: textColor),
                // Posicionar un indicador visual si hay historial
                if (ref.watch(planningHistoryProvider).isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showPlanningHistory(context, ref),
            tooltip: 'Historial de planificación',
          ),
          // Botón de biblioteca de recetas
          IconButton(
            icon: Icon(Icons.restaurant_menu, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeLibraryScreen(),
                ),
              );
            },
            tooltip: 'Biblioteca de recetas',
          ),
          // Botón de planificación de comidas
          IconButton(
            icon: Icon(Icons.calendar_today, color: textColor),
            onPressed: () {
              Navigator.pushNamed(context, '/meal-planning');
            },
            tooltip: 'Planificación de Comidas',
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: textColor),
            onPressed: () => _showShoppingList(context),
            tooltip: 'Lista de compra',
          ),
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: textColor),
            onPressed: () => _showStats(context),
            tooltip: 'Estadísticas de impacto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Título de la pantalla
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Planificación Semanal',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // Sección del calendario con funcionalidad de toggle
          Column(
            children: [
              // Selector de semana (siempre visible)
              WeekSelectorBuilder.buildWeekSelector(
                context,
                ref,
                currentWeek,
                textColor,
                primaryColor,
                _showMonthPicker,
              ),

              // Días de la semana (visibles solo cuando está expandido)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isCalendarExpanded ? 98 : 0, // 90 + 8 de margen
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _buildWeekDays(context, weekDays, textColor, ref),
                ),
              ),

              // Botón de toggle más grande y fácil de presionar
              InkWell(
                onTap: () {
                  ref.read(isCalendarExpandedProvider.notifier).state =
                      !isCalendarExpanded;
                },
                child: Container(
                  width: double.infinity,
                  height: 30,
                  alignment: Alignment.center,
                  child: Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCalendarExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Vista de día seleccionado
          if (selectedDay != null)
            Expanded(
              child: _buildDayPlanner(
                context,
                ref,
                selectedDay,
                textColor,
                primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  // Mostrar un selector de mes/semana
  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.read(currentWeekProvider);
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
                const SizedBox(height: 20),

                // Si es primera vez, mostrar mensaje informativo
                if (isFirstTime)
                  Container(
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
                  ),

                // Semanas disponibles
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: 12, // Mostrar semanas para los próximos 3 meses
                    itemBuilder: (context, index) {
                      // Independientemente de si es primera vez o no, comenzamos desde la semana actual
                      final weekOffset = index;
                      final weekDate = thisMonday.add(
                        Duration(days: weekOffset * 7),
                      );

                      final monday = weekDate;
                      final sunday = monday.add(const Duration(days: 6));

                      final isCurrentWeek =
                          monday.year == thisMonday.year &&
                          monday.month == thisMonday.month &&
                          monday.day == thisMonday.day;

                      final isPastWeek = monday.isBefore(thisMonday);
                      final isFutureWeek = monday.isAfter(thisMonday);

                      // Ya no mostramos semanas pasadas en el selector
                      if (isPastWeek) {
                        return const SizedBox.shrink();
                      }

                      final monthFormat = DateFormat('MMMM', 'es_ES');
                      final dayFormat = DateFormat('d');

                      String weekText;
                      if (monday.month == sunday.month) {
                        weekText =
                            '${dayFormat.format(monday)} - ${dayFormat.format(sunday)} ${monthFormat.format(monday)}';
                      } else {
                        weekText =
                            '${dayFormat.format(monday)} ${monthFormat.format(monday)} - ${dayFormat.format(sunday)} ${monthFormat.format(sunday)}';
                      }

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isCurrentWeek
                                    ? const Color(0xFF00BFA5)
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        color:
                            isCurrentWeek
                                ? const Color(0xFF00BFA5).withValues(alpha: 0.1)
                                : isPastWeek
                                ? Colors.grey.shade100
                                : Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(currentWeekProvider.notifier).state =
                                monday;
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isCurrentWeek
                                            ? const Color(
                                              0xFF00BFA5,
                                            ).withValues(alpha: 0.2)
                                            : isPastWeek
                                            ? Colors.grey.shade200
                                            : Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCurrentWeek
                                        ? Icons.calendar_today
                                        : isPastWeek
                                        ? Icons.history
                                        : Icons.calendar_month,
                                    size: 18,
                                    color:
                                        isCurrentWeek
                                            ? const Color(0xFF00BFA5)
                                            : isPastWeek
                                            ? Colors.grey.shade600
                                            : Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        weekText.capitalizePlanner(),
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight:
                                              isCurrentWeek
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                          color:
                                              isCurrentWeek
                                                  ? const Color(0xFF00BFA5)
                                                  : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isCurrentWeek
                                            ? 'Semana actual'
                                            : isPastWeek
                                            ? 'Semana pasada'
                                            : 'Semana futura',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              isCurrentWeek
                                                  ? const Color(0xFF00BFA5)
                                                  : isPastWeek
                                                  ? Colors.grey.shade600
                                                  : Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentWeek)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00BFA5,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Actual',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF00BFA5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Widget para mostrar los días de la semana
  Widget _buildWeekDays(
    BuildContext context,
    List<DateTime> weekDays,
    Color textColor,
    WidgetRef ref,
  ) {
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

  // Widget para mostrar el plan de comidas de un día
  Widget _buildDayPlanner(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    Color textColor,
    Color primaryColor,
  ) {
    return DayPlannerBuilder.buildDayPlanner(
                                context,
                                ref,
                                day,
      textColor,
      primaryColor,
      _showAddMealDialog,
      _showMealDetails,
      _showReminderDialog,
      (context, ref, meal, dateKey) =>
          _showMoveMealDialog(context, ref, meal, dateKey, day),
      (ref, dateKey, meal) =>
          ref.read(mealPlansProvider.notifier).removeMeal(dateKey, meal),
    );
  }

  // Widget para mostrar un estado vacío para un día sin comidas
  Widget _buildEmptyDayState(
    BuildContext context,
    Color textColor,
    WidgetRef ref,
    DateTime day,
  ) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(day) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isTomorrow =
        DateFormat('yyyy-MM-dd').format(day) ==
        DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now().add(const Duration(days: 1)));

    // Consejos específicos según el día
    String tipText =
        'Planifica tus comidas para reducir el desperdicio de alimentos.';
    List<String> actionSuggestions = [];

    if (isToday) {
      tipText =
          'Planificar tus comidas de hoy te ayudará a organizarte mejor y reducir el desperdicio.';
      actionSuggestions = [
        'Revisa tu inventario para ver qué ingredientes tienes disponibles',
        'Considera usar primero los alimentos perecederos',
      ];
    } else if (isTomorrow) {
      tipText =
          'Planificar con un día de antelación te permite prepararte mejor.';
      actionSuggestions = [
        'Considera descongelar alimentos que necesites para mañana',
        'Verifica qué alimentos necesitarás comprar',
      ];
    } else {
      tipText =
          'La planificación anticipada te ayuda a comprar de forma más eficiente.';
      actionSuggestions = [
        'Planifica tus comidas antes de hacer la compra semanal',
        'Intenta crear un menú equilibrado y variado',
      ];
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración principal
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 50,
                color: const Color(0xFF00BFA5),
              ),
            ),
            const SizedBox(height: 20),

            // Título principal
            Text(
              isToday
                  ? '¡Es hora de planificar tu día!'
                  : isTomorrow
                  ? '¡Prepárate para mañana!'
                  : '¡Día sin planificar!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Mensaje descriptivo
            Text(
              tipText,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 20),

            // Consejos y sugerencias
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Consejos',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...actionSuggestions.map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: const Color(0xFF00BFA5),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botón de acción
            ElevatedButton.icon(
              onPressed: () => _showAddMealDialog(context, ref, day),
              icon: const Icon(Icons.add),
              label: Text(
                isToday
                    ? 'Planificar comida de hoy'
                    : isTomorrow
                    ? 'Planificar para mañana'
                    : 'Añadir primera comida',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar una sección vacía para un tipo de comida
  Widget _buildEmptyMealTypeSection(
    BuildContext context,
    Color textColor,
    MealType type,
    VoidCallback onTap,
  ) {
    final isSnack = type == MealType.snack;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.icon, color: type.color, size: 18),
              const SizedBox(width: 8),
              Text(
                type.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              // Indicador del límite
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isSnack ? 'Máx. 3' : 'Máx. 1',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: type.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: type.color.withValues(alpha: 0.2),
                  width: 1,
                  style: BorderStyle.solid, // Cambiado de dashed a solid
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: type.color.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSnack
                        ? 'Agregar snack'
                        : 'Agregar ${type.name.toLowerCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: type.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar un elemento de comida
  Widget _buildMealItem(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    final isToday = dateKey == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Mostrar detalles de la comida
            _showMealDetails(context, ref, meal, dateKey);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(meal.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Chip tipo de comida
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: meal.type.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              meal.type.name,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: meal.type.color,
                              ),
                            ),
                          ),

                          // Si es hoy, mostrar indicador
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hoy',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meal.ingredients.length} ingredientes',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          if (meal.reminders != null &&
                              meal.reminders!.isNotEmpty)
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.notifications_active,
                                  size: 12,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Recordatorio',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) async {
                    final formattedDate = DateFormat(
                      'yyyy-MM-dd',
                    ).parse(dateKey);

                    if (value == 'edit') {
                      _showEditMealDialog(context, ref, meal, dateKey);
                    } else if (value == 'move') {
                      _showMoveMealDialog(
                        context,
                        ref,
                        meal,
                        dateKey,
                        formattedDate,
                      );
                    } else if (value == 'reminder') {
                      _showReminderDialog(context, ref, meal, dateKey);
                    } else if (value == 'delete') {
                      ref
                          .read(mealPlansProvider.notifier)
                          .removeMeal(dateKey, meal);

                      // Si es la primera vez que se planifica esta semana, registrarla en el historial
                      final weekKey = DateFormat('yyyy-MM-dd').format(
                        formattedDate.subtract(
                          Duration(days: formattedDate.weekday - 1),
                        ),
                      );
                      if (!ref
                          .read(planningHistoryProvider.notifier)
                          .hasWeekInHistory(weekKey)) {
                        ref
                            .read(planningHistoryProvider.notifier)
                            .addWeekToHistory(weekKey);
                      }
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'move',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, size: 20),
                              SizedBox(width: 8),
                              Text('Mover'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'reminder',
                          child: Row(
                            children: [
                              Icon(Icons.notifications, size: 20),
                              SizedBox(width: 8),
                              Text('Recordatorio'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Actualizar la selección de día al elegir uno en el selector
  void _updateSelectedDay(WidgetRef ref, DateTime day) {
    ref.read(selectedDayProvider.notifier).state = day;
  }

  // Mostrar diálogo para agregar una comida
  void _showAddMealDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime day, {
    MealType? initialType,
  }) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);

    AddMealDialog.show(
      context,
      ref,
      day,
      initialType: initialType,
      onMealAdded: (selectedMeal, dateKey) {
        // Actualizar fecha de último uso
        ref.read(allRecipesProvider.notifier).updateLastUsed(selectedMeal.id);

        // Agregar la comida con validaciones
        _addMealWithValidation(
          context,
          ref,
          selectedMeal,
          dateKey,
          expectedType: initialType,
        );
      },
    );
  }

  // Método original reemplazado - contenido removido
  void _showAddMealDialogOriginal(
    BuildContext context,
    WidgetRef ref,
    DateTime day, {
    MealType? initialType,
  }) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final formattedDate = DateFormat('EEEE d MMMM', 'es_ES').format(day);

    // Comida seleccionada actualmente para agregar
    MealPlan? selectedMeal;

    // Obtener todas las recetas, favoritos y recientes
    final allRecipes = ref.read(allRecipesProvider);
    final favorites = ref.read(favoriteRecipesProvider);
    final recents = ref.read(recentRecipesProvider);

    // Filtrar por tipo de comida (si se especificó)
    final filteredAll =
        initialType != null
            ? allRecipes.where((recipe) => recipe.type == initialType).toList()
            : allRecipes;

    final filteredFavorites =
        initialType != null
            ? favorites.where((recipe) => recipe.type == initialType).toList()
            : favorites;

    final filteredRecents =
        initialType != null
            ? recents.where((recipe) => recipe.type == initialType).toList()
            : recents;

    // Definir las pestañas
    const tabs = ['Todas', 'Favoritas', 'Recientes'];
    int selectedTabIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Determinar qué lista mostrar según la pestaña seleccionada
              List<MealPlan> currentList;
              switch (selectedTabIndex) {
                case 1:
                  currentList = filteredFavorites;
                  break;
                case 2:
                  currentList = filteredRecents;
                  break;
                case 0:
                default:
                  currentList = filteredAll;
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador visual para arrastrar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Título y fecha
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Añadir comida',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Text(
                            formattedDate.capitalizePlanner(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF00BFA5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filtro por tipo de comida
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: MealType.values.length,
                          itemBuilder: (context, index) {
                            final type = MealType.values[index];
                            final isSelected = initialType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(type.name),
                                selected: isSelected,
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: type.color.withValues(
                                  alpha: 0.2,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    initialType = selected ? type : null;
                                  });
                                },
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color:
                                      isSelected
                                          ? type.color
                                          : Colors.grey.shade700,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Pestañas para alternar entre Todas, Favoritas, Recientes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(
                          tabs.length,
                          (index) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTabIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          selectedTabIndex == index
                                              ? const Color(0xFF00BFA5)
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tabs[index],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight:
                                        selectedTabIndex == index
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        selectedTabIndex == index
                                            ? const Color(0xFF00BFA5)
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de recetas según la pestaña seleccionada
                    Expanded(
                      child:
                          currentList.isEmpty
                              ? _buildEmptyRecipesState(context)
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: currentList.length,
                                itemBuilder: (context, index) {
                                  final recipe = currentList[index];
                                  final isSelected =
                                      selectedMeal?.id == recipe.id;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedMeal =
                                            isSelected ? null : recipe;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFF00BFA5,
                                                ).withValues(alpha: 0.05)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF00BFA5)
                                                  : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Imagen o icono
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child:
                                                  recipe.imageUrl.startsWith(
                                                        'assets/',
                                                      )
                                                      ? Image.asset(
                                                        recipe.imageUrl,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : Container(
                                                        color: recipe.type.color
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        child: Icon(
                                                          recipe.type.icon,
                                                          color:
                                                              recipe.type.color,
                                                          size: 40,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          // Información
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Etiqueta de tipo
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: recipe.type.color
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      recipe.type.name,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            recipe.type.color,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Nombre
                                                  Text(
                                                    recipe.name,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Detalles
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.schedule,
                                                        size: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${recipe.prepTimeMinutes} min',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        Icons
                                                            .local_fire_department,
                                                        size: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${recipe.calories} kcal',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Indicador de selección
                                          if (isSelected)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF00BFA5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),

                    // Botón de IA
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          // Botón Sugerir con IA
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showAiSuggestionDialog(context, initialType, (
                                  suggestedMeal,
                                ) {
                                  setState(() {
                                    selectedMeal = suggestedMeal;
                                  });
                                }, ref);
                              },
                              icon: Icon(
                                Icons.auto_awesome,
                                color: const Color(0xFF00BFA5),
                              ),
                              label: Text('Sugerir con IA'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF00BFA5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          // Espacio entre botones
                          const SizedBox(width: 10),

                          // Botón Explorar más recetas
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Cerrar diálogo actual
                                Navigator.pop(context);
                                // Abrir biblioteca de recetas
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const RecipeLibraryScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.restaurant_menu,
                                color: const Color(0xFF00BFA5),
                              ),
                              label: Text('Explorar más'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: const Color(0xFF00BFA5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón para agregar
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: ElevatedButton(
                        onPressed:
                            selectedMeal == null
                                ? null
                                : () {
                                  // Cerrar el diálogo
                                  Navigator.pop(context);

                                  // Actualizar fecha de último uso
                                  ref
                                      .read(allRecipesProvider.notifier)
                                      .updateLastUsed(selectedMeal!.id);

                                  // Agregar la comida con validaciones
                                  _addMealWithValidation(
                                    context,
                                    ref,
                                    selectedMeal!,
                                    dateKey,
                                    expectedType: initialType,
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Agregar a mi plan'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  // Widget para mostrar un estado vacío cuando no hay recetas
  Widget _buildEmptyRecipesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No se encontraron recetas',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otro filtro o añade recetas nuevas',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Método para abrir la biblioteca de recetas en modo selección
  void _openRecipeLibraryForSelection(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    MealType? initialType,
  ) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecipeLibraryScreen(
              selectionMode: true,
              initialMealType: initialType,
              onRecipeSelected: (MealPlan selectedRecipe) {
                // Actualizar fecha de último uso
                ref
                    .read(allRecipesProvider.notifier)
                    .updateLastUsed(selectedRecipe.id);

                // Agregar la comida con validaciones
                _addMealWithValidation(
                  context,
                  ref,
                  selectedRecipe,
                  dateKey,
                  expectedType: initialType,
                );

                // Regresar a la pantalla anterior después de seleccionar
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  // Mostrar diálogo para sugerencias IA
  void _showAiSuggestionDialog(
    BuildContext context,
    MealType? initialType,
    Function(MealPlan) onSelect,
    WidgetRef ref,
  ) {
    final ingredients = TextEditingController();
    final dietaryTags = <String>[];
    final mealType = initialType ?? MealType.lunch;

    // Todas las etiquetas dietéticas disponibles
    final allDietaryTags = [
      'Vegetariano',
      'Vegano',
      'Sin gluten',
      'Sin lácteos',
      'Alto en proteínas',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Sugerencia Inteligente',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nuestra IA te recomendará recetas basadas en tus preferencias y los ingredientes que ya tienes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Ingredientes disponibles
                      Row(
                        children: [
                          Text(
                            'Ingredientes disponibles',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(Opcional)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Si no ingresas ingredientes, te recomendaremos recetas populares',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: ingredients,
                        decoration: InputDecoration(
                          hintText: 'Escribe ingredientes separados por comas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        maxLines: 2,
                      ),

                      SizedBox(height: 16),

                      // Preferencias dietéticas
                      Row(
                        children: [
                          Text(
                            'Preferencias dietéticas',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(Opcional)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Selecciona si tienes alguna preferencia dietética específica',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            allDietaryTags.map((tag) {
                              final isSelected = dietaryTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: isSelected,
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: const Color(
                                  0xFF00BFA5,
                                ).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFF00BFA5),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      dietaryTags.add(tag);
                                    } else {
                                      dietaryTags.remove(tag);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),

                      SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Preparar parámetros para la sugerencia
                          Builder(
                            builder: (context) {
                              final params = <String, dynamic>{
                                'mealType': mealType,
                                'dietaryTags': dietaryTags,
                                'availableIngredients':
                                    ingredients.text.isEmpty
                                        ? null
                                        : ingredients.text
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toList(),
                              };

                              return Column(
                                children: [
                                  // Botón para generar
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Invalidar el provider para generar nuevas sugerencias
                                      ref.invalidate(
                                        aiSuggestionsProvider(params),
                                      );
                                    },
                                    icon: Icon(Icons.autorenew),
                                    label: Text('Generar sugerencia'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00BFA5),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Resultado de la sugerencia
                                  ref
                                      .watch(aiSuggestionsProvider(params))
                                      .when(
                                        data: (suggestions) {
                                          if (suggestions.isEmpty) {
                                            return Text(
                                              'No se encontraron sugerencias con esos criterios',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            );
                                          }

                                          // Mostrar la primera sugerencia
                                          final suggestion = suggestions.first;

                                          return Column(
                                            children: [
                                              // Título de sugerencia
                                              Text(
                                                'Te recomendamos:',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              SizedBox(height: 12),

                                              // Receta sugerida
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Imagen
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.asset(
                                                        suggestion.imageUrl,
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),

                                                    // Info
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: suggestion
                                                                  .type
                                                                  .color
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              suggestion
                                                                  .type
                                                                  .name,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 10,
                                                                color:
                                                                    suggestion
                                                                        .type
                                                                        .color,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            suggestion.name,
                                                            style:
                                                                GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            suggestion
                                                                    .ingredients
                                                                    .take(3)
                                                                    .join(
                                                                      ', ',
                                                                    ) +
                                                                (suggestion
                                                                            .ingredients
                                                                            .length >
                                                                        3
                                                                    ? '...'
                                                                    : ''),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 16),

                                              // Botón para seleccionar
                                              OutlinedButton(
                                                onPressed: () {
                                                  // Seleccionar esta receta
                                                  onSelect(suggestion);
                                                  Navigator.pop(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFF00BFA5,
                                                  ),
                                                  side: BorderSide(
                                                    color: const Color(
                                                      0xFF00BFA5,
                                                    ),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    44,
                                                  ),
                                                ),
                                                child: Text('Usar esta receta'),
                                              ),
                                            ],
                                          );
                                        },
                                        loading:
                                            () => Center(
                                              child: Column(
                                                children: [
                                                  CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          const Color(
                                                            0xFF00BFA5,
                                                          ),
                                                        ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'Buscando la mejor receta para ti...',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        error:
                                            (error, stack) => Text(
                                              'Error al generar sugerencias. Inténtalo de nuevo.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                      ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Mostrar diálogo para editar una comida
  void _showEditMealDialog(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    final formattedDate = DateFormat(
      'EEEE d MMMM',
      'es_ES',
    ).format(DateFormat('yyyy-MM-dd').parse(dateKey));

    // Obtener todas las recetas
    final allRecipes = ref.read(allRecipesProvider);

    // Filtrar recetas del mismo tipo
    final recipes =
        allRecipes.where((recipe) => recipe.type == meal.type).toList();

    // Comida seleccionada actualmente
    MealPlan selectedMeal = meal;

    // Obtener favoritos y recientes
    final favorites =
        ref
            .read(favoriteRecipesProvider)
            .where((r) => r.type == meal.type)
            .toList();
    final recents =
        ref
            .read(recentRecipesProvider)
            .where((r) => r.type == meal.type)
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return DefaultTabController(
                length: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indicador visual para arrastrar
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Título y fecha
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Reemplazar comida',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            Text(
                              formattedDate.capitalizePlanner(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF00BFA5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Comida actual a reemplazar
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vas a reemplazar: ${meal.name}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tabs para categorías
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TabBar(
                          indicatorColor: const Color(0xFF00BFA5),
                          labelColor: const Color(0xFF00BFA5),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Todas'),
                            Tab(text: 'Favoritas'),
                            Tab(text: 'Recientes'),
                          ],
                        ),
                      ),

                      // Lista de recetas según tab seleccionada
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Todas las recetas
                            RecipeListBuilder.buildRecipeList(
                              context,
                              setState,
                              recipes,
                              selectedMeal,
                              (meal) => setState(() => selectedMeal = meal),
                              ref,
                            ),

                            // Favoritas
                            RecipeListBuilder.buildRecipeList(
                              context,
                              setState,
                              favorites,
                              selectedMeal,
                              (meal) => setState(() => selectedMeal = meal),
                              ref,
                            ),

                            // Recientes
                            RecipeListBuilder.buildRecipeList(
                              context,
                              setState,
                              recents,
                              selectedMeal,
                              (meal) => setState(() => selectedMeal = meal),
                              ref,
                            ),
                          ],
                        ),
                      ),

                      // Botón de IA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Mostrar diálogo de sugerencia IA
                            _showAiSuggestionDialog(context, meal.type, (
                              suggestedMeal,
                            ) {
                              setState(() {
                                selectedMeal = suggestedMeal;
                              });
                            }, ref);
                          },
                          icon: Icon(
                            Icons.auto_awesome,
                            color: const Color(0xFF00BFA5),
                          ),
                          label: Text('Sugerir con IA'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFF00BFA5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      // Botón para reemplazar
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: () {
                            // Cerrar el diálogo
                            Navigator.pop(context);

                            // Actualizar fecha de uso
                            ref
                                .read(allRecipesProvider.notifier)
                                .updateLastUsed(selectedMeal.id);

                            // Actualizar el plan reemplazando la comida anterior con la nueva seleccionada
                            ref
                                .read(mealPlansProvider.notifier)
                                .editMeal(dateKey, meal, selectedMeal);

                            // Mostrar confirmación
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Comida reemplazada correctamente',
                                ),
                                backgroundColor: const Color(0xFF00BFA5),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reemplazar comida'),
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

  // Mostrar lista de compra
  void _showShoppingList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: const Color(0xFF00BFA5),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lista de compra',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Basada en tu plan semanal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildShoppingCategory('Frutas y verduras', [
                      'Tomate (3)',
                      'Pepino (1)',
                      'Espinacas (200g)',
                      'Calabacín (2)',
                      'Berenjena (1)',
                    ]),
                    _buildShoppingCategory('Proteínas', [
                      'Huevos (6)',
                      'Queso feta (100g)',
                      'Garbanzos (200g)',
                    ]),
                    _buildShoppingCategory('Cereales', ['Quinoa (150g)']),
                    _buildShoppingCategory('Lácteos', [
                      'Yogur natural (500g)',
                      'Leche (500ml)',
                    ]),
                    _buildShoppingCategory('Otros', [
                      'Aceite de oliva (100ml)',
                      'Miel (50g)',
                    ]),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Exportar lista de compra
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Exportar lista'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Construir categoría de compras
  Widget _buildShoppingCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00BFA5),
            ),
          ),
        ),
        ...items.map(
          (item) => CheckboxListTile(
            value: false,
            onChanged: (value) {},
            title: Text(item, style: GoogleFonts.inter(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const Divider(height: 16),
      ],
    );
  }

  // Mostrar estadísticas
  void _showStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: const Color(0xFF00BFA5),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Impacto de tu planificación',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildStatItem(
                      'Alimentos salvados',
                      '3.2 kg',
                      Icons.eco,
                      Colors.green,
                      'Has evitado desperdiciar 3.2 kg de alimentos esta semana',
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      'Emisiones reducidas',
                      '2.5 kg CO₂',
                      Icons.cloud,
                      Colors.blue,
                      'Equivalente a no conducir 10 km en coche',
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      'Agua ahorrada',
                      '320 litros',
                      Icons.water_drop,
                      Colors.lightBlue,
                      'Equivalente al consumo de 4 días de una persona',
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      'Ahorro económico',
                      '€ 24.50',
                      Icons.euro,
                      Colors.amber,
                      'Has ahorrado aproximadamente €24.50 esta semana',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Construir elemento de estadística
  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para mover una comida a otro día
  void _showMoveMealDialog(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String currentDateKey,
    DateTime currentDate,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => MoveMealDialog(
            meal: meal,
            currentDateKey: currentDateKey,
            currentDate: currentDate,
            onMoveMeal: (fromDate, toDate, mealToMove) {
                      ref
                          .read(mealPlansProvider.notifier)
                  .moveMeal(fromDate, toDate, mealToMove);
            },
          ),
    );
  }

  // Mostrar diálogo para agregar un recordatorio
  void _showReminderDialog(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => CustomReminderDialog(
            onAdd: (reminderText) {
              // Agregar el recordatorio a la lista existente
              final currentReminders = meal.reminders ?? [];
              final updatedReminders = [...currentReminders, reminderText];
              final updatedMeal = meal.copyWith(reminders: updatedReminders);
                                  ref
                                      .read(mealPlansProvider.notifier)
                                      .editMeal(dateKey, meal, updatedMeal);
            },
          ),
    );
  }

  // Diálogo para añadir un recordatorio personalizado
  void _showAddCustomReminderDialog(
    BuildContext context,
    Function(String) onAdd, {
    String? initialText,
  }) {
    final TextEditingController controller = TextEditingController(
      text: initialText,
    );
    final TextEditingController customTimeController = TextEditingController(
      text: '30',
    );

    // Opciones para los tipos de recordatorios
    final reminderIcons = [
      {'icon': Icons.event_note, 'color': Colors.blue},
      {'icon': Icons.restaurant, 'color': Colors.orange},
      {'icon': Icons.shopping_basket, 'color': Colors.green},
      {'icon': Icons.water_drop, 'color': Colors.lightBlue},
      {'icon': Icons.kitchen, 'color': Colors.purple},
      {'icon': Icons.alarm, 'color': Colors.red},
    ];

    // Opciones de tiempo relativo
    final timeOptions = [
      {'value': 0, 'label': 'A la hora programada'},
      {'value': 15, 'label': '15 minutos antes'},
      {'value': 30, 'label': '30 minutos antes'},
      {'value': 60, 'label': '1 hora antes'},
      {'value': 180, 'label': '3 horas antes'},
      {'value': 360, 'label': '6 horas antes'},
      {'value': 1440, 'label': '1 día antes'},
      {'value': -1, 'label': 'Personalizado'},
    ];

    // Opciones para unidades de tiempo personalizadas
    final timeUnits = [
      {'value': 'minutes', 'label': 'minutos'},
      {'value': 'hours', 'label': 'horas'},
    ];

    // Índices seleccionados
    int selectedIconIndex = 0;
    int selectedTimeIndex = 2; // 30 minutos antes por defecto
    int selectedTimeUnitIndex = 0; // minutos por defecto
    bool isCustomTime = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Añadir listener al controlador de texto para actualizar la vista previa
              // en tiempo real cuando cambie el valor
              customTimeController.addListener(() {
                // Solo llamamos setState para forzar la actualización de la UI
                // No es necesario cambiar ningún valor aquí porque customTimeController
                // ya contiene el nuevo valor
                setState(() {});
              });

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_notifications,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              initialText != null
                                  ? 'Editar recordatorio'
                                  : 'Nuevo recordatorio',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Campo de texto con diseño mejorado
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Descripción del recordatorio',
                            hintText:
                                'Ej. Preparar ingredientes para la comida',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.amber.shade700,
                                width: 2,
                              ),
                            ),
                            floatingLabelStyle: GoogleFonts.inter(
                              color: Colors.amber.shade700,
                            ),
                            prefixIcon: const Icon(Icons.event_note),
                            suffixIcon: IconButton(
                              onPressed: () => controller.clear(),
                              icon: const Icon(Icons.clear),
                              splashRadius: 20,
                            ),
                          ),
                          maxLength: 50,
                          textCapitalization: TextCapitalization.sentences,
                          autofocus: true,
                        ),

                        const SizedBox(height: 16),

                        // Selector de tiempo relativo
                        Text(
                          '¿Cuándo quieres recibir el recordatorio?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: timeOptions.length,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (context, index) {
                              final option = timeOptions[index];
                              final isSelected = index == selectedTimeIndex;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTimeIndex = index;
                                    isCustomTime = option['value'] == -1;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.amber.shade100
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.amber.shade700
                                              : Colors.transparent,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      option['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            isSelected
                                                ? Colors.amber.shade700
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Opciones de tiempo personalizado
                        if (isCustomTime)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personaliza el tiempo del recordatorio',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    // Campo para introducir el tiempo
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tiempo',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.teal,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.teal,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: TextField(
                                              controller: customTimeController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                hintText: '30',
                                                hintStyle: GoogleFonts.inter(
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Selector de unidad de tiempo
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 18,
                                          ), // Alinear con el campo de texto
                                          Container(
                                            height: 46,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                for (
                                                  int i = 0;
                                                  i < timeUnits.length;
                                                  i++
                                                )
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedTimeUnitIndex =
                                                              i;
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color:
                                                              selectedTimeUnitIndex ==
                                                                      i
                                                                  ? Colors
                                                                      .amber
                                                                      .shade200
                                                                  : Colors
                                                                      .grey
                                                                      .shade50,
                                                          borderRadius: BorderRadius.horizontal(
                                                            left:
                                                                i == 0
                                                                    ? const Radius.circular(
                                                                      24,
                                                                    )
                                                                    : Radius
                                                                        .zero,
                                                            right:
                                                                i ==
                                                                        timeUnits.length -
                                                                            1
                                                                    ? const Radius.circular(
                                                                      24,
                                                                    )
                                                                    : Radius
                                                                        .zero,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            timeUnits[i]['label']
                                                                as String,
                                                            style: GoogleFonts.inter(
                                                              color:
                                                                  selectedTimeUnitIndex ==
                                                                          i
                                                                      ? Colors
                                                                          .amber
                                                                          .shade800
                                                                      : Colors
                                                                          .black87,
                                                              fontWeight:
                                                                  selectedTimeUnitIndex ==
                                                                          i
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .normal,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Selector de icono para el recordatorio
                        Text(
                          'Elige un icono para tu recordatorio',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Galería de iconos para seleccionar
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: reminderIcons.length,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (context, index) {
                              final item = reminderIcons[index];
                              final isSelected = index == selectedIconIndex;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIconIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? (item['color'] as Color)
                                                .withValues(alpha: 0.1)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? item['color'] as Color
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: item['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Vista previa del recordatorio
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isCustomTime
                                      ? 'Recibirás una notificación ${customTimeController.text} ${timeUnits[selectedTimeUnitIndex]['label']} antes de la comida'
                                      : 'Recibirás una notificación ${timeOptions[selectedTimeIndex]['label']} de la comida',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  // Obtener la información seleccionada
                                  final title = controller.text.trim();
                                  String timeLabel;

                                  // Determinar el tiempo seleccionado (predefinido o personalizado)
                                  if (isCustomTime) {
                                    final customTime =
                                        int.tryParse(
                                          customTimeController.text,
                                        ) ??
                                        30;
                                    final unit =
                                        timeUnits[selectedTimeUnitIndex]['label']
                                            as String;
                                    timeLabel = '$customTime $unit antes';
                                  } else {
                                    timeLabel =
                                        timeOptions[selectedTimeIndex]['label']
                                            as String;
                                  }

                                  // Crear el texto del recordatorio con el tiempo seleccionado
                                  final reminderText = '$title - $timeLabel';

                                  onAdd(reminderText);
                                  Navigator.pop(context);
                                } else {
                                  // Mostrar un error si el campo está vacío
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Por favor, escribe un recordatorio',
                                        style: GoogleFonts.inter(),
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                initialText != null ? 'Actualizar' : 'Añadir',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  // Mostrar historial de planificación
  void _showPlanningHistory(BuildContext context, WidgetRef ref) {
    final history = ref.read(planningHistoryProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de arrastre
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: const Color(0xFF00BFA5),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Historial de planificación',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Para acceder a semanas pasadas, selecciona una semana de este historial',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const Divider(height: 1),

                if (history.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes historial de planificación',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Comienza a planificar tus comidas para reducir el desperdicio',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final weekKey =
                            history[history.length -
                                1 -
                                index]; // Mostrar del más reciente al más antiguo
                        final weekStart = DateFormat(
                          'yyyy-MM-dd',
                        ).parse(weekKey);
                        final weekEnd = weekStart.add(const Duration(days: 6));

                        final weekFormat = DateFormat('d MMMM', 'es_ES');
                        final formattedRange =
                            '${weekFormat.format(weekStart)} - ${weekFormat.format(weekEnd)}';

                        // Obtener estadísticas de esta semana
                        final mealPlans = ref.read(mealPlansProvider);
                        int totalMeals = 0;

                        for (int i = 0; i < 7; i++) {
                          final day = weekStart.add(Duration(days: i));
                          final dayKey = DateFormat('yyyy-MM-dd').format(day);
                          if (mealPlans.containsKey(dayKey)) {
                            totalMeals += mealPlans[dayKey]!.length;
                          }
                        }

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              // Navegar a esta semana en el planificador
                              ref.read(currentWeekProvider.notifier).state =
                                  weekStart;
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.calendar_month,
                                        color: Colors.blueGrey.shade400,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedRange.capitalizePlanner(),
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$totalMeals comidas planificadas',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.navigate_next,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  // Método para mostrar detalles de una comida
  void _showMealDetails(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    final formattedDate =
        DateFormat(
          'EEEE d MMMM',
          'es_ES',
        ).format(DateFormat('yyyy-MM-dd').parse(dateKey)).capitalizePlanner();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la comida
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: AssetImage(meal.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: meal.type.color.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(meal.type.icon, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              meal.type.name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Información de la comida
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF00BFA5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditMealDialog(
                                  context,
                                  ref,
                                  meal,
                                  dateKey,
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Ingredientes',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...meal.ingredients.map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BFA5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  ingredient,
                                  style: GoogleFonts.inter(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Recordatorios',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (meal.reminders == null || meal.reminders!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_off,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No hay recordatorios configurados',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...meal.reminders!.map(
                            (reminder) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    reminder,
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showReminderDialog(context, ref, meal, dateKey);
                          },
                          icon: const Icon(Icons.notifications),
                          label: Text(
                            meal.reminders == null || meal.reminders!.isEmpty
                                ? 'Configurar recordatorios'
                                : 'Modificar recordatorios',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Método para agregar una comida al plan con validaciones
  void _addMealWithValidation(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey, {
    MealType? expectedType,
  }) {
    // Comprobar si el tipo de comida no coincide con el tipo esperado
    if (expectedType != null && meal.type != expectedType) {
      // Mostrar diálogo de confirmación
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Tipo de comida diferente',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Has seleccionado una receta de ${meal.type.name.toLowerCase()} mientras estabas buscando ${expectedType.name.toLowerCase()}.',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¿Deseas continuar y agregar esta receta de todos modos?',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Continuar con la validación normal
                    _processValidation(context, ref, meal, dateKey);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Continuar de todos modos'),
                ),
              ],
            ),
      );
      return;
    }

    // Si el tipo coincide o no se especificó, continuar con la validación normal
    _processValidation(context, ref, meal, dateKey);
  }

  // Método privado para procesar las validaciones
  void _processValidation(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
  ) {
    // Obtener todos los planes de comida existentes
    final allMealPlans = ref.read(mealPlansProvider);

    // Obtener las preferencias del usuario
    final preferences = ref.read(userPlanningPreferencesProvider);

    // Realizar todas las validaciones
    final validations = MealPlanValidator.validateMealPlan(
      newMeal: meal,
      dateKey: dateKey,
      allMealPlans: allMealPlans,
      preferences: preferences,
    );

    // Guardar los resultados de la validación
    ref.read(lastValidationResultsProvider.notifier).state = validations;

    // Verificar si hay errores (validaciones que no son válidas)
    final hasErrors = validations.any((v) => !v.isValid);

    if (hasErrors) {
      // Mostrar diálogo de error
      _showValidationDialog(
        context,
        validations.where((v) => !v.isValid).toList(),
        onContinue: null, // No hay opción de continuar si hay errores
      );
      return;
    }

    // Verificar si hay advertencias
    final warnings =
        validations
            .where((v) => v.isValid && v.severity == ValidationSeverity.warning)
            .toList();

    if (warnings.isNotEmpty) {
      // Mostrar diálogo de advertencia con opción de continuar
      _showValidationDialog(
        context,
        warnings,
        onContinue: () {
          // Agregar la comida al plan
          ref.read(mealPlansProvider.notifier).addMeal(dateKey, meal);

          // Registrar la planificación en el historial si es la primera vez
          final weekKey = DateFormat('yyyy-MM-dd').format(
            DateTime.parse(
              dateKey,
            ).subtract(Duration(days: DateTime.parse(dateKey).weekday - 1)),
          );

          if (!ref
              .read(planningHistoryProvider.notifier)
              .hasWeekInHistory(weekKey)) {
            ref
                .read(planningHistoryProvider.notifier)
                .addWeekToHistory(weekKey);
          }

          // Cerrar el diálogo
          Navigator.pop(context);

          // Mostrar animación de éxito en lugar de Snackbar
          _showSuccessAnimation(context, '¡Comida agregada a tu plan!');
        },
      );
      return;
    }

    // Si no hay errores ni advertencias, agregar directamente
    ref.read(mealPlansProvider.notifier).addMeal(dateKey, meal);

    // Registrar la planificación en el historial si es la primera vez
    final weekKey = DateFormat('yyyy-MM-dd').format(
      DateTime.parse(
        dateKey,
      ).subtract(Duration(days: DateTime.parse(dateKey).weekday - 1)),
    );

    if (!ref.read(planningHistoryProvider.notifier).hasWeekInHistory(weekKey)) {
      ref.read(planningHistoryProvider.notifier).addWeekToHistory(weekKey);
    }

    // Mostrar animación de éxito en lugar de Snackbar
    _showSuccessAnimation(context, '¡Comida agregada a tu plan!');
  }

  // Método para mostrar diálogo de validación
  void _showValidationDialog(
    BuildContext context,
    List<MealPlanValidation> validations, {
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              onContinue == null ? 'No se puede continuar' : 'Advertencias',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onContinue == null
                        ? 'Por favor, corrige los siguientes errores:'
                        : 'Se han encontrado las siguientes advertencias:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: validations.length,
                      itemBuilder: (context, index) {
                        final validation = validations[index];
                        final color =
                            validation.severity == ValidationSeverity.error
                                ? Colors.red.shade700
                                : Colors.orange.shade800;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                validation.severity == ValidationSeverity.error
                                    ? Icons.error_outline
                                    : Icons.warning_amber_outlined,
                                size: 20,
                                color: color,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  validation.message,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: Colors.grey.shade700),
                ),
              ),
              if (onContinue != null)
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continuar de todos modos'),
                ),
            ],
          ),
    );
  }

  // Método para mostrar el tutorial de onboarding
  void _showOnboardingTutorial(BuildContext context, WidgetRef ref) {
    // Crear un controlador para manejar las páginas del tutorial
    final PageController pageController = PageController();

    // Definir los pasos del tutorial
    final tutorialSteps = [
      {
        'title': '¡Bienvenido a tu planificador semanal!',
        'description':
            'Planifica tus comidas de forma inteligente y reduce el desperdicio de alimentos.',
        'icon': Icons.restaurant_menu,
        'color': const Color(0xFF00BFA5),
      },
      {
        'title': 'Selecciona un día',
        'description':
            'Toca en cualquier día de la semana para planificar tus comidas.',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
      },
      {
        'title': 'Añade comidas',
        'description':
            'Puedes agregar desayunos, almuerzos, cenas y snacks. Toca el botón "+" para empezar.',
        'icon': Icons.add_circle_outline,
        'color': Colors.orange,
      },
      {
        'title': 'Sugerencias inteligentes',
        'description':
            'Nuestra IA puede recomendarte recetas basadas en tus preferencias e ingredientes disponibles.',
        'icon': Icons.auto_awesome,
        'color': Colors.purple,
      },
      {
        'title': '¡Listo para empezar!',
        'description':
            'Ahora ya conoces lo básico para comenzar a planificar tus comidas y reducir el desperdicio.',
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
    ];

    // Variable para controlar la página actual - movida fuera del builder
    int currentPage = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 400,
                  child: Column(
                    children: [
                      // Contenido principal
                      Expanded(
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: tutorialSteps.length,
                          onPageChanged: (page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          itemBuilder: (context, index) {
                            final step = tutorialSteps[index];
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icono
                                  Container(
                                    width: 100,
                                    height: 77,
                                    decoration: BoxDecoration(
                                      color: (step['color'] as Color)
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      step['icon'] as IconData,
                                      size: 48,
                                      color: step['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Título
                                  Text(
                                    step['title'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),

                                  // Descripción
                                  Text(
                                    step['description'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Indicadores de página
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            tutorialSteps.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    currentPage == index
                                        ? const Color(0xFF00BFA5)
                                        : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Botones de navegación
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Botón omitir
                            TextButton(
                              onPressed: () {
                                // Marcar como no primera vez
                                ref
                                    .read(isFirstPlanningProvider.notifier)
                                    .state = false;
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Omitir',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),

                            // Botón siguiente o finalizar
                            ElevatedButton(
                              onPressed: () {
                                if (currentPage < tutorialSteps.length - 1) {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  // Marcar como no primera vez
                                  ref
                                      .read(isFirstPlanningProvider.notifier)
                                      .state = false;
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BFA5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                currentPage < tutorialSteps.length - 1
                                    ? 'Siguiente'
                                    : 'Comenzar',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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

  // Método para mostrar animación de éxito
  void _showSuccessAnimation(BuildContext context, String message) {
    // Usar un overlay para mostrar una animación flotante
    final overlay = Overlay.of(context);

    // Creamos la entrada del overlay
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 100,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                onEnd: () {
                  // Después de mostrar la animación, esperar un poco y eliminarla
                  Future.delayed(const Duration(seconds: 2), () {
                    entry.remove();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono que se anima
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF00BFA5),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mensaje sin formato especial que cause subrayado
                      Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    // Mostrar el overlay
    overlay.insert(entry);
  }

  // Método para mostrar una guía de los iconos
  void _showIconGuide(
    BuildContext context,
    WidgetRef ref, {
    bool forceShow = false,
  }) {
    // Si no se fuerza la visualización y ya se ha mostrado antes, no hacer nada
    if (!forceShow && ref.read(hasShownIconGuideProvider)) {
      return;
    }

    // Esperar a que se construya la UI
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF00BFA5),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Guía de iconos',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconGuideItem(
                    Icons.history_outlined,
                    'Historial de planificación',
                    'Accede a tus planificaciones anteriores',
                  ),
                  const SizedBox(height: 12),
                  _buildIconGuideItem(
                    Icons.restaurant_menu,
                    'Biblioteca de recetas',
                    'Explora todas las recetas disponibles',
                  ),
                  const SizedBox(height: 12),
                  _buildIconGuideItem(
                    Icons.shopping_cart_outlined,
                    'Lista de compra',
                    'Genera una lista basada en tu plan semanal',
                  ),
                  const SizedBox(height: 12),
                  _buildIconGuideItem(
                    Icons.analytics_outlined,
                    'Estadísticas de impacto',
                    'Visualiza el impacto positivo de tu planificación',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    'No mostrar de nuevo',
                    style: GoogleFonts.inter(color: Colors.grey.shade600),
                  ),
                  onPressed: () {
                    ref.read(hasShownIconGuideProvider.notifier).state = true;
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(hasShownIconGuideProvider.notifier).state = true;
                    Navigator.of(context).pop();
                  },
                  child: Text('Entendido'),
                ),
              ],
            ),
      );
    });
  }

  // Widget auxiliar para cada ítem de la guía de iconos
  Widget _buildIconGuideItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
