// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/meal_plan_models.dart';
import '../../providers/meal_planning_providers.dart';
import '../../../application/providers/meal_planning_providers.dart'
    as app_providers;
import 'meal_card_widget.dart';

class DailyMealPlannerWidget extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DailyMealPlannerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  ConsumerState<DailyMealPlannerWidget> createState() =>
      _DailyMealPlannerWidgetState();
}

class _DailyMealPlannerWidgetState
    extends ConsumerState<DailyMealPlannerWidget> {
  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final mealPlanAsync = ref.watch(mealPlanByDateProvider(dateString));

    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: mealPlanAsync.when(
            data: (mealPlan) => _buildMealPlanContent(mealPlan),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _changeDate(-1),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Día anterior',
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                        'es_ES',
                      ).format(widget.selectedDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeDate(1),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Día siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanContent(MealPlanModel? mealPlan) {
    if (mealPlan == null) {
      print('[DEBUG] No meal plan available, showing empty plan');
      return _buildEmptyPlan();
    }

    print('[DEBUG] Building meal plan content: ${mealPlan.uid}');
    print('[DEBUG] MealPlan structure: $mealPlan');
    print(
      '[DEBUG] Breakfast data: ${mealPlan.meals.breakfast?.recipeTitle ?? 'null'}',
    );
    print('[DEBUG] Meal count: ${mealPlan.meals.allMeals.length}');
    print('[DEBUG] Total calories: ${mealPlan.totalCalories}');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanSummary(mealPlan),
          const SizedBox(height: 20),
          _buildMealSection(
            title: 'Desayuno',
            mealType: MealType.breakfast,
            meal: mealPlan.meals.breakfast,
            onAdd: () => _addMeal(MealType.breakfast),
          ),
          const SizedBox(height: 16),
          _buildMealSection(
            title: 'Almuerzo',
            mealType: MealType.lunch,
            meal: mealPlan.meals.lunch,
            onAdd: () => _addMeal(MealType.lunch),
          ),
          const SizedBox(height: 16),
          _buildMealSection(
            title: 'Cena',
            mealType: MealType.dinner,
            meal: mealPlan.meals.dinner,
            onAdd: () => _addMeal(MealType.dinner),
          ),
          const SizedBox(height: 20),
          //_buildActionButtons(mealPlan),
        ],
      ),
    );
  }

  Widget _buildEmptyPlan() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay plan para este día',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea un plan de comidas para comenzar',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                final dateString = DateFormat(
                  'yyyy-MM-dd',
                ).format(widget.selectedDate);
                print('[DEBUG] Refreshing meal plan for date: $dateString');
                print('[DEBUG] Selected date widget: ${widget.selectedDate}');
                ref.invalidate(mealPlanByDateProvider(dateString));

                // Show a loading snackbar to confirm the action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Actualizando plan para $dateString...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Actualizar'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                // Plan Manual Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _createManualPlan(),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_calendar,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plan Personalizado',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Crea tu propio plan de comidas a tu gusto',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummary(MealPlanModel mealPlan) {
    // Debug logs para verificar los datos del plan
    print(
      '[DEBUG] Building plan summary: date=${mealPlan.date}, uid=${mealPlan.uid}',
    );
    print(
      '[DEBUG] Meals: breakfast=${mealPlan.meals.breakfast != null}, lunch=${mealPlan.meals.lunch != null}, dinner=${mealPlan.meals.dinner != null}',
    );
    print('[DEBUG] Meal count: ${mealPlan.meals.allMeals.length}');

    int mealCount = mealPlan.meals.allMeals.length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen del Día',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$mealCount comidas planificadas',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection({
    required String title,
    required MealType mealType,
    required Meal? meal,
    required VoidCallback onAdd,
  }) {
    // Debug logs para verificar qué datos están llegando
    print(
      '[DEBUG] Building meal section for $title: ${meal != null ? 'Has meal' : 'No meal'}',
    );
    if (meal != null) {
      print(
        '[DEBUG] Meal details: title=${meal.recipeTitle}, ingredients=${meal.ingredientsNeeded.length}',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(mealType.icon, color: mealType.color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (meal == null)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (meal != null)
          MealCardWidget(
            meal: meal,
            mealType: mealType,
            onEdit: () => _editMeal(mealType, meal),
            onDelete: () => _deleteMeal(mealType),
          )
        else
          _buildEmptyMealSlot(mealType, onAdd),
      ],
    );
  }

  Widget _buildEmptyMealSlot(MealType mealType, VoidCallback onAdd) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'Agregar ${mealType.name.toLowerCase()}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildActionButtons(MealPlanModel mealPlan) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _duplicatePlan(mealPlan),
            icon: const Icon(Icons.copy),
            label: const Text('Duplicar Plan'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _generateShoppingList(mealPlan),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Lista de Compras'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }*/

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el plan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => ref.refresh(
                  mealPlanByDateProvider(
                    DateFormat('yyyy-MM-dd').format(widget.selectedDate),
                  ),
                ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _changeDate(int days) {
    final newDate = widget.selectedDate.add(Duration(days: days));
    widget.onDateChanged(newDate);
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      widget.onDateChanged(picked);
    }
  }

  void _addMeal(MealType mealType) {
    // Navegar a la pantalla de generación de recetas en lugar de mostrar el bottom sheet
    context.pushNamed(
      'recipeGeneration',
      queryParameters: {
        'date': widget.selectedDate.toIso8601String(),
        'mealType': mealType.toString().split('.').last,
      },
    );
  }

  void _editMeal(MealType mealType, Meal meal) {
    // Navegar a la pantalla de generación de recetas para editar
    context.pushNamed(
      'recipeGeneration',
      queryParameters: {
        'date': widget.selectedDate.toIso8601String(),
        'mealType': mealType.toString().split('.').last,
      },
    );
  }

  void _deleteMeal(MealType mealType) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Comida'),
            content: Text(
              '¿Estás seguro de que deseas eliminar este ${mealType.name.toLowerCase()}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Implementar lógica de eliminación de comida
                  final dateString = DateFormat(
                    'yyyy-MM-dd',
                  ).format(widget.selectedDate);

                  try {
                    // Obtener el plan actual
                    final existingPlan = await ref.read(
                      mealPlanByDateProvider(dateString).future,
                    );

                    if (existingPlan != null) {
                      // Crear un nuevo plan sin la comida seleccionada
                      final updatedMeals = DailyMeals(
                        breakfast:
                            mealType == MealType.breakfast
                                ? null
                                : existingPlan.meals.breakfast,
                        lunch:
                            mealType == MealType.lunch
                                ? null
                                : existingPlan.meals.lunch,
                        dinner:
                            mealType == MealType.dinner
                                ? null
                                : existingPlan.meals.dinner,
                      );

                      // Actualizar el plan
                      await ref
                          .read(mealPlanningProvider.notifier)
                          .updateMealPlan(dateString, updatedMeals);

                      // Invalidar ambos providers para refrescar la UI
                      ref.invalidate(mealPlanByDateProvider(dateString));
                      ref.invalidate(app_providers.mealPlanningProvider);

                      // Mostrar mensaje de éxito
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${mealType.name} eliminado del plan',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Mostrar mensaje de error
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar la comida: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _createManualPlan() {
    context.pushNamed(
      'manualPlanCreation',
      queryParameters: {'date': widget.selectedDate.toIso8601String()},
    );
  }
}
