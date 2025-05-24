import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/core/navigation/app_router.dart' as router;

/// Provider for AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Provider que indica si el correo está verificado
final emailVerificationProvider = StateProvider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  // Si no hay usuario autenticado, devolver falso
  if (authState.value == null) {
    return false;
  }

  // Si hay un usuario, chequeamos su estado de verificación (asumimos falso inicialmente)
  // El estado real será actualizado por el AuthController después de iniciar sesión
  return false;
});

// Provider to check if current user is first time user
final isFirstTimeProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authControllerProvider);

  // Si no hay valor o está cargando, asumir que es primera vez
  if (authState is AsyncLoading || authState.value == null) {
    return true;
  }

  // Verificar usando el método del authController
  final authController = ref.watch(authControllerProvider.notifier);
  return await authController.isFirstTimeUser();
});

// Provider para determinar si el usuario completó onboarding
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  // Este proveedor puede usar la información del usuario logueado
  // para determinar si completó el onboarding

  // El estado real será actualizado por el AuthController después de iniciar sesión
  return false;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return AuthController(
        authRepository,
        AuthRepositoryImpl.globalProviderRefreshCallback,
      );
    });

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;
  final Function()? _globalProviderRefreshCallback;

  AuthController(this._authRepository, this._globalProviderRefreshCallback)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.getCurrentUserWithFirestore();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // No necesitamos mostrar la pantalla de carga, manejaremos el loading en la UI
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );

      state = AsyncValue.data(user);

      // 🔄 Disparar refresh del userPreferencesProvider después del login
      if (_globalProviderRefreshCallback != null) {
        print('🔄 Activando refresh de preferencias después del login exitoso');
        _globalProviderRefreshCallback!();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    // No necesitamos mostrar la pantalla de carga, manejaremos el loading en la UI
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
      );

      state = AsyncValue.data(user);

      // 🔄 Disparar refresh del userPreferencesProvider después del registro
      if (_globalProviderRefreshCallback != null) {
        print(
          '🔄 Activando refresh de preferencias después del registro exitoso',
        );
        _globalProviderRefreshCallback!();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);

      // 🔄 Disparar refresh del userPreferencesProvider después del login con Google
      if (_globalProviderRefreshCallback != null) {
        print(
          '🔄 Activando refresh de preferencias después del login con Google',
        );
        _globalProviderRefreshCallback!();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithApple();
      state = AsyncValue.data(user);

      // 🔄 Disparar refresh del userPreferencesProvider después del login con Apple
      if (_globalProviderRefreshCallback != null) {
        print(
          '🔄 Activando refresh de preferencias después del login con Apple',
        );
        _globalProviderRefreshCallback!();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithFacebook();
      state = AsyncValue.data(user);

      // 🔄 Disparar refresh del userPreferencesProvider después del login con Facebook
      if (_globalProviderRefreshCallback != null) {
        print(
          '🔄 Activando refresh de preferencias después del login con Facebook',
        );
        _globalProviderRefreshCallback!();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _authRepository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Usar refreshUserFromFirestore para obtener datos completos actualizados
      await refreshUserFromFirestore();
      print('✅ Perfil actualizado y datos refrescados desde Firestore');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Check if this is the user's first login
  Future<bool> isFirstTimeUser() async {
    if (state.value == null || state.value?.id == null) {
      return true; // If no user is logged in or no ID, assume first time
    }
    return await _authRepository.isFirstTimeUser(state.value!.id);
  }

  /// Mark user as having completed onboarding
  Future<void> markOnboardingCompleted() async {
    if (state.value != null && state.value?.id != null) {
      await _authRepository.markOnboardingCompleted(state.value!.id);
    }
  }

  /// Send verification email to the current user
  Future<void> sendVerificationEmail() async {
    try {
      await _authRepository.sendVerificationEmail();
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  /// Check if the current user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      return await _authRepository.isEmailVerified();
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  /// Reload the current user to get updated verification status
  Future<void> reloadUser() async {
    try {
      await _authRepository.reloadUser();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  /// Refresh user data from Firestore
  Future<void> refreshUserFromFirestore() async {
    try {
      print('🔄 Refrescando datos de usuario desde Firestore...');

      // Get user data directly from Firestore (bypass cache)
      // NO reload Firebase user first to avoid potential issues
      final firestoreUser = await _authRepository.getCurrentUserWithFirestore();

      if (firestoreUser != null) {
        // Actualizar directamente el estado con los datos de Firestore
        state = AsyncValue.data(firestoreUser);
        print('✅ User data refreshed from Firestore successfully');
        print('   - User ID: ${firestoreUser.id}');
        print('   - Email: ${firestoreUser.email}');
        print(
          '   - initialPreferencesCompleted: ${firestoreUser.initialPreferencesCompleted}',
        );
        print('   - Allergies count: ${firestoreUser.allergies?.length ?? 0}');
        print('   - Cooking level: ${firestoreUser.cookingLevel}');
        print(
          '   - Special diets count: ${firestoreUser.specialDiets?.length ?? 0}',
        );
        print(
          '   - Preferred food types count: ${firestoreUser.preferredFoodTypes?.length ?? 0}',
        );
      } else {
        print(
          '⚠️ No user found in Firestore, re-initializing from Firebase Auth',
        );
        // Si no hay usuario en Firestore, re-inicializar
        await _init();
      }
    } catch (e) {
      print('❌ Error refreshing user from Firestore: $e');
      // En caso de error, intentar inicializar desde Firebase Auth
      await _init();
    }
  }
}
