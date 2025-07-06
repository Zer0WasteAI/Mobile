import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';
import 'meal_planning_providers.dart';

/// Legacy provider compatibility file
/// This file provides compatibility with old provider names while delegating to new providers

// Re-export from meal planning providers for compatibility
export 'meal_planning_providers.dart' show selectedDateProvider;

/// Proveedor para el día seleccionado dentro de la semana
final selectedDayProvider = StateProvider<DateTime?>((ref) {
  final today = DateTime.now();
  return today;
});

/// Proveedor para verificar si es la primera vez que el usuario planifica
final isFirstPlanningProvider = StateProvider<bool>((ref) {
  final allMealPlans = ref.watch(allMealPlansProvider);
  return allMealPlans.when(
    data: (plans) => plans.isEmpty,
    loading: () => true,
    error: (_, _) => true,
  );
});

/// Proveedor para el historial de planificación
final planningHistoryProvider = StateNotifierProvider<PlanningHistoryNotifier, List<String>>((ref) {
  return PlanningHistoryNotifier();
});

/// Notifier para el historial de planificación
class PlanningHistoryNotifier extends StateNotifier<List<String>> {
  PlanningHistoryNotifier() : super([]);

  void addWeekToHistory(String weekKey) {
    if (!state.contains(weekKey)) {
      state = [...state, weekKey];
    }
  }

  bool hasWeekInHistory(String weekKey) {
    return state.contains(weekKey);
  }
}

/// Clase para las preferencias de usuario en cuanto a planificación
class UserPlanningPreferences {
  final List<String> dietaryRestrictions;
  final List<String> favoriteIngredients;
  final List<String> dislikedIngredients;
  final int maxMealsPerDay;

  UserPlanningPreferences({
    this.dietaryRestrictions = const [],
    this.favoriteIngredients = const [],
    this.dislikedIngredients = const [],
    this.maxMealsPerDay = 5,
  });
}

/// Proveedor para las preferencias de usuario
final userPlanningPreferencesProvider = StateProvider<UserPlanningPreferences>((ref) {
  return UserPlanningPreferences();
});

/// Sistema de validaciones para la planificación de comidas
class MealPlanValidation {
  final bool isValid;
  final String message;
  final ValidationSeverity severity;

  MealPlanValidation({
    required this.isValid,
    required this.message,
    required this.severity,
  });

  factory MealPlanValidation.success() {
    return MealPlanValidation(
      isValid: true,
      message: 'Validación exitosa',
      severity: ValidationSeverity.success,
    );
  }

  factory MealPlanValidation.warning(String message) {
    return MealPlanValidation(
      isValid: true,
      message: message,
      severity: ValidationSeverity.warning,
    );
  }

  factory MealPlanValidation.error(String message) {
    return MealPlanValidation(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
    );
  }
}

/// Niveles de severidad para las validaciones
enum ValidationSeverity { success, info, warning, error }

/// Clase para el sistema de validaciones
class MealPlanValidator {
  static List<MealPlanValidation> validateRecipePlan({
    required String recipeName,
    required MealType mealType,
    required String dateKey,
    required Map<String, List<String>> allRecipePlans,
    required UserPlanningPreferences preferences,
  }) {
    final validations = <MealPlanValidation>[];
    
    // Simplified validation for now
    validations.add(MealPlanValidation.success());
    
    return validations;
  }

  // Legacy method name for compatibility
  static List<MealPlanValidation> validateMealPlan({
    required SimpleRecipe newMeal,
    required String dateKey,
    required Map<String, List<SimpleRecipe>> allMealPlans,
    required UserPlanningPreferences preferences,
  }) {
    return validateRecipePlan(
      recipeName: newMeal.name,
      mealType: newMeal.type,
      dateKey: dateKey,
      allRecipePlans: {},
      preferences: preferences,
    );
  }
}

/// Proveedor para los resultados de la última validación
final lastValidationResultsProvider = StateProvider<List<MealPlanValidation>>((ref) {
  return [];
});

/// Simplified recipe providers for compatibility
final allRecipesProvider = StateNotifierProvider<SimpleRecipeNotifier, List<SimpleRecipe>>((ref) {
  return SimpleRecipeNotifier();
});

final favoriteRecipesProvider = Provider<List<SimpleRecipe>>((ref) {
  final allRecipes = ref.watch(allRecipesProvider);
  return allRecipes.where((recipe) => recipe.isFavorite).toList();
});

final recentRecipesProvider = Provider<List<SimpleRecipe>>((ref) {
  final allRecipes = ref.watch(allRecipesProvider);
  return allRecipes.take(5).toList();
});

/// Simple recipe model is now defined in meal_plan_models.dart

/// Simple recipe notifier
class SimpleRecipeNotifier extends StateNotifier<List<SimpleRecipe>> {
  SimpleRecipeNotifier() : super([
    SimpleRecipe(
      id: '1',
      name: 'Ensalada mediterránea',
      imageUrl: 'assets/images/meal1.jpg',
      ingredients: ['Tomate', 'Pepino', 'Aceitunas'],
      prepTimeMinutes: 15,
      calories: 250,
      difficulty: 'Fácil',
      dietaryTags: ['Vegetariano', 'Sin gluten'],
      type: MealType.lunch,
    ),
    SimpleRecipe(
      id: '2',
      name: 'Omelette de espinacas',
      imageUrl: 'assets/images/meal2.jpg',
      ingredients: ['Huevos', 'Espinacas'],
      prepTimeMinutes: 10,
      calories: 180,
      difficulty: 'Fácil',
      dietaryTags: ['Alto en proteínas'],
      type: MealType.breakfast,
    ),
  ]);

  void toggleFavorite(String id) {
    state = state.map((recipe) {
      if (recipe.id == id) {
        return recipe.copyWith(isFavorite: !recipe.isFavorite);
      }
      return recipe;
    }).toList();
  }

  void updateLastUsed(String id) {
    state = state.map((recipe) {
      if (recipe.id == id) {
        return recipe.copyWith(lastUsed: DateTime.now());
      }
      return recipe;
    }).toList();
  }
}

/// AI Suggestions mock
final aiSuggestionsProvider = FutureProvider.family<List<SimpleRecipe>, Map<String, dynamic>>((ref, parameters) async {
  await Future.delayed(const Duration(seconds: 1));
  final allRecipes = ref.read(allRecipesProvider);
  return allRecipes.take(3).toList();
});

/// Provider for selected meal compatibility
final selectedMealProvider = StateProvider<SimpleRecipe?>((ref) => null);

/// Recipe filters for compatibility
class RecipeFilters {
  final List<String> categories;
  final int? maxCookingTimeMinutes;
  final int? maxPrepTimeMinutes;
  final int? maxCalories;
  final String? searchQuery;
  final String? difficulty;
  final String? dietType;
  final List<String> dietaryTags;
  final MealType? mealType;

  RecipeFilters({
    this.categories = const [],
    this.maxCookingTimeMinutes,
    this.maxPrepTimeMinutes,
    this.maxCalories,
    this.searchQuery,
    this.difficulty,
    this.dietType,
    this.dietaryTags = const [],
    this.mealType,
  });

  RecipeFilters copyWith({
    List<String>? categories,
    int? maxCookingTimeMinutes,
    int? maxPrepTimeMinutes,
    int? maxCalories,
    String? searchQuery,
    String? difficulty,
    String? dietType,
    List<String>? dietaryTags,
    MealType? mealType,
    bool clearCookingTime = false,
    bool clearPrepTime = false,
    bool clearCalories = false,
    bool clearSearch = false,
    bool clearDifficulty = false,
    bool clearDietType = false,
    bool clearMealType = false,
  }) {
    return RecipeFilters(
      categories: categories ?? this.categories,
      maxCookingTimeMinutes: clearCookingTime ? null : maxCookingTimeMinutes ?? this.maxCookingTimeMinutes,
      maxPrepTimeMinutes: clearPrepTime ? null : maxPrepTimeMinutes ?? this.maxPrepTimeMinutes,
      maxCalories: clearCalories ? null : maxCalories ?? this.maxCalories,
      searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
      difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
      dietType: clearDietType ? null : dietType ?? this.dietType,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      mealType: clearMealType ? null : mealType ?? this.mealType,
    );
  }

  bool get hasFilters =>
      categories.isNotEmpty ||
      maxCookingTimeMinutes != null ||
      maxPrepTimeMinutes != null ||
      maxCalories != null ||
      searchQuery != null ||
      difficulty != null ||
      dietType != null ||
      dietaryTags.isNotEmpty ||
      mealType != null;
}

/// Provider for recipe filters
final recipeFiltersProvider = StateProvider<RecipeFilters>((ref) {
  return RecipeFilters();
});

/// Provider for filtered recipes
final filteredRecipesProvider = Provider<List<SimpleRecipe>>((ref) {
  final allRecipes = ref.watch(allRecipesProvider);
  final filters = ref.watch(recipeFiltersProvider);

  var result = allRecipes;

  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    final query = filters.searchQuery!.toLowerCase();
    result = result.where((recipe) {
      final nameMatch = recipe.name.toLowerCase().contains(query);
      final ingredientMatch = recipe.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(query),
      );
      return nameMatch || ingredientMatch;
    }).toList();
  }

  return result;
});