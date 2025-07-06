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
    // ✅ FIXED: Use real authentication through use case
    return await loginUseCase.call(
      LoginParams(email: email, password: password),
    );
  }

  /// Login with Google
  Future<UserEntity> loginWithGoogle() async {
    // ✅ FIXED: Use real Google authentication through use case
    return await googleLoginUseCase.call(NoParams());
  }

  /// Login with Facebook
  Future<UserEntity> loginWithFacebook() async {
    // ✅ FIXED: Use real Facebook authentication through use case
    return await facebookLoginUseCase.call(NoParams());
  }

  /// Login with Apple
  Future<UserEntity> loginWithApple() async {
    // ✅ FIXED: Use real Apple authentication through use case
    return await appleLoginUseCase.call(NoParams());
  }

  /// Validate email
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Simple email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
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
