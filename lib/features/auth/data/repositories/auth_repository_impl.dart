import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zer0_waste_ai/features/auth/data/mappers/user_mapper.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  /// Constructor
  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserModelFromFirebaseUser(userCredential.user!);
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
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);
      await _createUserInFirestore(userCredential.user!, displayName);

      return _getUserModelFromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      await _createUserInFirestore(
        userCredential.user!,
        googleUser.displayName,
      );
      return _getUserModelFromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
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

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );
      await _createUserInFirestore(
        userCredential.user!,
        appleCredential.givenName,
      );
      return _getUserModelFromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Intento de login con Facebook
      print('Iniciando login con Facebook...');
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      // Log del estado de resultado
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
      print('Token string: ${result.accessToken!.tokenString}');

      // Get credential using the access token string
      try {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        print(
          'Credencial Facebook creada, intentando autenticación en Firebase...',
        );
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );

        print('Autenticación Firebase exitosa, obteniendo datos de usuario...');
        final userData = await _facebookAuth.getUserData();
        print('Datos de usuario obtenidos: ${userData['name']}');

        await _createUserInFirestore(
          userCredential.user!,
          userData['name'] as String,
        );

        return _getUserModelFromFirebaseUser(userCredential.user!);
      } catch (firebaseError) {
        print('Error de autenticación Firebase: $firebaseError');
        await _facebookAuth.logOut(); // Limpiar estado en caso de error
        throw Exception('Error al autenticar con Firebase: $firebaseError');
      }
    } catch (e, stackTrace) {
      print('=== ERROR DE LOGIN FACEBOOK ===');
      print('Error detallado: $e');
      print('Stack trace: $stackTrace');
      print('=============================');

      // Intentar limpiar estado en caso de error
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
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      _facebookAuth.logOut(),
    ]);
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

      // In a real implementation, you would verify the code against your backend
      // or use Firebase custom auth tokens

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
      // In a real implementation, you would use a custom auth solution or Firebase Admin SDK
      // This is a simplified implementation for demonstration purposes

      // Verify the code (would be handled by your backend)
      // ...

      // Reset the password
      // For Firebase, you might need to implement this on your backend
      // as client SDKs don't support code-based verification directly

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
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await _updateUserInFirestore(user.uid, displayName, photoURL);
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
        await _firestore.collection('users').doc(user.uid).delete();
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
      // This would implement token refresh logic with your backend
      // For now, it's a placeholder implementation
      print('Refreshing application tokens...');
      // TODO: Implement actual token refresh logic
    } catch (e) {
      throw Exception('Failed to refresh tokens: ${e.toString()}');
    }
  }
}
