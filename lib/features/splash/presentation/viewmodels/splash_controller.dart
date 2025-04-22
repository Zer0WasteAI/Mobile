import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  /// Current status
  final SplashStatus status;

  /// Error message if any
  final String? error;

  /// Copy with method
  SplashState copyWith({
    SplashStatus? status,
    String? error,
  }) {
    return SplashState(
      status: status ?? this.status,
      error: error ?? this.error,
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
      
      // Set state to completed
      state = state.copyWith(status: SplashStatus.completed);
    } catch (e) {
      state = state.copyWith(
        status: SplashStatus.error,
        error: e.toString(),
      );
    }
  }
}