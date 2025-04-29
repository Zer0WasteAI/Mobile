import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/send_reset_code_usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/login_provider.dart';
import 'package:zer0_waste_ai/features/auth/presentation/viewmodels/forgot_password_controller.dart';

/// Forgot password step
enum ForgotPasswordStep {
  /// Email input step
  emailInput,

  /// Code verification step
  codeVerification,

  /// Password reset step
  passwordReset,

  /// Success step
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

  /// Code
  final String code;

  /// New password
  final String newPassword;

  /// Confirm password
  final String confirmPassword;

  /// Email error message
  final String? emailError;

  /// Code error message
  final String? codeError;

  /// New password error message
  final String? newPasswordError;

  /// Confirm password error message
  final String? confirmPasswordError;

  /// Verification attempts
  final int verificationAttempts;

  /// Resend timer in seconds
  final int resendTimer;

  final bool isLoading;

  /// Is email form valid
  bool get isEmailFormValid => emailError == null && email.isNotEmpty;

  /// Is code form valid
  bool get isCodeFormValid => codeError == null && code.isNotEmpty;

  /// Is password form valid
  bool get isPasswordFormValid =>
      newPasswordError == null &&
      confirmPasswordError == null &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty;

  /// Constructor
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.emailInput,
    this.email = '',
    this.code = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.emailError,
    this.codeError,
    this.newPasswordError,
    this.confirmPasswordError,
    this.verificationAttempts = 0,
    this.resendTimer = 0,
    this.isLoading = false,
  });

  /// Copy with
  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? email,
    String? code,
    String? newPassword,
    String? confirmPassword,
    Object? emailError = const _NotPassed(),
    Object? codeError = const _NotPassed(),
    Object? newPasswordError = const _NotPassed(),
    Object? confirmPasswordError = const _NotPassed(),
    int? verificationAttempts,
    int? resendTimer,
    bool? isLoading,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailError:
          emailError is _NotPassed ? this.emailError : emailError as String?,
      codeError:
          codeError is _NotPassed ? this.codeError : codeError as String?,
      newPasswordError:
          newPasswordError is _NotPassed
              ? this.newPasswordError
              : newPasswordError as String?,
      confirmPasswordError:
          confirmPasswordError is _NotPassed
              ? this.confirmPasswordError
              : confirmPasswordError as String?,
      verificationAttempts: verificationAttempts ?? this.verificationAttempts,
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

  /// Update code
  void updateCode(String code) {
    final isValid = _controller.isValidCode(code);
    state = state.copyWith(
      code: code,
      codeError:
          isValid ? null : 'Por favor, ingresa un código válido de 6 dígitos',
    );
  }

  /// Update new password
  void updateNewPassword(String newPassword) {
    final passwordValidationError = _controller.validatePassword(newPassword);
    final doMatch = _controller.doPasswordsMatch(
      newPassword,
      state.confirmPassword,
    );

    state = state.copyWith(
      newPassword: newPassword,
      newPasswordError: passwordValidationError,
      confirmPasswordError:
          state.confirmPassword.isEmpty
              ? null
              : (doMatch ? null : 'Las contraseñas no coinciden'),
    );
  }

  /// Update confirm password
  void updateConfirmPassword(String confirmPassword) {
    final doMatch = _controller.doPasswordsMatch(
      state.newPassword,
      confirmPassword,
    );
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: doMatch ? null : 'Las contraseñas no coinciden',
    );
  }

  /// Send reset code
  Future<bool> sendResetCode() async {
    if (!state.isEmailFormValid || state.isLoading) return false;

    state = state.copyWith(isLoading: true);

    try {
      await _controller.sendResetCode(state.email);

      // Move to code verification step
      state = state.copyWith(
        step: ForgotPasswordStep.codeVerification,
        emailError: null,
        code: '',
        verificationAttempts: 0,
        resendTimer: 60,
        isLoading: false,
      );
      _startInternalTimer();

      return true;
    } catch (e) {
      state = state.copyWith(
        emailError: 'Error al enviar el código de restablecimiento: $e',
        isLoading: false,
      );
      return false;
    }
  }

  /// Verify code
  Future<bool> verifyCode() async {
    if (!state.isCodeFormValid || state.isLoading) return false;

    state = state.copyWith(isLoading: true);

    try {
      final isValid = await _controller.verifyCode(state.email, state.code);

      if (isValid) {
        _stopInternalTimer();
        // Move to password reset step
        state = state.copyWith(
          step: ForgotPasswordStep.passwordReset,
          code: '',
          codeError: null,
          isLoading: false,
        );
        return true;
      } else {
        // Increment verification attempts
        final newAttempts = state.verificationAttempts + 1;

        if (newAttempts >= 3) {
          // Demasiados intentos, volver al inicio
          _stopInternalTimer();
          resetToEmailInput(
            initialEmailError:
                'Demasiados intentos de verificación. Por favor, inténtalo de nuevo.',
          );
          // isLoading ya se pondrá a false en resetToEmailInput
          return false;
        } else {
          state = state.copyWith(
            verificationAttempts: newAttempts,
            codeError: 'Código inválido. Por favor, inténtalo de nuevo.',
            isLoading: false,
          );
          return false;
        }
      }
    } catch (e) {
      // Check if too many attempts
      state = state.copyWith(
        codeError: 'Error al verificar el código: $e',
        verificationAttempts: state.verificationAttempts + 1,
        isLoading: false,
      );
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword() async {
    if (!state.isPasswordFormValid || state.isLoading) return false;

    state = state.copyWith(isLoading: true);

    try {
      await _controller.resetPassword(
        state.email,
        state.code,
        state.newPassword,
      );

      // Move to success step
      state = state.copyWith(
        step: ForgotPasswordStep.success,
        isLoading: false,
        newPassword: '',
        confirmPassword: '',
        newPasswordError: null,
        confirmPasswordError: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        newPasswordError: 'Error al restablecer la contraseña: $e',
        isLoading: false,
      );
      return false;
    }
  }

  void _startInternalTimer() {
    _timer?.cancel(); // Cancela timer anterior si existe
    if (state.resendTimer > 0) {
      state = state.copyWith(resendTimer: 60);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.resendTimer > 0) {
          state = state.copyWith(resendTimer: state.resendTimer - 1);
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  void _stopInternalTimer() {
    _timer?.cancel();
    state = state.copyWith(resendTimer: 0);
  }

  Future<void> resendCode() async {
    await sendResetCode();
  }

  void resetToEmailInput({String? initialEmailError}) {
    _stopInternalTimer();
    state = ForgotPasswordState(
      email: state.email,
      emailError: initialEmailError,
      isLoading: false,
    );
  }

  /// Decrement resend timer
  void decrementResendTimer() {
    if (state.resendTimer > 0) {
      state = state.copyWith(resendTimer: state.resendTimer - 1);
    }
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

/// Verify code use case provider
final verifyCodeUseCaseProvider = Provider<VerifyCodeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyCodeUseCase(repository);
});

/// Reset password use case provider
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

/// Forgot password controller provider
final forgotPasswordControllerProvider = Provider<ForgotPasswordController>((
  ref,
) {
  return ForgotPasswordController(
    sendResetCodeUseCase: ref.watch(sendResetCodeUseCaseProvider),
    verifyCodeUseCase: ref.watch(verifyCodeUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
  );
});

/// Forgot password notifier provider
final forgotPasswordProvider = StateNotifierProvider.autoDispose<
  ForgotPasswordNotifier,
  ForgotPasswordState
>((ref) {
  return ForgotPasswordNotifier(ref.watch(forgotPasswordControllerProvider));
});
