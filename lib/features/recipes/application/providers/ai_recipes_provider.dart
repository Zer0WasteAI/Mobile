import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_backend_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/firestore_recipes_provider.dart';

/// AI Recipe Generation State
class AIRecipeState {
  final bool isGenerating;
  final List<Recipe> recipes;
  final String? error;
  final bool hasGenerated;
  final Map<String, dynamic>? personalizationInfo;
  final String? totalRecipes;
  final String? inventoryUsage;
  final DateTime? lastGenerated;
  final String? generationType; // 'inventory', 'custom', 'planner'

  const AIRecipeState({
    this.isGenerating = false,
    this.recipes = const [],
    this.error,
    this.hasGenerated = false,
    this.personalizationInfo,
    this.totalRecipes,
    this.inventoryUsage,
    this.lastGenerated,
    this.generationType,
  });

  AIRecipeState copyWith({
    bool? isGenerating,
    List<Recipe>? recipes,
    String? error,
    bool? hasGenerated,
    Map<String, dynamic>? personalizationInfo,
    String? totalRecipes,
    String? inventoryUsage,
    DateTime? lastGenerated,
    String? generationType,
  }) {
    return AIRecipeState(
      isGenerating: isGenerating ?? this.isGenerating,
      recipes: recipes ?? this.recipes,
      error: error,
      hasGenerated: hasGenerated ?? this.hasGenerated,
      personalizationInfo: personalizationInfo ?? this.personalizationInfo,
      totalRecipes: totalRecipes ?? this.totalRecipes,
      inventoryUsage: inventoryUsage ?? this.inventoryUsage,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      generationType: generationType ?? this.generationType,
    );
  }

  // Cache intelligence methods
  bool get areRecipesFresh {
    if (lastGenerated == null) return false;
    return DateTime.now().difference(lastGenerated!).inHours < 1;
  }

  bool get hasRecentRecipes {
    return recipes.isNotEmpty && areRecipesFresh;
  }

  String get cacheStatusMessage {
    if (!hasRecentRecipes) return '';

    switch (generationType) {
      case 'inventory':
        return 'Recetas guardadas del inventario';
      case 'custom':
        return 'Recetas personalizadas guardadas';
      case 'planner':
        return 'Recetas del planificador guardadas';
      default:
        return 'Recetas recientes guardadas';
    }
  }
}

/// AI Recipe Generation Notifier
class AIRecipeNotifier extends StateNotifier<AIRecipeState> {
  final RecipeBackendNotifier _recipeBackend;
  final Ref _ref;

  AIRecipeNotifier(this._recipeBackend, this._ref)
    : super(const AIRecipeState());

  /// Generate recipes from current inventory using real AI backend
  /// 🚀 OPTIMIZED: Anti-spam protection + retry with exponential backoff
  Future<void> generateRecipesFromInventory({
    bool forceRegenerate = false,
  }) async {
    // ✅ CACHE: Check if we have fresh inventory recipes
    if (!forceRegenerate &&
        state.hasRecentRecipes &&
        state.generationType == 'inventory') {
      log('📦 Using cached inventory recipes, skipping API call');
      return;
    }

    // ✅ ANTI-SPAM: Prevent multiple concurrent calls
    if (state.isGenerating) {
      log(
        '🛡️ AI Recipe generation already in progress, skipping duplicate call',
      );
      return;
    }

    state = state.copyWith(isGenerating: true, error: null);

    const maxRetries = 2;
    const baseDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log('🚀 AI Recipe generation attempt $attempt/$maxRetries');

        // Call real backend API - returns complete response with generated_recipes, inventory_utilization, and images info
        final response = await _recipeBackend.generateRecipesFromInventory();

        // Parse the complete response according to the new API format
        final recipesData = response['generated_recipes'] as List? ?? [];
        final recipes =
            recipesData.map((data) => _parseRecipeFromAPI(data)).toList();

        state = state.copyWith(
          isGenerating: false,
          recipes: recipes,
          hasGenerated: true,
          // Capture inventory utilization info
          totalRecipes: response['total_recipes']?.toString(),
          inventoryUsage:
              (response['inventory_utilization']?['utilization_percentage'])
                  ?.toString(),
          // Cache info
          lastGenerated: DateTime.now(),
          generationType: 'inventory',
        );

        // Save recipes to Firestore
        _saveRecipesToFirestore(recipes);

        log('✅ AI Recipe generation successful on attempt $attempt');
        return; // Success, exit retry loop
      } catch (e) {
        log('❌ AI Recipe generation attempt $attempt failed: $e');

        // If this is the last attempt, set error state
        if (attempt >= maxRetries) {
          state = state.copyWith(
            isGenerating: false,
            error:
                'No se pudieron generar las recetas después de $maxRetries intentos. Verifica tu conexión e intenta nuevamente.',
            hasGenerated: true,
          );
          log('💥 AI Recipe generation failed after all retries');
          return;
        }

        // Wait before retry with exponential backoff
        final delay = Duration(seconds: baseDelay.inSeconds * attempt);
        log('⏳ Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);
      }
    }
  }

  /// Generate custom recipes with specific ingredients and preferences
  Future<void> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
    List<String>? recipeCategories,
    int numRecipes = 2,
    bool forceRegenerate = false,
  }) async {
    // ✅ CACHE: Check if we have fresh custom recipes (basic check)
    if (!forceRegenerate &&
        state.hasRecentRecipes &&
        state.generationType == 'custom') {
      log('🎨 Using cached custom recipes, skipping API call');
      return;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      // Call real backend API - returns complete response with generated_recipes and images info
      final response = await _recipeBackend.generateCustomRecipes(
        ingredients: ingredients,
        preferences: preferences,
        recipeCategories: recipeCategories,
        numRecipes: numRecipes,
      );

      // Parse the complete response according to the new API format
      final recipesData = response['generated_recipes'] as List? ?? [];
      final recipes =
          recipesData.map((data) => _parseRecipeFromAPI(data)).toList();

      state = state.copyWith(
        isGenerating: false,
        recipes: recipes,
        hasGenerated: true,
        // Capture generation info
        totalRecipes: response['total_recipes']?.toString(),
        inventoryUsage:
            '100%', // Custom recipes use 100% of specified ingredients
        // Cache info
        lastGenerated: DateTime.now(),
        generationType: 'custom',
      );

      // Save recipes to Firestore
      _saveRecipesToFirestore(recipes);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        hasGenerated: true,
      );
    }
  }

  /// Load recipes from Firestore
  Future<void> loadRecipesFromFirestore() async {
    try {
      final firestoreNotifier = _ref.read(firestoreRecipesProvider.notifier);
      await firestoreNotifier.loadRecipes();

      // Update local state with recipes from Firestore
      final firestoreRecipes = _ref.read(firestoreRecipesListProvider);
      if (firestoreRecipes.isNotEmpty) {
        state = state.copyWith(
          recipes: firestoreRecipes,
          hasGenerated: true,
          lastGenerated: DateTime.now(),
          generationType: 'firestore',
        );
        log('📚 Loaded ${firestoreRecipes.length} recipes from Firestore');
      }
    } catch (e) {
      log('❌ Failed to load recipes from Firestore: $e');
      // We don't update state here as this is just an additional retrieval step
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
    // Parse ingredients from the new API format with quantity and type_unit
    final ingredientsData = data['ingredients'] as List? ?? [];
    final ingredientNames =
        ingredientsData
            .map((ingredient) {
              if (ingredient is Map<String, dynamic>) {
                final name = ingredient['name']?.toString() ?? '';
                final quantity = ingredient['quantity']?.toString() ?? '';
                final unit = ingredient['type_unit']?.toString() ?? '';

                // Format as "quantity unit name" if we have all parts
                if (name.isNotEmpty && quantity.isNotEmpty && unit.isNotEmpty) {
                  return '$quantity $unit $name';
                } else if (name.isNotEmpty) {
                  return name;
                }
                return '';
              }
              return ingredient.toString();
            })
            .where((name) => name.isNotEmpty)
            .toList();

    // Parse steps from the API response (backend uses 'steps' not 'instructions')
    final stepsData = data['steps'] as List? ?? [];
    final instructions =
        stepsData
            .map((stepData) {
              if (stepData is Map<String, dynamic>) {
                return stepData['description']?.toString() ?? '';
              }
              return stepData.toString();
            })
            .where((instruction) => instruction.isNotEmpty)
            .toList();

    return Recipe(
      id:
          data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['title'] ?? data['name'] ?? 'Receta Generada',
      description: data['description'] ?? '',
      emoji: _getEmojiForRecipe(data['title'] ?? data['name'] ?? ''),
      ingredients: ingredientNames,
      instructions: instructions,
      requiredIngredientsCount: ingredientNames.length,
      availableIngredientsCount: ingredientNames.length,
      usesExpiringItems: data['uses_expiring_items'] ?? false,
      cookingTime: _parseDuration(data['duration']) ?? 30,
      difficulty: data['difficulty'] ?? 'fácil',
      dietType: data['diet_type'] ?? 'Omnívora',
      categories: [data['category'] ?? 'Generado por IA'],
    );
  }

  /// Convert Recipe model to API format for saving
  Map<String, dynamic> _convertRecipeToAPI(Recipe recipe) {
    // Convert ingredients to the format expected by the save endpoint
    final ingredientsData =
        recipe.ingredients
            .map(
              (ingredient) => {
                'name': ingredient,
                'quantity': 1, // Default quantity
                'type_unit': 'unidades', // Default unit (using new field name)
              },
            )
            .toList();

    // Convert instructions to steps format with step_order
    final stepsData =
        recipe.instructions.isNotEmpty
            ? recipe.instructions
                .asMap()
                .entries
                .map(
                  (entry) => {
                    'step_order': entry.key + 1,
                    'description': entry.value,
                  },
                )
                .toList()
            : [
              {
                'step_order': 1,
                'description': 'Preparar todos los ingredientes',
              },
              {
                'step_order': 2,
                'description': 'Seguir las instrucciones de cocción',
              },
              {'step_order': 3, 'description': 'Servir y disfrutar'},
            ];

    return {
      'title': recipe.name,
      'description': recipe.description,
      'ingredients': ingredientsData,
      'steps': stepsData, // Use steps format instead of instructions
      'duration': '${recipe.cookingTime} min', // Format duration as string
      'difficulty': recipe.difficulty,
      'category':
          recipe.categories.isNotEmpty ? recipe.categories.first : 'general',
      'image_path': null, // Will be generated by backend
    };
  }

  /// Parse duration string like "25 min" to integer minutes
  int? _parseDuration(String? duration) {
    if (duration == null || duration.isEmpty) return null;

    // Extract numbers from duration string (e.g., "25 min" -> 25)
    final RegExp numberRegex = RegExp(r'(\d+)');
    final match = numberRegex.firstMatch(duration);

    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }

    return null;
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

  // Helper method to save recipes to Firestore
  Future<void> _saveRecipesToFirestore(List<Recipe> recipes) async {
    try {
      final firestoreNotifier = _ref.read(firestoreRecipesProvider.notifier);

      for (final recipe in recipes) {
        await firestoreNotifier.saveRecipe(recipe);
        log('📝 Recipe saved to Firestore: ${recipe.name}');
      }
    } catch (e) {
      log('❌ Failed to save recipes to Firestore: $e');
      // We don't update state here since the generation was successful
      // This is just an additional persistence step
    }
  }
}

/// Provider for AI Recipe Generation
final aiRecipeProvider = StateNotifierProvider<AIRecipeNotifier, AIRecipeState>(
  (ref) {
    final recipeBackend = ref.watch(recipeBackendProvider);
    return AIRecipeNotifier(recipeBackend, ref);
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
