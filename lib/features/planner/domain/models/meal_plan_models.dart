/// INFO: Data models for meal planning functionality
/// ADVICE: These models match the API structure for meal planning endpoints
library;

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

  Map<String, dynamic> toJson() {
    return {
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
    if (breakfast != null) result['breakfast'] = breakfast!.toJson();
    if (lunch != null) result['lunch'] = lunch!.toJson();
    if (dinner != null) result['dinner'] = dinner!.toJson();
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
