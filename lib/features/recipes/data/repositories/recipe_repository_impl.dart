import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:zer0_waste_ai/features/favorites/domain/repositories/favorite_recipe_repository.dart';
import 'package:zer0_waste_ai/features/favorites/data/repositories/favorite_recipe_repository_impl.dart';
import 'package:zer0_waste_ai/features/favorites/domain/models/favorite_recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// INFO: Implementation of RecipeRepository using ZeroWasteAI backend
/// ADVICE: This repository bridges the domain layer with the API service for recipes
/// USAGE: Use this through the recipeRepositoryProvider
class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;
  final FavoriteRecipeRepository _favoriteRepository;

  RecipeRepositoryImpl({ApiService? apiService, FavoriteRecipeRepository? favoriteRepository})
    : _apiService = apiService ?? ApiService.instance,
      _favoriteRepository = favoriteRepository ?? FavoriteRecipeRepositoryImpl(FirebaseFirestore.instance);

  @override
  Future<Map<String, dynamic>> generateRecipesFromInventory() async {
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
  Future<Map<String, dynamic>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    List<String>? recipeCategories,
    int numRecipes = 2,
  }) async {
    try {
      // INFO: AI generates custom recipes based on specified ingredients and preferences
      return await _apiService.generateCustomRecipes(
        ingredients: ingredients,
        preferences: preferences,
        recipeCategories: recipeCategories,
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
      // Convert recipe data to FavoriteRecipe model
      final favoriteRecipe = FavoriteRecipe(
        id: recipeData['id'] ?? '',
        userId: recipeData['userId'] ?? '',
        title: recipeData['name'] ?? recipeData['title'] ?? '',
        description: recipeData['description'] ?? '',
        ingredients: (recipeData['ingredients'] as List<String>? ?? [])
            .map((ing) => FavoriteIngredient(
                  name: ing,
                  quantity: 1.0,
                  unit: 'unidad',
                ))
            .toList(),
        instructions: recipeData['instructions'] as List<String>? ?? [],
        prepTime: recipeData['prepTime'] ?? recipeData['prep_time'] ?? 0,
        cookTime: recipeData['cookTime'] ?? recipeData['cook_time'] ?? 
                  recipeData['cookingTime'] ?? recipeData['cooking_time'] ?? 30,
        servings: recipeData['servings'] ?? 1,
        difficulty: recipeData['difficulty'] ?? 'Medio',
        imagePath: recipeData['imagePath'] ?? recipeData['imageUrl'],
        mealType: recipeData['mealType'] ?? recipeData['meal_type'],
        createdAt: DateTime.now(),
      );

      await _favoriteRepository.addFavorite(favoriteRecipe);
      
      return {
        'success': true,
        'message': 'Recipe saved to favorites',
        'recipe': recipeData,
      };
    } catch (e) {
      throw Exception('Failed to save recipe to favorites: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getSavedRecipes() async {
    try {
      // This method should accept a userId parameter in real implementation
      // For now, returning empty list since this should be handled by userFavoritesProvider
      return {
        'success': true,
        'message': 'Please use userFavoritesProvider from favorites module instead',
        'recipes': [],
        'count': 0,
      };
    } catch (e) {
      throw Exception('Failed to get saved recipes: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getAllRecipes() async {
    try {
      // INFO: Retrieve all available recipes (public + user's)
      return await _apiService.getAllRecipes();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get all recipes: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDefaultRecipes({String? category}) async {
    try {
      // INFO: Retrieve curated default recipes with optional category filter
      return await _apiService.getDefaultRecipes(category: category);
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get default recipes: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> deleteRecipe(String recipeTitle) async {
    try {
      // Find and remove recipe by title from Firestore favorites
      // Note: This is a simplified implementation. In real app, you'd need userId
      // and might want to remove by ID instead of title for better reliability
      
      // For now, this method should not be used directly.
      // Use favoriteActionProvider.toggleFavorite() instead
      return {
        'success': true,
        'message': 'Please use favoriteActionProvider.toggleFavorite() instead',
      };
    } catch (e) {
      throw Exception('Failed to delete recipe from favorites: ${e.toString()}');
    }
  }
}
