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

  /// Update user information after Apple Sign In when data is hidden
  Future<UserModel> updateUserAfterAppleSignIn(
    String displayName,
    String email,
  );

  /// Sign out
  Future<void> signOut();

  /// Get current user (Firebase Auth only, use getCurrentUserWithFirestore for Firestore data)
  UserModel? get currentUser;

  /// Get current user with Firestore data
  Future<UserModel?> getCurrentUserWithFirestore();

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

  /// Check if this is the user's first login
  Future<bool> isFirstTimeUser(String userId);

  /// Mark user as having completed onboarding
  Future<void> markOnboardingCompleted(String userId);

  /// Send verification email to the current user
  Future<void> sendVerificationEmail();

  /// Check if the current user's email is verified
  Future<bool> isEmailVerified();

  /// Reload the current user to get updated verification status
  Future<void> reloadUser();

  /// Save user allergies
  Future<void> saveUserAllergies(List<String> allergies);

  /// Save user special diets
  Future<void> saveUserSpecialDiets(List<String> specialDiets);

  /// Save user cooking level
  Future<void> saveUserCookingLevel(String cookingLevel);

  /// Save user preferred food types
  Future<void> saveUserPreferredFoodTypes(List<String> foodTypes);

  /// Mark user initial preferences as completed
  Future<void> markInitialPreferencesCompleted();

  /// Check if user has completed initial preferences
  Future<bool> hasCompletedInitialPreferences();

  /// Save user allergies as objects with custom flag
  Future<void> saveUserAllergyItems(List<Map<String, dynamic>> allergyItems);

  /// Save user special diets as objects with custom flag
  Future<void> saveUserSpecialDietItems(List<Map<String, dynamic>> dietItems);

  /// Save user preferred food types as objects with custom flag
  Future<void> saveUserPreferredFoodTypeItems(
    List<Map<String, dynamic>> foodTypeItems,
  );
}
