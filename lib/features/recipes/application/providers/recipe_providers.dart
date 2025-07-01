import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart'
    as state_lib;
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/filter_models.dart';
import 'package:zer0_waste_ai/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:zer0_waste_ai/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';


// --- Provider Definitions ---

// StateNotifier for Recipe Logic
class RecipeController extends StateNotifier<state_lib.RecipeState> {
  final RecipeMode _mode;
  final Ref _ref;
  // For real implementation:
  // final RecipeRepository _recipeRepository;
  // final InventoryRepository _inventoryRepository;

  RecipeController(this._mode, this._ref)
    : super(const state_lib.RecipeState()) {
    _loadRecipes(); // Load recipes on initialization based on mode
  }

  Future<void> _loadRecipes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // ✅ UPDATED: Using real API instead of mock data
      final RecipeRepository repository = RecipeRepositoryImpl();

      Map<String, dynamic> apiResponse;

      // Load recipes based on mode
      switch (_mode) {
        case RecipeMode.smartFromInventory:
          // Use AI to generate recipes from current inventory
          apiResponse = await repository.generateRecipesFromInventory();
          break;
        case RecipeMode.explore:
          // Get all available recipes
          apiResponse = await repository.getAllRecipes();
          break;
      }

      // Parse API response to Recipe objects
      final List<state_lib.Recipe> stateRecipes = _parseApiRecipes(apiResponse);

      state = state.copyWith(
        isLoading: false,
        recipes: stateRecipes,
        allRecipes: stateRecipes, // Store all recipes for filtering
        expiringIngredientsUsedCount:
            _mode == RecipeMode.smartFromInventory
                ? _extractExpiringIngredientsCount(apiResponse)
                : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recipes: ${e.toString()}',
      );
    }
  }

  // Parse ingredient names from API response (handles both String and Map formats)
  List<String> _parseIngredientNames(dynamic ingredientsData) {
    if (ingredientsData == null) return [];

    final List<dynamic> ingredients =
        ingredientsData is List ? ingredientsData : [];

    return ingredients
        .map((ingredient) {
          if (ingredient is String) {
            return ingredient;
          } else if (ingredient is Map<String, dynamic>) {
            return ingredient['name']?.toString() ?? ingredient.toString();
          } else {
            return ingredient.toString();
          }
        })
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // Parse API response to Recipe objects
  List<state_lib.Recipe> _parseApiRecipes(Map<String, dynamic> apiResponse) {
    final List<dynamic> recipesData =
        apiResponse['recipes'] ?? apiResponse['generated_recipes'] ?? [];

    return recipesData.map((recipeData) {
      return state_lib.Recipe(
        id: recipeData['id']?.toString() ?? '',
        name: recipeData['title'] ?? recipeData['name'] ?? '',
        description: recipeData['description'] ?? '',
        emoji: _getRecipeEmoji(recipeData['category'] ?? ''),
        ingredients: _parseIngredientNames(recipeData['ingredients']),
        requiredIngredientsCount:
            (recipeData['ingredients'] as List?)?.length ?? 0,
        availableIngredientsCount: _calculateAvailableIngredients(
          recipeData['ingredients'],
        ),
        usesExpiringItems: recipeData['uses_expiring_items'] ?? false,
      );
    }).toList();
  }

  // Extract expiring ingredients count from API response
  int? _extractExpiringIngredientsCount(Map<String, dynamic> apiResponse) {
    final inventoryUtilization = apiResponse['inventory_utilization'];
    return inventoryUtilization?['expiring_items_used']?.length;
  }

  // Get appropriate emoji for recipe category
  String _getRecipeEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'pasta':
      case 'italian':
        return '🍝';
      case 'asian':
      case 'stir-fry':
        return '🥘';
      case 'soup':
      case 'broth':
        return '🥣';
      case 'salad':
        return '🥗';
      case 'dessert':
        return '🍰';
      case 'breakfast':
        return '🥞';
      default:
        return '🍽️';
    }
  }

  // ✅ UPDATED: Calculate available ingredients by comparing with real inventory
  int _calculateAvailableIngredients(List<dynamic>? ingredients) {
    if (ingredients == null || ingredients.isEmpty) return 0;

    try {
      // Get current inventory items from the real provider
      final inventoryItems = _ref.read(inventoryRealProvider).items;

      // Create a set of available ingredient names (normalized to lowercase)
      final availableIngredientNames =
          inventoryItems.map((item) => item.name.toLowerCase().trim()).toSet();

      // Count how many recipe ingredients are available in inventory
      int availableCount = 0;

      for (final ingredient in ingredients) {
        final ingredientName = ingredient.toString().toLowerCase().trim();

        // Check for exact match first
        if (availableIngredientNames.contains(ingredientName)) {
          availableCount++;
          continue;
        }

        // Check for partial matches (ingredient contains inventory item name or vice versa)
        bool foundPartialMatch = false;
        for (final availableName in availableIngredientNames) {
          if (_isIngredientMatch(ingredientName, availableName)) {
            availableCount++;
            foundPartialMatch = true;
            break;
          }
        }

        if (!foundPartialMatch) {
          // Check if any inventory item contains this ingredient name
          for (final availableName in availableIngredientNames) {
            if (availableName.contains(ingredientName) ||
                ingredientName.contains(availableName)) {
              availableCount++;
              break;
            }
          }
        }
      }

      return availableCount;
    } catch (e) {
      // Fallback to estimate if there's an error accessing inventory
      return (ingredients.length * 0.7).round(); // Assume 70% availability
    }
  }

  // Helper method to check if two ingredient names match
  bool _isIngredientMatch(String recipeIngredient, String inventoryItem) {
    // Remove common words and normalize
    final recipeClean = _normalizeIngredientName(recipeIngredient);
    final inventoryClean = _normalizeIngredientName(inventoryItem);

    // Check for exact match after normalization
    if (recipeClean == inventoryClean) return true;

    // Check if one contains the other (for cases like "tomate" vs "tomate cherry")
    if (recipeClean.contains(inventoryClean) ||
        inventoryClean.contains(recipeClean)) {
      return true;
    }

    // Check for common ingredient variations
    return _checkIngredientVariations(recipeClean, inventoryClean);
  }

  // Normalize ingredient names by removing common words
  String _normalizeIngredientName(String name) {
    final normalized = name.toLowerCase().trim();

    // Remove common descriptive words
    final wordsToRemove = [
      'fresco',
      'fresh',
      'orgánico',
      'organic',
      'natural',
      'picado',
      'chopped',
      'cortado',
      'diced',
      'sliced',
      'grande',
      'pequeño',
      'mediano',
      'large',
      'small',
      'medium',
      'maduro',
      'ripe',
      'verde',
      'green',
      'rojo',
      'red',
      'blanco',
      'white',
      'negro',
      'black',
    ];

    String result = normalized;
    for (final word in wordsToRemove) {
      result = result.replaceAll(RegExp('\\b$word\\b'), '').trim();
    }

    // Remove extra spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }

  // Check for common ingredient variations and synonyms
  bool _checkIngredientVariations(String ingredient1, String ingredient2) {
    final variations = {
      'papa': ['patata', 'papas', 'patatas'],
      'tomate': ['jitomate', 'tomates', 'jitomates'],
      'cebolla': ['cebollas', 'cebolleta', 'cebollín'],
      'ajo': ['ajos', 'diente de ajo'],
      'pimiento': ['pimientos', 'pimentón', 'ají'],
      'zanahoria': ['zanahorias'],
      'apio': ['celery'],
      'perejil': ['parsley'],
      'cilantro': ['coriander'],
      'limón': ['lima', 'limones'],
      'naranja': ['naranjas'],
      'manzana': ['manzanas'],
      'plátano': ['banano', 'banana', 'plátanos'],
      'arroz': ['rice'],
      'pasta': ['spaghetti', 'macarrones', 'fideos'],
      'pollo': ['chicken', 'pechuga'],
      'carne': ['beef', 'res'],
      'pescado': ['fish', 'salmón', 'atún'],
      'leche': ['milk'],
      'queso': ['cheese'],
      'huevo': ['huevos', 'egg', 'eggs'],
      'aceite': ['oil', 'aceite de oliva'],
      'sal': ['salt'],
      'azúcar': ['sugar', 'azucar'],
      'harina': ['flour'],
    };

    // Check if either ingredient matches any variation of the other
    for (final entry in variations.entries) {
      final baseWord = entry.key;
      final variants = entry.value;

      if ((ingredient1.contains(baseWord) ||
              variants.any((v) => ingredient1.contains(v))) &&
          (ingredient2.contains(baseWord) ||
              variants.any((v) => ingredient2.contains(v)))) {
        return true;
      }
    }

    return false;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSearch();
  }

  void toggleShowOnlyWithMyIngredients(bool value) {
    state = state.copyWith(showOnlyWithMyIngredients: value);
    _applyFiltersAndSearch();
  }

  void applyFilters(Map<String, Set<String>> filters) {
    state = state.copyWith(selectedFilters: filters);
    _applyFiltersAndSearch();
  }

  // Apply both filters and search query to recipes
  void _applyFiltersAndSearch() {
    final allRecipes =
        state.allRecipes.isNotEmpty ? state.allRecipes : state.recipes;

    // Store all recipes if not already stored
    if (state.allRecipes.isEmpty && state.recipes.isNotEmpty) {
      state = state.copyWith(allRecipes: state.recipes);
    }

    List<state_lib.Recipe> filteredRecipes = List.from(allRecipes);

    // Apply search query filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filteredRecipes =
          filteredRecipes.where((recipe) {
            return recipe.name.toLowerCase().contains(query) ||
                recipe.description.toLowerCase().contains(query) ||
                recipe.ingredients.any(
                  (ingredient) => ingredient.toLowerCase().contains(query),
                );
          }).toList();
    }

    // Apply category filters
    if (state.selectedFilters.isNotEmpty) {
      filteredRecipes =
          filteredRecipes.where((recipe) {
            return _recipeMatchesFilters(recipe, state.selectedFilters);
          }).toList();
    }

    // Apply "only with my ingredients" filter
    if (state.showOnlyWithMyIngredients) {
      filteredRecipes =
          filteredRecipes.where((recipe) {
            return recipe.availableIngredientsCount != null &&
                recipe.requiredIngredientsCount != null &&
                recipe.availableIngredientsCount! >=
                    recipe.requiredIngredientsCount! * 0.7;
          }).toList();
    }

    state = state.copyWith(recipes: filteredRecipes);
  }

  // Check if a recipe matches the selected filters
  bool _recipeMatchesFilters(
    state_lib.Recipe recipe,
    Map<String, Set<String>> filters,
  ) {
    for (final filterEntry in filters.entries) {
      final category = filterEntry.key;
      final selectedValues = filterEntry.value;

      if (selectedValues.isEmpty) continue;

      bool categoryMatches = false;

      switch (category) {
        case 'Tipo de receta':
          // Map recipe categories to filter values
          categoryMatches = _checkRecipeTypeFilter(recipe, selectedValues);
          break;
        case 'Dificultad':
          // For now, assume all recipes are "facil" (easy)
          categoryMatches = selectedValues.contains('facil');
          break;
        case 'Tiempo de preparación':
          // For now, assume all recipes are medium time (15-30 min)
          categoryMatches = selectedValues.contains('medium_time');
          break;
        case 'Tipo de dieta':
          // Check diet type based on ingredients
          categoryMatches = _checkDietTypeFilter(recipe, selectedValues);
          break;
        case 'Sostenibilidad':
          // Check sustainability based on recipe properties
          categoryMatches = _checkSustainabilityFilter(recipe, selectedValues);
          break;
        default:
          categoryMatches = true; // Unknown category, don't filter
      }

      if (!categoryMatches) {
        return false; // Recipe doesn't match this filter category
      }
    }

    return true; // Recipe matches all filter categories
  }

  bool _checkRecipeTypeFilter(
    state_lib.Recipe recipe,
    Set<String> selectedValues,
  ) {
    // Determine recipe type based on name and ingredients
    final recipeName = recipe.name.toLowerCase();
    // ignore: unused_local_variable
    final ingredients = recipe.ingredients.map((i) => i.toLowerCase()).toList();

    for (final value in selectedValues) {
      switch (value) {
        case 'entrada':
          if (recipeName.contains('ensalada') ||
              recipeName.contains('entrada') ||
              recipeName.contains('aperitivo')) {
            return true;
          }
          break;
        case 'fondo':
          if (recipeName.contains('pasta') ||
              recipeName.contains('pollo') ||
              recipeName.contains('carne') ||
              recipeName.contains('arroz') ||
              recipeName.contains('curry') ||
              recipeName.contains('guiso')) {
            return true;
          }
          break;
        case 'postre':
          if (recipeName.contains('postre') ||
              recipeName.contains('dulce') ||
              recipeName.contains('torta') ||
              recipeName.contains('helado')) {
            return true;
          }
          break;
        case 'bebida':
          if (recipeName.contains('jugo') ||
              recipeName.contains('batido') ||
              recipeName.contains('smoothie') ||
              recipeName.contains('bebida')) {
            return true;
          }
          break;
        case 'snack':
          if (recipeName.contains('snack') ||
              recipeName.contains('bocadito') ||
              recipeName.contains('aperitivo')) {
            return true;
          }
          break;
      }
    }

    // If no specific type matches, consider it as "fondo" (main dish) by default
    return selectedValues.contains('fondo');
  }

  bool _checkDietTypeFilter(
    state_lib.Recipe recipe,
    Set<String> selectedValues,
  ) {
    final ingredients = recipe.ingredients.map((i) => i.toLowerCase()).toList();

    for (final value in selectedValues) {
      switch (value) {
        case 'vegana':
          // Check if recipe contains no animal products
          final animalProducts = [
            'pollo',
            'carne',
            'pescado',
            'huevo',
            'leche',
            'queso',
            'mantequilla',
          ];
          if (!ingredients.any(
            (ingredient) =>
                animalProducts.any((animal) => ingredient.contains(animal)),
          )) {
            return true;
          }
          break;
        case 'vegetariana':
          // Check if recipe contains no meat but may have dairy/eggs
          final meatProducts = ['pollo', 'carne', 'pescado', 'cerdo', 'res'];
          if (!ingredients.any(
            (ingredient) =>
                meatProducts.any((meat) => ingredient.contains(meat)),
          )) {
            return true;
          }
          break;
        case 'sin_gluten':
          // Check if recipe contains no gluten
          final glutenProducts = ['harina', 'trigo', 'pasta', 'pan', 'avena'];
          if (!ingredients.any(
            (ingredient) =>
                glutenProducts.any((gluten) => ingredient.contains(gluten)),
          )) {
            return true;
          }
          break;
        case 'sin_lactosa':
          // Check if recipe contains no dairy
          final dairyProducts = [
            'leche',
            'queso',
            'mantequilla',
            'crema',
            'yogurt',
          ];
          if (!ingredients.any(
            (ingredient) =>
                dairyProducts.any((dairy) => ingredient.contains(dairy)),
          )) {
            return true;
          }
          break;
      }
    }

    return false;
  }

  bool _checkSustainabilityFilter(
    state_lib.Recipe recipe,
    Set<String> selectedValues,
  ) {
    for (final value in selectedValues) {
      switch (value) {
        case 'sobrantes':
          // Check if recipe uses expiring items or common leftover ingredients
          if (recipe.usesExpiringItems) return true;
          break;
        case 'bajo_impacto':
          // Consider vegetarian recipes as lower environmental impact
          final ingredients =
              recipe.ingredients.map((i) => i.toLowerCase()).toList();
          final meatProducts = ['pollo', 'carne', 'pescado', 'cerdo', 'res'];
          if (!ingredients.any(
            (ingredient) =>
                meatProducts.any((meat) => ingredient.contains(meat)),
          )) {
            return true;
          }
          break;
      }
    }

    return false;
  }

  void retryLoad() {
    _loadRecipes();
  }
}

// Provider definition using family to pass the mode
final recipeControllerProviderFamily = StateNotifierProvider.autoDispose.family<
  RecipeController,
  state_lib.RecipeState,
  RecipeMode
>((ref, mode) {
  // ✅ COMPLETED: Real dependencies available through providers
  // ADVICE: Use recipeRepositoryProvider and inventoryRealProvider for real data
  return RecipeController(mode, ref);
});

// Modificación del provider de filtros para mejor rendimiento
// Provider to asynchronously load filter categories from JSON (with caching)
final recipeFiltersProvider = FutureProvider<List<FilterCategory>>((ref) async {
  try {
    // Define los filtros estáticamente para evitar la carga del archivo JSON
    // Esta es una versión hardcodeada del JSON para cargar más rápido
    final String filtersJson = '''
[
    {
      "category": "Tipo de receta",
      "filters": [
        { "label": "Entrada", "value": "entrada", "icon": "restaurant_menu" },
        { "label": "Plato principal", "value": "fondo", "icon": "dinner_dining" },
        { "label": "Postre", "value": "postre", "icon": "icecream" },
        { "label": "Bebida", "value": "bebida", "icon": "local_cafe" },
        { "label": "Snack / Bocadito", "value": "snack", "icon": "emoji_food_beverage" }
      ]
    },
    {
      "category": "Tiempo de preparación",
      "filters": [
        { "label": "< 15 min", "value": "short_time", "icon": "timer" },
        { "label": "15–30 min", "value": "medium_time", "icon": "schedule" },
        { "label": "> 30 min", "value": "long_time", "icon": "hourglass_bottom" }
      ]
    },
    {
      "category": "Dificultad",
      "filters": [
        { "label": "Fácil", "value": "facil", "icon": "light_mode" },
        { "label": "Intermedio", "value": "intermedio", "icon": "star_half" },
        { "label": "Difícil", "value": "dificil", "icon": "grade" }
      ]
    },
    {
      "category": "Tipo de dieta",
      "filters": [
        { "label": "Vegana", "value": "vegana", "icon": "eco" },
        { "label": "Vegetariana", "value": "vegetariana", "icon": "spa" },
        { "label": "Sin gluten", "value": "sin_gluten", "icon": "no_food" },
        { "label": "Sin lactosa", "value": "sin_lactosa", "icon": "free_breakfast" }
      ]
    },
    {
      "category": "Sostenibilidad",
      "filters": [
        { "label": "Aprovechar sobrantes", "value": "sobrantes", "icon": "recycling" },
        { "label": "Bajo impacto ambiental", "value": "bajo_impacto", "icon": "compost" }
      ]
    }
]
    ''';

    // Decode the JSON string into a List<dynamic>
    final List<dynamic> jsonList = jsonDecode(filtersJson) as List<dynamic>;

    // Map the JSON list to a List<FilterCategory>
    final List<FilterCategory> categories =
        jsonList
            .map(
              (json) => FilterCategory.fromJson(json as Map<String, dynamic>),
            )
            .toList();

    return categories;
  } catch (e) {
    // Handle potential errors during loading or parsing
    log('Error loading recipe filters: $e');
    throw Exception('Failed to load recipe filters: $e');
  }
}, name: 'recipeFilters');

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl();
});

final savedRecipesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  final result = await repository.getSavedRecipes();
  return result['recipes'] as List<dynamic>;
});

final recipesProvider = StateNotifierProvider<RecipesNotifier, List<Recipe>>((
  ref,
) {
  return RecipesNotifier();
});

class RecipesNotifier extends StateNotifier<List<Recipe>> {
  RecipesNotifier() : super([]);

  // Helper method to format quantity with unit
  String formatQuantity(double quantity, String unit) {
    if (quantity >= 1000 && unit == 'g') {
      return '${(quantity / 1000).toStringAsFixed(1)} kg';
    }
    if (quantity >= 1000 && unit == 'ml') {
      return '${(quantity / 1000).toStringAsFixed(1)} L';
    }
    return '${quantity.toStringAsFixed(1)} $unit';
  }

  // Helper method to get base unit for ingredient
  String getBaseUnit(String ingredient) {
    // Default to grams for solid ingredients
    if (ingredient.contains('leche') ||
        ingredient.contains('agua') ||
        ingredient.contains('aceite') ||
        ingredient.contains('vino') ||
        ingredient.contains('zumo')) {
      return 'ml';
    }
    return 'g';
  }
}

// --- End Provider Definitions ---
