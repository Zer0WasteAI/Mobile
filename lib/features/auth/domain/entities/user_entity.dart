import 'package:flutter/foundation.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_preferences_entity.dart';

/// User entity
class UserEntity {
  /// Constructor
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phone,
    this.emailVerified = false,
    this.favoriteRecipes = const [],
    this.prefs = const UserPreferencesEntity(),
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
  final String? phone;

  /// Whether email is verified
  final bool emailVerified;

  /// User's favorite recipes
  final List<String> favoriteRecipes;

  /// User preferences
  final UserPreferencesEntity prefs;

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
        other.phone == phone &&
        other.emailVerified == emailVerified &&
        listEquals(other.favoriteRecipes, favoriteRecipes) &&
        other.prefs == prefs &&
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
      phone,
      emailVerified,
      Object.hashAll(favoriteRecipes),
      prefs,
      initialPreferencesCompleted,
      createdAt,
      lastLoginAt,
    );
  }

  /// String representation
  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, phone: $phone, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, prefs: $prefs, initialPreferencesCompleted: $initialPreferencesCompleted, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }
}
