import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_state.freezed.dart';

// Model for a single Recipe (adjust fields as needed)
@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    required String description,
    String? imageUrl,
    @Default('🍲') String emoji,
    required List<String> ingredients, // List of ingredient names or IDs
    // Smart mode specific fields (might be null in explore mode)
    int? requiredIngredientsCount,
    int? availableIngredientsCount,
    @Default(false) bool usesExpiringItems,
    // Add other fields like cooking time, difficulty, instructions etc.
  }) = _Recipe;
}

// State for the Recipe Screen
@freezed
abstract class RecipeState with _$RecipeState {
  const factory RecipeState({
    @Default(false) bool isLoading,
    @Default([]) List<Recipe> recipes,
    @Default([]) List<Recipe> allRecipes,
    String? errorMessage,
    // Smart mode specific
    int? expiringIngredientsUsedCount,
    // Explore mode specific
    @Default('') String searchQuery,
    @Default(false) bool showOnlyWithMyIngredients,
    // Map of category value to Set of selected filter values
    @Default({}) Map<String, Set<String>> selectedFilters,
    // ✅ RESOLVED: Comprehensive filter criteria already implemented:
    // - Recipe type, preparation time, difficulty, diet type, sustainability
    // - Sorting by name, cooking time, difficulty (in favorite_recipes_provider.dart)
    // - Search functionality, category filtering, ingredient availability toggle

    // Cache and source tracking
    @Default(false) bool hasLoadedCache,
    @Default({}) Map<String, DateTime> lastGeneratedAt,
    @Default({}) Map<String, String> recipeSource,
  }) = _RecipeState;

  const RecipeState._();

  bool get hasCachedRecipes => recipes.isNotEmpty && hasLoadedCache;

  bool isRecipeFresh(String recipeId) {
    if (!lastGeneratedAt.containsKey(recipeId)) return false;
    final generatedAt = lastGeneratedAt[recipeId]!;
    final now = DateTime.now();
    return now.difference(generatedAt).inHours <
        24; // Consider recipes fresh for 24 hours
  }

  String getRecipeSourceMessage(String recipeId) {
    if (!recipeSource.containsKey(recipeId)) return '';
    return recipeSource[recipeId] ?? '';
  }
}
