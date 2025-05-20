import 'package:flutter/foundation.dart';

/// User entity
class UserEntity {
  /// Constructor
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.emailVerified = false,
    this.favoriteRecipes = const [],
    this.allergies = const [],
    this.allergyItems = const [],
    this.specialDiets = const [],
    this.specialDietItems = const [],
    this.cookingLevel,
    this.preferredFoodTypes = const [],
    this.preferredFoodTypeItems = const [],
    this.initialPreferencesCompleted = false,
    this.createdAt,
    this.lastLoginAt,
  });

  /// User ID
  final String id;

  /// User email
  final String email;

  /// User display name
  final String? displayName;

  /// User photo URL
  final String? photoURL;

  /// User phone number
  final String? phoneNumber;

  /// Whether email is verified
  final bool emailVerified;

  /// User's favorite recipes
  final List<String> favoriteRecipes;

  /// User's allergies (legacy)
  final List<String> allergies;

  /// User's allergies items with custom metadata
  final List<Map<String, dynamic>> allergyItems;

  /// User's special diets (legacy)
  final List<String> specialDiets;

  /// User's special diet items with custom metadata
  final List<Map<String, dynamic>> specialDietItems;

  /// User's cooking level
  final String? cookingLevel;

  /// User's preferred food types (legacy)
  final List<String> preferredFoodTypes;

  /// User's preferred food type items with custom metadata
  final List<Map<String, dynamic>> preferredFoodTypeItems;

  /// Whether initial preferences setup is completed
  final bool initialPreferencesCompleted;

  /// User created date
  final DateTime? createdAt;

  /// User last login date
  final DateTime? lastLoginAt;

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.phoneNumber == phoneNumber &&
        other.emailVerified == emailVerified &&
        listEquals(other.favoriteRecipes, favoriteRecipes) &&
        listEquals(other.allergies, allergies) &&
        listEquals(other.specialDiets, specialDiets) &&
        other.cookingLevel == cookingLevel &&
        listEquals(other.preferredFoodTypes, preferredFoodTypes) &&
        other.initialPreferencesCompleted == initialPreferencesCompleted &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  /// Hash code
  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      displayName,
      photoURL,
      phoneNumber,
      emailVerified,
      Object.hashAll(favoriteRecipes),
      Object.hashAll(allergies),
      Object.hashAll(specialDiets),
      cookingLevel,
      Object.hashAll(preferredFoodTypes),
      initialPreferencesCompleted,
      createdAt,
      lastLoginAt,
    );
  }

  /// String representation
  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, phoneNumber: $phoneNumber, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, allergies: $allergies, specialDiets: $specialDiets, cookingLevel: $cookingLevel, preferredFoodTypes: $preferredFoodTypes, initialPreferencesCompleted: $initialPreferencesCompleted, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }
}
