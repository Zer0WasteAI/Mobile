import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/utils/debug_helpers.dart';

/// Estado de las preferencias del usuario
class UserPreferencesState {
  final bool isLoading;
  final bool hasCompletedPreferences;
  final String? error;

  const UserPreferencesState({
    this.isLoading = true,
    this.hasCompletedPreferences = false,
    this.error,
  });

  UserPreferencesState copyWith({
    bool? isLoading,
    bool? hasCompletedPreferences,
    String? error,
  }) {
    return UserPreferencesState(
      isLoading: isLoading ?? this.isLoading,
      hasCompletedPreferences:
          hasCompletedPreferences ?? this.hasCompletedPreferences,
      error: error ?? this.error,
    );
  }
}

/// Proveedor global del estado de preferencias del usuario
final userPreferencesProvider = StateNotifierProvider<
  UserPreferencesNotifier,
  UserPreferencesState
>((ref) {
  final notifier = UserPreferencesNotifier(ref);

  // Listen to auth state changes and reload preferences when auth completes
  ref.listen(authStateProvider, (previous, next) {
    log('🔄 UserPreferencesService: Auth state changed - previous: ${previous?.hasValue}, next: ${next.hasValue}');
    
    // Reload preferences whenever we have a user (auth completion or refresh)
    if (next.hasValue) {
      log('🔄 Auth state has user - reloading user preferences');
      notifier.loadUserPreferences();
    } else if (next.isLoading) {
      // If auth is loading, mark preferences as loading
      log('🔄 Auth loading - setting preferences loading');
      notifier.setLoading();
    } else if (previous != null && previous.hasValue && !next.hasValue) {
      // If logged out, reset state
      log('🔄 Auth logged out - resetting preferences');
      notifier.reset();
    }
  });

  // Check initial auth state and load preferences if user exists
  final initialAuth = ref.read(authStateProvider);
  if (initialAuth.hasValue) {
    log('🔄 UserPreferencesService: Initial auth has user - loading preferences immediately');
    notifier.loadUserPreferences();
  } else {
    log('🔄 UserPreferencesService: No initial user - will wait for auth');
  }

  return notifier;
});

/// Notificador que gestiona el estado de las preferencias del usuario
class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final Ref _ref;

  UserPreferencesNotifier(this._ref) : super(const UserPreferencesState()) {
    // El inicializador no se ejecuta automáticamente cuando hay un usuario autenticado
    // Esto lo manejaremos externamente cuando sea necesario
  }

  /// Verifica y carga las preferencias del usuario actual
  Future<void> loadUserPreferences() async {
    try {
      log('UserPreferencesService: Starting loadUserPreferences...');
      
      // Set loading state first to prevent router redirects
      state = state.copyWith(isLoading: true);
      
      // SI YA ESTÁN MARCADAS COMO COMPLETADAS EN MEMORIA, NO SOBRESCRIBIR
      if (state.hasCompletedPreferences) {
        log(
          '⚡ Preferencias ya marcadas como completadas en memoria - NO sobrescribir',
        );
        state = state.copyWith(isLoading: false);
        return;
      }

      final user = _ref.read(authControllerProvider).value;

      // Si no hay usuario, no es necesario cargar preferencias
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          hasCompletedPreferences: false,
        );
        return;
      }

      // Get current user without refreshing first (to avoid hanging)
      final currentUser = _ref.read(authControllerProvider).value;
      
      log('UserPreferencesService: Checking user state...');
      if (currentUser != null) {
        log('UserPreferencesService: User found with ID: ${currentUser.id}');
        log('UserPreferencesService: User initialPreferencesCompleted: ${currentUser.initialPreferencesCompleted}');
      } else {
        log('UserPreferencesService: No user found in auth state!');
      }

      // Use the current user's initialPreferencesCompleted directly
      final firestorePreferencesStatus = currentUser?.initialPreferencesCompleted ?? false;

      log(
        'UserPreferencesService: Firestore initialPreferencesCompleted = $firestorePreferencesStatus',
      );

      // Actualizar el estado con el resultado, priorizando el valor de Firestore
      state = state.copyWith(
        isLoading: false,
        hasCompletedPreferences: firestorePreferencesStatus,
      );
      
      log('UserPreferencesService: Final state - hasCompletedPreferences: ${state.hasCompletedPreferences}, isLoading: ${state.isLoading}');
    } catch (e, stackTrace) {
      log('❌ Error al cargar preferencias del usuario: $e');
      log('❌ Stack trace: $stackTrace');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Marcar las preferencias como completadas
  Future<void> markPreferencesAsCompleted() async {
    try {
      // Marcar inmediatamente en memoria para evitar redirecciones
      state = state.copyWith(hasCompletedPreferences: true, isLoading: false);
      log(
        "UserPreferencesService: Preferencias marcadas como completadas en memoria",
      );

      // Verificar que la actualización fue exitosa al leer el estado del auth controller
      final authController = _ref.read(authControllerProvider.notifier);
      await authController.refreshUserFromFirestore();
      
      final refreshedUser = _ref.read(authControllerProvider).value;
      if (refreshedUser?.initialPreferencesCompleted == true) {
        log(
          "✅ UserPreferencesService: Confirmado que preferencias están marcadas en Firestore",
        );
      } else {
        log(
          "⚠️ UserPreferencesService: Preferencias no confirmadas en Firestore, manteniendo estado en memoria",
        );
      }
    } catch (e) {
      log("❌ UserPreferencesService: Error al confirmar preferencias: $e");
      // Keep the in-memory state as completed even if verification fails
      // to prevent navigation loops
    }
  }

  /// Resetear el estado cuando el usuario cierra sesión
  void reset() {
    state = const UserPreferencesState();
  }

  void setLoading() {
    state = state.copyWith(isLoading: true);
  }

  /// Fuerza la actualización del estado basado en el valor de initialPreferencesCompleted del usuario actual
  Future<void> forceUpdateFromUserState() async {
    try {
      // Obtener el usuario actual del estado de autenticación
      final user = _ref.read(authControllerProvider).value;
      if (user == null) {
        log('forceUpdateFromUserState: No hay usuario autenticado');
        return;
      }

      // Actualizar directamente el estado basado en el valor del usuario
      final preferencesCompleted = user.initialPreferencesCompleted;
      log(
        'forceUpdateFromUserState: Actualizando estado directamente, initialPreferencesCompleted=$preferencesCompleted',
      );

      state = state.copyWith(
        isLoading: false,
        hasCompletedPreferences: preferencesCompleted,
      );
    } catch (e) {
      log('Error en forceUpdateFromUserState: $e');
    }
  }

  /// Forzar sincronización inmediata con Firestore
  Future<void> forceSyncWithFirestore() async {
    try {
      log('🔄 Forzando sincronización con Firestore...');

      // Actualizar estado a cargando
      state = state.copyWith(isLoading: true);

      // Obtener datos frescos directamente desde Firestore
      final authController = _ref.read(authControllerProvider.notifier);
      await authController.refreshUserFromFirestore();

      // Obtener el usuario actualizado
      final updatedUser = _ref.read(authControllerProvider).value;

      if (updatedUser != null) {
        final firestoreValue = updatedUser.initialPreferencesCompleted;
        log(
          '✅ Sincronización completa - initialPreferencesCompleted: $firestoreValue',
        );

        // Actualizar estado con el valor de Firestore
        state = state.copyWith(
          isLoading: false,
          hasCompletedPreferences: firestoreValue,
        );
      } else {
        log('⚠️ No se pudo obtener usuario actualizado');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      log('❌ Error en forceSyncWithFirestore: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Método específico para INICIAR SESIÓN - siempre lee desde Firestore
  Future<void> loadUserPreferencesFromFirestore() async {
    try {
      log('🔄 INICIO SESIÓN: Cargando preferencias desde Firestore...');

      // Actualizar estado a cargando
      state = state.copyWith(isLoading: true);

      final authController = _ref.read(authControllerProvider.notifier);
      final user = _ref.read(authControllerProvider).value;

      // Si no hay usuario, resetear estado
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          hasCompletedPreferences: false,
        );
        return;
      }

      // SIEMPRE refrescar datos del usuario desde Firestore en login
      await authController.refreshUserFromFirestore();

      // Obtener el usuario actualizado después de refrescar
      final refreshedUser = _ref.read(authControllerProvider).value;

      if (refreshedUser != null) {
        // AUTO-FIX: Check if preferences are actually complete but flag is false
        await _autoFixPreferencesCompletionIfNeeded(refreshedUser);
      }

      // Obtener el usuario nuevamente después del posible auto-fix
      final finalUser = _ref.read(authControllerProvider).value;

      // Usar el valor de Firestore directamente
      final firestorePreferencesStatus =
          finalUser?.initialPreferencesCompleted ?? false;

      log(
        '✅ INICIO SESIÓN: Firestore initialPreferencesCompleted = $firestorePreferencesStatus',
      );

      // Actualizar el estado con el resultado de Firestore
      state = state.copyWith(
        isLoading: false,
        hasCompletedPreferences: firestorePreferencesStatus,
      );
    } catch (e) {
      log('❌ Error al cargar preferencias desde Firestore: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Auto-fix preferences completion flag if needed
  Future<void> _autoFixPreferencesCompletionIfNeeded(dynamic user) async {
    try {
      final currentFlag = user.initialPreferencesCompleted as bool? ?? false;
      
      // Skip if already marked as complete
      if (currentFlag) {
        return;
      }

      log('🔍 AUTO-FIX: Checking if preferences completion needs fixing for user ${user.id}');

      // Check if preferences are actually complete
      final isActuallyComplete = DebugHelpers.arePreferencesComplete(
        cookingLevel: user.prefs?.cookingLevel,
        allergies: user.prefs?.allergies,
        specialDiets: user.prefs?.specialDiets,
        preferredFoodTypes: user.prefs?.preferredFoodTypes,
      );

      if (isActuallyComplete) {
        log('🔧 AUTO-FIX: Preferences are complete but flag is false - fixing automatically');
        await DebugHelpers.forceCompleteUserPreferences(user.id);
        
        // Refresh user data after fix
        final authController = _ref.read(authControllerProvider.notifier);
        await authController.refreshUserFromFirestore();
        
        log('✅ AUTO-FIX: Preferences completion flag fixed automatically');
      }
    } catch (e) {
      log('❌ AUTO-FIX: Error during auto-fix: $e');
      // Don't throw - this is just a helpful auto-fix
    }
  }
}
