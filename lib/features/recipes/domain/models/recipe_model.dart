import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_model.freezed.dart';
part 'recipe_model.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    required String description,
    required String emoji,
    required List<String> ingredients,
    required int requiredIngredientsCount,
    required int availableIngredientsCount,
    required bool usesExpiringItems,
    required int cookingTime,
    required String difficulty,
    required String dietType,
    required List<String> categories,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}

extension RecipeExtension on Recipe {
  // Format cooking time as a human-readable string
  String get formattedCookingTime {
    if (cookingTime < 60) {
      return '$cookingTime min';
    }
    final hours = cookingTime ~/ 60;
    final minutes = cookingTime % 60;
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }

  // Get ingredient availability percentage
  double get ingredientAvailabilityPercentage {
    if (requiredIngredientsCount == 0) return 0;
    return (availableIngredientsCount / requiredIngredientsCount) * 100;
  }

  // Get difficulty level color
  int get difficultyLevel {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return 1;
      case 'medio':
        return 2;
      case 'difícil':
        return 3;
      default:
        return 1;
    }
  }

  // Get difficulty level icon
  String get difficultyIcon {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return '🟢';
      case 'medio':
        return '🟡';
      case 'difícil':
        return '🔴';
      default:
        return '⚪️';
    }
  }

  // Get diet type icon
  String get dietTypeIcon {
    switch (dietType.toLowerCase()) {
      case 'vegetariano':
        return '🥬';
      case 'vegano':
        return '🌱';
      case 'sin gluten':
        return '🌾';
      case 'sin lactosa':
        return '🥛';
      case 'bajo en carbohidratos':
        return '🥩';
      case 'bajo en calorías':
        return '🥗';
      default:
        return '🍽️';
    }
  }

  // Create a copy of this recipe with optional field updates
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    List<String>? ingredients,
    int? requiredIngredientsCount,
    int? availableIngredientsCount,
    bool? usesExpiringItems,
    int? cookingTime,
    String? difficulty,
    String? dietType,
    List<String>? categories,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      ingredients: ingredients ?? this.ingredients,
      requiredIngredientsCount:
          requiredIngredientsCount ?? this.requiredIngredientsCount,
      availableIngredientsCount:
          availableIngredientsCount ?? this.availableIngredientsCount,
      usesExpiringItems: usesExpiringItems ?? this.usesExpiringItems,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      dietType: dietType ?? this.dietType,
      categories: categories ?? this.categories,
    );
  }

  // Check if this recipe matches filter criteria
  bool matchesFilters(Map<String, Set<String>> filters) {
    if (filters.isEmpty) return true;

    // Check each filter category
    for (final category in filters.keys) {
      final values = filters[category]!;

      switch (category) {
        case 'Tiempo de preparación':
          final bool matchesTime = values.any((value) {
            if (value == 'short_time') return cookingTime < 15;
            if (value == 'medium_time') {
              return cookingTime >= 15 && cookingTime <= 30;
            }
            if (value == 'long_time') return cookingTime > 30;
            return false;
          });
          if (!matchesTime) return false;
          break;

        case 'Dificultad':
          final bool matchesDifficulty = values.any((value) {
            if (value == 'facil') return difficulty == 'Fácil';
            if (value == 'intermedio') return difficulty == 'Medio';
            if (value == 'dificil') return difficulty == 'Difícil';
            return false;
          });
          if (!matchesDifficulty) return false;
          break;

        case 'Tipo de dieta':
          final bool matchesDiet = values.any((value) {
            if (value == 'vegetariana') return dietType == 'Vegetariana';
            if (value == 'vegana') return dietType == 'Vegana';
            if (value == 'omnivora') return dietType == 'Omnívora';
            // Other diet types...
            return false;
          });
          if (!matchesDiet) return false;
          break;

        // Add other filter categories as needed
      }
    }

    return true;
  }

  // Check if recipe matches search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowercaseQuery = query.toLowerCase();

    // Check name
    if (name.toLowerCase().contains(lowercaseQuery)) return true;

    // Check description
    if (description.toLowerCase().contains(lowercaseQuery)) return true;

    // Check ingredients
    for (final ingredient in ingredients) {
      if (ingredient.toLowerCase().contains(lowercaseQuery)) return true;
    }

    return false;
  }
}
