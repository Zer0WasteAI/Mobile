import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
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
      // 1. Authenticate with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Get Firebase ID Token
      final firebaseIdToken = await userCredential.user!.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      // 3. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(
        firebaseIdToken!,
      );

      // 4. Create UserModel with tokens
      final userModel = UserModel.fromFirebaseAuthAndBackendSignInResponse(
        backendResponse,
        firebaseUid: userCredential.user!.uid,
        firebaseEmail: userCredential.user!.email ?? '',
        firebaseEmailVerified: userCredential.user!.emailVerified,
        firebaseProviderId: 'email',
      );

      // 5. Store tokens securely
      await _secureTokenService.storeTokens(
        accessToken: backendResponse['access_token'] as String,
        refreshToken: backendResponse['refresh_token'] as String,
        expiresIn: backendResponse['expires_in'] as int?,
      );

      return userModel;
    } catch (e) {
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
      final firebaseIdToken = await userCredential.user!.getIdToken();

      // 5. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(
        firebaseIdToken!,
      );

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
      final firebaseIdToken = await userCredential.user!.getIdToken();

      // 5. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(
        firebaseIdToken!,
      );

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
      final firebaseIdToken = await userCredential.user!.getIdToken();

      // 5. Exchange Firebase token for backend JWT tokens
      final backendResponse = await _apiService.firebaseSignIn(
        firebaseIdToken!,
      );

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
      print('Iniciando login con Facebook...');
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      print('Estado de login Facebook: ${result.status}');

      if (result.status == LoginStatus.cancelled) {
        print('Login cancelado por el usuario');
        throw Exception('Login de Facebook cancelado por el usuario');
      } else if (result.status == LoginStatus.failed) {
        print('Error de login Facebook: ${result.message}');
        throw Exception('Login de Facebook falló: ${result.message}');
      } else if (result.status != LoginStatus.success) {
        print('Estado de login inesperado: ${result.status}');
        throw Exception(
          'Estado de login de Facebook inesperado: ${result.status}',
        );
      }

      if (result.accessToken == null) {
        print('Access token de Facebook es nulo');
        throw Exception('Token de acceso de Facebook es nulo');
      }

      print('Login Facebook exitoso, token obtenido');

      try {
        // 2. Get Firebase credential
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        print(
          'Credencial Facebook creada, intentando autenticación en Firebase...',
        );

        // 3. Sign in with Firebase
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );

        print('Autenticación Firebase exitosa, obteniendo datos de usuario...');

        // 4. Get Facebook user data
        final userData = await _facebookAuth.getUserData();
        print('Datos de usuario obtenidos: ${userData['name']}');

        // 5. Create/update user in Firestore
        await _createUserInFirestore(
          userCredential.user!,
          userData['name'] as String,
        );

        // 6. Get Firebase ID Token
        final firebaseIdToken = await userCredential.user!.getIdToken();
        if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
          throw Exception('Failed to get Firebase ID token');
        }

        // 7. Exchange Firebase token for backend JWT tokens
        final backendResponse = await _apiService.firebaseSignIn(
          firebaseIdToken!,
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
        print('Error de autenticación Firebase: $firebaseError');
        await _facebookAuth.logOut();
        throw Exception('Error al autenticar con Firebase: $firebaseError');
      }
    } catch (e, stackTrace) {
      print('=== ERROR DE LOGIN FACEBOOK ===');
      print('Error detallado: $e');
      print('Stack trace: $stackTrace');
      print('=============================');

      try {
        await _facebookAuth.logOut();
      } catch (logoutError) {
        print('Error al hacer logout de Facebook: $logoutError');
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
      print('Warning: Logout may not have completed fully: ${e.toString()}');
    }
  }

  @override
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? _getUserModelFromFirebaseUser(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _getUserModelFromFirebaseUser(user) : null;
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

        // 2. Update Firestore
        await _updateUserInFirestore(user.uid, displayName, photoURL);

        // 3. Update backend profile
        try {
          await _apiService.updateProfile({
            if (displayName != null) 'name': displayName,
            if (photoURL != null) 'photo_url': photoURL,
          });
        } catch (e) {
          print('Warning: Backend profile update failed: $e');
          // Continue even if backend update fails
        }
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
  Future<void> saveUserMeasurementUnit(String measurementUnit) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'measurementUnit': measurementUnit,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save measurement unit: ${e.toString()}');
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
        // Force refresh the user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          // The user data will be automatically updated through listeners
          print('User data refreshed from Firestore');
        }
      }
    } catch (e) {
      throw Exception('Failed to refresh user from Firestore: ${e.toString()}');
    }
  }

  @override
  Future<void> refreshApplicationTokens() async {
    try {
      // Use the ApiService to refresh tokens
      final newAccessToken = await _apiService.refreshTokens();
      if (newAccessToken == null) {
        throw Exception(
          'Failed to refresh tokens - no new access token received',
        );
      }
      print('Application tokens refreshed successfully');
    } catch (e) {
      throw Exception('Failed to refresh tokens: ${e.toString()}');
    }
  }
}
