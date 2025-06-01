import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:zer0_waste_ai/features/recipes/data/repositories/recipe_repository_impl.dart';

/// Provider for the recipe repository
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl();
});

/// Provider for recipe backend operations
final recipeBackendProvider = Provider<RecipeBackendNotifier>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeBackendNotifier(repository);
});

/// Notifier for recipe backend operations
class RecipeBackendNotifier {
  final RecipeRepository _repository;

  RecipeBackendNotifier(this._repository);

  /// Generate recipes from current inventory using AI
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory() async {
    return await _repository.generateRecipesFromInventory();
  }

  /// Generate custom recipes with specific ingredients using AI
  Future<List<Map<String, dynamic>>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  }) async {
    return await _repository.generateCustomRecipes(
      ingredients: ingredients,
      preferences: preferences,
      numRecipes: numRecipes,
    );
  }

  /// Save a recipe to user's favorites
  Future<Map<String, dynamic>> saveRecipe(
    Map<String, dynamic> recipeData,
  ) async {
    return await _repository.saveRecipe(recipeData);
  }

  /// Get all saved/favorite recipes
  Future<Map<String, dynamic>> getSavedRecipes() async {
    return await _repository.getSavedRecipes();
  }
}
