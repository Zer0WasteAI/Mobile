import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Reset password parameters
class ResetPasswordParams {
  /// Email
  final String email;
  
  /// Code
  final String code;
  
  /// New password
  final String newPassword;
  
  /// Constructor
  const ResetPasswordParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}

/// Reset password use case
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const ResetPasswordUseCase(this.repository);
  
  @override
  Future<void> call(ResetPasswordParams params) {
    return repository.resetPassword(
      params.email,
      params.code,
      params.newPassword,
    );
  }
}