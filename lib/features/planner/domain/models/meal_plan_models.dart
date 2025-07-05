/// INFO: Data models for meal planning functionality  
/// ADVICE: These models match the API structure for meal planning endpoints
library;

import 'package:flutter/material.dart';

/// Enum for meal types with UI extensions
enum MealType { breakfast, lunch, dinner, snack }

/// Extension for meal type UI properties
extension MealTypeExtension on MealType {
  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  Color get color {
    switch (this) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return Colors.blue;
    }
  }
}

/// INFO: Ingredient model for meal planning
class MealIngredient {
  final String name;
  final int quantity;
  final String unit;

  const MealIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory MealIngredient.fromJson(Map<String, dynamic> json) {
    return MealIngredient(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'unit': unit};
  }

  @override
  String toString() => '$quantity $unit de $name';
}

/// INFO: Individual meal model (breakfast, lunch, dinner)
class Meal {
  final String recipeTitle;
  final List<MealIngredient> ingredientsNeeded;
  final int prepTime;
  final int calories;

  const Meal({
    required this.recipeTitle,
    required this.ingredientsNeeded,
    required this.prepTime,
    required this.calories,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      recipeTitle: json['recipe_title'] as String,
      ingredientsNeeded:
          (json['ingredients_needed'] as List<dynamic>)
              .map(
                (ingredient) =>
                    MealIngredient.fromJson(ingredient as Map<String, dynamic>),
              )
              .toList(),
      prepTime: json['prep_time'] as int,
      calories: json['calories'] as int,
    );
  }

  Map<String, dynamic> toJson([String? mealType]) {
    // Map meal type to proper category
    String getCategory(String? mealType) {
      switch (mealType) {
        case 'breakfast':
          return 'desayuno';
        case 'lunch':
          return 'almuerzo';
        case 'dinner':
          return 'cena';
        default:
          return 'desayuno'; // Default fallback
      }
    }
    
    return {
      // Map to the format the backend actually expects
      'title': recipeTitle,
      'duration': prepTime.toString(), // Convert to string
      'difficulty': 'Intermedio', // Proper capitalization with accent
      'ingredients': ingredientsNeeded.map((ingredient) => {
        'name': ingredient.name,
        'quantity': ingredient.quantity,
        'unit': ingredient.unit, // Use unit as per API documentation
      }).toList(),
      'steps': [{'step_order': 1, 'description': 'Preparar según receta'}], // Proper step format
      'generated_by_ai': true,
      'category': getCategory(mealType), // Dynamic category based on meal type
      'description': 'Receta generada por IA',
      
      // Keep original format for compatibility
      'recipe_title': recipeTitle,
      'ingredients_needed':
          ingredientsNeeded.map((ingredient) => ingredient.toJson()).toList(),
      'prep_time': prepTime,
      'calories': calories,
    };
  }
}

/// INFO: Daily meals structure (breakfast, lunch, dinner)
class DailyMeals {
  final Meal? breakfast;
  final Meal? lunch;
  final Meal? dinner;

  const DailyMeals({this.breakfast, this.lunch, this.dinner});

  factory DailyMeals.fromJson(Map<String, dynamic> json) {
    return DailyMeals(
      breakfast:
          json['breakfast'] != null
              ? Meal.fromJson(json['breakfast'] as Map<String, dynamic>)
              : null,
      lunch:
          json['lunch'] != null
              ? Meal.fromJson(json['lunch'] as Map<String, dynamic>)
              : null,
      dinner:
          json['dinner'] != null
              ? Meal.fromJson(json['dinner'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (breakfast != null) result['breakfast'] = breakfast!.toJson('breakfast');
    if (lunch != null) result['lunch'] = lunch!.toJson('lunch');
    if (dinner != null) result['dinner'] = dinner!.toJson('dinner');
    return result;
  }

  /// INFO: Calculate total calories for the day
  int get totalCalories {
    int total = 0;
    if (breakfast != null) total += breakfast!.calories;
    if (lunch != null) total += lunch!.calories;
    if (dinner != null) total += dinner!.calories;
    return total;
  }

  /// INFO: Get all meals as a list (non-null meals only)
  List<Meal> get allMeals {
    final List<Meal> meals = [];
    if (breakfast != null) meals.add(breakfast!);
    if (lunch != null) meals.add(lunch!);
    if (dinner != null) meals.add(dinner!);
    return meals;
  }
}

/// INFO: Complete meal plan model
class MealPlanModel {
  final String uid;
  final String date;
  final DailyMeals meals;
  final int totalCalories;
  final DateTime createdAt;

  const MealPlanModel({
    required this.uid,
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.createdAt,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      uid: json['uid'] as String,
      date: json['date'] as String,
      meals: DailyMeals.fromJson(json['meals'] as Map<String, dynamic>),
      totalCalories: json['total_calories'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
      'meals': meals.toJson(),
      'total_calories': totalCalories,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// INFO: Create a copy with updated values
  MealPlanModel copyWith({
    String? uid,
    String? date,
    DailyMeals? meals,
    int? totalCalories,
    DateTime? createdAt,
  }) {
    return MealPlanModel(
      uid: uid ?? this.uid,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// INFO: Meal plan save request model
class SaveMealPlanRequest {
  final String date;
  final DailyMeals meals;

  const SaveMealPlanRequest({required this.date, required this.meals});

  Map<String, dynamic> toJson() {
    return {'date': date, 'meals': meals.toJson()};
  }
}

/// INFO: Meal plan response wrapper
class MealPlanResponse {
  final String message;
  final MealPlanModel mealPlan;

  const MealPlanResponse({required this.message, required this.mealPlan});

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      message: json['message'] as String,
      mealPlan: MealPlanModel.fromJson(
        json['meal_plan'] as Map<String, dynamic>,
      ),
    );
  }
}

/// INFO: Get meal plan by date response
class GetMealPlanResponse {
  final MealPlanModel? mealPlan;

  const GetMealPlanResponse({this.mealPlan});

  factory GetMealPlanResponse.fromJson(Map<String, dynamic> json) {
    return GetMealPlanResponse(
      mealPlan:
          json['meal_plan'] != null
              ? MealPlanModel.fromJson(
                json['meal_plan'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

/// INFO: Get all meal plans response
class GetAllMealPlansResponse {
  final List<MealPlanModel> mealPlans;

  const GetAllMealPlansResponse({required this.mealPlans});

  factory GetAllMealPlansResponse.fromJson(Map<String, dynamic> json) {
    return GetAllMealPlansResponse(
      mealPlans:
          (json['meal_plans'] as List<dynamic>)
              .map(
                (plan) => MealPlanModel.fromJson(plan as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

/// INFO: Get meal plan dates response
class GetMealPlanDatesResponse {
  final List<String> dates;

  const GetMealPlanDatesResponse({required this.dates});

  factory GetMealPlanDatesResponse.fromJson(Map<String, dynamic> json) {
    return GetMealPlanDatesResponse(
      dates:
          (json['dates'] as List<dynamic>)
              .map((date) => date as String)
              .toList(),
    );
  }
}

/// INFO: Delete meal plan response
class DeleteMealPlanResponse {
  final String message;

  const DeleteMealPlanResponse({required this.message});

  factory DeleteMealPlanResponse.fromJson(Map<String, dynamic> json) {
    return DeleteMealPlanResponse(message: json['message'] as String);
  }
}

/// INFO: Simple recipe model for meal planning
class SimpleRecipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final int prepTimeMinutes;
  final int calories;
  final String difficulty;
  final List<String> dietaryTags;
  final MealType type;
  final bool isFavorite;
  final List<String>? reminders;
  final DateTime? lastUsed;

  const SimpleRecipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.prepTimeMinutes,
    required this.calories,
    required this.difficulty,
    required this.dietaryTags,
    required this.type,
    this.isFavorite = false,
    this.reminders,
    this.lastUsed,
  });

  SimpleRecipe copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? ingredients,
    int? prepTimeMinutes,
    int? calories,
    String? difficulty,
    List<String>? dietaryTags,
    MealType? type,
    bool? isFavorite,
    List<String>? reminders,
    DateTime? lastUsed,
  }) {
    return SimpleRecipe(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      calories: calories ?? this.calories,
      difficulty: difficulty ?? this.difficulty,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      reminders: reminders ?? this.reminders,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  factory SimpleRecipe.fromJson(Map<String, dynamic> json) {
    return SimpleRecipe(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
      calories: json['calories'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'Fácil',
      dietaryTags: (json['dietaryTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      type: MealType.values.firstWhere(
        (e) => e.toString() == 'MealType.${json['type']}',
        orElse: () => MealType.lunch,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'prepTimeMinutes': prepTimeMinutes,
      'calories': calories,
      'difficulty': difficulty,
      'dietaryTags': dietaryTags,
      'type': type.toString().split('.').last,
      'isFavorite': isFavorite,
      'reminders': reminders,
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }
}
