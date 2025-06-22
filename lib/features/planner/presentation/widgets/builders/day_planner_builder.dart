import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';

class DayPlannerBuilder {
  static Widget buildDayPlanner(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    Color textColor,
    Color primaryColor,
    Function(BuildContext, WidgetRef, DateTime, {MealType? initialType})
    onAddMeal,
    Function(BuildContext, WidgetRef, MealPlan, String) onShowMealDetails,
    Function(BuildContext, WidgetRef, MealPlan, String) onShowReminderDialog,
    Function(BuildContext, WidgetRef, MealPlan, String) onMoveMeal,
    Function(WidgetRef, String, MealPlan) onDeleteMeal,
  ) {
    // Formatear fecha como clave para el mapa de planes de comida
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final formattedDate = DateFormat('EEEE d MMMM', 'es_ES').format(day);
    final capitalizedDate =
        formattedDate.isEmpty
            ? formattedDate
            : '${formattedDate[0].toUpperCase()}${formattedDate.substring(1)}';

    // Obtener los planes de comida para este día
    final mealPlans = ref.watch(mealPlansProvider);
    final mealsForDay = mealPlans[dateKey] ?? [];

    // Lista ordenada de tipos de comida
    final orderedMealTypes = [
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
      MealType.snack,
    ];

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragIndicator(),
          _buildDateHeader(capitalizedDate, primaryColor, textColor, ref, day),
          const SizedBox(height: 16),
          _buildInfoMessage(),
          const SizedBox(height: 16),
          Expanded(
            child:
                mealsForDay.isEmpty
                    ? _buildEmptyDayState(
                      context,
                      textColor,
                      ref,
                      day,
                      onAddMeal,
                    )
                    : _buildMealsList(
                      context,
                      ref,
                      mealsForDay,
                      orderedMealTypes,
                      dateKey,
                      textColor,
                      primaryColor,
                      onAddMeal,
                      onShowMealDetails,
                      onShowReminderDialog,
                      onMoveMeal,
                      onDeleteMeal,
                    ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDragIndicator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  static Widget _buildDateHeader(
    String capitalizedDate,
    Color primaryColor,
    Color textColor,
    WidgetRef ref,
    DateTime day,
  ) {
    final historyWeekKey = DateFormat(
      'yyyy-MM-dd',
    ).format(day.subtract(Duration(days: day.weekday - 1)));
    final hasPlannedThisWeekBefore = ref
        .read(planningHistoryProvider.notifier)
        .hasWeekInHistory(historyWeekKey);

    return Row(
      children: [
        Icon(Icons.event, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          capitalizedDate,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Spacer(),
        if (!hasPlannedThisWeekBefore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Primera vez',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Puedes planificar 1 desayuno, 1 almuerzo, 1 cena y hasta 3 snacks por día.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyDayState(
    BuildContext context,
    Color textColor,
    WidgetRef ref,
    DateTime day,
    Function(BuildContext, WidgetRef, DateTime, {MealType? initialType})
    onAddMeal,
  ) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(day) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              isToday
                  ? '¡Es hora de planificar tu día!'
                  : '¡Día sin planificar!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Planifica tus comidas para reducir el desperdicio de alimentos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => onAddMeal(context, ref, day),
              icon: const Icon(Icons.add),
              label: Text(
                isToday ? 'Planificar comida de hoy' : 'Añadir primera comida',
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

  static Widget _buildMealsList(
    BuildContext context,
    WidgetRef ref,
    List<MealPlan> mealsForDay,
    List<MealType> orderedMealTypes,
    String dateKey,
    Color textColor,
    Color primaryColor,
    Function(BuildContext, WidgetRef, DateTime, {MealType? initialType})
    onAddMeal,
    Function(BuildContext, WidgetRef, MealPlan, String) onShowMealDetails,
    Function(BuildContext, WidgetRef, MealPlan, String) onShowReminderDialog,
    Function(BuildContext, WidgetRef, MealPlan, String) onMoveMeal,
    Function(WidgetRef, String, MealPlan) onDeleteMeal,
  ) {
    final day = DateFormat('yyyy-MM-dd').parse(dateKey);

    return ListView.builder(
      itemCount: orderedMealTypes.length,
      itemBuilder: (context, index) {
        final type = orderedMealTypes[index];
        final mealsOfType = mealsForDay.where((m) => m.type == type).toList();

        if (mealsOfType.isEmpty) {
          return _buildEmptyMealTypeSection(
            context,
            textColor,
            type,
            () => onAddMeal(context, ref, day, initialType: type),
          );
        }

        return Column(
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
                const Spacer(),
                if ((type == MealType.snack && mealsOfType.length < 3) ||
                    mealsOfType.isEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                    onPressed:
                        () => onAddMeal(context, ref, day, initialType: type),
                    tooltip: 'Añadir ${type.name}',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...mealsOfType.map(
              (meal) => _buildMealItem(
                context,
                ref,
                meal,
                dateKey,
                onShowMealDetails,
                onShowReminderDialog,
                onMoveMeal,
                onDeleteMeal,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  static Widget _buildEmptyMealTypeSection(
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

  static Widget _buildMealItem(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    String dateKey,
    Function(BuildContext, WidgetRef, MealPlan, String) onShowMealDetails,
    Function(BuildContext, WidgetRef, MealPlan, String) onShowReminderDialog,
    Function(BuildContext, WidgetRef, MealPlan, String) onMoveMeal,
    Function(WidgetRef, String, MealPlan) onDeleteMeal,
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
          onTap: () => onShowMealDetails(context, ref, meal, dateKey),
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
                    switch (value) {
                      case 'edit':
                        onShowMealDetails(context, ref, meal, dateKey);
                        break;
                      case 'move':
                        onMoveMeal(context, ref, meal, dateKey);
                        break;
                      case 'reminder':
                        onShowReminderDialog(context, ref, meal, dateKey);
                        break;
                      case 'delete':
                        onDeleteMeal(ref, dateKey, meal);
                        break;
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
}
