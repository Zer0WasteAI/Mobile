import 'package:equatable/equatable.dart';

/// Clase base para todos los failures (errores de dominio)
///
/// Los Failures representan errores en la capa de dominio y se usan
// ignore: unintended_html_in_doc_comment
/// como resultado de Either<Failure, Success> en los use cases

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Failure cuando hay problemas con el servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Failure cuando hay problemas de red/conectividad
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Failure cuando hay problemas de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

/// Failure cuando hay problemas con caché local
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Failure cuando hay problemas de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Failure cuando el usuario no tiene permisos
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}

/// Failure cuando el recurso no se encuentra
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.code]);
}

/// Failure para errores de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.code]);
}

/// Failure genérico para errores inesperados
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.code]);
}

/// Failure para errores de formato de datos
class FormatFailure extends Failure {
  const FormatFailure(super.message, [super.code]);
}

/// Extensión para convertir Exceptions en Failures
extension ExceptionToFailure on Exception {
  Failure toFailure() {
    final String message = toString();

    if (message.contains('ServerException')) {
      return ServerFailure(message);
    } else if (message.contains('NetworkException')) {
      return NetworkFailure(message);
    } else if (message.contains('AuthenticationException')) {
      return AuthenticationFailure(message);
    } else if (message.contains('CacheException')) {
      return CacheFailure(message);
    } else if (message.contains('ValidationException')) {
      return ValidationFailure(message);
    } else if (message.contains('PermissionException')) {
      return PermissionFailure(message);
    } else if (message.contains('NotFoundException')) {
      return NotFoundFailure(message);
    } else if (message.contains('TimeoutException')) {
      return TimeoutFailure(message);
    } else {
      return UnexpectedFailure(message);
    }
  }
}
