import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Login parameters
class LoginParams {
  /// Email
  final String email;
  
  /// Password
  final String password;
  
  /// Constructor
  const LoginParams({
    required this.email,
    required this.password,
  });
}

/// Login use case
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const LoginUseCase(this.repository);
  
  @override
  Future<UserEntity> call(LoginParams params) {
    return repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

/// Google login use case
class GoogleLoginUseCase implements UseCase<UserEntity, NoParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const GoogleLoginUseCase(this.repository);
  
  @override
  Future<UserEntity> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}

/// Facebook login use case
class FacebookLoginUseCase implements UseCase<UserEntity, NoParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const FacebookLoginUseCase(this.repository);
  
  @override
  Future<UserEntity> call(NoParams params) {
    return repository.signInWithFacebook();
  }
}

/// Apple login use case
class AppleLoginUseCase implements UseCase<UserEntity, NoParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const AppleLoginUseCase(this.repository);
  
  @override
  Future<UserEntity> call(NoParams params) {
    return repository.signInWithApple();
  }
}