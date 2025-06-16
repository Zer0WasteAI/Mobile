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

  /// INFO: Save meal plan for a specific date
  /// USAGE: Save complete meal plan with breakfast, lunch, dinner for a date
  /// RETURNS: Saved meal plan with UID and total calories
  Future<Map<String, dynamic>> saveMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    return await _repository.saveMealPlan(date: date, meals: meals);
  }

  /// INFO: Update existing meal plan
  /// USAGE: Update meal plan for a specific date with new meal data
  /// RETURNS: Updated meal plan with modifications
  Future<Map<String, dynamic>> updateMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    return await _repository.updateMealPlan(date: date, meals: meals);
  }

  /// INFO: Get meal plan by specific date
  /// USAGE: Retrieve meal plan for a specific date (YYYY-MM-DD format)
  /// RETURNS: Meal plan with breakfast, lunch, dinner and total calories
  Future<Map<String, dynamic>> getMealPlanByDate(String date) async {
    return await _repository.getMealPlanByDate(date);
  }

  /// INFO: Get all user's meal plans
  /// USAGE: Retrieve all meal plans created by the user
  /// RETURNS: Array of all meal plans with metadata
  Future<Map<String, dynamic>> getAllMealPlans() async {
    return await _repository.getAllMealPlans();
  }

  /// INFO: Get list of dates with existing meal plans
  /// USAGE: Get dates that have meal plans for calendar/navigation purposes
  /// RETURNS: Array of dates in YYYY-MM-DD format
  Future<Map<String, dynamic>> getMealPlanDates() async {
    return await _repository.getMealPlanDates();
  }

  /// INFO: Delete meal plan for specific date
  /// USAGE: Remove meal plan for a specific date
  /// RETURNS: Confirmation message
  Future<Map<String, dynamic>> deleteMealPlan(String date) async {
    return await _repository.deleteMealPlan(date);
  }
}
