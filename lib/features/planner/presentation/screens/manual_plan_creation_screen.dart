import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/meal_plan_models.dart';
import '../providers/meal_planning_providers.dart';
import '../widgets/meal_creation_card.dart';

class ManualPlanCreationScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const ManualPlanCreationScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<ManualPlanCreationScreen> createState() =>
      _ManualPlanCreationScreenState();
}

class _ManualPlanCreationScreenState
    extends ConsumerState<ManualPlanCreationScreen> {
  Meal? breakfast;
  Meal? lunch;
  Meal? dinner;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Crear Plan Personalizado'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          /*if (_hasAnyMeal())
            TextButton(
              onPressed: _isSaving ? null : _savePlan,
              child:
                  _isSaving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        'Guardar',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),*/
        ],
      ),
      body: Column(
        children: [
          _buildHeader(colorScheme, textTheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructions(textTheme, colorScheme),
                  const SizedBox(height: 24),
                  _buildMealSection(
                    'Desayuno',
                    MealType.breakfast,
                    breakfast,
                    Icons.breakfast_dining,
                    Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  _buildMealSection(
                    'Almuerzo',
                    MealType.lunch,
                    lunch,
                    Icons.lunch_dining,
                    Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildMealSection(
                    'Cena',
                    MealType.dinner,
                    dinner,
                    Icons.dinner_dining,
                    Colors.purple,
                  ),
                  const SizedBox(height: 30),
                  if (_hasAnyMeal()) _buildSummary(colorScheme, textTheme),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _hasAnyMeal()
              ? FloatingActionButton.extended(
                heroTag: "manual_plan_creation_fab",
                onPressed: _isSaving ? null : _savePlan,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar Plan'),
                backgroundColor: colorScheme.primary,
              )
              : null,
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.create,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Personalizado',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM',
                        'es_ES',
                      ).format(widget.selectedDate),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Crea tu plan perfecto seleccionando comidas para cada momento del día',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cómo funciona',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('1. Toca "Agregar" en cada comida que quieras planificar'),
          const SizedBox(height: 4),
          const Text('2. Selecciona una receta'),
          const SizedBox(height: 4),
          const Text('3. Revisa tu plan y guárdalo cuando esté listo'),
        ],
      ),
    );
  }

  Widget _buildMealSection(
    String title,
    MealType mealType,
    Meal? meal,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (meal != null)
              TextButton(
                onPressed: () => _editMeal(mealType),
                child: const Text('Cambiar'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (meal != null)
          MealCreationCard(
            meal: meal,
            mealType: mealType,
            onAddMeal: () => _editMeal(mealType),
            onMealChanged: (newMeal) => _deleteMeal(mealType),
          )
        else
          _buildAddMealCard(mealType, color),
      ],
    );
  }

  Widget _buildAddMealCard(MealType mealType, Color color) {
    return GestureDetector(
      onTap: () => _addMeal(mealType),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              'Agregar ${mealType.name.toLowerCase()}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toca para seleccionar una receta',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ColorScheme colorScheme, TextTheme textTheme) {
    // ignore: unused_local_variable
    final totalCalories = _getTotalCalories();
    final mealCount = _getMealCount();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Resumen del Plan',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              /*Expanded(
                child: _buildSummaryItem(
                  Icons.local_fire_department,
                  '$totalCalories kcal',
                  'Calorías totales',
                  Colors.orange,
                ),
              ),*/
              //const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  Icons.restaurant,
                  '$mealCount comida${mealCount != 1 ? 's' : ''}',
                  'Planificadas',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  void _addMeal(MealType mealType) async {
    final result = await context.pushNamed(
      'recipeGeneration',
      queryParameters: {
        'date': widget.selectedDate.toIso8601String(),
        'mealType': mealType.toString().split('.').last,
        'isManualPlan': 'true',
      },
    );

    // Handle the returned meal
    if (result is Meal) {
      setState(() {
        switch (mealType) {
          case MealType.breakfast:
            breakfast = result;
            break;
          case MealType.lunch:
            lunch = result;
            break;
          case MealType.dinner:
            dinner = result;
            break;
          case MealType.snack:
            // Not used in this flow
            break;
        }
      });
    }
  }

  void _editMeal(MealType mealType) {
    _addMeal(mealType);
  }

  void _deleteMeal(MealType mealType) {
    setState(() {
      switch (mealType) {
        case MealType.breakfast:
          breakfast = null;
          break;
        case MealType.lunch:
          lunch = null;
          break;
        case MealType.dinner:
          dinner = null;
          break;
        case MealType.snack:
          // Not used in this flow
          break;
      }
    });
  }

  Future<void> _savePlan() async {
    if (!_hasAnyMeal()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final dailyMeals = DailyMeals(
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      );
      final dateString = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      print('[DEBUG] Manual plan creation - saving for date: $dateString');
      print('[DEBUG] Widget selected date: ${widget.selectedDate}');

      try {
        // First, try to save as a new plan
        await ref
            .read(mealPlanningProvider.notifier)
            .saveMealPlan(dateString, dailyMeals);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to unified planning screen in daily view with the date
          print(
            '[DEBUG] Navigating back to unified planning with date: $dateString',
          );
          context.go(
            '/unified-planning?date=${widget.selectedDate.toIso8601String()}',
          );
        }
      } catch (saveError) {
        // Check if the error is about existing plan
        final errorMessage = saveError.toString().toLowerCase();
        if (errorMessage.contains('ya existe') ||
            errorMessage.contains('already exists')) {
          // Plan already exists, try to update instead
          try {
            await ref
                .read(mealPlanningProvider.notifier)
                .updateMealPlan(dateString, dailyMeals);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plan actualizado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate back to unified planning screen in daily view with the date
              print(
                '[DEBUG] Navigating back to unified planning after update with date: $dateString',
              );
              context.go(
                '/unified-planning?date=${widget.selectedDate.toIso8601String()}',
              );
            }
          } catch (updateError) {
            // If update also fails, rethrow the original error
            rethrow;
          }
        } else {
          // If it's not about existing plan, rethrow the original error
          rethrow;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _hasAnyMeal() {
    return breakfast != null || lunch != null || dinner != null;
  }

  int _getTotalCalories() {
    int total = 0;
    if (breakfast != null) total += breakfast!.calories;
    if (lunch != null) total += lunch!.calories;
    if (dinner != null) total += dinner!.calories;
    return total;
  }

  int _getMealCount() {
    int count = 0;
    if (breakfast != null) count++;
    if (lunch != null) count++;
    if (dinner != null) count++;
    return count;
  }
}
