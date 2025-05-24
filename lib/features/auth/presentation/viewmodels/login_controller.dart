import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/login_usecase.dart';

/// Login controller
class LoginController {
  /// Email/password login use case
  final LoginUseCase loginUseCase;

  /// Google login use case
  final GoogleLoginUseCase googleLoginUseCase;

  /// Facebook login use case
  final FacebookLoginUseCase facebookLoginUseCase;

  /// Apple login use case
  final AppleLoginUseCase appleLoginUseCase;

  /// Constructor
  const LoginController({
    required this.loginUseCase,
    required this.googleLoginUseCase,
    required this.facebookLoginUseCase,
    required this.appleLoginUseCase,
  });

  /// Login with email and password
  Future<UserEntity> login(String email, String password) async {
    final params = LoginParams(email: email, password: password);
    return await loginUseCase(params);
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
    // Return a mock user for UI navigation without functionality
    return UserEntity(
      id: 'apple-user-id',
      email: 'apple@example.com',
      displayName: 'Apple User',
      photoURL: 'https://via.placeholder.com/150',
    );
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
}
