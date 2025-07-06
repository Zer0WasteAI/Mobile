import 'package:dio/dio.dart';
import 'failures.dart';
import 'exceptions.dart';
import 'user_friendly_error_messages.dart';
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
  static String getDisplayMessage(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customHint,
  }) {
    return getUserFriendlyMessage(
      error,
      context: context,
      action: action,
      customHint: customHint,
    );
  }

  /// Converts any error into a user-friendly message using the new smart system
  /// Technical details are logged separately for developers
  static String getUserFriendlyMessage(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customHint,
  }) {
    // Log technical details for developers
    log('🔍 ErrorHandler - Technical Details: $error');
    log('🔍 ErrorHandler - Context: $context, Action: $action');

    // Use the new smart error message system
    return UserFriendlyErrorMessages.getSmartMessage(
      error,
      context: context,
      action: action,
      customHint: customHint,
    );
  }

  /// Get action suggestions for the user
  static List<String> getActionSuggestions(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
  }) {
    return UserFriendlyErrorMessages.getActionSuggestions(
      error,
      context: context,
    );
  }

}
