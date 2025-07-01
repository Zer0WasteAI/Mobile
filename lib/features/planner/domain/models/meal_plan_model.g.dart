// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => _MealPlan(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  meals: (json['meals'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, PlannedMeal.fromJson(e as Map<String, dynamic>)),
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  nutritionalSummary: NutritionalSummary.fromJson(
    json['nutritionalSummary'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MealPlanToJson(_MealPlan instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'meals': instance.meals,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'nutritionalSummary': instance.nutritionalSummary,
};

_PlannedMeal _$PlannedMealFromJson(Map<String, dynamic> json) => _PlannedMeal(
  recipeId: json['recipeId'] as String,
  servings: (json['servings'] as num).toInt(),
  notes: json['notes'] as String?,
  modifications: (json['modifications'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  type: $enumDecode(_$MealTypeEnumMap, json['type']),
);

Map<String, dynamic> _$PlannedMealToJson(_PlannedMeal instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'servings': instance.servings,
      'notes': instance.notes,
      'modifications': instance.modifications,
      'type': _$MealTypeEnumMap[instance.type]!,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};

_NutritionalSummary _$NutritionalSummaryFromJson(Map<String, dynamic> json) =>
    _NutritionalSummary(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionalSummaryToJson(_NutritionalSummary instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fats': instance.fats,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
    };
