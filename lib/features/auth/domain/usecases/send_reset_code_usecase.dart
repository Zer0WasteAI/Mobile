import 'package:zer0_waste_ai/core/usecases/usecase.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Send reset code parameters
class SendResetCodeParams {
  /// Email
  final String email;
  
  /// Constructor
  const SendResetCodeParams({
    required this.email,
  });
}

/// Send reset code use case
class SendResetCodeUseCase implements UseCase<void, SendResetCodeParams> {
  /// Auth repository
  final AuthRepository repository;
  
  /// Constructor
  const SendResetCodeUseCase(this.repository);
  
  @override
  Future<void> call(SendResetCodeParams params) {
    return repository.sendPasswordResetEmail(params.email);
  }
}