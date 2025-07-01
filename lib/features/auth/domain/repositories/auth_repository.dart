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

  // User preference methods
  /// Save user cooking level
  Future<void> saveUserCookingLevel(String cookingLevel);

  /// Save user language
  Future<void> saveUserLanguage(String language);

  /// Save user preferred food types
  Future<void> saveUserPreferredFoodTypes(List<String> foodTypes);

  /// Save user allergy items (simple list)
  Future<void> saveUserAllergyItems(List<String> allergyItems);

  /// Save user special diet items (simple list)
  Future<void> saveUserSpecialDietItems(List<String> specialDietItems);

  /// Mark initial preferences completed
  Future<void> markInitialPreferencesCompleted();

  /// Refresh user data from Firestore
  Future<void> refreshUserFromFirestore();

  /// Refresh application tokens
  Future<void> refreshApplicationTokens();

  // Complex preference methods with emoji and metadata
  /// Save user allergy items with emoji and isCustom flag
  Future<void> saveUserAllergyItemsWithMetadata(
    List<Map<String, dynamic>> allergyItems,
  );

  /// Save user special diet items with emoji and isCustom flag
  Future<void> saveUserSpecialDietItemsWithMetadata(
    List<Map<String, dynamic>> specialDietItems,
  );

  /// Save user preferred food type items with emoji and isCustom flag
  Future<void> saveUserPreferredFoodTypeItemsWithMetadata(
    List<Map<String, dynamic>> foodTypeItems,
  );
}
