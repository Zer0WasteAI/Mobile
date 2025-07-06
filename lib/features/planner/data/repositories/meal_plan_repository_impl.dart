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

  @override
  Future<Map<String, dynamic>> saveMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    try {
      // INFO: Save complete meal plan for a specific date
      return await _apiService.saveMealPlan(date: date, meals: meals);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to save meal plan: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    try {
      // INFO: Update existing meal plan for a specific date
      return await _apiService.updateMealPlan(date: date, meals: meals);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to update meal plan: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getMealPlanByDate(String date) async {
    try {
      // INFO: Get meal plan for a specific date
      return await _apiService.getMealPlanByDate(date);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get meal plan by date: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAllMealPlans() async {
    try {
      // INFO: Get all user's meal plans
      return await _apiService.getAllMealPlans();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get all meal plans: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getMealPlanDates() async {
    try {
      // INFO: Get dates with existing meal plans
      return await _apiService.getMealPlanDates();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get meal plan dates: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> deleteMealPlan(String date) async {
    try {
      // INFO: Delete meal plan for a specific date
      return await _apiService.deleteMealPlan(date);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to delete meal plan: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
