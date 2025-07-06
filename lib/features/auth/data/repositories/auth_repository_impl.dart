import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/core/services/secure_token_service.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final ApiService _apiService;
  final SecureTokenService _secureTokenService;

  /// Constructor
  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
    ApiService? apiService,
    SecureTokenService? secureTokenService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance,
       _apiService = apiService ?? ApiService.instance,
       _secureTokenService = secureTokenService ?? SecureTokenService();

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      log(
        '🔐 AuthRepository: Starting email/password authentication for: $email',
      );

      // 1. Authenticate with Firebase
      log('🔍 Step 1: Authenticating with Firebase...');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('✅ Firebase authentication successful');

      // 2. Get Firebase ID Token
      log('🔍 Step 2: Getting Firebase ID token...');
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      // INFO: Debug token structure (without exposing the actual token)
      log('✅ Firebase ID token obtained');
      log('🔧 Token length: ${firebaseIdToken.length} characters');
      log(
        '🔧 Token structure: ${firebaseIdToken.split('.').length} parts (should be 3)',
      );
      log('🔧 User UID: ${userCredential.user!.uid}');
      log('🔧 User email: ${userCredential.user!.email}');
      log('🔧 Email verified: ${userCredential.user!.emailVerified}');

      // INFO: Additional Firebase token validation
      if (firebaseIdToken.split('.').length != 3) {
        log('❌ Invalid Firebase token structure! Not a valid JWT.');
        throw Exception('Invalid Firebase ID token structure');
      }

      // 3. Exchange Firebase token for backend JWT tokens
      log('🔍 Step 3: Exchanging Firebase token for backend JWT tokens...');
      final backendResponse = await _apiService.firebaseSignIn(firebaseIdToken);
      log('✅ Backend JWT tokens obtained successfully');

      // 4. Create UserModel with tokens
      log('🔍 Step 4: Creating user model...');
      final userModel = UserModel.fromFirebaseAuthAndBackendSignInResponse(
        backendResponse,
        firebaseUid: userCredential.user!.uid,
        firebaseEmail: userCredential.user!.email ?? '',
        firebaseEmailVerified: userCredential.user!.emailVerified,
        firebaseProviderId: 'email',
      );

      // 5. Store tokens securely
      log('🔍 Step 5: Storing tokens securely...');
      await _secureTokenService.storeTokens(
        accessToken: backendResponse['access_token'] as String,
        refreshToken: backendResponse['refresh_token'] as String,
        expiresIn: backendResponse['expires_in'] as int?,
      );

      log('🎉 Email/password authentication completed successfully!');
      return userModel;
    } catch (e) {
      log('❌ Email/password authentication failed: ${e.toString()}');
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      // 1. Create Firebase user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update Firebase display name
      await userCredential.user?.updateDisplayName(displayName);

      // 3. Create user in Firestore
      await _createUserInFirestore(userCredential.user!, displayName);

      // 4. Get Firebase ID Token
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      // 5. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(firebaseIdToken);

      // 6. Create UserModel with tokens
      final userModel = UserModel.fromFirebaseAuthAndBackendSignInResponse(
        backendResponse,
        firebaseUid: userCredential.user!.uid,
        firebaseEmail: userCredential.user!.email ?? '',
        firebaseEmailVerified: userCredential.user!.emailVerified,
        firebaseProviderId: 'email',
      );

      // 7. Store tokens securely
      await _secureTokenService.storeTokens(
        accessToken: backendResponse['access_token'] as String,
        refreshToken: backendResponse['refresh_token'] as String,
        expiresIn: backendResponse['expires_in'] as int?,
      );

      return userModel;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Authenticate with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // 3. Create/update user in Firestore
      await _createUserInFirestore(
        userCredential.user!,
        googleUser.displayName,
      );

      // 4. Get Firebase ID Token
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      // 5. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(firebaseIdToken);

      // 6. Create UserModel with tokens
      final userModel = UserModel.fromFirebaseAuthAndBackendSignInResponse(
        backendResponse,
        firebaseUid: userCredential.user!.uid,
        firebaseEmail: userCredential.user!.email ?? '',
        firebaseEmailVerified: userCredential.user!.emailVerified,
        firebaseProviderId: 'google',
      );

      // 7. Store tokens securely
      await _secureTokenService.storeTokens(
        accessToken: backendResponse['access_token'] as String,
        refreshToken: backendResponse['refresh_token'] as String,
        expiresIn: backendResponse['expires_in'] as int?,
      );

      return userModel;
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // 1. Authenticate with Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 2. Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      // 3. Create/update user in Firestore
      await _createUserInFirestore(
        userCredential.user!,
        appleCredential.givenName,
      );

      // 4. Get Firebase ID Token
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      // 5. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(firebaseIdToken);

      // 6. Create UserModel with tokens
      final userModel = UserModel.fromFirebaseAuthAndBackendSignInResponse(
        backendResponse,
        firebaseUid: userCredential.user!.uid,
        firebaseEmail: userCredential.user!.email ?? '',
        firebaseEmailVerified: userCredential.user!.emailVerified,
        firebaseProviderId: 'apple',
      );

      // 7. Store tokens securely
      await _secureTokenService.storeTokens(
        accessToken: backendResponse['access_token'] as String,
        refreshToken: backendResponse['refresh_token'] as String,
        expiresIn: backendResponse['expires_in'] as int?,
      );

      return userModel;
    } catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // 1. Attempt Facebook login
      log('Iniciando login con Facebook...');
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      log('Estado de login Facebook: ${result.status}');

      if (result.status == LoginStatus.cancelled) {
        log('Login cancelado por el usuario');
        throw Exception('Login de Facebook cancelado por el usuario');
      } else if (result.status == LoginStatus.failed) {
        log('Error de login Facebook: ${result.message}');
        throw Exception('Login de Facebook falló: ${result.message}');
      } else if (result.status != LoginStatus.success) {
        log('Estado de login inesperado: ${result.status}');
        throw Exception(
          'Estado de login de Facebook inesperado: ${result.status}',
        );
      }

      if (result.accessToken == null) {
        log('Access token de Facebook es nulo');
        throw Exception('Token de acceso de Facebook es nulo');
      }

      log('Login Facebook exitoso, token obtenido');

      try {
        // 2. Get Firebase credential
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        log(
          'Credencial Facebook creada, intentando autenticación en Firebase...',
        );

        // 3. Sign in with Firebase
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );

        log('Autenticación Firebase exitosa, obteniendo datos de usuario...');

        // 4. Get Facebook user data
        final userData = await _facebookAuth.getUserData();
        log('Datos de usuario obtenidos: ${userData['name']}');

        // 5. Create/update user in Firestore
        await _createUserInFirestore(
          userCredential.user!,
          userData['name'] as String,
        );

        // 6. Get Firebase ID Token
        final firebaseIdToken = await userCredential.user?.getIdToken();
        if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
          throw Exception('Failed to get Firebase ID token');
        }

        // 7. Exchange Firebase token for backend JWT tokens
        final backendResponse = await _apiService.firebaseSignIn(
          firebaseIdToken,
        );

        // 8. Create UserModel with tokens
        final userModel = UserModel.fromFirebaseAuthAndBackendSignInResponse(
          backendResponse,
          firebaseUid: userCredential.user!.uid,
          firebaseEmail: userCredential.user!.email ?? '',
          firebaseEmailVerified: userCredential.user!.emailVerified,
          firebaseProviderId: 'facebook',
        );

        // 9. Store tokens securely
        await _secureTokenService.storeTokens(
          accessToken: backendResponse['access_token'] as String,
          refreshToken: backendResponse['refresh_token'] as String,
          expiresIn: backendResponse['expires_in'] as int?,
        );

        return userModel;
      } catch (firebaseError) {
        log('Error de autenticación Firebase: $firebaseError');
        await _facebookAuth.logOut();
        throw Exception('Error al autenticar con Firebase: $firebaseError');
      }
    } catch (e, stackTrace) {
      log('=== ERROR DE LOGIN FACEBOOK ===');
      log('Error detallado: $e');
      log('Stack trace: $stackTrace');
      log('=============================');

      try {
        await _facebookAuth.logOut();
      } catch (logoutError) {
        log('Error al hacer logout de Facebook: $logoutError');
      }

      throw Exception('Failed to sign in with Facebook: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // 1. Logout from backend
      await _apiService.logout();

      // 2. Clear secure tokens
      await _secureTokenService.clearTokens();

      // 3. Sign out from all providers
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      // Even if backend logout fails, still clear local tokens and sign out
      await _secureTokenService.clearTokens();
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      log('Warning: Logout may not have completed fully: ${e.toString()}');
    }
  }

  @override
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    
    // Note: This is a synchronous getter, so we can't await Firestore data
    // For real-time updates with Firestore data, use authStateChanges stream
    // For synchronous access with Firestore data, call refreshUserFromFirestore() first
    return _getUserModelFromFirebaseUser(user);
  }

  /// Get current user with complete Firestore data (async)
  @override
  Future<UserModel?> getCurrentUserWithFirestore() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    
    return await _getUserModelFromFirebaseUserWithFirestore(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      return user != null
          ? await _getUserModelFromFirebaseUserWithFirestore(user)
          : null;
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      // Firebase doesn't have a built-in way to verify reset codes
      // This would typically be implemented with a custom backend
      throw UnimplementedError(
        'Verification code validation requires a custom backend implementation',
      );
    } catch (e) {
      throw Exception('Failed to verify reset code: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      // Firebase doesn't directly support code-based password reset
      throw UnimplementedError(
        'Password reset with code verification requires a custom backend implementation',
      );
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // 1. Update Firebase profile
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // 2. Update Firestore (profile data stays in Firestore only)
        await _updateUserInFirestore(user.uid, displayName, photoURL);

        // NOTE: Profile updates are Firestore-only, no backend calls needed
        log('✅ Profile updated successfully in Firebase & Firestore');
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // 1. Clear tokens
        await _secureTokenService.clearTokens();

        // 2. Delete from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // 3. Delete Firebase user
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  Future<void> _createUserInFirestore(User user, String? displayName) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final userData = {
      'id': user.uid,
      'email': user.email,
      'displayName': displayName ?? user.displayName,
      'photoURL': user.photoURL,
      'phone': user.phoneNumber,
      'emailVerified': user.emailVerified,
      'favoriteRecipes': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    await userDoc.set(userData, SetOptions(merge: true));
  }

  Future<void> _updateUserInFirestore(
    String uid,
    String? displayName,
    String? photoURL,
  ) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoURL != null) updates['photoURL'] = photoURL;
    updates['lastLoginAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(uid).update(updates);
  }

  UserModel _getUserModelFromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      phone: user.phoneNumber,
      emailVerified: user.emailVerified,
    );
  }

  Future<UserModel> _getUserModelFromFirebaseUserWithFirestore(
    User user,
  ) async {
    try {
      log('🔍 Loading user data from Firestore for UID: ${user.uid}');

      // Try to get user data from Firestore first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        log('✅ User document found in Firestore');
        log('🔧 Firestore data keys: ${userData.keys.toList()}');

        // Log the preference data specifically
        log('🔧 cookingLevel: ${userData['cookingLevel']}');
        log('🔧 allergies: ${userData['allergies']}');
        log('🔧 specialDiets: ${userData['specialDiets']}');
        log('🔧 preferredFoodTypes: ${userData['preferredFoodTypes']}');

        // Build UserPreferencesModel from Firestore data
        final prefs = UserPreferencesModel(
          language: userData['language'] as String? ?? 'es',
          cookingLevel: userData['cookingLevel'] as String?,
          allergies:
              (userData['allergies'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          allergyItems:
              (userData['allergyItems'] as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [],
          specialDiets:
              (userData['specialDiets'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          specialDietItems:
              (userData['specialDietItems'] as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [],
          preferredFoodTypes:
              (userData['preferredFoodTypes'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          preferredFoodTypeItems:
              (userData['preferredFoodTypeItems'] as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [],
        );

        log(
          '🔧 Built UserPreferencesModel - cookingLevel: ${prefs.cookingLevel}',
        );

        return UserModel(
          id: user.uid,
          email: userData['email'] as String? ?? user.email ?? '',
          displayName: userData['displayName'] as String? ?? user.displayName,
          photoURL: userData['photoURL'] as String? ?? user.photoURL,
          phone: user.phoneNumber,
          emailVerified: user.emailVerified,
          favoriteRecipes:
              (userData['favoriteRecipes'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          prefs: prefs,
          initialPreferencesCompleted:
              userData['initialPreferencesCompleted'] as bool? ?? false,
          createdAt:
              userData['createdAt'] != null
                  ? (userData['createdAt'] as Timestamp).toDate()
                  : null,
          lastLoginAt:
              userData['lastLoginAt'] != null
                  ? (userData['lastLoginAt'] as Timestamp).toDate()
                  : null,
        );
      } else {
        log('❌ User document NOT found in Firestore');
      }
    } catch (e) {
      log('❌ Error loading user data from Firestore: $e');
    }

    // Fallback to Firebase Auth data only
    log('⚠️ Fallback: Using Firebase Auth data only (no Firestore data)');
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      phone: user.phoneNumber,
      emailVerified: user.emailVerified,
    );
  }

  // User preference methods implementation
  @override
  Future<void> saveUserCookingLevel(String cookingLevel) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'cookingLevel': cookingLevel,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save cooking level: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserLanguage(String language) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'language': language,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save language: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserPreferredFoodTypes(List<String> foodTypes) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'preferredFoodTypes': foodTypes,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save preferred food types: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserAllergyItems(List<String> allergyItems) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'allergyItems': allergyItems,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save allergy items: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserSpecialDietItems(List<String> specialDietItems) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'specialDietItems': specialDietItems,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save special diet items: ${e.toString()}');
    }
  }

  @override
  Future<void> markInitialPreferencesCompleted() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'initialPreferencesCompleted': true,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to mark preferences completed: ${e.toString()}');
    }
  }

  @override
  Future<void> refreshUserFromFirestore() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // 1. Get fresh Firebase ID token
        log('🔄 Getting fresh Firebase ID token...');
        final firebaseIdToken = await user.getIdToken(true); // Force refresh
        
        if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
          throw Exception('Failed to get Firebase ID token');
        }
        
        // 2. Exchange Firebase token for new JWT tokens
        log('🔄 Exchanging Firebase token for new JWT tokens...');
        final backendResponse = await _apiService.firebaseSignIn(firebaseIdToken);
        
        // 3. Update local Firestore with backend profile data if available
        if (backendResponse.containsKey('profile')) {
          final profile = backendResponse['profile'] as Map<String, dynamic>;
          final initialPreferencesCompleted = profile['initialPreferencesCompleted'] as bool? ?? false;
          
          log('🔄 Updating Firestore with backend profile data...');
          log('🔧 Backend says initialPreferencesCompleted: $initialPreferencesCompleted');
          
          // Update Firestore to match backend state
          await _firestore.collection('users').doc(user.uid).update({
            'initialPreferencesCompleted': initialPreferencesCompleted,
            'lastUpdatedAt': FieldValue.serverTimestamp(),
          });
          
          log('✅ Firestore updated to match backend state');
        }
        
        // 4. Force refresh the user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          log('✅ User data and tokens refreshed successfully');
        }
      }
    } catch (e) {
      log('❌ Failed to refresh user from Firestore: $e');
      throw Exception('Failed to refresh user from Firestore: ${e.toString()}');
    }
  }

  @override
  Future<void> refreshApplicationTokens() async {
    try {
      log('🔄 AuthRepository: Starting token refresh process...');

      // Use the ApiService to refresh tokens
      final newAccessToken = await _apiService.refreshTokens();
      if (newAccessToken == null) {
        log('❌ Token refresh failed - no new access token received');
        throw Exception(
          'Failed to refresh tokens - no new access token received',
        );
      }
      log('🎉 AuthRepository: Application tokens refreshed successfully!');
    } catch (e) {
      log('❌ AuthRepository: Token refresh failed - ${e.toString()}');
      throw Exception('Failed to refresh tokens: ${e.toString()}');
    }
  }

  // Complex preference methods with emoji and metadata
  @override
  Future<void> saveUserAllergyItemsWithMetadata(
    List<Map<String, dynamic>> allergyItems,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Extract simple names for legacy field
        final List<String> simpleAllergies =
            allergyItems.map((item) => item['name'] as String).toList();

        await _firestore.collection('users').doc(user.uid).update({
          'allergyItems':
              allergyItems, // Complex structure with emoji, isCustom
          'allergies': simpleAllergies, // Legacy simple list
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception(
        'Failed to save allergy items with metadata: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveUserSpecialDietItemsWithMetadata(
    List<Map<String, dynamic>> specialDietItems,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Extract simple names for legacy field
        final List<String> simpleSpecialDiets =
            specialDietItems.map((item) => item['name'] as String).toList();

        await _firestore.collection('users').doc(user.uid).update({
          'specialDietItems':
              specialDietItems, // Complex structure with emoji, isCustom
          'specialDiets': simpleSpecialDiets, // Legacy simple list
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception(
        'Failed to save special diet items with metadata: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveUserPreferredFoodTypeItemsWithMetadata(
    List<Map<String, dynamic>> foodTypeItems,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Extract simple names for legacy field
        final List<String> simpleFoodTypes =
            foodTypeItems.map((item) => item['name'] as String).toList();

        await _firestore.collection('users').doc(user.uid).update({
          'preferredFoodTypeItems':
              foodTypeItems, // Complex structure with emoji, isCustom
          'preferredFoodTypes': simpleFoodTypes, // Legacy simple list
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception(
        'Failed to save preferred food type items with metadata: ${e.toString()}',
      );
    }
  }
}
