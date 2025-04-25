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
      // Simulate loading for 2-3 seconds
      await Future.delayed(const Duration(seconds: 3));

      // Check if onboarding has been seen
      final onboardingSeen = ref.read(onboardingSeenProvider);

      // Set state to completed with onboarding seen status
      state = state.copyWith(
        status: SplashStatus.completed,
        onboardingSeen: onboardingSeen,
      );
    } catch (e) {
      state = state.copyWith(
        status: SplashStatus.error,
        error: e.toString(),
      );
    }
  }
}
