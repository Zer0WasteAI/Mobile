import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/planner/domain/repositories/meal_plan_repository.dart';

/// INFO: Implementation of MealPlanRepository using ZeroWasteAI backend
/// ADVICE: This repository bridges the domain layer with the API service for meal planning
/// USAGE: Use this through the mealPlanRepositoryProvider
class MealPlanRepositoryImpl implements MealPlanRepository {
  final ApiService _apiService;

  MealPlanRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      // INFO: AI analyzes ingredients to create optimal meal plans
      return await _apiService.generateMealPlan(ingredients: ingredients);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to generate meal plan: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getMealPlanHistory() async {
    try {
      // INFO: Retrieve historical meal plans and their execution status
      return await _apiService.getMealPlanHistory();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get meal plan history: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
