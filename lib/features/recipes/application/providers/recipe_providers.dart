import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart'
    as state_lib;
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/filter_models.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

// --- Provider Definitions ---

// StateNotifier for Recipe Logic
class RecipeController extends StateNotifier<state_lib.RecipeState> {
  final RecipeMode _mode;
  // For real implementation:
  // final RecipeRepository _recipeRepository;
  // final InventoryRepository _inventoryRepository;

  RecipeController(this._mode) : super(const state_lib.RecipeState()) {
    _loadRecipes(); // Load recipes on initialization based on mode
  }

  Future<void> _loadRecipes() async {
    this.state = this.state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Simulate network delay (reducido para mejor experiencia)
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Implement actual data fetching logic based on _mode
      // - If _mode == RecipeMode.smartFromInventory:
      //   - Get inventory items (prioritize near-expired)
      //   - Call AI/Backend service with ingredients
      //   - Populate `recipes` and `expiringIngredientsUsedCount`
      // - If _mode == RecipeMode.explore:
      //   - Fetch all recipes (or apply initial filters)
      //   - Populate `recipes`

      // Map our domain Recipe to the state Recipe
      final List<state_lib.Recipe> stateRecipes =
          _getMockRecipes()
              .map(
                (recipe) => state_lib.Recipe(
                  id: recipe.id,
                  name: recipe.name,
                  description: recipe.description,
                  emoji: recipe.emoji,
                  ingredients: recipe.ingredients,
                  requiredIngredientsCount: recipe.requiredIngredientsCount,
                  availableIngredientsCount: recipe.availableIngredientsCount,
                  usesExpiringItems: recipe.usesExpiringItems,
                ),
              )
              .toList();

      this.state = this.state.copyWith(
        isLoading: false,
        recipes: stateRecipes,
        // Example: Set based on actual logic
        expiringIngredientsUsedCount:
            _mode == RecipeMode.smartFromInventory ? 3 : null,
      );
    } catch (e) {
      this.state = this.state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recipes: ${e.toString()}',
      );
    }
  }

  // Helper method to create mock recipes from our domain model
  List<Recipe> _getMockRecipes() {
    return [
      Recipe(
        id: '1',
        name: 'Pasta Aglio e Olio',
        description: 'Classic Italian pasta with garlic and oil.',
        emoji: '🍝',
        ingredients: [
          'Spaghetti',
          'Garlic',
          'Olive Oil',
          'Chili Flakes',
          'Parsley',
        ],
        requiredIngredientsCount: 5,
        availableIngredientsCount: 3,
        usesExpiringItems: _mode == RecipeMode.smartFromInventory,
        cookingTime: 25,
        difficulty: 'Fácil',
        dietType: 'Vegetariana',
        categories: ['Destacados', 'Vegetarianas'],
      ),
      Recipe(
        id: '2',
        name: 'Chicken Stir-Fry',
        description: 'Quick and easy chicken stir-fry with vegetables.',
        emoji: '🥘',
        ingredients: [
          'Chicken Breast',
          'Broccoli',
          'Bell Pepper',
          'Soy Sauce',
          'Ginger',
          'Garlic',
        ],
        requiredIngredientsCount: 6,
        availableIngredientsCount: 5,
        usesExpiringItems: false,
        cookingTime: 30,
        difficulty: 'Medio',
        dietType: 'Omnívora',
        categories: ['Destacados', 'Rápidas y Fáciles'],
      ),
      Recipe(
        id: '3',
        name: 'Lentil Soup',
        description: 'Hearty and healthy lentil soup.',
        emoji: '🥣',
        ingredients: [
          'Lentils',
          'Carrot',
          'Celery',
          'Onion',
          'Vegetable Broth',
          'Tomato Paste',
        ],
        requiredIngredientsCount: 6,
        availableIngredientsCount: 6,
        usesExpiringItems: _mode == RecipeMode.smartFromInventory,
        cookingTime: 45,
        difficulty: 'Fácil',
        dietType: 'Vegana',
        categories: ['Vegetarianas', 'Saludables'],
      ),
    ];
  }

  void setSearchQuery(String query) {
    this.state = this.state.copyWith(searchQuery: query);
    _applyFiltersAndSearch();
  }

  void toggleShowOnlyWithMyIngredients(bool value) {
    this.state = this.state.copyWith(showOnlyWithMyIngredients: value);
    _applyFiltersAndSearch();
  }

  void applyFilters(Map<String, Set<String>> filters) {
    this.state = this.state.copyWith(selectedFilters: filters);
    _applyFiltersAndSearch();
  }

  // Apply both filters and search query to recipes
  void _applyFiltersAndSearch() {
    // This would filter the recipes based on selected filters and search query
    // For now, we'll just update the loading state
    this.state = this.state.copyWith(isLoading: true);

    // In a real implementation, you'd filter the recipes here

    // For demo, simulate a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      this.state = this.state.copyWith(isLoading: false);
    });
  }

  void retryLoad() {
    _loadRecipes();
  }
}

// Provider definition using family to pass the mode
final recipeControllerProviderFamily = StateNotifierProvider.autoDispose
    .family<RecipeController, state_lib.RecipeState, RecipeMode>((ref, mode) {
      // TODO: Pass dependencies like repositories to the controller
      // final inventoryRepository = ref.watch(inventoryRepositoryProvider);
      // final recipeRepository = ref.watch(recipeRepositoryProvider);
      return RecipeController(
        mode /*, inventoryRepository, recipeRepository */,
      );
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
    print('Error loading recipe filters: $e');
    throw Exception('Failed to load recipe filters: $e');
  }
}, name: 'recipeFilters');

// --- End Provider Definitions ---
