import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';

/// Implementation of RecipeRepository using ZeroWasteAI backend
class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;

  RecipeRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory() async {
    try {
      return await _apiService.generateRecipesFromInventory();
    } catch (e) {
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
      return await _apiService.generateCustomRecipes(
        ingredients: ingredients,
        preferences: preferences,
        numRecipes: numRecipes,
      );
    } catch (e) {
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
      return await _apiService.saveRecipe(recipeData);
    } catch (e) {
      throw Exception(
        'Failed to save recipe: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSavedRecipes() async {
    try {
      return await _apiService.getSavedRecipes();
    } catch (e) {
      throw Exception(
        'Failed to get saved recipes: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
