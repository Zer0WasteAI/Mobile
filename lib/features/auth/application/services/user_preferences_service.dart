import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

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

  // SOLUCIÓN: NO usar listener automático que sobrescribe el estado en memoria
  // El listener automático causa race conditions cuando marcamos preferencias en memoria
  // ref.listen(authStateProvider, (previous, next) {
  //   if (next.hasValue) {
  //     // Si hay un nuevo usuario o cambio en la autenticación, recargar preferencias
  //     notifier.loadUserPreferences();
  //   } else if (next.isLoading) {
  //     // Si la autenticación está cargando, marcar como cargando
  //     notifier.setLoading();
  //   } else if (previous != null && previous.hasValue && !next.hasValue) {
  //     // Si se cerró sesión, resetear estado
  //     notifier.reset();
  //   }
  // });

  // Inicializar preferencias inmediatamente solo una vez
  notifier.loadUserPreferences();

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
      // SI YA ESTÁN MARCADAS COMO COMPLETADAS EN MEMORIA, NO SOBRESCRIBIR
      if (state.hasCompletedPreferences) {
        log(
          '⚡ Preferencias ya marcadas como completadas en memoria - NO sobrescribir',
        );
        return;
      }

      final authController = _ref.read(authControllerProvider.notifier);
      final user = _ref.read(authControllerProvider).value;

      // Si no hay usuario, no es necesario cargar preferencias
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          hasCompletedPreferences: false,
        );
        return;
      }

      // Refrescar datos del usuario desde Firestore
      await authController.refreshUserFromFirestore();

      // Obtener el usuario actualizado después de refrescar
      final refreshedUser = _ref.read(authControllerProvider).value;

      // Usar el valor de Firestore directamente (más confiable)
      final firestorePreferencesStatus =
          refreshedUser?.initialPreferencesCompleted ?? false;

      log(
        'UserPreferencesService: Firestore initialPreferencesCompleted = $firestorePreferencesStatus',
      );

      // Actualizar el estado con el resultado, priorizando el valor de Firestore
      state = state.copyWith(
        isLoading: false,
        hasCompletedPreferences: firestorePreferencesStatus,
      );
    } catch (e) {
      log('Error al cargar preferencias del usuario: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Marcar las preferencias como completadas
  Future<void> markPreferencesAsCompleted() async {
    // Marcar inmediatamente en memoria para evitar redirecciones
    state = state.copyWith(hasCompletedPreferences: true, isLoading: false);
    log(
      "UserPreferencesService: Preferencias marcadas como completadas en memoria",
    );

    // No intentar guardar en Firestore aquí para evitar duplicados
    // El guardado en Firestore debe hacerse desde el screen que maneja la lógica de negocio
    log(
      "UserPreferencesService: No guardando en Firestore para evitar race conditions",
    );
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

      // Usar el valor de Firestore directamente
      final firestorePreferencesStatus =
          refreshedUser?.initialPreferencesCompleted ?? false;

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
}
