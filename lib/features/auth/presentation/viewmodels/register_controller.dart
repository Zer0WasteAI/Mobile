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
    String password, {
    String? phone,
  }) async {
    // ✅ FIXED: Use real registration through use case
    return await registerUseCase.call(
      RegisterParams(name: name, email: email, password: password),
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

    // Simple email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
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

  /// Validate phone number (optional)
  bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return true; // Phone is optional

    // Simple phone validation: at least 10 digits
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length >= 10;
  }

  /// Validate password confirmation
  bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
