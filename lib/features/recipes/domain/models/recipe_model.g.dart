// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  emoji: json['emoji'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>).map((e) => e as String).toList(),
  requiredIngredientsCount: (json['requiredIngredientsCount'] as num).toInt(),
  availableIngredientsCount: (json['availableIngredientsCount'] as num).toInt(),
  usesExpiringItems: json['usesExpiringItems'] as bool,
  cookingTime: (json['cookingTime'] as num).toInt(),
  difficulty: json['difficulty'] as String,
  dietType: json['dietType'] as String,
  categories:
      (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'emoji': instance.emoji,
  'ingredients': instance.ingredients,
  'requiredIngredientsCount': instance.requiredIngredientsCount,
  'availableIngredientsCount': instance.availableIngredientsCount,
  'usesExpiringItems': instance.usesExpiringItems,
  'cookingTime': instance.cookingTime,
  'difficulty': instance.difficulty,
  'dietType': instance.dietType,
  'categories': instance.categories,
};
