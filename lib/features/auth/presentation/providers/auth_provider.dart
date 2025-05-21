import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/core/navigation/app_router.dart' as router;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository not initialized');
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

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return AuthController(authRepository);
    });

final isFirstTimeUserProvider = FutureProvider<bool>((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  final authState = ref.watch(authControllerProvider);

  // Si no hay usuario logueado o la autenticación está cargando, devolver true
  if (authState is AsyncLoading || authState.value == null) {
    return true;
  }

  return await authController.isFirstTimeUser();
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = const AsyncValue.loading();
    try {
      final user = _authRepository.currentUser;
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithApple();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithFacebook();
      state = AsyncValue.data(user);
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
      await _init();
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
      // First reload the Firebase user to ensure we have the latest auth state
      await reloadUser();

      // Get user data directly from Firestore (bypass cache)
      final firestoreUser = await _authRepository.getCurrentUserWithFirestore();

      if (firestoreUser != null) {
        // Actualizar directamente el estado con los datos de Firestore
        state = AsyncValue.data(firestoreUser);
        print('User data refreshed from Firestore successfully');
      } else {
        // Si no hay usuario en Firestore, re-inicializar
        await _init();
        print('No user found in Firestore, using Firebase Auth data');
      }
    } catch (e) {
      print('Error refreshing user from Firestore: $e');
      // En caso de error, intentar inicializar desde Firebase Auth
      await _init();
    }
  }
}
