import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Verify code parameters
class VerifyCodeParams {
  /// Email
  final String email;
  
  /// Code
  final String code;
  
  /// Constructor
  const VerifyCodeParams({
    required this.email,
    required this.code,
  });
}

/// Verify code use case
class VerifyCodeUseCase implements UseCase<bool, VerifyCodeParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const VerifyCodeUseCase(this.repository);
  
  @override
  Future<bool> call(VerifyCodeParams params) {
    return repository.verifyResetCode(params.email, params.code);
  }
}