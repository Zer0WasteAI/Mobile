import 'dart:async';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';

/// Authentication API interface
abstract class AuthApi {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Register with email, password and name
  Future<UserModel> registerWithEmailAndPassword(
    String name,
    String email,
    String password, {
    String? phone,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Facebook
  Future<UserModel> signInWithFacebook();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /*
  /// Verify reset code
  Future<bool> verifyResetCode(String email, String code);

  /// Reset password with code
  Future<void> resetPassword(String email, String code, String newPassword);
  */
}

// ✅ REMOVED: MockAuthApi dead code eliminated (200+ lines)
// Authentication now uses real Firebase + Backend API implementation

/// Extension methods for UserModel
extension UserModelExtension on UserModel {
  /// Create a copy of this UserModel with some fields replaced
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phone,
    bool? emailVerified,
    List<String>? favoriteRecipes,
    UserPreferencesModel? prefs,
    bool? initialPreferencesCompleted,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? needsAdditionalInfo,
    String? providerId,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      emailVerified: emailVerified ?? this.emailVerified,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      prefs: prefs ?? this.prefs,
      initialPreferencesCompleted:
          initialPreferencesCompleted ?? this.initialPreferencesCompleted,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      needsAdditionalInfo: needsAdditionalInfo ?? this.needsAdditionalInfo,
      providerId: providerId ?? this.providerId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
