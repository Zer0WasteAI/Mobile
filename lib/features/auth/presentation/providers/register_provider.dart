import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:zer0_waste_ai/features/auth/presentation/viewmodels/register_controller.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Sentinel value for optional parameters
class _NotPassed {
  const _NotPassed();
}

/// Register state
class RegisterState {
  /// Name
  final String name;

  /// Email
  final String email;

  /// Password
  final String password;

  /// Confirm password
  final String confirmPassword;

  /// Name error
  final String? nameError;

  /// Email error
  final String? emailError;

  /// Password error
  final String? passwordError;

  /// Confirm password error
  final String? confirmPasswordError;

  /// Is loading
  final bool isLoading;

  /// Constructor
  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
  });

  /// Is valid
  bool get isValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null;

  /// Copy with
  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    Object? nameError = const _NotPassed(),
    Object? emailError = const _NotPassed(),
    Object? passwordError = const _NotPassed(),
    Object? confirmPasswordError = const _NotPassed(),
    bool? isLoading,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameError:
          nameError is _NotPassed ? this.nameError : nameError as String?,
      emailError:
          emailError is _NotPassed ? this.emailError : emailError as String?,
      passwordError:
          passwordError is _NotPassed
              ? this.passwordError
              : passwordError as String?,
      confirmPasswordError:
          confirmPasswordError is _NotPassed
              ? this.confirmPasswordError
              : confirmPasswordError as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Register form state notifier (solo para el estado del formulario)
class RegisterFormNotifier extends StateNotifier<RegisterState> {
  final RegisterController _controller;

  RegisterFormNotifier(this._controller) : super(const RegisterState());

  /// Update name
  void updateName(String name) {
    final isValid = _controller.isValidName(name);
    state = state.copyWith(
      name: name,
      nameError:
          isValid
              ? null
              : 'Por favor, ingresa tu nombre completo (nombre y apellido)',
    );
  }

  /// Update email
  void updateEmail(String email) {
    final isValid = _controller.isValidEmail(email);
    state = state.copyWith(
      email: email,
      emailError:
          isValid ? null : 'Por favor, ingresa un correo electrónico válido',
    );
  }

  /// Update password
  void updatePassword(String password) {
    final passwordError = _controller.validatePassword(password);
    final doMatch = _controller.doPasswordsMatch(
      password,
      state.confirmPassword,
    );

    state = state.copyWith(
      password: password,
      passwordError: passwordError,
      confirmPasswordError:
          state.confirmPassword.isEmpty
              ? null
              : (doMatch ? null : 'Las contraseñas no coinciden'),
    );
  }

  /// Update confirm password
  void updateConfirmPassword(String confirmPassword) {
    final doMatch = _controller.doPasswordsMatch(
      state.password,
      confirmPassword,
    );
    state = state.copyWith(
      confirmPassword: confirmPassword,
      confirmPasswordError: doMatch ? null : 'Las contraseñas no coinciden',
    );
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// Register authentication notifier (solo para el resultado de autenticación)
class RegisterAuthNotifier extends AutoDisposeAsyncNotifier<UserEntity?> {
  late final RegisterController _controller;

  @override
  Future<UserEntity?> build() async {
    _controller = ref.watch(registerControllerProvider);
    return null;
  }

  /// Register with email and password
  Future<void> register(String name, String email, String password) async {
    try {
      state = const AsyncValue.loading();
    } catch (_) {
      // Si el notifier fue disposed, no hacer nada
      return;
    }

    try {
      final result = await _controller.register(name, email, password);
      try {
        state = AsyncValue.data(result);
      } catch (_) {
        // Si el notifier fue disposed, no hacer nada
      }
    } catch (error, stackTrace) {
      try {
        state = AsyncValue.error(error, stackTrace);
      } catch (_) {
        // Si el notifier fue disposed, no hacer nada
      }
    }
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    try {
      state = const AsyncValue.loading();
    } catch (_) {
      return;
    }

    try {
      final result = await _controller.loginWithGoogle();
      try {
        state = AsyncValue.data(result);
      } catch (_) {}
    } catch (error, stackTrace) {
      try {
        state = AsyncValue.error(error, stackTrace);
      } catch (_) {}
    }
  }

  /// Login with Facebook
  Future<void> loginWithFacebook() async {
    try {
      state = const AsyncValue.loading();
    } catch (_) {
      return;
    }

    try {
      final result = await _controller.loginWithFacebook();
      try {
        state = AsyncValue.data(result);
      } catch (_) {}
    } catch (error, stackTrace) {
      try {
        state = AsyncValue.error(error, stackTrace);
      } catch (_) {}
    }
  }

  /// Login with Apple
  Future<void> loginWithApple() async {
    try {
      state = const AsyncValue.loading();
    } catch (_) {
      return;
    }

    try {
      final result = await _controller.loginWithApple();
      try {
        state = AsyncValue.data(result);
      } catch (_) {}
    } catch (error, stackTrace) {
      try {
        state = AsyncValue.error(error, stackTrace);
      } catch (_) {}
    }
  }
}

/// Register use case provider
final registerUseCaseProvider = Provider.autoDispose<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

/// Google login use case provider
final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleLoginUseCase(repository);
});

/// Facebook login use case provider
final facebookLoginUseCaseProvider = Provider<FacebookLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return FacebookLoginUseCase(repository);
});

/// Apple login use case provider
final appleLoginUseCaseProvider = Provider<AppleLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AppleLoginUseCase(repository);
});

/// Register controller provider
final registerControllerProvider = Provider.autoDispose<RegisterController>((
  ref,
) {
  return RegisterController(
    registerUseCase: ref.watch(registerUseCaseProvider),
    googleLoginUseCase: ref.watch(googleLoginUseCaseProvider),
    facebookLoginUseCase: ref.watch(facebookLoginUseCaseProvider),
    appleLoginUseCase: ref.watch(appleLoginUseCaseProvider),
  );
});

/// Register form state provider
final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterState>((
      ref,
    ) {
      final controller = ref.watch(registerControllerProvider);
      return RegisterFormNotifier(controller);
    });

/// Register authentication provider
final registerAuthProvider =
    AsyncNotifierProvider.autoDispose<RegisterAuthNotifier, UserEntity?>(() {
      return RegisterAuthNotifier();
    });

/// Combined register provider que coordina formulario y autenticación
final registerProvider = Provider.autoDispose<RegisterProviderState>((ref) {
  final formState = ref.watch(registerFormProvider);
  final authState = ref.watch(registerAuthProvider);

  return RegisterProviderState(formState: formState, authState: authState);
});

/// Estado combinado para el registro
class RegisterProviderState {
  final RegisterState formState;
  final AsyncValue<UserEntity?> authState;

  const RegisterProviderState({
    required this.formState,
    required this.authState,
  });

  bool get isLoading => formState.isLoading || authState.isLoading;
  bool get hasError => authState.hasError;
  Object? get error => authState.error;
  StackTrace? get stackTrace => authState.stackTrace;
  bool get hasValue => authState.hasValue;
  UserEntity? get value => authState.value;
}

/*
PROVIDERS DISPONIBLES:
- `registerProvider`: Estado combinado (formulario + autenticación)
- `registerFormProvider`: Solo el estado del formulario y validaciones
- `registerAuthProvider`: Solo el estado de autenticación (loading, success, error)

VENTAJAS DE LA NUEVA ARQUITECTURA:
✅ Separación clara de responsabilidades
✅ Testeo más fácil (cada provider por separado)
✅ Mejor performance (providers más específicos)
✅ Menos conflictos de estado en Riverpod
✅ Código más mantenible y escalable
*/
