import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/login_usecase.dart';

/// Register controller
class RegisterController {
  /// Register use case
  final RegisterUseCase registerUseCase;

  /// Google login use case
  final GoogleLoginUseCase googleLoginUseCase;

  /// Facebook login use case
  final FacebookLoginUseCase facebookLoginUseCase;

  /// Apple login use case
  final AppleLoginUseCase appleLoginUseCase;

  /// Constructor
  const RegisterController({
    required this.registerUseCase,
    required this.googleLoginUseCase,
    required this.facebookLoginUseCase,
    required this.appleLoginUseCase,
  });

  /// Register with email and password
  Future<UserEntity> register(
    String name,
    String email,
    String password,
  ) async {
    final params = RegisterParams(name: name, email: email, password: password);
    return await registerUseCase(params);
  }

  /// Login with Google
  Future<UserEntity> loginWithGoogle() async {
    return await googleLoginUseCase(const NoParams());
  }

  /// Login with Facebook
  Future<UserEntity> loginWithFacebook() async {
    return await facebookLoginUseCase(const NoParams());
  }

  /// Login with Apple
  Future<UserEntity> loginWithApple() async {
    return await appleLoginUseCase(const NoParams());
  }

  /// Validate name
  bool isValidName(String name) {
    if (name.isEmpty) return false;

    // Name should have at least 2 words (first and last name)
    final nameWords = name.trim().split(' ');
    return nameWords.length >= 2 && nameWords.every((word) => word.isNotEmpty);
  }

  /// Validate email
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Mejorar la validación de email para ser compatible con Firebase
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // Verificaciones adicionales
    if (!emailRegex.hasMatch(email)) return false;

    // No permitir emails que empiecen o terminen con puntos
    if (email.startsWith('.') || email.endsWith('.')) return false;

    // No permitir puntos consecutivos
    if (email.contains('..')) return false;

    // Verificar que el dominio no empiece o termine con guión
    final parts = email.split('@');
    if (parts.length != 2) return false;

    final domain = parts[1];
    if (domain.startsWith('-') || domain.endsWith('-')) return false;

    return true;
  }

  /// Validate password
  bool isValidPassword(String password) {
    if (password.length < 6) return false;

    // Password should contain at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'La contraseña es obligatoria';
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
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
