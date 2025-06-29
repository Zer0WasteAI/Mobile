import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_model.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:zer0_waste_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/core/services/secure_token_service.dart';
import 'package:zer0_waste_ai/core/services/auth_service.dart';

// INFO: Provider for the real auth repository implementation
// USAGE: Connects Firebase Auth with ZeroWasteAI backend API
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ApiService.instance;
  final secureTokenService = ref.watch(secureTokenServiceProvider);

  return AuthRepositoryImpl(
    apiService: apiService,
    secureTokenService: secureTokenService,
  );
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return AuthController(authRepository);
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

  Future<void> refreshUserFromFirestore() async {
    try {
      await _authRepository.refreshUserFromFirestore();
      await _init(); // Reload the current user state
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Manejar expiración de sesión - requiere re-autenticación con Firebase
  Future<void> handleSessionExpired(String message) async {
    try {
      log('🚪 Handling session expiry - trying to refresh Firebase token first');
      
      // Primero intentar renovar automáticamente si hay sesión de Firebase activa
      final success = await _tryRefreshFromFirebase();
      if (success) {
        log('✅ Successfully refreshed tokens from Firebase session');
        return; // No need to show error if we fixed it
      }
      
      log('❌ No active Firebase session - requiring full re-authentication');
      
      // Si no se pudo renovar, mostrar error y requerir login
      state = AsyncValue.error(
        SessionExpiredException(message), 
        StackTrace.current,
      );
      
      // Resetear a data(null) para ir a login
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          state = const AsyncValue.data(null);
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Intentar renovar tokens usando sesión activa de Firebase
  Future<bool> _tryRefreshFromFirebase() async {
    try {
      // Verificar si hay usuario autenticado en Firebase
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        log('❌ No Firebase user found for token refresh');
        return false;
      }
      
      log('🔄 Found Firebase user, attempting to refresh ID token and exchange for JWT');
      
      // Refrescar desde Firestore para asegurar que tengamos datos actualizados
      await _authRepository.refreshUserFromFirestore();
      
      // Actualizar estado con usuario renovado
      await _init();
      
      log('✅ Successfully refreshed user state from Firebase');
      return true;
    } catch (e) {
      log('❌ Failed to refresh from Firebase: $e');
      return false;
    }
  }
}
