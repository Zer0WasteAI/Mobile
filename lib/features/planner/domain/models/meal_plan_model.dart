import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_plan_model.freezed.dart';
part 'meal_plan_model.g.dart';

enum MealType { breakfast, lunch, dinner, snack }

enum MealStatus { planned, prepared, completed }

@freezed
abstract class MealPlan with _$MealPlan {
  const factory MealPlan({
    required String id,
    required DateTime date,
    required Map<String, PlannedMeal> meals,
    required DateTime createdAt,
    required DateTime updatedAt,
    required NutritionalSummary nutritionalSummary,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);
}

@freezed
abstract class PlannedMeal with _$PlannedMeal {
  const factory PlannedMeal({
    required String recipeId,
    required int servings,
    String? notes,
    Map<String, String>? modifications,
    required MealType type,
    @Default(MealStatus.planned) MealStatus status,
    DateTime? preparedAt,
    Map<String, dynamic>? impactData,
  }) = _PlannedMeal;

  factory PlannedMeal.fromJson(Map<String, dynamic> json) =>
      _$PlannedMealFromJson(json);
}

@freezed
abstract class NutritionalSummary with _$NutritionalSummary {
  const factory NutritionalSummary({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required double fiber,
    required double sugar,
  }) = _NutritionalSummary;

  factory NutritionalSummary.fromJson(Map<String, dynamic> json) =>
      _$NutritionalSummaryFromJson(json);
}
