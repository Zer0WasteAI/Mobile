// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoURL: json['photoURL'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  favoriteRecipes:
      (json['favoriteRecipes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
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
  cookingLevel: json['cookingLevel'] as String?,
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
  initialPreferencesCompleted:
      json['initialPreferencesCompleted'] as bool? ?? false,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  needsAdditionalInfo: json['needsAdditionalInfo'] as bool? ?? false,
  providerId: json['providerId'] as String? ?? 'email',
  language: json['language'] as String? ?? 'es',
  measurementUnit: json['measurementUnit'] as String? ?? 'metric',
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'emailVerified': instance.emailVerified,
      'favoriteRecipes': instance.favoriteRecipes,
      'allergies': instance.allergies,
      'allergyItems': instance.allergyItems,
      'specialDiets': instance.specialDiets,
      'specialDietItems': instance.specialDietItems,
      'cookingLevel': instance.cookingLevel,
      'preferredFoodTypes': instance.preferredFoodTypes,
      'preferredFoodTypeItems': instance.preferredFoodTypeItems,
      'initialPreferencesCompleted': instance.initialPreferencesCompleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'needsAdditionalInfo': instance.needsAdditionalInfo,
      'providerId': instance.providerId,
      'language': instance.language,
      'measurementUnit': instance.measurementUnit,
    };
