import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/planner/domain/repositories/meal_plan_repository.dart';
import 'package:zer0_waste_ai/features/planner/data/repositories/meal_plan_repository_impl.dart';

/// INFO: Provider for MealPlanRepository implementation
/// USAGE: Use ref.watch(mealPlanRepositoryProvider) to get repository instance
final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepositoryImpl();
});

/// INFO: Provider for meal plan generation backend operations
/// USAGE: Use this for generating meal plans from inventory
final mealPlanBackendProvider = Provider<MealPlanBackendNotifier>((ref) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return MealPlanBackendNotifier(repository);
});

/// INFO: Backend notifier for meal plan operations
/// ADVICE: Handles all backend communication for meal planning
class MealPlanBackendNotifier {
  final MealPlanRepository _repository;

  MealPlanBackendNotifier(this._repository);

  /// INFO: Generate meal plan from available ingredients
  /// USAGE: Pass list of ingredient objects from inventory
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
  }) async {
    return await _repository.generateMealPlan(ingredients: ingredients);
  }

  /// INFO: Get historical meal plans
  /// RETURNS: Map with meal plan history and metadata
  Future<Map<String, dynamic>> getMealPlanHistory() async {
    return await _repository.getMealPlanHistory();
  }
}
