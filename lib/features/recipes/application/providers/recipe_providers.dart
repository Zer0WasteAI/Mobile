import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:zer0_waste_ai/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/recipe_generation_providers.dart';

enum RecipeMode { explore, smart }

final recipeControllerProviderFamily =
    StateNotifierProvider.family<RecipeController, RecipeState, RecipeMode>(
      (ref, mode) => RecipeController(mode, ref),
    );

/// Provider that combines all saved recipes from different sources
final savedRecipesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((
  ref,
) {
  // Watch other recipe providers
  final aiRecipes = ref.watch(generatedRecipesProvider);
  // final favoriteRecipes = ref.watch(favoriteRecipesListProvider); // Removed - using Firestore now
  final plannerRecipes = ref.watch(plannerGeneratedRecipesProvider);

  try {
    // Convert recipes to a common format
    final List<Map<String, dynamic>> allRecipes = [
      // Add AI generated recipes
      ...aiRecipes.map(
        (recipe) => {
          'uid': recipe.id,
          'title': recipe.name,
          'description': recipe.description,
          'imageUrl': null, // AI recipes don't have images yet
          'difficulty': recipe.difficulty,
          'ingredients': recipe.ingredients,
          'cookingTime': recipe.cookingTime,
          'dietType': recipe.dietType,
          'categories': recipe.categories,
          'source': 'ai',
        },
      ),

      // Favorite recipes now handled by Firestore provider in favorites module

      // Add planner-generated recipes
      ...plannerRecipes.map(
        (recipe) => {
          'uid': recipe.id,
          'title': recipe.name,
          'description': recipe.description,
          'imageUrl': null,
          'difficulty': recipe.difficulty,
          'ingredients': recipe.ingredients,
          'cookingTime': recipe.cookingTime,
          'dietType': recipe.dietType,
          'categories': recipe.categories,
          'source': 'planner',
        },
      ),
    ];

    // Remove duplicates based on recipe ID
    final uniqueRecipes =
        allRecipes
            .fold<Map<String, Map<String, dynamic>>>({}, (map, recipe) {
              if (!map.containsKey(recipe['uid'])) {
                map[recipe['uid']] = recipe;
              }
              return map;
            })
            .values
            .toList();

    return AsyncValue.data(uniqueRecipes);
  } catch (e, st) {
    log('Error combining saved recipes: $e');
    return AsyncValue.error(e, st);
  }
});

class RecipeController extends StateNotifier<RecipeState> {
  // ignore: unused_field
  final Ref _ref;

  RecipeController(RecipeMode mode, this._ref) : super(const RecipeState()) {
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final RecipeRepository repository = RecipeRepositoryImpl();

      // First try to load from cache
      final cachedRecipes = await _loadFromCache();
      if (cachedRecipes.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          recipes: cachedRecipes,
          allRecipes: cachedRecipes,
        );
        return;
      }

      // If no cache, load from repository
      final response = await repository.getAllRecipes();
      final recipes =
          (response['recipes'] as List)
              .map(
                (recipe) => Recipe(
                  id: recipe['id'] as String,
                  name: recipe['name'] as String,
                  description: recipe['description'] as String,
                  imageUrl: recipe['imageUrl'] as String?,
                  emoji: recipe['emoji'] as String? ?? '🍲',
                  ingredients: (recipe['ingredients'] as List).cast<String>(),
                  requiredIngredientsCount:
                      recipe['requiredIngredientsCount'] as int?,
                  availableIngredientsCount:
                      recipe['availableIngredientsCount'] as int?,
                  usesExpiringItems:
                      recipe['usesExpiringItems'] as bool? ?? false,
                ),
              )
              .toList();

      state = state.copyWith(
        isLoading: false,
        recipes: recipes,
        allRecipes: recipes,
      );

      // Save to cache
      await _saveToCache(recipes);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<List<Recipe>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getStringList('cached_recipes') ?? [];

      return recipesJson.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return Recipe(
          id: json['id'] as String,
          name: json['name'] as String,
          description: json['description'] as String,
          imageUrl: json['imageUrl'] as String?,
          emoji: json['emoji'] as String? ?? '🍲',
          ingredients: (json['ingredients'] as List).cast<String>(),
          requiredIngredientsCount: json['requiredIngredientsCount'] as int?,
          availableIngredientsCount: json['availableIngredientsCount'] as int?,
          usesExpiringItems: json['usesExpiringItems'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      log('Error loading from cache: $e');
      return [];
    }
  }

  Future<void> _saveToCache(List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson =
          recipes
              .map(
                (recipe) => jsonEncode({
                  'id': recipe.id,
                  'name': recipe.name,
                  'description': recipe.description,
                  'imageUrl': recipe.imageUrl,
                  'emoji': recipe.emoji,
                  'ingredients': recipe.ingredients,
                  'requiredIngredientsCount': recipe.requiredIngredientsCount,
                  'availableIngredientsCount': recipe.availableIngredientsCount,
                  'usesExpiringItems': recipe.usesExpiringItems,
                }),
              )
              .toList();
      await prefs.setStringList('cached_recipes', recipesJson);
    } catch (e) {
      log('Error saving to cache: $e');
    }
  }

  void filterRecipes(String query) {
    if (query.isEmpty) {
      state = state.copyWith(recipes: state.allRecipes, searchQuery: '');
      return;
    }

    final filteredRecipes =
        state.allRecipes
            .where(
              (recipe) =>
                  recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                  recipe.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  recipe.ingredients.any(
                    (ingredient) =>
                        ingredient.toLowerCase().contains(query.toLowerCase()),
                  ),
            )
            .toList();

    state = state.copyWith(recipes: filteredRecipes, searchQuery: query);
  }

  void toggleIngredientFilter() {
    state = state.copyWith(
      showOnlyWithMyIngredients: !state.showOnlyWithMyIngredients,
    );
    _applyFilters();
  }

  void updateFilters(Map<String, Set<String>> newFilters) {
    state = state.copyWith(selectedFilters: newFilters);
    _applyFilters();
  }

  void _applyFilters() {
    var filteredRecipes = state.allRecipes;

    // Apply ingredient filter if enabled
    if (state.showOnlyWithMyIngredients) {
      filteredRecipes =
          filteredRecipes
              .where(
                (recipe) =>
                    recipe.availableIngredientsCount != null &&
                    recipe.availableIngredientsCount! > 0,
              )
              .toList();
    }

    // Apply category filters
    if (state.selectedFilters.isNotEmpty) {
      filteredRecipes =
          filteredRecipes.where((recipe) {
            for (final entry in state.selectedFilters.entries) {
              final category = entry.key;
              final selectedValues = entry.value;

              if (selectedValues.isEmpty) continue;

              switch (category) {
                case 'diet':
                  // Skip diet filter since it's not in the Recipe model
                  break;
                case 'difficulty':
                  // Skip difficulty filter since it's not in the Recipe model
                  break;
                case 'categories':
                  // Skip categories filter since it's not in the Recipe model
                  break;
              }
            }
            return true;
          }).toList();
    }

    // Apply search query if exists
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filteredRecipes =
          filteredRecipes
              .where(
                (recipe) =>
                    recipe.name.toLowerCase().contains(query) ||
                    recipe.description.toLowerCase().contains(query) ||
                    recipe.ingredients.any(
                      (ingredient) => ingredient.toLowerCase().contains(query),
                    ),
              )
              .toList();
    }

    state = state.copyWith(recipes: filteredRecipes);
  }
}
