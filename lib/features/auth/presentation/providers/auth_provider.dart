import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

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
      // Obtener datos completos del usuario con Firestore
      final user = await _authRepository.getCurrentUserWithFirestore();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refrescar datos del usuario desde Firestore
  Future<void> refreshUserFromFirestore() async {
    try {
      // Verificar si hay un usuario en el estado actual
      final currentState = state.value;
      if (currentState != null) {
        final user = await _authRepository.getCurrentUserWithFirestore();
        state = AsyncValue.data(user);
      }
    } catch (e) {
      print('Error al refrescar datos del usuario: $e');
      // No actualizamos el estado para no afectar la UI si hay error
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
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

      // Verificar si necesitamos información adicional
      // Nota: en este punto el usuario ya está autenticado en Firebase,
      // pero necesitamos solicitar información adicional
      if (user.needsAdditionalInfo) {
        // Establecemos el estado con el usuario parcial
        // El controlador de UI puede verificar esta bandera y mostrar un diálogo
        state = AsyncValue.data(user);
        return;
      }

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
      // Asegurarse de que el estado se actualice antes de la navegación
      state = const AsyncValue.data(null);
      // No hay necesidad de redirigir aquí, el router se encargará de eso
      // basado en el cambio del estado de autenticación
    } catch (e) {
      print('Error en signOut: $e');
      // Aún cuando hay un error, marcamos el estado como desconectado
      // para permitir navegación apropiada
      state = const AsyncValue.data(null);
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

    print(
      'Verificando si el usuario ${state.value!.id} necesita completar preferencias...',
    );

    // IMPORTANTE: Siempre verificar con Firestore para Apple/Google/Facebook auth
    // ya que state.value puede tener datos antiguos o incompletos

    // Forzar recarga del usuario desde Firestore primero
    await refreshUserFromFirestore();

    // Verificar si el usuario ha completado las preferencias iniciales
    final isFirstTime = await _authRepository.isFirstTimeUser(state.value!.id);
    final hasCompletedPreferences = await hasCompletedInitialPreferences();

    print(
      'Resultado verificación: isFirstTime=$isFirstTime, hasCompletedPreferences=$hasCompletedPreferences',
    );
    print(
      'Necesita ir al selector de preferencias: ${isFirstTime || !hasCompletedPreferences}',
    );

    // El usuario debe ir al flujo de preferencias si es primera vez O no ha completado preferencias
    return isFirstTime || !hasCompletedPreferences;
  }

  /// Check if user has completed initial preferences setup
  Future<bool> hasCompletedInitialPreferences() async {
    try {
      if (state.value == null) {
        print('hasCompletedInitialPreferences: No hay usuario autenticado');
        return false; // If no user is logged in, return false
      }

      print('Verificando estado de preferencias para ${state.value!.id}...');

      // Forzar recarga de datos de Firestore - CRÍTICO para autenticación social (Apple, Google, Facebook)
      // IGNORA el valor de initialPreferencesCompleted almacenado en el modelo local
      final result = await _authRepository.hasCompletedInitialPreferences();
      print(
        'Resultado directo de Firestore: preferencias completadas = $result',
      );

      return result;
    } catch (e) {
      print('Error verificando preferencias completadas: $e');
      return false; // En caso de error, retornar false para asegurar que el usuario pase por configuración
    }
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

  // Agregar un nuevo método para actualizar la información después de Apple Sign In
  Future<void> updateUserAfterAppleSignIn(
    String displayName,
    String email,
  ) async {
    try {
      final updatedUser = await _authRepository.updateUserAfterAppleSignIn(
        displayName,
        email,
      );
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
