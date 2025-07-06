import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';

// Proveedor para la semana actual
final currentWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  // Obtener el lunes de la semana actual
  return now.subtract(Duration(days: now.weekday - 1));
});

// Proveedor para controlar si el calendario está expandido o colapsado
final isCalendarExpandedProvider = StateProvider<bool>((ref) => true);

// Proveedor para controlar si ya se mostró la guía de iconos
final hasShownIconGuideProvider = StateProvider<bool>((ref) => false);

// Proveedor para almacenar los planes de comida
final mealPlansProvider =
    StateNotifierProvider<MealPlanNotifier, Map<String, List<SimpleRecipe>>>((ref) {
      return MealPlanNotifier();
    });

// Notifier para los planes de comida
class MealPlanNotifier extends StateNotifier<Map<String, List<SimpleRecipe>>> {
  MealPlanNotifier() : super({});

  // Agregar una comida al plan
  void addMeal(String date, SimpleRecipe meal) {
    final currentPlans = state[date] ?? [];

    state = {
      ...state,
      date: [...currentPlans, meal],
    };
  }

  // Eliminar una comida del plan
  void removeMeal(String date, SimpleRecipe meal) {
    final currentPlans = state[date] ?? [];

    state = {
      ...state,
      date: currentPlans.where((m) => m.id != meal.id).toList(),
    };
  }

  // Editar una comida del plan
  void editMeal(String date, SimpleRecipe oldMeal, SimpleRecipe newMeal) {
    final currentPlans = state[date] ?? [];
    final updatedPlans =
        currentPlans.map((meal) {
          if (meal.id == oldMeal.id) {
            return newMeal;
          }
          return meal;
        }).toList();

    state = {...state, date: updatedPlans};
  }

  // Mover una comida de un día a otro
  void moveMeal(String fromDate, String toDate, SimpleRecipe meal) {
    // Primero eliminamos la comida del día original
    removeMeal(fromDate, meal);

    // Luego la añadimos al nuevo día
    addMeal(toDate, meal);
  }
}
