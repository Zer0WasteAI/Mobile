/// Excepciones personalizadas para manejo centralizado de errores
///
/// Estas excepciones se usan en la capa de datos (repositories)
/// y se convierten en Failures en la capa de dominio
library;

/// Excepción cuando hay problemas con el servidor
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

/// Excepción cuando hay problemas de red/conectividad
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción cuando hay problemas de autenticación
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException([this.message = 'Authentication failed']);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Excepción cuando hay problemas con caché local
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción cuando hay problemas de validación
class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation failed']);

  @override
  String toString() => 'ValidationException: $message';
}

/// Excepción cuando el usuario no tiene permisos
class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);

  @override
  String toString() => 'PermissionException: $message';
}

/// Excepción cuando el recurso no se encuentra
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Excepción para errores de timeout
class TimeoutException implements Exception {
  final String message;
  const TimeoutException([this.message = 'Operation timed out']);

  @override
  String toString() => 'TimeoutException: $message';
}
