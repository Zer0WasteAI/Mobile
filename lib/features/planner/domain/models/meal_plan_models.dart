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
    // Debug: Print ingredient JSON
    print('--- MealIngredient.fromJson ---');
    print('Ingredient JSON: $json');
    
    // Parse quantity properly - can be integer, double, string, or null
    int quantity = 1;
    
    if (json['quantity'] != null) {
      if (json['quantity'] is int) {
        quantity = json['quantity'] as int;
      } else if (json['quantity'] is double) {
        quantity = (json['quantity'] as double).toInt();
      } else if (json['quantity'] is String) {
        quantity = int.tryParse(json['quantity'] as String) ?? 1;
      }
    }
    
    final ingredient = MealIngredient(
      name: (json['name'] ?? '') as String,
      quantity: quantity,
      unit: (json['type_unit'] ?? json['unit'] ?? '') as String, // Support both formats
    );
    
    print('Parsed ingredient: ${ingredient.toString()}');
    print('--- End MealIngredient.fromJson ---');
    
    return ingredient;
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'type_unit': unit};
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
  final List<String> instructions;

  const Meal({
    required this.recipeTitle,
    required this.ingredientsNeeded,
    required this.prepTime,
    required this.calories,
    this.instructions = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Debug: Print raw JSON to see backend response
    print('=== MEAL.fromJson DEBUG ===');
    print('Raw JSON: $json');
    print('Available keys: ${json.keys.toList()}');
    
    List<dynamic> ingredients = [];
    
    if (json['ingredients_needed'] != null) {
      ingredients = json['ingredients_needed'] as List<dynamic>;
    } else if (json['ingredients'] != null) {
      ingredients = json['ingredients'] as List<dynamic>;
    }
    
    // Parse calories properly - can be integer, double, string, or null
    int calories = 250; // Valor predeterminado de calorías
    if (json['calories'] != null) {
      if (json['calories'] is int) {
        calories = json['calories'] as int;
      } else if (json['calories'] is double) {
        calories = (json['calories'] as double).toInt();
      } else if (json['calories'] is String) {
        calories = int.tryParse(json['calories'] as String) ?? 250;
      }
    }
    
    // Parse prep_time properly - can be integer, double, string, or null
    int prepTime = 30; // Valor predeterminado de tiempo de preparación
    if (json['prep_time'] != null) {
      if (json['prep_time'] is int) {
        prepTime = json['prep_time'] as int;
      } else if (json['prep_time'] is double) {
        prepTime = (json['prep_time'] as double).toInt();
      } else if (json['prep_time'] is String) {
        prepTime = int.tryParse(json['prep_time'] as String) ?? 30;
      }
    } else if (json['duration'] != null) {
      if (json['duration'] is int) {
        prepTime = json['duration'] as int;
      } else if (json['duration'] is double) {
        prepTime = (json['duration'] as double).toInt();
      } else if (json['duration'] is String) {
        prepTime = int.tryParse(json['duration'] as String) ?? 30;
      }
    }
    
    // Parse instructions/steps from backend
    List<String> instructions = [];
    print('Looking for instructions/steps...');
    if (json['steps'] != null) {
      print('Found steps: ${json['steps']}');
      final steps = json['steps'] as List<dynamic>;
      instructions = steps.map((step) {
        if (step is Map<String, dynamic>) {
          return step['description']?.toString() ?? '';
        }
        return step.toString();
      }).where((instruction) => instruction.isNotEmpty).toList();
    } else if (json['instructions'] != null) {
      print('Found instructions: ${json['instructions']}');
      instructions = (json['instructions'] as List<dynamic>)
          .map((instruction) => instruction.toString())
          .where((instruction) => instruction.isNotEmpty)
          .toList();
    } else {
      print('No instructions or steps found in JSON');
    }
    print('Parsed instructions: $instructions');
    
    final meal = Meal(
      recipeTitle: (json['recipe_title'] ?? json['title'] ?? '') as String,
      ingredientsNeeded: ingredients
          .map<MealIngredient>((ingredient) {
            // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
            final Map<String, dynamic> ingredientMap = Map<String, dynamic>.from(ingredient as Map);
            return MealIngredient.fromJson(ingredientMap);
          })
          .toList(),
      prepTime: prepTime,
      calories: calories,
      instructions: instructions,
    );
    print('=== END MEAL.fromJson DEBUG ===');
    
    return meal;
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
        'type_unit': ingredient.unit, // Backend expects type_unit not unit
      }).toList(),
      'steps': instructions.isNotEmpty 
          ? instructions.asMap().entries.map((entry) => {
              'step_order': entry.key + 1,
              'description': entry.value,
            }).toList()
          : [{'step_order': 1, 'description': 'Preparar según receta'}], // Proper step format
      'generated_by_ai': true,
      'category': getCategory(mealType), // Dynamic category based on meal type
      'description': 'Receta generada por IA',
      
      // Keep original format for compatibility
      'recipe_title': recipeTitle,
      'ingredients_needed':
          ingredientsNeeded.map((ingredient) => ingredient.toJson()).toList(),
      'prep_time': prepTime,
      'calories': calories,
      'instructions': instructions,
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
    // Debug para ver el contenido del JSON
    print('[DEBUG] DailyMeals.fromJson: ${json.keys}');
    
    return DailyMeals(
      breakfast:
          json['breakfast'] != null
              ? Meal.fromJson(Map<String, dynamic>.from(json['breakfast'] as Map))
              : null,
      lunch:
          json['lunch'] != null
              ? Meal.fromJson(Map<String, dynamic>.from(json['lunch'] as Map))
              : null,
      dinner:
          json['dinner'] != null
              ? Meal.fromJson(Map<String, dynamic>.from(json['dinner'] as Map))
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

  @override
  String toString() {
    return 'DailyMeals(breakfast: ${breakfast != null}, lunch: ${lunch != null}, dinner: ${dinner != null})';
  }

  /// INFO: Calculate total calories for the day
  int get totalCalories {
    int total = 0;
    if (breakfast != null) {
      print('[DEBUG] Breakfast calories: ${breakfast!.calories}');
      total += breakfast!.calories;
    }
    if (lunch != null) {
      print('[DEBUG] Lunch calories: ${lunch!.calories}');
      total += lunch!.calories;
    }
    if (dinner != null) {
      print('[DEBUG] Dinner calories: ${dinner!.calories}');
      total += dinner!.calories;
    }
    print('[DEBUG] Total calories calculated: $total');
    return total;
  }

  /// INFO: Get all meals as a list (non-null meals only)
  List<Meal> get allMeals {
    print('[DEBUG] Checking all meals in DailyMeals');
    print('[DEBUG] Breakfast: ${breakfast != null}');
    print('[DEBUG] Lunch: ${lunch != null}');
    print('[DEBUG] Dinner: ${dinner != null}');
    
    final List<Meal> meals = [];
    if (breakfast != null) {
      print('[DEBUG] Adding breakfast to allMeals: ${breakfast!.recipeTitle}');
      meals.add(breakfast!);
    }
    if (lunch != null) {
      print('[DEBUG] Adding lunch to allMeals: ${lunch!.recipeTitle}');
      meals.add(lunch!);
    }
    if (dinner != null) {
      print('[DEBUG] Adding dinner to allMeals: ${dinner!.recipeTitle}');
      meals.add(dinner!);
    }
    print('[DEBUG] Total meals collected: ${meals.length}');
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
    // Debug para ver el contenido completo que recibimos
    print('[DEBUG] MealPlanModel.fromJson: ${json.keys}');
    
    // Crear DailyMeals
    DailyMeals meals = DailyMeals.fromJson(
      json['meals'] != null 
      ? Map<String, dynamic>.from(json['meals'] as Map)
      : {}
    );
    
    // Calcular calorías manualmente en caso de que no vengan en el JSON
    int totalCalories = json['total_calories'] != null 
        ? (json['total_calories'] is int 
            ? json['total_calories'] as int 
            : int.tryParse(json['total_calories'].toString()) ?? meals.totalCalories)
        : meals.totalCalories;
    
    // Asegurar que el UID no sea vacío
    String uid = (json['uid'] ?? '').toString();
    if (uid.isEmpty) {
      uid = "plan_${json['date'] ?? DateTime.now().toString()}";
    }
    
    return MealPlanModel(
      uid: uid,
      date: (json['date'] ?? '') as String,
      meals: meals,
      totalCalories: totalCalories,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
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

  @override
  String toString() {
    return 'MealPlanModel(uid: $uid, date: $date, meals: $meals, totalCalories: $totalCalories)';
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
        Map<String, dynamic>.from(json['meal_plan'] as Map),
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
                Map<String, dynamic>.from(json['meal_plan'] as Map),
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
                (plan) => MealPlanModel.fromJson(Map<String, dynamic>.from(plan as Map)),
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
