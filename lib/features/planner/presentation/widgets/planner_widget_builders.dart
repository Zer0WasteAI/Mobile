import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/planner_dialog_manager.dart';

/// Constructores de widgets para el planner
class PlannerWidgetBuilders {

  /// Construir los días de la semana
  static Widget buildWeekDays(
    BuildContext context,
    WidgetRef ref,
    List<DateTime> weekDays,
    DateTime? selectedDay,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final isSelected = selectedDay?.day == day.day &&
              selectedDay?.month == day.month &&
              selectedDay?.year == day.year;
          final isToday = _isToday(day);
          
          return GestureDetector(
            onTap: () => _updateSelectedDay(ref, day),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : isToday
                        ? primaryColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('es_ES').format(day),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? primaryColor
                              : theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? primaryColor
                              : theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  /// Construir el planificador del día
  static Widget buildDayPlanner(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
    List<MealPlan>? dayMeals,
  ) {
    if (dayMeals == null || dayMeals.isEmpty) {
      return buildEmptyDayState(context, selectedDay, ref);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(context, selectedDay),
          const SizedBox(height: 20),
          
          // Desayuno
          _buildMealSection(
            context,
            ref,
            'Desayuno',
            MealType.breakfast,
            dayMeals.where((meal) => meal.type == MealType.breakfast).toList(),
            selectedDay,
            Icons.wb_sunny,
            Colors.orange,
          ),
          
          const SizedBox(height: 16),
          
          // Almuerzo
          _buildMealSection(
            context,
            ref,
            'Almuerzo',
            MealType.lunch,
            dayMeals.where((meal) => meal.type == MealType.lunch).toList(),
            selectedDay,
            Icons.lunch_dining,
            Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          // Cena
          _buildMealSection(
            context,
            ref,
            'Cena',
            MealType.dinner,
            dayMeals.where((meal) => meal.type == MealType.dinner).toList(),
            selectedDay,
            Icons.dinner_dining,
            Colors.purple,
          ),
          
          const SizedBox(height: 16),
          
          // Snacks
          _buildMealSection(
            context,
            ref,
            'Snacks',
            MealType.snack,
            dayMeals.where((meal) => meal.type == MealType.snack).toList(),
            selectedDay,
            Icons.cookie,
            Colors.blue,
          ),
          
          const SizedBox(height: 32),
          
          // Botones de acción
          _buildActionButtons(context, ref, selectedDay),
        ],
      ),
    );
  }

  /// Construir estado vacío del día
  static Widget buildEmptyDayState(BuildContext context, DateTime selectedDay, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay comidas planificadas',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'para el ${DateFormat('d MMMM', 'es_ES').format(selectedDay)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Mostrar dialog para agregar primera comida
                PlannerDialogManager.showAddMealDialog(
                  context,
                  ref,
                  selectedDay,
                  MealType.breakfast,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Comida'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir sección de comida vacía
  static Widget buildEmptyMealTypeSection(
    BuildContext context,
    WidgetRef ref,
    String mealTypeName,
    MealType mealType,
    DateTime selectedDay,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'No hay $mealTypeName planificado',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              PlannerDialogManager.showAddMealDialog(
                context,
                ref,
                selectedDay,
                mealType,
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar'),
            style: TextButton.styleFrom(
              foregroundColor: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir item de comida
  static Widget buildMealItem(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
    DateTime selectedDay,
    MealType mealType,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: meal.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  meal.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.restaurant,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : Icon(
                Icons.restaurant,
                color: Colors.grey[400],
              ),
        title: Text(
          meal.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: meal.ingredients.isNotEmpty
            ? Text(
                meal.ingredients.take(3).join(', ') + 
                (meal.ingredients.length > 3 ? '...' : ''),
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMealAction(
            context,
            ref,
            value,
            meal,
            selectedDay,
            mealType,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'move',
              child: ListTile(
                leading: Icon(Icons.move_up),
                title: Text('Mover'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'reminder',
              child: ListTile(
                leading: Icon(Icons.alarm),
                title: Text('Recordatorio'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showMealDetails(context, ref, meal),
      ),
    );
  }

  /// Construir estado de recetas vacías
  static Widget buildEmptyRecipesState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes recetas guardadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunas recetas a tu colección para planificar comidas más fácilmente',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a biblioteca de recetas
            },
            icon: const Icon(Icons.add),
            label: const Text('Explorar Recetas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares privados

  static bool _isToday(DateTime day) {
    final today = DateTime.now();
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }

  static void _updateSelectedDay(WidgetRef ref, DateTime day) {
    ref.read(selectedDayProvider.notifier).state = day;
  }

  static Widget _buildDayHeader(BuildContext context, DateTime selectedDay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightPrimary,
            AppColors.lightPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE', 'es_ES').format(selectedDay),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('d MMMM yyyy', 'es_ES').format(selectedDay),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildMealSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    MealType mealType,
    List<MealPlan> meals,
    DateTime selectedDay,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    PlannerDialogManager.showAddMealDialog(
                      context,
                      ref,
                      selectedDay,
                      mealType,
                    );
                  },
                  icon: Icon(Icons.add, color: color),
                ),
              ],
            ),
          ),
          meals.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: buildEmptyMealTypeSection(
                    context,
                    ref,
                    title.toLowerCase(),
                    mealType,
                    selectedDay,
                    icon,
                    color,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: meals.map((meal) => buildMealItem(
                      context,
                      ref,
                      meal,
                      selectedDay,
                      mealType,
                    )).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  static Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => PlannerDialogManager.showShoppingList(context, ref),
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Lista de\nCompras'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => PlannerDialogManager.showStats(context, ref),
          icon: const Icon(Icons.analytics),
          label: const Text('Estadísticas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  static void _handleMealAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    MealPlan meal,
    DateTime selectedDay,
    MealType mealType,
  ) {
    switch (action) {
      case 'edit':
        // Mostrar dialog de edición
        break;
      case 'move':
        PlannerDialogManager.showMoveMealDialog(context, ref, meal);
        break;
      case 'reminder':
        PlannerDialogManager.showReminderDialog(context, ref, meal);
        break;
      case 'delete':
        // Confirmar y eliminar
        break;
    }
  }

  static void _showMealDetails(BuildContext context, WidgetRef ref, MealPlan meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meal.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meal.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Ingredientes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingredient)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}