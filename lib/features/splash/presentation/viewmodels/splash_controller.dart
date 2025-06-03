import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';

/// Splash screen states
enum SplashStatus {
  /// Initial state
  initial,

  /// Loading state
  loading,

  /// Completed state
  completed,

  /// Error state
  error,
}

/// Splash state class
class SplashState {
  /// Constructor
  const SplashState({
    this.status = SplashStatus.initial,
    this.error,
    this.onboardingSeen = false,
  });

  /// Current status
  final SplashStatus status;

  /// Error message if any
  final String? error;

  /// Whether onboarding has been seen
  final bool onboardingSeen;

  /// Copy with method
  SplashState copyWith({
    SplashStatus? status,
    String? error,
    bool? onboardingSeen,
  }) {
    return SplashState(
      status: status ?? this.status,
      error: error ?? this.error,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    );
  }
}

/// Splash controller
class SplashController extends StateNotifier<SplashState> {
  /// Constructor
  SplashController(this.ref) : super(const SplashState()) {
    _initialize();
  }

  /// Reference to the provider
  final Ref ref;

  /// Initialize the splash screen
  Future<void> _initialize() async {
    state = state.copyWith(status: SplashStatus.loading);

    try {
      // Simular carga reducida a 1.5 segundos para una experiencia más fluida
      await Future.delayed(const Duration(milliseconds: 1500));

      // Verificar si el onboarding ha sido visto
      bool onboardingSeen = false;
      try {
        onboardingSeen = ref.read(onboardingSeenProvider);
      } catch (e) {
        // Si hay error al leer el onboarding, asumimos que no se ha visto
        log('Error al leer estado de onboarding: $e');
        onboardingSeen = false;
      }

      // Establecer estado como completado con estado de onboarding
      state = state.copyWith(
        status: SplashStatus.completed,
        onboardingSeen: onboardingSeen,
      );

      // Failsafe: Si después de 5 segundos todavía estamos en splash, forzar el estado a completado
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && (state.status != SplashStatus.completed)) {
          state = state.copyWith(
            status: SplashStatus.completed,
            onboardingSeen: onboardingSeen,
          );
        }
      });
    } catch (e) {
      log('Error en splash controller: $e');
      // Si hay un error, intentamos manejarlo y continuar con la navegación
      state = state.copyWith(
        status:
            SplashStatus
                .completed, // Importante: usamos completed en lugar de error
        error: e.toString(),
        // Asumimos que no ha visto el onboarding (por defecto)
      );
    }
  }
}
