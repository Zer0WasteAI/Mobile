import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_backend_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

/// AI Recipe Generation State
class AIRecipeState {
  final bool isGenerating;
  final List<Recipe> recipes;
  final String? error;
  final bool hasGenerated;
  final Map<String, dynamic>? personalizationInfo;
  final String? totalRecipes;
  final String? inventoryUsage;

  const AIRecipeState({
    this.isGenerating = false,
    this.recipes = const [],
    this.error,
    this.hasGenerated = false,
    this.personalizationInfo,
    this.totalRecipes,
    this.inventoryUsage,
  });

  AIRecipeState copyWith({
    bool? isGenerating,
    List<Recipe>? recipes,
    String? error,
    bool? hasGenerated,
    Map<String, dynamic>? personalizationInfo,
    String? totalRecipes,
    String? inventoryUsage,
  }) {
    return AIRecipeState(
      isGenerating: isGenerating ?? this.isGenerating,
      recipes: recipes ?? this.recipes,
      error: error ?? this.error,
      hasGenerated: hasGenerated ?? this.hasGenerated,
      personalizationInfo: personalizationInfo ?? this.personalizationInfo,
      totalRecipes: totalRecipes ?? this.totalRecipes,
      inventoryUsage: inventoryUsage ?? this.inventoryUsage,
    );
  }
}

/// AI Recipe Generation Notifier
class AIRecipeNotifier extends StateNotifier<AIRecipeState> {
  final RecipeBackendNotifier _recipeBackend;

  AIRecipeNotifier(this._recipeBackend) : super(const AIRecipeState());

  /// Generate recipes from current inventory using real AI backend
  Future<void> generateRecipesFromInventory() async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      // Call real backend API - NOTA: Esto debe devolver el response completo
      final response =
          await _recipeBackend.generateRecipesFromInventoryComplete();

      // 🆕 Parsear el response completo según CAMBIOS_ENDPOINTS.md
      final recipesData = response['generated_recipes'] as List? ?? [];
      final recipes =
          recipesData.map((data) => _parseRecipeFromAPI(data)).toList();

      state = state.copyWith(
        isGenerating: false,
        recipes: recipes,
        hasGenerated: true,
        // 🆕 Capturar información de personalización
        personalizationInfo:
            response['personalization_info'] as Map<String, dynamic>?,
        totalRecipes: response['total_recipes']?.toString(),
        inventoryUsage: response['inventory_usage']?.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        hasGenerated: true,
      );
    }
  }

  /// Generate custom recipes with specific ingredients
  Future<void> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    int numRecipes = 2,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      // Call real backend API - NOTA: Esto debe devolver el response completo
      final response = await _recipeBackend.generateCustomRecipesComplete(
        ingredients: ingredients,
        preferences: preferences,
        numRecipes: numRecipes,
      );

      // 🆕 Parsear el response completo según CAMBIOS_ENDPOINTS.md
      final recipesData = response['generated_recipes'] as List? ?? [];
      final recipes =
          recipesData.map((data) => _parseRecipeFromAPI(data)).toList();

      state = state.copyWith(
        isGenerating: false,
        recipes: recipes,
        hasGenerated: true,
        // 🆕 Capturar información de personalización
        personalizationInfo:
            response['personalization_info'] as Map<String, dynamic>?,
        totalRecipes: response['total_recipes']?.toString(),
        inventoryUsage: response['inventory_usage']?.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        hasGenerated: true,
      );
    }
  }

  /// Save a recipe to favorites
  Future<bool> saveRecipe(Recipe recipe) async {
    try {
      final recipeData = _convertRecipeToAPI(recipe);
      await _recipeBackend.saveRecipe(recipeData);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear state
  void clearState() {
    state = const AIRecipeState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Convert API response to Recipe model
  Recipe _parseRecipeFromAPI(Map<String, dynamic> data) {
    return Recipe(
      id:
          data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['name'] ?? 'Receta Generada',
      description: data['description'] ?? '',
      emoji: _getEmojiForRecipe(data['name'] ?? ''),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      requiredIngredientsCount: (data['ingredients'] as List?)?.length ?? 0,
      availableIngredientsCount: (data['ingredients'] as List?)?.length ?? 0,
      usesExpiringItems: data['uses_expiring_items'] ?? false,
      cookingTime: data['cooking_time_minutes'] ?? 30,
      difficulty: data['difficulty'] ?? 'Medio',
      dietType: data['diet_type'] ?? 'Omnívora',
      categories: List<String>.from(data['categories'] ?? ['Generado por IA']),
    );
  }

  /// Convert Recipe model to API format
  Map<String, dynamic> _convertRecipeToAPI(Recipe recipe) {
    return {
      'id': recipe.id,
      'name': recipe.name,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
      'instructions': [], // Will be handled separately if needed
      'cooking_time_minutes': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'diet_type': recipe.dietType,
      'categories': recipe.categories,
      'servings': 4, // Default servings
      'nutritional_info': null, // Will be handled separately if needed
    };
  }

  /// Get appropriate emoji for recipe based on name/ingredients
  String _getEmojiForRecipe(String recipeName) {
    final name = recipeName.toLowerCase();

    if (name.contains('pasta') ||
        name.contains('spaghetti') ||
        name.contains('penne')) {
      return '🍝';
    } else if (name.contains('pizza')) {
      return '🍕';
    } else if (name.contains('ensalada') || name.contains('salad')) {
      return '🥗';
    } else if (name.contains('sopa') || name.contains('soup')) {
      return '🍲';
    } else if (name.contains('arroz') || name.contains('rice')) {
      return '🍚';
    } else if (name.contains('pollo') || name.contains('chicken')) {
      return '🍗';
    } else if (name.contains('pescado') || name.contains('fish')) {
      return '🐟';
    } else if (name.contains('verduras') || name.contains('vegetable')) {
      return '🥕';
    } else if (name.contains('huevo') || name.contains('egg')) {
      return '🍳';
    } else if (name.contains('taco')) {
      return '🌮';
    } else if (name.contains('hamburguesa') || name.contains('burger')) {
      return '🍔';
    } else if (name.contains('curry')) {
      return '🍛';
    } else {
      return '🍽️';
    }
  }
}

/// Provider for AI Recipe Generation
final aiRecipeProvider = StateNotifierProvider<AIRecipeNotifier, AIRecipeState>(
  (ref) {
    final recipeBackend = ref.watch(recipeBackendProvider);
    return AIRecipeNotifier(recipeBackend);
  },
);

/// Convenience providers
final isGeneratingRecipesProvider = Provider<bool>((ref) {
  return ref.watch(aiRecipeProvider).isGenerating;
});

final generatedRecipesProvider = Provider<List<Recipe>>((ref) {
  return ref.watch(aiRecipeProvider).recipes;
});

final recipeGenerationErrorProvider = Provider<String?>((ref) {
  return ref.watch(aiRecipeProvider).error;
});

/// 🆕 NUEVOS providers para información de personalización según CAMBIOS_ENDPOINTS.md
final personalizationInfoProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(aiRecipeProvider).personalizationInfo;
});

final totalRecipesGeneratedProvider = Provider<String?>((ref) {
  return ref.watch(aiRecipeProvider).totalRecipes;
});

final inventoryUsageProvider = Provider<String?>((ref) {
  return ref.watch(aiRecipeProvider).inventoryUsage;
});

/// Provider para obtener lista de preferencias aplicadas
final appliedPreferencesProvider = Provider<List<String>>((ref) {
  final personalizationInfo = ref.watch(personalizationInfoProvider);
  if (personalizationInfo == null) return [];

  final preferencesApplied = personalizationInfo['preferences_applied'];
  if (preferencesApplied is List) {
    return List<String>.from(preferencesApplied);
  }
  return [];
});

/// Provider para obtener lista de alergias filtradas
final filteredAllergiesProvider = Provider<List<String>>((ref) {
  final personalizationInfo = ref.watch(personalizationInfoProvider);
  if (personalizationInfo == null) return [];

  final allergiesFiltered = personalizationInfo['allergies_filtered'];
  if (allergiesFiltered is List) {
    return List<String>.from(allergiesFiltered);
  }
  return [];
});

/// Provider para obtener idioma usado en generación
final recipeLanguageProvider = Provider<String?>((ref) {
  final personalizationInfo = ref.watch(personalizationInfoProvider);
  return personalizationInfo?['language'] as String?;
});

/// Provider para obtener sistema de medidas usado
final measurementSystemProvider = Provider<String?>((ref) {
  final personalizationInfo = ref.watch(personalizationInfoProvider);
  return personalizationInfo?['measurement_system'] as String?;
});

/// Provider para obtener nivel de cocina usado
final cookingLevelProvider = Provider<String?>((ref) {
  final personalizationInfo = ref.watch(personalizationInfoProvider);
  return personalizationInfo?['cooking_level'] as String?;
});
