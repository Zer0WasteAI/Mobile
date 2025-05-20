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

  // Configurar listener para recargar automáticamente cuando cambia el estado de autenticación
  ref.listen(authStateProvider, (previous, next) {
    if (next.hasValue) {
      // Si hay un nuevo usuario o cambio en la autenticación, recargar preferencias
      notifier.loadUserPreferences();
    } else if (next.isLoading) {
      // Si la autenticación está cargando, marcar como cargando
      notifier.setLoading();
    } else if (previous != null && previous.hasValue && !next.hasValue) {
      // Si se cerró sesión, resetear estado
      notifier.reset();
    }
  });

  // Inicializar preferencias inmediatamente
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

      // Verificar si ha completado las preferencias iniciales como respaldo
      final hasCompletedPreferences =
          await authController.hasCompletedInitialPreferences();

      print(
        'UserPreferencesService: Firestore initialPreferencesCompleted = $firestorePreferencesStatus, Verificación API = $hasCompletedPreferences',
      );

      // Si hay inconsistencia, registrarlo pero priorizar el valor de Firestore
      if (firestorePreferencesStatus != hasCompletedPreferences) {
        print(
          '⚠️ UserPreferencesService: Inconsistencia entre valor de Firestore y verificación API',
        );
      }

      // Actualizar el estado con el resultado, priorizando el valor de Firestore
      state = state.copyWith(
        isLoading: false,
        hasCompletedPreferences: firestorePreferencesStatus,
      );
    } catch (e) {
      print('Error al cargar preferencias del usuario: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Marcar las preferencias como completadas
  void markPreferencesAsCompleted() {
    state = state.copyWith(hasCompletedPreferences: true, isLoading: false);
    print(
      "UserPreferencesService: Preferencias marcadas como completadas en memoria",
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
        print('forceUpdateFromUserState: No hay usuario autenticado');
        return;
      }

      // Actualizar directamente el estado basado en el valor del usuario
      final preferencesCompleted = user.initialPreferencesCompleted;
      print(
        'forceUpdateFromUserState: Actualizando estado directamente, initialPreferencesCompleted=$preferencesCompleted',
      );

      state = state.copyWith(
        isLoading: false,
        hasCompletedPreferences: preferencesCompleted,
      );
    } catch (e) {
      print('Error en forceUpdateFromUserState: $e');
    }
  }
}
