import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/data/mappers/user_mapper.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Register parameters
class RegisterParams {
  /// Full name
  final String name;

  /// Email
  final String email;

  /// Password
  final String password;

  /// Phone number (optional)
  final String? phone;

  /// Constructor
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });
}

/// Register use case
class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  /// Auth repository
  final AuthRepository repository;

  /// Constructor
  const RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) async {
    final userModel = await repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
      params.name,
    );

    // Note: The phone number can't be updated directly with the current repository interface
    // The interface only supports updating displayName and photoURL
    // A more comprehensive solution would require modifying the repository interface

    return userModel.toEntity();
  }
}
