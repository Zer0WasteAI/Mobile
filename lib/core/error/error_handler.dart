import 'package:dio/dio.dart';
import 'failures.dart';
import 'exceptions.dart';
import 'dart:developer';

/// Manejador centralizado de errores
///
/// Convierte errores de diferentes fuentes (Dio, Firebase, etc.)
/// en mensajes amigables para el usuario

class ErrorHandler {
  /// Convierte cualquier error en un mensaje amigable para el usuario
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Failure) {
      return _handleFailure(error);
    } else if (error is Exception) {
      return _handleException(error);
    } else {
      return 'Ha ocurrido un error inesperado';
    }
  }

  /// Maneja errores específicos de Dio (HTTP)
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado. Verifica tu conexión a internet.';

      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado. Intenta nuevamente.';

      case DioExceptionType.receiveTimeout:
        return 'Tiempo de respuesta agotado. El servidor tardó demasiado en responder.';

      case DioExceptionType.badResponse:
        return _handleHttpStatusCode(error.response?.statusCode);

      case DioExceptionType.cancel:
        return 'Operación cancelada';

      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu conexión a internet.';

      case DioExceptionType.badCertificate:
        return 'Error de certificado SSL. No se puede verificar la seguridad de la conexión.';

      case DioExceptionType.unknown:
      // ignore: unreachable_switch_default
      default:
        return 'Error de conexión desconocido. Verifica tu conexión a internet.';
    }
  }

  /// Maneja códigos de estado HTTP
  static String _handleHttpStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud inválida. Verifica los datos ingresados.';
      case 401:
        return 'No autorizado. Por favor, inicia sesión nuevamente.';
      case 403:
        return 'Acceso denegado. No tienes permisos para esta acción.';
      case 404:
        return 'Recurso no encontrado. El elemento solicitado no existe.';
      case 409:
        return 'Conflicto. Los datos ya existen o están en uso.';
      case 422:
        return 'Datos inválidos. Verifica la información ingresada.';
      case 429:
        return 'Demasiadas solicitudes. Intenta nuevamente en unos momentos.';
      case 500:
        return 'Error interno del servidor. Intenta nuevamente más tarde.';
      case 502:
        return 'Error de puerta de enlace. Servicio temporalmente no disponible.';
      case 503:
        return 'Servicio no disponible. Intenta nuevamente más tarde.';
      case 504:
        return 'Tiempo de espera del servidor agotado.';
      default:
        return 'Error del servidor ($statusCode). Intenta nuevamente más tarde.';
    }
  }

  /// Maneja failures de dominio
  static String _handleFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    } else if (failure is AuthenticationFailure) {
      return 'Error de autenticación. Por favor, inicia sesión nuevamente.';
    } else if (failure is ServerFailure) {
      return 'Error del servidor. Intenta nuevamente más tarde.';
    } else if (failure is CacheFailure) {
      return 'Error de almacenamiento local. Los datos pueden no estar actualizados.';
    } else if (failure is ValidationFailure) {
      return 'Datos inválidos. Verifica la información ingresada.';
    } else if (failure is PermissionFailure) {
      return 'Sin permisos. No tienes acceso a esta funcionalidad.';
    } else if (failure is NotFoundFailure) {
      return 'Elemento no encontrado.';
    } else if (failure is TimeoutFailure) {
      return 'Tiempo de espera agotado. Intenta nuevamente.';
    } else {
      return failure.message.isNotEmpty ? failure.message : 'Error desconocido';
    }
  }

  /// Maneja excepciones personalizadas
  static String _handleException(Exception exception) {
    if (exception is ServerException) {
      return 'Error del servidor. Intenta nuevamente más tarde.';
    } else if (exception is NetworkException) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    } else if (exception is AuthenticationException) {
      return 'Error de autenticación. Por favor, inicia sesión nuevamente.';
    } else if (exception is CacheException) {
      return 'Error de almacenamiento local.';
    } else if (exception is ValidationException) {
      return 'Datos inválidos. Verifica la información ingresada.';
    } else if (exception is PermissionException) {
      return 'Sin permisos para realizar esta acción.';
    } else if (exception is NotFoundException) {
      return 'Elemento no encontrado.';
    } else if (exception is TimeoutException) {
      return 'Tiempo de espera agotado. Intenta nuevamente.';
    } else {
      return 'Ha ocurrido un error inesperado.';
    }
  }

  /// Convierte errores en Failures para use cases
  static Failure convertToFailure(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutFailure(_handleDioError(error));

        case DioExceptionType.connectionError:
          return NetworkFailure(_handleDioError(error));

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return AuthenticationFailure(_handleDioError(error), statusCode);
          } else if (statusCode == 403) {
            return PermissionFailure(_handleDioError(error), statusCode);
          } else if (statusCode == 404) {
            return NotFoundFailure(_handleDioError(error), statusCode);
          } else if (statusCode != null && statusCode >= 500) {
            return ServerFailure(_handleDioError(error), statusCode);
          } else {
            return ServerFailure(_handleDioError(error), statusCode);
          }

        default:
          return UnexpectedFailure(_handleDioError(error));
      }
    } else if (error is Exception) {
      return error.toFailure();
    } else {
      return UnexpectedFailure(error.toString());
    }
  }

  /// Verifica si un error es recuperable (el usuario puede reintentar)
  static bool isRecoverable(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          return statusCode == 500 ||
              statusCode == 502 ||
              statusCode == 503 ||
              statusCode == 504;

        default:
          return false;
      }
    } else if (error is NetworkException ||
        error is TimeoutException ||
        error is ServerException) {
      return true;
    }

    return false;
  }

  /// Converts any error into a user-friendly message for UI display
  /// This is the main method that should be used throughout the app
  static String getDisplayMessage(dynamic error) {
    return getUserFriendlyMessage(error);
  }

  /// Converts any error into a user-friendly message
  /// Technical details are logged separately for developers
  static String getUserFriendlyMessage(dynamic error) {
    // Log technical details for developers
    log('🔍 ErrorHandler - Technical Details: $error');

    if (error == null) {
      return 'Ocurrió un problema inesperado. Por favor, intenta nuevamente.';
    }

    String errorString = error.toString();

    // Log the raw error string
    log('🔍 ErrorHandler - Raw error string: $errorString');

    // Handle common error patterns
    if (errorString.contains('Exception:')) {
      errorString = errorString.replaceAll('Exception:', '').trim();
    }

    // Check for specific error patterns and provide appropriate messages
    if (_isConnectionError(errorString)) {
      return 'No se pudo conectar al servidor. Verifica tu conexión a internet e intenta nuevamente.';
    }

    if (_isAuthenticationError(errorString)) {
      return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
    }

    if (_isValidationError(errorString)) {
      return 'Algunos datos no son válidos. Por favor, revisa la información e intenta nuevamente.';
    }

    if (_isServerError(errorString)) {
      return 'Ocurrió un problema en nuestros servidores. Estamos trabajando para solucionarlo.';
    }

    if (_isTimeoutError(errorString)) {
      return 'La operación está tardando demasiado. Por favor, intenta nuevamente.';
    }

    if (_isNotFoundError(errorString)) {
      return 'El contenido que buscas no está disponible en este momento.';
    }

    // If error looks technical (contains code references), provide generic message
    if (_isTechnicalError(errorString)) {
      log(
        '🔍 ErrorHandler - Detected technical error, providing generic message',
      );
      return 'Ocurrió un problema inesperado. Por favor, intenta nuevamente.';
    }

    // If error is already user-friendly (short and without technical terms), return it
    if (_isUserFriendly(errorString)) {
      return errorString;
    }

    // Default fallback message
    return 'Ocurrió un problema inesperado. Por favor, intenta nuevamente.';
  }

  // Private helper methods to detect error types

  static bool _isConnectionError(String error) {
    final connectionKeywords = [
      'connection',
      'network',
      'internet',
      'timeout',
      'conectar',
      'conexión',
      'red',
      'no se pudo conectar',
      'verifica tu conexión',
      'error de conexión',
      'socketexception',
      'httpclientexception',
    ];

    return connectionKeywords.any(
      (keyword) => error.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  static bool _isAuthenticationError(String error) {
    final authKeywords = [
      'unauthorized',
      'authentication',
      'token',
      'expired',
      'sesión',
      'login',
      'auth',
      'no autorizado',
      'tu sesión ha expirado',
      'inicia sesión',
    ];

    return authKeywords.any(
      (keyword) => error.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  static bool _isValidationError(String error) {
    final validationKeywords = [
      'validation',
      'invalid',
      'required',
      'format',
      'validación',
      'inválido',
      'requerido',
      'formato',
      'datos no válidos',
      'revisa la información',
    ];

    return validationKeywords.any(
      (keyword) => error.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  static bool _isServerError(String error) {
    final serverKeywords = [
      'server error',
      'internal server',
      'servidor',
      'error del servidor',
      'problema en nuestros servidores',
      '500',
      '502',
      '503',
      '504',
    ];

    return serverKeywords.any(
      (keyword) => error.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  static bool _isTimeoutError(String error) {
    final timeoutKeywords = [
      'timeout',
      'time out',
      'tardando',
      'demasiado tiempo',
      'está tardando',
    ];

    return timeoutKeywords.any(
      (keyword) => error.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  static bool _isNotFoundError(String error) {
    final notFoundKeywords = [
      'not found',
      'no encontr',
      'no está disponible',
      'no existe',
      '404',
    ];

    return notFoundKeywords.any(
      (keyword) => error.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  static bool _isTechnicalError(String error) {
    final technicalIndicators = [
      'dart:',
      'package:',
      'stack trace',
      'exception:',
      'error:',
      'at line',
      'lib/',
      'flutter/',
      'dioexception',
      'httpexception',
      'formatexception',
    ];

    return technicalIndicators.any(
          (indicator) => error.toLowerCase().contains(indicator.toLowerCase()),
        ) ||
        error.length > 200; // Very long errors are likely technical
  }

  static bool _isUserFriendly(String error) {
    // Consider an error user-friendly if it's:
    // - Not too long (< 150 characters)
    // - Doesn't contain technical terms
    // - Is in Spanish and sounds conversational
    return error.length < 150 &&
        !_isTechnicalError(error) &&
        !error.contains('Exception') &&
        !error.contains('Error:');
  }
}
