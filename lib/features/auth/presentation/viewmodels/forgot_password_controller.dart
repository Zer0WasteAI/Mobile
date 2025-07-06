import 'package:zer0_waste_ai/features/auth/domain/usecases/send_reset_code_usecase.dart';

/// Forgot password controller
class ForgotPasswordController {
  /// Send reset code use case
  final SendResetCodeUseCase sendResetCodeUseCase;

  /// Constructor
  const ForgotPasswordController({required this.sendResetCodeUseCase});

  /// Send reset code to email
  Future<void> sendResetCode(String email) async {
    await sendResetCodeUseCase.call(SendResetCodeParams(email: email));
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
    if (password.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'La contraseña debe contener al menos un carácter especial';
    }
    return null;
  }

  /// Validate password confirmation
  bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
