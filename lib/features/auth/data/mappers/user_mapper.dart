import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';

/// Mappers between UserModel and UserEntity
extension UserModelToEntityMapper on UserModel {
  /// Convert UserModel to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      favoriteRecipes: favoriteRecipes,
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
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      favoriteRecipes: favoriteRecipes,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
