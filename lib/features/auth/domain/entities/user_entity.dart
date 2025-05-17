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
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  /// Hash code
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        phoneNumber.hashCode ^
        emailVerified.hashCode ^
        favoriteRecipes.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode;
  }

  /// String representation
  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL, phoneNumber: $phoneNumber, emailVerified: $emailVerified, favoriteRecipes: $favoriteRecipes, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }
}
