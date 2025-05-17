import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  );

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Facebook
  Future<UserModel> signInWithFacebook();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  UserModel? get currentUser;

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Verify reset code
  Future<bool> verifyResetCode(String email, String code);

  /// Reset password with verification code
  Future<void> resetPassword(String email, String code, String newPassword);

  /// Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL});

  /// Delete account
  Future<void> deleteAccount();
}
