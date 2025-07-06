// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreferencesModel _$UserPreferencesModelFromJson(
  Map<String, dynamic> json,
) => _UserPreferencesModel(
  language: json['language'] as String? ?? 'es',
  measurementUnit: json['measurementUnit'] as String? ?? 'metric',
  cookingLevel: json['cookingLevel'] as String?,
  allergies:
      (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  allergyItems:
      (json['allergyItems'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  specialDiets:
      (json['specialDiets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  specialDietItems:
      (json['specialDietItems'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  preferredFoodTypes:
      (json['preferredFoodTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preferredFoodTypeItems:
      (json['preferredFoodTypeItems'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserPreferencesModelToJson(
  _UserPreferencesModel instance,
) => <String, dynamic>{
  'language': instance.language,
  'measurementUnit': instance.measurementUnit,
  'cookingLevel': instance.cookingLevel,
  'allergies': instance.allergies,
  'allergyItems': instance.allergyItems,
  'specialDiets': instance.specialDiets,
  'specialDietItems': instance.specialDietItems,
  'preferredFoodTypes': instance.preferredFoodTypes,
  'preferredFoodTypeItems': instance.preferredFoodTypeItems,
};
