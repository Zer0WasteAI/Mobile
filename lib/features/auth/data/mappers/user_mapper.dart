import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_preferences_entity.dart';

/// Mappers between UserModel and UserEntity
extension UserModelToEntityMapper on UserModel {
  /// Convert UserModel to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      phone: phone,
      emailVerified: emailVerified,
      favoriteRecipes: favoriteRecipes,
      prefs: prefs.toEntity(),
      initialPreferencesCompleted: initialPreferencesCompleted,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }
}

/// Mappers for UserEntity
extension UserEntityToModelMapper on UserEntity {
  /// Convert UserEntity to UserModel
  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      phone: phone,
      emailVerified: emailVerified,
      favoriteRecipes: favoriteRecipes,
      prefs: prefs.toModel(),
      initialPreferencesCompleted: initialPreferencesCompleted,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }
}

/// Mappers between UserPreferencesModel and UserPreferencesEntity
extension UserPreferencesModelToEntityMapper on UserPreferencesModel {
  UserPreferencesEntity toEntity() {
    return UserPreferencesEntity(
      language: language,
      measurementUnit: measurementUnit,
      cookingLevel: cookingLevel,
      allergies: allergies,
      allergyItems: allergyItems,
      specialDiets: specialDiets,
      specialDietItems: specialDietItems,
      preferredFoodTypes: preferredFoodTypes,
      preferredFoodTypeItems: preferredFoodTypeItems,
    );
  }
}

extension UserPreferencesEntityToModelMapper on UserPreferencesEntity {
  UserPreferencesModel toModel() {
    return UserPreferencesModel(
      language: language,
      measurementUnit: measurementUnit,
      cookingLevel: cookingLevel,
      allergies: allergies,
      allergyItems: allergyItems,
      specialDiets: specialDiets,
      specialDietItems: specialDietItems,
      preferredFoodTypes: preferredFoodTypes,
      preferredFoodTypeItems: preferredFoodTypeItems,
    );
  }
}
