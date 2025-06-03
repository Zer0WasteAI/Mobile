import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:zer0_waste_ai/features/recipes/data/repositories/recipe_repository_impl.dart';

/// INFO: Provider for the recipe repository implementation
/// USAGE: Use ref.watch(recipeRepositoryProvider) to get repository instance
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl();
});

/// INFO: Provider for recipe backend operations notifier
/// USAGE: Use ref.watch(recipeBackendProvider) to get notifier instance
final recipeBackendProvider = Provider<RecipeBackendNotifier>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeBackendNotifier(repository);
});

/// INFO: Notifier class for AI-powered recipe backend operations
/// ADVICE: This provides a clean interface for UI to interact with recipe AI
/// USAGE: Access through recipeBackendProvider to perform recipe operations
class RecipeBackendNotifier {
  final RecipeRepository _repository;

  RecipeBackendNotifier(this._repository);

  /// INFO: Generate recipes from current inventory using AI
  /// ADVICE: AI analyzes your inventory and suggests optimal recipes to reduce waste
  /// RETURNS: List of generated recipe objects with ingredients, instructions, etc.
  Future<List<Map<String, dynamic>>> generateRecipesFromInventory() async {
    return await _repository.generateRecipesFromInventory();
  }

  /// 🆕 NUEVO: Generate recipes from inventory with complete response info
  /// RETURNS: Complete response with personalization_info según CAMBIOS_ENDPOINTS.md
  Future<Map<String, dynamic>> generateRecipesFromInventoryComplete() async {
    // Por ahora devolvemos el formato antiguo hasta que el backend implemente el nuevo
    final recipes = await _repository.generateRecipesFromInventory();
    return {
      'generated_recipes': recipes,
      'total_recipes': recipes.length,
      'inventory_usage': '75%', // Mock value
      'personalization_info': <String, dynamic>{
        'language': 'es',
        'measurement_system': 'metric',
        'cooking_level': 'intermediate',
        'preferences_applied': <String>[],
        'allergies_filtered': <String>[],
        'dietary_restrictions': <String>[],
        'preferred_food_types': <String>[],
      },
    };
  }

  /// INFO: Generate custom recipes with specific ingredients using AI
  /// USAGE: Specify ingredients you want to use and dietary preferences
  /// ADVICE: Use preferences like ["vegetarian", "gluten-free", "low-calorie"]
  /// RETURNS: List of custom recipe objects tailored to your requirements
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

  /// 🆕 NUEVO: Generate custom recipes with complete response info
  /// RETURNS: Complete response with personalization_info según CAMBIOS_ENDPOINTS.md
  Future<Map<String, dynamic>> generateCustomRecipesComplete({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  }) async {
    // Por ahora devolvemos el formato antiguo hasta que el backend implemente el nuevo
    final recipes = await _repository.generateCustomRecipes(
      ingredients: ingredients,
      preferences: preferences,
      numRecipes: numRecipes,
    );
    return {
      'generated_recipes': recipes,
      'total_recipes': recipes.length,
      'inventory_usage': '100%', // Mock value
      'personalization_info': <String, dynamic>{
        'language': 'es',
        'measurement_system': 'metric',
        'cooking_level': 'intermediate',
        'preferences_applied': preferences ?? <String>[],
        'allergies_filtered': <String>[],
        'dietary_restrictions': <String>[],
        'preferred_food_types': <String>[],
      },
    };
  }

  /// INFO: Save a recipe to user's favorites collection
  /// USAGE: Pass complete recipe object to save for later access
  /// RETURNS: Confirmation with saved recipe data
  Future<Map<String, dynamic>> saveRecipe(
    Map<String, dynamic> recipeData,
  ) async {
    return await _repository.saveRecipe(recipeData);
  }

  /// INFO: Get all user's saved/favorite recipes
  /// RETURNS: Map containing array of saved recipes
  Future<Map<String, dynamic>> getSavedRecipes() async {
    return await _repository.getSavedRecipes();
  }
}
