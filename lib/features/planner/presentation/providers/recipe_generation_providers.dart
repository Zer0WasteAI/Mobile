import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal_plan_models.dart';
import '../../../recipes/application/providers/ai_recipes_provider.dart';
import '../../../recipes/domain/models/recipe_model.dart';

/// Get emoji for recipe based on title
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

// Recipe generation state
class RecipeGenerationState {
  final List<GeneratedRecipe> recipes;
  final bool isLoading;
  final String? error;
  final String? imageTaskId;
  final DateTime? lastGenerated;
  final MealType? lastMealType;

  const RecipeGenerationState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
    this.imageTaskId,
    this.lastGenerated,
    this.lastMealType,
  });

  RecipeGenerationState copyWith({
    List<GeneratedRecipe>? recipes,
    bool? isLoading,
    String? error,
    String? imageTaskId,
    DateTime? lastGenerated,
    MealType? lastMealType,
  }) {
    return RecipeGenerationState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      imageTaskId: imageTaskId ?? this.imageTaskId,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      lastMealType: lastMealType ?? this.lastMealType,
    );
  }

  // Check if recipes are still fresh (less than 1 hour old)
  bool get areRecipesFresh {
    if (lastGenerated == null) return false;
    return DateTime.now().difference(lastGenerated!).inHours < 1;
  }

  // Check if we have cached recipes for the same meal type
  bool hasCachedRecipesFor(MealType mealType) {
    return lastMealType == mealType && recipes.isNotEmpty && areRecipesFresh;
  }
}

// Recipe generation notifier
class RecipeGenerationNotifier extends StateNotifier<RecipeGenerationState> {
  final AIRecipeNotifier _aiRecipeNotifier;

  RecipeGenerationNotifier(this._aiRecipeNotifier)
    : super(const RecipeGenerationState());

  Future<void> generateCustomRecipes({
    required MealType mealType,
    int numRecipes = 5,
    List<String>? preferences,
    List<String>? categories,
    bool forceRegenerate = false,
  }) async {
    // Check if we have fresh cached recipes for this meal type
    if (!forceRegenerate && state.hasCachedRecipesFor(mealType)) {
      // Return cached recipes without making API call
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Prepare ingredients and preferences based on meal type
      final ingredients = _getIngredientsForMealType(mealType);
      final mealPreferences = _getPreferencesForMealType(mealType, preferences);
      final mealCategories = _getCategoriesForMealType(mealType, categories);

      // Call the real AI service to generate recipes
      await _aiRecipeNotifier.generateCustomRecipes(
        ingredients: ingredients,
        preferences: mealPreferences,
        recipeCategories: mealCategories,
        numRecipes: numRecipes,
      );

      // Get the generated recipes from AI provider
      final aiState = _aiRecipeNotifier.state;

      if (aiState.error != null) {
        throw Exception(aiState.error);
      }

      // Convert Recipe models to GeneratedRecipe models
      final generatedRecipes =
          aiState.recipes
              .map((recipe) => _convertToGeneratedRecipe(recipe, mealType))
              .toList();

      state = state.copyWith(
        recipes: generatedRecipes,
        imageTaskId: 'ai-generated-task-id',
        isLoading: false,
        lastGenerated: DateTime.now(),
        lastMealType: mealType,
      );

      // Sync with main AI provider for unified cache
      await _syncWithMainAIProvider(generatedRecipes);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearRecipes() {
    state = const RecipeGenerationState();
    _aiRecipeNotifier.clearState();
  }

  /// Save a generated recipe to favorites
  Future<bool> saveGeneratedRecipe(GeneratedRecipe recipe) async {
    try {
      // Convert GeneratedRecipe to Recipe format for saving
      // ignore: unused_local_variable
      final recipeData = {
        'title': recipe.title,
        'description': recipe.description,
        'ingredients':
            recipe.ingredients
                .map(
                  (ing) => {
                    'name': ing.name,
                    'quantity': ing.quantity,
                    'unit': ing.unit,
                  },
                )
                .toList(),
        'instructions': recipe.instructions,
        'prep_time': recipe.prepTime,
        'cook_time': recipe.cookTime,
        'servings': recipe.servings,
        'difficulty': recipe.difficulty,
        'calories': recipe.calories,
        'dietary_info': recipe.dietaryInfo,
      };

      await _aiRecipeNotifier.saveRecipe(
        Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: recipe.title,
          description: recipe.description,
          emoji: _getEmojiForRecipe(recipe.title),
          ingredients: recipe.ingredients.map((ing) => ing.name).toList(),
          requiredIngredientsCount: recipe.ingredients.length,
          availableIngredientsCount: recipe.ingredients.length,
          usesExpiringItems: false,
          cookingTime: recipe.prepTime + recipe.cookTime,
          difficulty: recipe.difficulty,
          dietType: 'Generada por IA',
          categories: recipe.dietaryInfo,
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sync planner recipes with main AI provider for unified cache
  Future<void> _syncWithMainAIProvider(
    List<GeneratedRecipe> generatedRecipes,
  ) async {
    try {
      // Convert GeneratedRecipe back to Recipe for the main provider
      final recipes =
          generatedRecipes
              .map(
                (genRecipe) => Recipe(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: genRecipe.title,
                  description: genRecipe.description,
                  emoji: _getEmojiForRecipe(genRecipe.title),
                  ingredients:
                      genRecipe.ingredients.map((ing) => ing.name).toList(),
                  requiredIngredientsCount: genRecipe.ingredients.length,
                  availableIngredientsCount: genRecipe.ingredients.length,
                  usesExpiringItems: false,
                  cookingTime: genRecipe.prepTime + genRecipe.cookTime,
                  difficulty: genRecipe.difficulty,
                  dietType: 'Generada por IA',
                  categories: genRecipe.dietaryInfo,
                ),
              )
              .toList();

      // Update main AI provider state to include these recipes
      _aiRecipeNotifier.state = _aiRecipeNotifier.state.copyWith(
        recipes: recipes,
        lastGenerated: DateTime.now(),
        generationType: 'planner',
        hasGenerated: true,
      );
    } catch (e) {
      // Log error but don't fail the main generation flow
      // Log error but don't fail the main generation flow
    }
  }

  // Helper methods for meal type specific generation
  List<String> _getIngredientsForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return ['huevos', 'pan', 'leche', 'frutas', 'avena', 'yogurt'];
      case MealType.lunch:
        return ['pollo', 'verduras', 'arroz', 'pasta', 'pescado', 'legumbres'];
      case MealType.dinner:
        return ['proteína', 'vegetales', 'ensalada', 'sopa', 'granos'];
      case MealType.snack:
        return ['frutas', 'nueces', 'yogurt', 'crackers', 'hummus'];
    }
  }

  List<String> _getPreferencesForMealType(
    MealType mealType,
    List<String>? customPreferences,
  ) {
    final defaultPreferences = <String>[];

    switch (mealType) {
      case MealType.breakfast:
        defaultPreferences.addAll(['nutritivo', 'energético', 'rápido']);
        break;
      case MealType.lunch:
        defaultPreferences.addAll(['completo', 'balanceado', 'satisfactorio']);
        break;
      case MealType.dinner:
        defaultPreferences.addAll(['ligero', 'digestivo', 'reconfortante']);
        break;
      case MealType.snack:
        defaultPreferences.addAll(['saludable', 'portátil', 'rápido']);
        break;
    }

    if (customPreferences != null) {
      defaultPreferences.addAll(customPreferences);
    }

    return defaultPreferences;
  }

  List<String> _getCategoriesForMealType(
    MealType mealType,
    List<String>? customCategories,
  ) {
    final defaultCategories = <String>[mealType.name.toLowerCase()];

    if (customCategories != null) {
      defaultCategories.addAll(customCategories);
    }

    return defaultCategories;
  }

  GeneratedRecipe _convertToGeneratedRecipe(Recipe recipe, MealType mealType) {
    // Convert ingredients from strings to RecipeIngredient objects
    final ingredients =
        recipe.ingredients
            .map(
              (ingredient) => RecipeIngredient(
                name: ingredient,
                quantity: 1.0,
                unit: 'unidad',
              ),
            )
            .toList();

    return GeneratedRecipe(
      title: recipe.name,
      description: recipe.description,
      ingredients: ingredients,
      instructions: [
        'Preparar todos los ingredientes necesarios',
        'Seguir las técnicas de cocción apropiadas para ${mealType.name.toLowerCase()}',
        'Combinar ingredientes según la receta',
        'Servir y disfrutar',
      ],
      prepTime: (recipe.cookingTime * 0.3).round(), // 30% del tiempo total
      cookTime: (recipe.cookingTime * 0.7).round(), // 70% del tiempo total
      servings: 2, // Default serving size
      difficulty: recipe.difficulty,
      calories: _estimateCaloriesForMealType(mealType),
      dietaryInfo: [recipe.dietType, ...recipe.categories],
      generatedAt: DateTime.now(),
    );
  }

  int _estimateCaloriesForMealType(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 300 + (DateTime.now().millisecond % 200); // 300-500 cal
      case MealType.lunch:
        return 500 + (DateTime.now().millisecond % 300); // 500-800 cal
      case MealType.dinner:
        return 400 + (DateTime.now().millisecond % 250); // 400-650 cal
      case MealType.snack:
        return 150 + (DateTime.now().millisecond % 150); // 150-300 cal
    }
  }
}

// Generated recipe model
class GeneratedRecipe {
  final String title;
  final String description;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final int? calories;
  final List<String> dietaryInfo;
  final String? imagePath;
  final String imageStatus;
  final DateTime generatedAt;

  const GeneratedRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.calories,
    this.dietaryInfo = const [],
    this.imagePath,
    this.imageStatus = 'generating',
    required this.generatedAt,
  });

  factory GeneratedRecipe.fromJson(Map<String, dynamic> json) {
    return GeneratedRecipe(
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map(
                (ingredient) => RecipeIngredient.fromJson(
                  ingredient as Map<String, dynamic>,
                ),
              )
              .toList(),
      instructions:
          (json['instructions'] as List<dynamic>)
              .map((instruction) => instruction as String)
              .toList(),
      prepTime: json['prep_time'] as int,
      cookTime: json['cook_time'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      calories: json['calories'] as int?,
      dietaryInfo:
          (json['dietary_info'] as List<dynamic>?)
              ?.map((info) => info as String)
              .toList() ??
          [],
      imagePath: json['image_path'] as String?,
      imageStatus: json['image_status'] as String? ?? 'generating',
      generatedAt: DateTime.parse(
        json['generated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  GeneratedRecipe copyWith({
    String? title,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<String>? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    int? calories,
    List<String>? dietaryInfo,
    String? imagePath,
    String? imageStatus,
    DateTime? generatedAt,
  }) {
    return GeneratedRecipe(
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      calories: calories ?? this.calories,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      imagePath: imagePath ?? this.imagePath,
      imageStatus: imageStatus ?? this.imageStatus,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

// Recipe ingredient model
class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  @override
  String toString() => '$quantity $unit de $name';
}

// Recipe generation result
class RecipeGenerationResult {
  final List<GeneratedRecipe> recipes;
  final String? imageTaskId;

  const RecipeGenerationResult({required this.recipes, this.imageTaskId});
}

// Providers
final recipeGenerationProvider =
    StateNotifierProvider<RecipeGenerationNotifier, RecipeGenerationState>((
      ref,
    ) {
      final aiRecipeNotifier = ref.watch(aiRecipeProvider.notifier);
      return RecipeGenerationNotifier(aiRecipeNotifier);
    });

/// Provider to expose planner-generated recipes
final plannerGeneratedRecipesProvider = Provider<List<Recipe>>((ref) {
  final generationState = ref.watch(recipeGenerationProvider);

  // Convert GeneratedRecipe to Recipe format
  return generationState.recipes
      .map(
        (generatedRecipe) => Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: generatedRecipe.title,
          description: generatedRecipe.description,
          emoji: _getEmojiForRecipe(generatedRecipe.title),
          ingredients:
              generatedRecipe.ingredients.map((ing) => ing.name).toList(),
          requiredIngredientsCount: generatedRecipe.ingredients.length,
          availableIngredientsCount: generatedRecipe.ingredients.length,
          usesExpiringItems: false,
          cookingTime: generatedRecipe.prepTime + generatedRecipe.cookTime,
          difficulty: generatedRecipe.difficulty,
          dietType:
              generatedRecipe.dietaryInfo.isNotEmpty
                  ? generatedRecipe.dietaryInfo.first
                  : 'Generada por IA',
          categories: generatedRecipe.dietaryInfo,
        ),
      )
      .toList();
});
