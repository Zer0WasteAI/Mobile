import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);

  /// Register with email, password and name
  Future<UserEntity> registerWithEmailAndPassword(String name, String email, String password, {String? phone});

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Sign in with Facebook
  Future<UserEntity> signInWithFacebook();

  /// Sign in with Apple
  Future<UserEntity> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Verify reset code
  Future<bool> verifyResetCode(String email, String code);

  /// Reset password with code
  Future<void> resetPassword(String email, String code, String newPassword);
}
