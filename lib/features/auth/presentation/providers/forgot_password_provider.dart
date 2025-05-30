import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/send_reset_code_usecase.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/viewmodels/forgot_password_controller.dart';

/// Forgot password step
enum ForgotPasswordStep {
  /// Email input step
  emailInput,

  /// Success step (email sent)
  success,
}

class _NotPassed {
  const _NotPassed();
}

/// Forgot password state
class ForgotPasswordState {
  /// Current step
  final ForgotPasswordStep step;

  /// Email
  final String email;

  /// Email error message
  final String? emailError;

  /// Resend timer in seconds
  final int resendTimer;

  final bool isLoading;

  /// Is email form valid
  bool get isEmailFormValid => emailError == null && email.isNotEmpty;

  /// Constructor
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.emailInput,
    this.email = '',
    this.emailError,
    this.resendTimer = 0,
    this.isLoading = false,
  });

  /// Copy with
  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? email,
    Object? emailError = const _NotPassed(),
    int? resendTimer,
    bool? isLoading,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      emailError:
          emailError is _NotPassed ? this.emailError : emailError as String?,
      resendTimer: resendTimer ?? this.resendTimer,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Forgot password notifier
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  /// Forgot password controller
  final ForgotPasswordController _controller;
  Timer? _timer;

  /// Constructor
  ForgotPasswordNotifier(this._controller) : super(const ForgotPasswordState());

  /// Update email
  void updateEmail(String email) {
    final isValid = _controller.isValidEmail(email);
    state = state.copyWith(
      email: email,
      emailError:
          isValid ? null : 'Por favor, ingresa un correo electrónico válido',
    );
  }

  /// Send reset code
  Future<bool> sendResetCode() async {
    if (!state.isEmailFormValid || state.isLoading) return false;

    state = state.copyWith(isLoading: true);

    try {
      await _controller.sendResetCode(state.email);

      // Move to success step
      state = state.copyWith(
        step: ForgotPasswordStep.success,
        emailError: null,
        resendTimer: 60,
        isLoading: false,
      );
      _startResendTimer();

      return true;
    } catch (e) {
      state = state.copyWith(
        emailError: 'Error al enviar el correo de restablecimiento: $e',
        isLoading: false,
      );
      return false;
    }
  }

  void _startResendTimer() {
    _timer?.cancel(); // Cancel previous timer if exists
    if (state.resendTimer > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.resendTimer > 0) {
          state = state.copyWith(resendTimer: state.resendTimer - 1);
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    state = state.copyWith(resendTimer: 0);
  }

  Future<void> resendCode() async {
    if (state.resendTimer == 0) {
      await sendResetCode();
    }
  }

  void resetToEmailInput({String? initialEmailError}) {
    _stopTimer();
    state = ForgotPasswordState(
      email: state.email,
      emailError: initialEmailError,
      isLoading: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Send reset code use case provider
final sendResetCodeUseCaseProvider = Provider<SendResetCodeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendResetCodeUseCase(repository);
});

/// Forgot password controller provider
final forgotPasswordControllerProvider = Provider<ForgotPasswordController>((
  ref,
) {
  return ForgotPasswordController(
    sendResetCodeUseCase: ref.watch(sendResetCodeUseCaseProvider),
  );
});

/// Forgot password notifier provider
final forgotPasswordProvider = StateNotifierProvider.autoDispose<
  ForgotPasswordNotifier,
  ForgotPasswordState
>((ref) {
  return ForgotPasswordNotifier(ref.watch(forgotPasswordControllerProvider));
});
