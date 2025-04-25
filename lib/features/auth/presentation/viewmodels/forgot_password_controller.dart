import 'package:zer0_waste_ai/features/auth/domain/usecases/send_reset_code_usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/reset_password_usecase.dart';

/// Forgot password controller
class ForgotPasswordController {
  /// Send reset code use case
  final SendResetCodeUseCase sendResetCodeUseCase;

  /// Verify code use case
  final VerifyCodeUseCase verifyCodeUseCase;

  /// Reset password use case
  final ResetPasswordUseCase resetPasswordUseCase;

  /// Constructor
  const ForgotPasswordController({
    required this.sendResetCodeUseCase,
    required this.verifyCodeUseCase,
    required this.resetPasswordUseCase,
  });

  /// Send reset code to email
  Future<void> sendResetCode(String email) async {
    // Mock implementation for UI navigation without functionality
    // Just return without doing anything
    return;
  }

  /// Verify reset code
  Future<bool> verifyCode(String email, String code) async {
    // Mock implementation for UI navigation without functionality
    // Always return true to allow navigation to next step
    return true;
  }

  /// Reset password
  Future<void> resetPassword(String email, String code, String newPassword) async {
    // Mock implementation for UI navigation without functionality
    // Just return without doing anything
    return;
  }

  /// Validate email
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Simple email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  /// Validate code
  bool isValidCode(String code) {
    // Code should be 6 digits
    return code.length == 6 && int.tryParse(code) != null;
  }

  /// Validate password
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain at least one number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return 'Password must contain at least one special character';
    return null;
  }

  /// Validate password confirmation
  bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
