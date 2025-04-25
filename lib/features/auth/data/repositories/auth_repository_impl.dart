import 'package:zer0_waste_ai/features/auth/data/datasources/auth_api.dart';
import 'package:zer0_waste_ai/features/auth/domain/entities/user_entity.dart';
import 'package:zer0_waste_ai/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  /// Auth API
  final AuthApi authApi;

  /// Constructor
  const AuthRepositoryImpl(this.authApi);

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    return await authApi.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword(String name, String email, String password, {String? phone}) async {
    return await authApi.registerWithEmailAndPassword(name, email, password, phone: phone);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await authApi.signInWithGoogle();
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    return await authApi.signInWithFacebook();
  }

  @override
  Future<UserEntity> signInWithApple() async {
    return await authApi.signInWithApple();
  }

  @override
  Future<void> signOut() async {
    await authApi.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await authApi.getCurrentUser();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await authApi.sendPasswordResetEmail(email);
  }

  @override
  Future<bool> verifyResetCode(String email, String code) async {
    return await authApi.verifyResetCode(email, code);
  }

  @override
  Future<void> resetPassword(String email, String code, String newPassword) async {
    await authApi.resetPassword(email, code, newPassword);
  }
}
