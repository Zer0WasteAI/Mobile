import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal_plan_models.dart';
import '../../../recipes/application/providers/ai_recipes_provider.dart';
import '../../../recipes/domain/models/recipe_model.dart';
import '../../../recipes/application/providers/recipe_backend_provider.dart';

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
  }) {
    return RecipeGenerationState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      imageTaskId: imageTaskId ?? this.imageTaskId,
    );
  }
}

// Recipe generation notifier
class RecipeGenerationNotifier extends StateNotifier<RecipeGenerationState> {
  final AIRecipeNotifier _aiRecipeNotifier;

  RecipeGenerationNotifier(this._aiRecipeNotifier) : super(const RecipeGenerationState());

  Future<void> generateCustomRecipes({
    required MealType mealType,
    int numRecipes = 5,
    List<String>? preferences,
    List<String>? categories,
  }) async {
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
      final generatedRecipes = aiState.recipes.map((recipe) => _convertToGeneratedRecipe(recipe, mealType)).toList();

      state = state.copyWith(
        recipes: generatedRecipes,
        imageTaskId: 'ai-generated-task-id',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearRecipes() {
    state = const RecipeGenerationState();
    _aiRecipeNotifier.clearState();
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

  List<String> _getPreferencesForMealType(MealType mealType, List<String>? customPreferences) {
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

  List<String> _getCategoriesForMealType(MealType mealType, List<String>? customCategories) {
    final defaultCategories = <String>[mealType.name.toLowerCase()];
    
    if (customCategories != null) {
      defaultCategories.addAll(customCategories);
    }
    
    return defaultCategories;
  }

  GeneratedRecipe _convertToGeneratedRecipe(Recipe recipe, MealType mealType) {
    // Convert ingredients from strings to RecipeIngredient objects
    final ingredients = recipe.ingredients.map((ingredient) => 
      RecipeIngredient(
        name: ingredient,
        quantity: 1.0,
        unit: 'unidad',
      )
    ).toList();

    return GeneratedRecipe(
      title: recipe.name,
      description: recipe.description,
      ingredients: ingredients,
      instructions: [
        'Preparar todos los ingredientes necesarios',
        'Seguir las técnicas de cocción apropiadas para ${mealType.name.toLowerCase()}',
        'Combinar ingredientes según la receta',
        'Servir y disfrutar'
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
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((ingredient) => RecipeIngredient.fromJson(ingredient as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((instruction) => instruction as String)
          .toList(),
      prepTime: json['prep_time'] as int,
      cookTime: json['cook_time'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      calories: json['calories'] as int?,
      dietaryInfo: (json['dietary_info'] as List<dynamic>?)
          ?.map((info) => info as String)
          .toList() ?? [],
      imagePath: json['image_path'] as String?,
      imageStatus: json['image_status'] as String? ?? 'generating',
      generatedAt: DateTime.parse(json['generated_at'] as String? ?? DateTime.now().toIso8601String()),
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

  const RecipeGenerationResult({
    required this.recipes,
    this.imageTaskId,
  });
}

// Providers
final recipeGenerationProvider = StateNotifierProvider<RecipeGenerationNotifier, RecipeGenerationState>((ref) {
  final aiRecipeNotifier = ref.watch(aiRecipeProvider.notifier);
  return RecipeGenerationNotifier(aiRecipeNotifier);
});