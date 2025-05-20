import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

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
      return await _getUserModelFromFirebaseUser(userCredential.user!);
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
      // Primero verificar si este email ya existe en Firestore
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      // Si encontramos documentos, significa que el email ya está registrado
      if (emailQuery.docs.isNotEmpty) {
        final existingUserData = emailQuery.docs.first.data();
        final authProvider = existingUserData['authProvider'];

        if (authProvider != null && authProvider != 'password') {
          // El email ya está registrado con otro proveedor de autenticación
          throw Exception(
            'Este correo ya está registrado con ${_getProviderName(authProvider)}. '
            'Por favor, inicia sesión usando ese método.',
          );
        }
      }

      // Verificar también con Firebase Auth si hay métodos de inicio de sesión asociados
      // ignore: deprecated_member_use
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(
        email,
      );

      if (signInMethods.isNotEmpty && !signInMethods.contains('password')) {
        final provider = signInMethods.first;
        throw Exception(
          'Este correo ya está registrado con ${_getProviderName(provider)}. '
          'Por favor, inicia sesión usando ese método.',
        );
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);

      // Enviar correo de verificación
      await userCredential.user?.sendEmailVerification();

      await _createUserInFirestore(
        userCredential.user!,
        displayName,
        authProvider: 'password',
      );

      return await _getUserModelFromFirebaseUser(userCredential.user!);
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

      // Extract additional data from Google account
      final additionalData = {
        'googleId': googleUser.id,
        'googlePhotoUrl': googleUser.photoUrl,
        'googleEmail': googleUser.email,
        // Add any other relevant Google data you want to store
      };

      // Verificar si el usuario tiene un documento en Firestore
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        print(
          'Creando documento para usuario de Google: ${userCredential.user!.uid}',
        );
        await _createUserInFirestore(
          userCredential.user!,
          googleUser.displayName,
          authProvider: 'google.com',
          additionalData: additionalData,
        );
      } else {
        print(
          'Documento de usuario Google encontrado: ${userCredential.user!.uid}',
        );
      }
      return await _getUserModelFromFirebaseUser(userCredential.user!);
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

      // Construir el nombre completo si está disponible
      String? fullName;
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        fullName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((name) => name != null).join(' ');
        fullName = fullName.isNotEmpty ? fullName : null;
      }

      // Extraer datos adicionales de Apple
      final additionalData = <String, dynamic>{};
      if (appleCredential.email != null) {
        additionalData['appleEmail'] = appleCredential.email;
      }
      if (appleCredential.givenName != null) {
        additionalData['appleGivenName'] = appleCredential.givenName;
      }
      if (appleCredential.familyName != null) {
        additionalData['appleFamilyName'] = appleCredential.familyName;
      }

      // Verificar si necesitamos solicitar información adicional al usuario
      // Apple puede ocultar nombre y email si el usuario selecciona "Hide My Email"
      bool needsAdditionalInfo =
          (fullName == null || fullName.isEmpty) ||
          (appleCredential.email == null || appleCredential.email!.isEmpty);

      // También verificar el usuario actual
      if (userCredential.user?.displayName == null ||
          userCredential.user?.email == null) {
        needsAdditionalInfo = true;
      }

      // Verificar si el usuario tiene un documento en Firestore
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      // Si el usuario necesita información adicional, retornar con bandera
      if (needsAdditionalInfo) {
        // Si no existe documento en Firestore, lo creamos con datos parciales
        if (!userDoc.exists) {
          print(
            'Creando documento parcial para usuario de Apple: ${userCredential.user!.uid}',
          );
          await _createUserInFirestore(
            userCredential.user!,
            fullName ?? appleCredential.givenName,
            authProvider: 'apple.com',
            additionalData: additionalData.isNotEmpty ? additionalData : null,
          );
        } else {
          print(
            'Documento de usuario Apple encontrado, pero necesita información adicional',
          );
        }

        // Aquí agregamos una función de devolución de llamada que debe ser implementada por el caller
        // Ya que no podemos mostrar un diálogo directamente desde el repositorio
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          phoneNumber: userCredential.user!.phoneNumber,
          emailVerified: userCredential.user!.emailVerified,
          // Añadimos una bandera para indicar que necesitamos información adicional
          needsAdditionalInfo: true,
          // Establecer el providerId a 'apple.com'
          providerId: 'apple.com',
          // Default values for new fields
          allergies: [],
          cookingLevel: null,
          preferredFoodTypes: [],
          initialPreferencesCompleted: false,
        );
      }

      // Si no existe el documento y no necesita información adicional, lo creamos
      if (!userDoc.exists) {
        print(
          'Creando documento para usuario de Apple: ${userCredential.user!.uid}',
        );
        await _createUserInFirestore(
          userCredential.user!,
          fullName ?? appleCredential.givenName,
          authProvider: 'apple.com',
          additionalData: additionalData.isNotEmpty ? additionalData : null,
        );

        // Si es un nuevo usuario, marcamos explícitamente que no ha completado preferencias
        print(
          'Nuevo usuario de Apple - garantizando que sea dirigido al selector de preferencias',
        );
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? fullName,
          photoURL: userCredential.user!.photoURL,
          phoneNumber: userCredential.user!.phoneNumber,
          emailVerified: userCredential.user!.emailVerified,
          // Establecer el providerId a 'apple.com'
          providerId: 'apple.com',
          // Sin preferencias completadas
          allergies: [],
          cookingLevel: null,
          preferredFoodTypes: [],
          initialPreferencesCompleted: false,
        );
      } else {
        print(
          'Documento de usuario Apple encontrado: ${userCredential.user!.uid}',
        );

        // Verificar explícitamente si ha completado las preferencias iniciales
        final userData = userDoc.data();
        final bool hasCompletedPrefs =
            userData != null &&
            userData['initialPreferencesCompleted'] == true &&
            userData.containsKey('allergies') &&
            userData.containsKey('cookingLevel') &&
            userData.containsKey('preferredFoodTypes');

        print(
          'Usuario Apple existente - estado de preferencias: ${hasCompletedPrefs ? "COMPLETADO" : "NO COMPLETADO"}',
        );

        // Forzar verificación de Firestore, no confiar en los datos de Firebase Auth
        if (!hasCompletedPrefs) {
          print(
            'Usuario Apple NO tiene preferencias completas - redirigiendo al flujo de preferencias',
          );
          return UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? userData?['email'] ?? '',
            displayName:
                userCredential.user!.displayName ?? userData?['displayName'],
            photoURL: userCredential.user!.photoURL ?? userData?['photoURL'],
            phoneNumber:
                userCredential.user!.phoneNumber ?? userData?['phoneNumber'],
            emailVerified: userCredential.user!.emailVerified,
            providerId: 'apple.com',
            // Sin preferencias completadas
            allergies: [],
            cookingLevel: null,
            preferredFoodTypes: [],
            initialPreferencesCompleted: false,
          );
        }
      }

      // Solo llegar aquí si realmente tiene sus preferencias completas
      return await _getUserModelFromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Para iOS usaremos Limited Login que no requiere App Tracking Transparency
      // Solo solicitamos el permiso si estamos en otro sistema operativo que lo necesite
      if (Platform.isIOS) {
        print('Configurando Limited Login para iOS...');
      } else if (Platform.isAndroid) {
        // En Android podríamos solicitar permisos específicos si fueran necesarios
        print('Configurando login estándar para Android...');
      }

      // Intento de login con Facebook
      print('Iniciando login con Facebook...');

      // Generar un nonce aleatorio para la autenticación (requerido para Limited Login)
      String generateNonce([int length = 32]) {
        const charset =
            '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
        final random = math.Random.secure();
        return List.generate(
          length,
          (_) => charset[random.nextInt(charset.length)],
        ).join();
      }

      final nonce = generateNonce();

      // Configuración para iniciar sesión con Facebook
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
        loginBehavior:
            Platform.isIOS
                ? LoginBehavior
                    .dialogOnly // Usar dialogOnly para iOS
                : LoginBehavior.nativeWithFallback,
        // Usar LoginTracking.limited para iOS para cumplir con las restricciones de iOS
        loginTracking:
            Platform.isIOS ? LoginTracking.limited : LoginTracking.enabled,
        // Pasar nonce para iOS (requerido para Limited Login)
        nonce: nonce,
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
      print('Tipo de token: ${result.accessToken!.type}');
      print('Token string de tipo: ${result.accessToken.runtimeType}');

      // Obtener info del usuario mientras tenemos token válido
      final userData = await _facebookAuth.getUserData();
      print('Datos de usuario Facebook obtenidos: ${userData['name']}');

      // Get credential using the access token string
      try {
        print('Token string: ${result.accessToken!.tokenString}');
        print('Token type: ${result.accessToken!.type}');

        // En caso de Limited Login, esto sería un AuthenticationToken en vez de AccessToken
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        print('Credencial creada: $credential');
        print(
          'Credencial Facebook creada, intentando autenticación en Firebase...',
        );

        try {
          final userCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );

          print(
            'Autenticación Firebase exitosa, procesando datos de usuario...',
          );

          // Extraer datos adicionales del usuario de Facebook
          final additionalData = <String, dynamic>{};
          if (userData.containsKey('id')) {
            additionalData['facebookId'] = userData['id'];
          }
          if (userData.containsKey('email')) {
            additionalData['facebookEmail'] = userData['email'];
          }
          if (userData.containsKey('picture') &&
              userData['picture'] is Map &&
              userData['picture']['data'] is Map &&
              userData['picture']['data']['url'] is String) {
            additionalData['facebookPictureUrl'] =
                userData['picture']['data']['url'];
          }

          // Puedes extraer más campos según lo que necesites
          for (var field in ['birthday', 'gender', 'location']) {
            if (userData.containsKey(field)) {
              additionalData['facebook${field.substring(0, 1).toUpperCase()}${field.substring(1)}'] =
                  userData[field];
            }
          }

          // Verificar si el usuario tiene un documento en Firestore
          final userDoc =
              await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .get();

          if (!userDoc.exists) {
            print(
              'Creando documento para usuario de Facebook: ${userCredential.user!.uid}',
            );
            await _createUserInFirestore(
              userCredential.user!,
              userData['name'] as String? ??
                  userCredential.user!.displayName ??
                  'Usuario de Facebook',
              authProvider: 'facebook.com',
              additionalData: additionalData.isNotEmpty ? additionalData : null,
            );
          } else {
            print(
              'Documento de usuario Facebook encontrado: ${userCredential.user!.uid}',
            );
          }
          return await _getUserModelFromFirebaseUser(userCredential.user!);
        } catch (firebaseError) {
          print('Error de autenticación Firebase DETALLADO: $firebaseError');
          print('Tipo de error: ${firebaseError.runtimeType}');

          // Intentar una ruta alternativa de autenticación si el primer método falla
          if (firebaseError.toString().contains('Bad signature') ||
              firebaseError.toString().contains('invalid-credential')) {
            try {
              print('Intentando ruta alternativa de autenticación...');
              // Obtener detalles del usuario de Facebook para crear un nuevo credential
              final email = userData['email'];

              if (email != null && email.toString().isNotEmpty) {
                print(
                  'Usando email de Facebook para autenticación alternativa: $email',
                );

                // Verificar si el usuario ya existe
                try {
                  final methods = await _firebaseAuth
                      .fetchSignInMethodsForEmail(email.toString());
                  print('Métodos de login disponibles: $methods');

                  if (methods.contains('facebook.com')) {
                    // El usuario ya existe, intentar login con otro método
                    print(
                      'Usuario ya existe con Facebook, reintentando conexión',
                    );

                    // Intentar autenticar por email si es que facebook.com está entre los métodos
                    print('Intentando crear una sesión alternativa...');

                    // Actualizar la credencial y reintentar
                    final newCredential = FacebookAuthProvider.credential(
                      result.accessToken!.tokenString,
                    );

                    // Intentar el inicio de sesión nuevamente
                    final userCredential = await _firebaseAuth
                        .signInWithCredential(newCredential);

                    await _createUserInFirestore(
                      userCredential.user!,
                      userData['name'] as String? ?? 'Usuario de Facebook',
                      authProvider: 'facebook.com',
                      additionalData: {'facebookId': userData['id']},
                    );

                    return await _getUserModelFromFirebaseUser(
                      userCredential.user!,
                    );
                  } else {
                    // Si el email existe pero no con facebook, podría ser otro método
                    print(
                      'El email existe, pero no con Facebook. Métodos disponibles: $methods',
                    );
                  }
                } catch (methodError) {
                  print('Error al verificar métodos de inicio: $methodError');
                }
              } else {
                print(
                  'No se pudo obtener email del usuario de Facebook para autenticación alternativa',
                );
              }
            } catch (alternativeError) {
              print('Error en ruta alternativa: $alternativeError');
            }

            print('Detectado error de firma inválida o credencial inválida');

            // Limpiar sesiones
            await _facebookAuth.logOut();
            try {
              await _firebaseAuth.signOut();
            } catch (e) {
              // Ignorar error de logout
            }

            // Mostrar un mensaje más amigable
            throw Exception(
              'Error de autenticación con Facebook. Por favor, intenta con otro método de inicio de sesión o contacta a soporte.',
            );
          }

          await _facebookAuth.logOut(); // Limpiar estado en caso de error
          throw Exception('Error al autenticar con Firebase: $firebaseError');
        }
      } catch (firebaseError) {
        print('Error en el proceso de autenticación: $firebaseError');
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

      // Personalizar mensaje para el usuario final
      if (e.toString().contains('Bad signature') ||
          e.toString().contains('invalid-credential')) {
        throw Exception(
          'Error de autenticación con Facebook. Por favor, intenta con otro método de inicio de sesión o contacta a soporte.',
        );
      }

      throw Exception(
        'No se pudo iniciar sesión con Facebook: ${e.toString()}',
      );
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
    if (user == null) return null;

    // Como este método debe ser síncrono (getter), no podemos usar await para obtener datos de Firestore
    // Usamos solo los datos disponibles de Firebase Auth
    String providerId = 'password';
    if (user.providerData.isNotEmpty) {
      providerId = user.providerData[0].providerId;
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      providerId: providerId,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      // Usar asyncMap para poder usar await dentro del map
      return await _getUserModelFromFirebaseUser(user);
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

  /// Check if this is the user's first login
  @override
  Future<bool> isFirstTimeUser(String userId) async {
    try {
      print('Checking if user $userId is first time user...');

      // Check if the user has completed initial preferences setup
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('isFirstTimeUser: User document does not exist, is first time');
        return true; // If user document doesn't exist, it's first login
      }

      // Check if the user has completed initial preferences
      final userData = userDoc.data();
      if (userData == null) {
        print('isFirstTimeUser: User data is null, treating as first time');
        return true;
      }

      // Check if initialPreferencesCompleted flag is explicitly set to true
      final bool preferencesCompleted =
          userData['initialPreferencesCompleted'] == true;

      // Check if required preference fields exist
      final bool hasAllFields =
          userData.containsKey('allergies') &&
          userData.containsKey('cookingLevel') &&
          userData.containsKey('preferredFoodTypes');

      print('isFirstTimeUser check:');
      print(' - preferencesCompleted flag: $preferencesCompleted');
      print(' - has all required fields: $hasAllFields');

      // User is not first-time only if all conditions are met
      final bool isFirstTime = !(preferencesCompleted && hasAllFields);
      print('isFirstTimeUser result: $isFirstTime');

      return isFirstTime;
    } catch (e) {
      // If there's an error, assume it's the first time to be safe
      print('Error checking first time user: ${e.toString()}');
      return true;
    }
  }

  /// Mark user as having completed onboarding
  @override
  Future<void> markOnboardingCompleted(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'completedOnboarding': true,
      });
    } catch (e) {
      print('Error marking onboarding as completed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception(
        'Error al enviar correo de verificación: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      return user.emailVerified;
    } catch (e) {
      throw Exception('Error al verificar estado del correo: ${e.toString()}');
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: ${e.toString()}');
    }
  }

  /// Save user allergies
  @override
  Future<void> saveUserAllergies(List<String> allergies) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'allergies': allergies,
        });
      }
    } catch (e) {
      print('Error saving allergies: ${e.toString()}');
      throw Exception('Failed to save allergies: ${e.toString()}');
    }
  }

  /// Save user special diets
  @override
  Future<void> saveUserSpecialDiets(List<String> specialDiets) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'specialDiets': specialDiets,
        });
      }
    } catch (e) {
      print('Error saving special diets: ${e.toString()}');
      throw Exception('Failed to save special diets: ${e.toString()}');
    }
  }

  /// Save user cooking level
  @override
  Future<void> saveUserCookingLevel(String cookingLevel) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'cookingLevel': cookingLevel,
        });
      }
    } catch (e) {
      print('Error saving cooking level: ${e.toString()}');
      throw Exception('Failed to save cooking level: ${e.toString()}');
    }
  }

  /// Save user preferred food types
  @override
  Future<void> saveUserPreferredFoodTypes(List<String> foodTypes) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'preferredFoodTypes': foodTypes,
        });
      }
    } catch (e) {
      print('Error saving preferred food types: ${e.toString()}');
      throw Exception('Failed to save preferred food types: ${e.toString()}');
    }
  }

  /// Mark user initial preferences as completed
  @override
  Future<void> markInitialPreferencesCompleted() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'initialPreferencesCompleted': true,
        });
      }
    } catch (e) {
      print('Error marking initial preferences as completed: ${e.toString()}');
      throw Exception(
        'Failed to mark initial preferences as completed: ${e.toString()}',
      );
    }
  }

  /// Check if user has completed initial preferences
  @override
  Future<bool> hasCompletedInitialPreferences() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        print('hasCompletedInitialPreferences: No current user found');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        print('hasCompletedInitialPreferences: User document does not exist');
        return false;
      }

      final userData = userDoc.data();
      if (userData == null) {
        print('hasCompletedInitialPreferences: User data is null');
        return false;
      }

      // Check if the flag is explicitly set to true
      final bool isMarkedComplete =
          userData['initialPreferencesCompleted'] == true;

      // Verify that all required preference fields exist
      final hasAllergies = userData.containsKey('allergies');
      final hasCookingLevel = userData.containsKey('cookingLevel');
      final hasPreferredFoodTypes = userData.containsKey('preferredFoodTypes');

      // For debugging, print the state of each field
      print('hasCompletedInitialPreferences check:');
      print(' - isMarkedComplete: $isMarkedComplete');
      print(' - hasAllergies: $hasAllergies');
      print(' - hasCookingLevel: $hasCookingLevel');
      print(' - hasPreferredFoodTypes: $hasPreferredFoodTypes');

      // If any required field is missing, consider preferences as incomplete
      if (!isMarkedComplete ||
          !hasAllergies ||
          !hasCookingLevel ||
          !hasPreferredFoodTypes) {
        print(
          'hasCompletedInitialPreferences: Some preference fields are missing or flag not set',
        );
        return false;
      }

      print(
        'hasCompletedInitialPreferences: All preference fields exist and flag is set',
      );
      return true;
    } catch (e) {
      print('Error checking initial preferences completion: ${e.toString()}');
      return false;
    }
  }

  /// Save user allergies as objects with custom flag
  @override
  Future<void> saveUserAllergyItems(
    List<Map<String, dynamic>> allergyItems,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'allergyItems': allergyItems,
          // Keep the legacy field updated too for backward compatibility
          'allergies':
              allergyItems.map((item) => item['name'] as String).toList(),
        });
      }
    } catch (e) {
      print('Error saving allergy items: ${e.toString()}');
      throw Exception('Failed to save allergy items: ${e.toString()}');
    }
  }

  /// Save user special diets as objects with custom flag
  @override
  Future<void> saveUserSpecialDietItems(
    List<Map<String, dynamic>> dietItems,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'specialDietItems': dietItems,
          // Keep the legacy field updated too for backward compatibility
          'specialDiets':
              dietItems.map((item) => item['name'] as String).toList(),
        });
      }
    } catch (e) {
      print('Error saving special diet items: ${e.toString()}');
      throw Exception('Failed to save special diet items: ${e.toString()}');
    }
  }

  /// Save user preferred food types as objects with custom flag
  @override
  Future<void> saveUserPreferredFoodTypeItems(
    List<Map<String, dynamic>> foodTypeItems,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'preferredFoodTypeItems': foodTypeItems,
          // Keep the legacy field updated too for backward compatibility
          'preferredFoodTypes':
              foodTypeItems.map((item) => item['name'] as String).toList(),
        });
      }
    } catch (e) {
      print('Error saving preferred food type items: ${e.toString()}');
      throw Exception(
        'Failed to save preferred food type items: ${e.toString()}',
      );
    }
  }

  Future<void> _createUserInFirestore(
    User user,
    String? displayName, {
    String? authProvider,
    Map<String, dynamic>? additionalData,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    // Check if this is the first login
    final docSnapshot = await userDoc.get();
    final isFirstLogin = !docSnapshot.exists;

    // Base user data
    final userData = {
      'id': user.uid,
      'email': user.email,
      'displayName': displayName ?? user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'emailVerified': user.emailVerified,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    // For first time login, add these fields
    if (isFirstLogin) {
      userData['favoriteRecipes'] = <String>[];
      userData['createdAt'] = FieldValue.serverTimestamp();

      // Add authentication provider information
      if (authProvider != null) {
        userData['authProvider'] = authProvider;
      } else if (user.providerData.isNotEmpty) {
        userData['authProvider'] = user.providerData[0].providerId;
      }

      // Add any additional data provided by the social login
      if (additionalData != null && additionalData.isNotEmpty) {
        userData.addAll(additionalData);
      }
    }

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

  Future<UserModel> _getUserModelFromFirebaseUser(User user) async {
    // Determinar el providerId a partir de los providerData
    String providerId = 'password';
    if (user.providerData.isNotEmpty) {
      providerId = user.providerData[0].providerId;
    }

    try {
      // Intentar obtener los datos del usuario desde Firestore primero
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Si el documento existe, usamos esos datos
        final userData = userDoc.data()!;

        // Verificar explícitamente el valor de initialPreferencesCompleted
        bool hasCompletedPreferences = false;
        if (userData.containsKey('initialPreferencesCompleted')) {
          hasCompletedPreferences =
              userData['initialPreferencesCompleted'] == true;
        }

        // Verificar que los campos de preferencias existan
        final List<String> allergies =
            (userData['allergies'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];

        final List<Map<String, dynamic>> allergyItems =
            (userData['allergyItems'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        final String? cookingLevel = userData['cookingLevel'] as String?;

        final List<String> preferredFoodTypes =
            (userData['preferredFoodTypes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];

        final List<Map<String, dynamic>> preferredFoodTypeItems =
            (userData['preferredFoodTypeItems'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        final List<String> specialDiets =
            (userData['specialDiets'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];

        final List<Map<String, dynamic>> specialDietItems =
            (userData['specialDietItems'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        // Print debug information about special diets
        print('User Firestore data debug:');
        print(' - specialDiets: $specialDiets');
        print(' - specialDietItems: $specialDietItems');

        // Si faltan campos de preferencias, marcar como no completado
        if (!userData.containsKey('allergies') ||
            !userData.containsKey('cookingLevel') ||
            !userData.containsKey('preferredFoodTypes')) {
          hasCompletedPreferences = false;
        }

        return UserModel(
          id: user.uid,
          email: userData['email'] as String? ?? user.email ?? '',
          displayName: userData['displayName'] as String? ?? user.displayName,
          photoURL: userData['photoURL'] as String? ?? user.photoURL,
          phoneNumber: userData['phoneNumber'] as String? ?? user.phoneNumber,
          emailVerified:
              userData['emailVerified'] as bool? ?? user.emailVerified,
          providerId: userData['authProvider'] as String? ?? providerId,
          // Otros campos específicos de Firestore
          favoriteRecipes:
              (userData['favoriteRecipes'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          // Campos de preferencias de usuario
          allergies: allergies,
          allergyItems: allergyItems,
          specialDiets: specialDiets,
          specialDietItems: specialDietItems,
          cookingLevel: cookingLevel,
          preferredFoodTypes: preferredFoodTypes,
          preferredFoodTypeItems: preferredFoodTypeItems,
          initialPreferencesCompleted: hasCompletedPreferences,
          // Otros campos
          createdAt:
              userData['createdAt'] != null
                  ? (userData['createdAt'] as Timestamp).toDate()
                  : null,
          lastLoginAt:
              userData['lastLoginAt'] != null
                  ? (userData['lastLoginAt'] as Timestamp).toDate()
                  : null,
        );
      }
    } catch (e) {
      print('Error al obtener datos del usuario desde Firestore: $e');
      // Si hay un error, continuamos con los datos de Firebase Auth
    }

    // Si no hay documento en Firestore o hubo un error, usamos los datos de Firebase Auth
    // También intentamos crear el documento en Firestore de forma asíncrona
    _verifyUserDocumentExists(user, providerId);

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      providerId: providerId,
      // Ensure default values for new fields are set properly
      allergies: [],
      allergyItems: [],
      specialDiets: [],
      specialDietItems: [],
      cookingLevel: null,
      preferredFoodTypes: [],
      preferredFoodTypeItems: [],
      initialPreferencesCompleted: false,
    );
  }

  // Método para verificar y crear el documento del usuario si no existe
  Future<void> _verifyUserDocumentExists(User user, String providerId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      // Si el documento no existe, crearlo
      if (!userDoc.exists) {
        print('Documento de usuario no encontrado. Creando uno nuevo...');

        String? displayName = user.displayName;
        // Para algunos proveedores, podríamos querer extraer más información
        Map<String, dynamic>? additionalData;

        if (providerId == 'google.com') {
          additionalData = {'googleId': user.uid, 'googleEmail': user.email};
        } else if (providerId == 'facebook.com') {
          additionalData = {
            'facebookId': user.uid,
            'facebookEmail': user.email,
          };
        } else if (providerId == 'apple.com') {
          additionalData = {'appleId': user.uid, 'appleEmail': user.email};
        }

        // Crear el documento del usuario
        await _createUserInFirestore(
          user,
          displayName,
          authProvider: providerId,
          additionalData: additionalData,
        );

        print('Documento creado exitosamente para el usuario: ${user.uid}');
      } else {
        print('Documento del usuario encontrado: ${user.uid}');
      }
    } catch (e) {
      print('Error al verificar/crear documento del usuario: $e');
      // No lanzamos el error para que no interrumpa el flujo de autenticación
    }
  }

  // Añadimos un método específico para actualizar la información del usuario después de sign-in con Apple
  @override
  Future<UserModel> updateUserAfterAppleSignIn(
    String displayName,
    String email,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Actualizar perfil en Firebase Auth
        await user.updateDisplayName(displayName);

        // Si no tiene email, intentar actualizar (puede no ser posible si el auth provider no lo permite)
        if (user.email == null || user.email!.isEmpty) {
          try {
            await user.verifyBeforeUpdateEmail(email);
            //await user.updateEmail(email);
          } catch (e) {
            print('No se pudo actualizar el email en Firebase Auth: $e');
            // Continuamos de todas formas, al menos lo guardaremos en Firestore
          }
        }

        // Actualizar en Firestore con toda la información necesaria
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': displayName,
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
          'needsAdditionalInfo':
              false, // Importante: marcar que ya no necesita información adicional
        }, SetOptions(merge: true));

        // Recargar usuario para obtener cambios
        await user.reload();
        return await _getUserModelFromFirebaseUser(user);
      } else {
        throw Exception('No hay usuario autenticado para actualizar');
      }
    } catch (e) {
      throw Exception(
        'Error al actualizar información de usuario: ${e.toString()}',
      );
    }
  }

  // Método auxiliar para obtener un nombre amigable del proveedor
  String _getProviderName(String providerId) {
    switch (providerId) {
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'apple.com':
        return 'Apple';
      case 'password':
        return 'Email y Contraseña';
      default:
        return 'otro método';
    }
  }

  @override
  Future<UserModel?> getCurrentUserWithFirestore() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    // Usar el método asíncrono para obtener datos completos de Firestore
    return await _getUserModelFromFirebaseUser(user);
  }
}
