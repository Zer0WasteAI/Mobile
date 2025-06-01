import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';

/// INFO: Implementation of RecipeRepository using ZeroWasteAI backend
/// ADVICE: This repository bridges the domain layer with the API service for recipes
/// USAGE: Use this through the recipeRepositoryProvider
class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;

  RecipeRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory() async {
    try {
      // INFO: AI analyzes current inventory to suggest optimal recipes
      return await _apiService.generateRecipesFromInventory();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to generate recipes from inventory: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  }) async {
    try {
      // INFO: AI generates custom recipes based on specified ingredients and preferences
      return await _apiService.generateCustomRecipes(
        ingredients: ingredients,
        preferences: preferences,
        numRecipes: numRecipes,
      );
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to generate custom recipes: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> saveRecipe(
    Map<String, dynamic> recipeData,
  ) async {
    try {
      // INFO: Save recipe to user's favorites collection for later access
      return await _apiService.saveRecipe(recipeData);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to save recipe: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSavedRecipes() async {
    try {
      // INFO: Retrieve all saved recipes from user's favorites
      return await _apiService.getSavedRecipes();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get saved recipes: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
