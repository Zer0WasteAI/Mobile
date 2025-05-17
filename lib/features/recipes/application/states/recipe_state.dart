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
    String? errorMessage,
    // Smart mode specific
    int? expiringIngredientsUsedCount,
    // Explore mode specific
    @Default('') String searchQuery,
    @Default(false) bool showOnlyWithMyIngredients,
    // Map of category value to Set of selected filter values
    // e.g., {"Tipo de receta": {"entrada", "postre"}, "Tiempo de preparación": {"short_time"}}
    @Default({}) Map<String, Set<String>> selectedFilters,
    // TODO: Add other filter criteria (sort, categories, etc.)
  }) = _RecipeState;
}
