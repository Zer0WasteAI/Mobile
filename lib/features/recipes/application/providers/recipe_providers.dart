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
        ingredients: List<String>.from(recipeData['ingredients'] ?? []),
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
    // This would filter the recipes based on selected filters and search query
    // For now, we'll just update the loading state
    state = state.copyWith(isLoading: true);

    // In a real implementation, you'd filter the recipes here

    // ✅ UPDATED: Immediate response without artificial delay
    state = state.copyWith(isLoading: false);
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

// --- End Provider Definitions ---
