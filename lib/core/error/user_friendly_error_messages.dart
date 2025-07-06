/// Sistema de mensajes de error amigables para el usuario
/// 
/// Este archivo centraliza todos los mensajes de error que ve el usuario,
/// traduciendo errores técnicos en mensajes comprensibles y útiles.
library;

/// Contextos específicos donde pueden ocurrir errores
enum ErrorContext {
  auth,           // Autenticación y registro
  inventory,      // Gestión de inventario
  recipes,        // Búsqueda y gestión de recetas
  recognition,    // Reconocimiento de imágenes
  scan,          // Escaneo de alimentos
  profile,       // Configuración de perfil
  planner,       // Planificación de comidas
  impact,        // Seguimiento de impacto
  network,       // Problemas de red
  general,       // Errores generales
}

/// Tipos de acciones que pueden fallar
enum ActionType {
  load,          // Cargar datos
  save,          // Guardar datos
  delete,        // Eliminar datos
  update,        // Actualizar datos
  create,        // Crear nuevo elemento
  search,        // Buscar elementos
  upload,        // Subir archivos
  download,      // Descargar archivos
  sync,          // Sincronizar datos
  validate,      // Validar información
}

/// Clase que proporciona mensajes de error amigables basados en contexto
class UserFriendlyErrorMessages {
  
  /// Mapeo de contextos y acciones a mensajes específicos
  static const Map<ErrorContext, Map<ActionType, String>> _contextualMessages = {
    ErrorContext.auth: {
      ActionType.load: 'No se pudo verificar tu sesión. Por favor, intenta iniciar sesión nuevamente.',
      ActionType.save: 'No se pudieron guardar tus datos de perfil. Verifica tu conexión e intenta nuevamente.',
      ActionType.create: 'No se pudo crear tu cuenta. Verifica tu información e intenta nuevamente.',
      ActionType.validate: 'Los datos ingresados no son válidos. Por favor, revisa la información.',
      ActionType.sync: 'No se pudieron sincronizar tus preferencias. Intenta nuevamente más tarde.',
    },
    
    ErrorContext.inventory: {
      ActionType.load: 'No se pudo cargar tu inventario. Verifica tu conexión e intenta nuevamente.',
      ActionType.save: 'No se pudo guardar el elemento en tu inventario. Intenta nuevamente.',
      ActionType.delete: 'No se pudo eliminar el elemento de tu inventario. Intenta nuevamente.',
      ActionType.update: 'No se pudo actualizar el elemento. Verifica tu conexión e intenta nuevamente.',
      ActionType.create: 'No se pudo añadir el elemento a tu inventario. Intenta nuevamente.',
      ActionType.search: 'No se pudieron buscar elementos en tu inventario. Intenta nuevamente.',
      ActionType.sync: 'No se pudo sincronizar tu inventario. Los cambios se guardarán cuando tengas conexión.',
    },
    
    ErrorContext.recipes: {
      ActionType.load: 'No se pudieron cargar las recetas. Verifica tu conexión e intenta nuevamente.',
      ActionType.save: 'No se pudo guardar la receta. Intenta nuevamente.',
      ActionType.delete: 'No se pudo eliminar la receta. Intenta nuevamente.',
      ActionType.create: 'No se pudo generar la receta. Verifica tu conexión e intenta nuevamente.',
      ActionType.search: 'No se pudieron buscar recetas. Verifica tu conexión e intenta nuevamente.',
      ActionType.sync: 'No se pudieron sincronizar tus recetas favoritas.',
    },
    
    ErrorContext.recognition: {
      ActionType.load: 'No se pudo procesar la imagen. Intenta tomar otra foto.',
      ActionType.create: 'No se pudo reconocer los alimentos en la imagen. Intenta con mejor iluminación.',
      ActionType.validate: 'La imagen no es válida. Por favor, toma una nueva foto.',
      ActionType.upload: 'No se pudo subir la imagen. Verifica tu conexión e intenta nuevamente.',
    },
    
    ErrorContext.scan: {
      ActionType.load: 'No se pudo acceder a la cámara. Verifica los permisos de la aplicación.',
      ActionType.create: 'No se pudo escanear el código. Intenta nuevamente con mejor iluminación.',
      ActionType.validate: 'El código escaneado no es válido.',
    },
    
    ErrorContext.profile: {
      ActionType.load: 'No se pudo cargar tu perfil. Verifica tu conexión e intenta nuevamente.',
      ActionType.save: 'No se pudieron guardar los cambios en tu perfil. Intenta nuevamente.',
      ActionType.update: 'No se pudo actualizar tu perfil. Verifica tu conexión e intenta nuevamente.',
      ActionType.validate: 'Algunos datos de tu perfil no son válidos. Por favor, revísalos.',
      ActionType.sync: 'No se pudieron sincronizar tus preferencias.',
    },
    
    ErrorContext.planner: {
      ActionType.load: 'No se pudo cargar tu planificación de comidas. Intenta nuevamente.',
      ActionType.save: 'No se pudo guardar la planificación. Intenta nuevamente.',
      ActionType.create: 'No se pudo crear el plan de comidas. Intenta nuevamente.',
      ActionType.update: 'No se pudo actualizar la planificación. Intenta nuevamente.',
      ActionType.delete: 'No se pudo eliminar la comida planificada. Intenta nuevamente.',
      ActionType.sync: 'No se pudo sincronizar tu planificación.',
    },
    
    ErrorContext.impact: {
      ActionType.load: 'No se pudo cargar tu seguimiento de impacto. Intenta nuevamente.',
      ActionType.sync: 'No se pudieron sincronizar tus datos de impacto ambiental.',
    },
    
    ErrorContext.network: {
      ActionType.load: 'Sin conexión a internet. Verifica tu conexión e intenta nuevamente.',
      ActionType.save: 'Sin conexión a internet. Los cambios se guardarán cuando tengas conexión.',
      ActionType.sync: 'Sin conexión a internet. La sincronización se realizará automáticamente cuando tengas conexión.',
    },
    
    ErrorContext.general: {
      ActionType.load: 'No se pudieron cargar los datos. Intenta nuevamente.',
      ActionType.save: 'No se pudieron guardar los cambios. Intenta nuevamente.',
      ActionType.delete: 'No se pudo eliminar el elemento. Intenta nuevamente.',
      ActionType.update: 'No se pudo actualizar la información. Intenta nuevamente.',
      ActionType.create: 'No se pudo crear el elemento. Intenta nuevamente.',
      ActionType.search: 'No se pudo realizar la búsqueda. Intenta nuevamente.',
      ActionType.validate: 'Los datos ingresados no son válidos. Por favor, revísalos.',
      ActionType.sync: 'No se pudieron sincronizar los datos.',
    },
  };

  /// Mensajes específicos para errores comunes
  static const Map<String, String> _specificMessages = {
    // Errores de autenticación
    'email_already_in_use': 'Este correo electrónico ya está registrado. Intenta iniciar sesión o usa otro correo.',
    'weak_password': 'La contraseña es muy débil. Debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas y números.',
    'invalid_email': 'El correo electrónico no es válido. Por favor, ingresa un correo válido.',
    'user_not_found': 'No se encontró una cuenta con este correo electrónico.',
    'wrong_password': 'La contraseña es incorrecta. Intenta nuevamente o restablece tu contraseña.',
    'too_many_requests': 'Demasiados intentos. Por favor, espera unos minutos antes de intentar nuevamente.',
    'account_disabled': 'Tu cuenta ha sido deshabilitada. Contacta al soporte técnico.',
    'invalid_credentials': 'Credenciales incorrectas. Verifica tu correo y contraseña.',
    'network_request_failed': 'Error de conexión. Verifica tu internet e intenta nuevamente.',
    
    // Errores de red
    'connection_timeout': 'La conexión tardó demasiado. Verifica tu internet e intenta nuevamente.',
    'no_internet': 'Sin conexión a internet. Verifica tu conexión e intenta nuevamente.',
    'server_error': 'Nuestros servidores están experimentando problemas. Intenta nuevamente en unos minutos.',
    'service_unavailable': 'El servicio no está disponible temporalmente. Intenta más tarde.',
    
    // Errores de permisos
    'permission_denied': 'No tienes permisos para realizar esta acción.',
    'camera_permission': 'Se necesitan permisos de cámara para esta funcionalidad. Ve a configuración y activa los permisos.',
    'storage_permission': 'Se necesitan permisos de almacenamiento para guardar imágenes.',
    
    // Errores de validación
    'invalid_data': 'Los datos ingresados no son válidos. Por favor, revísalos.',
    'missing_required_field': 'Faltan campos obligatorios. Por favor, completa toda la información.',
    'invalid_format': 'El formato de los datos no es correcto.',
    
    // Errores de almacenamiento
    'storage_quota_exceeded': 'Se agotó el espacio de almacenamiento. Libera espacio e intenta nuevamente.',
    'file_too_large': 'El archivo es demasiado grande. Intenta con una imagen más pequeña.',
    'unsupported_file_type': 'Tipo de archivo no compatible. Usa imágenes JPG o PNG.',
    
    // Errores de la API
    'api_key_invalid': 'Error de configuración. Por favor, contacta al soporte técnico.',
    'rate_limit_exceeded': 'Has alcanzado el límite de solicitudes. Intenta nuevamente en unos minutos.',
    'quota_exceeded': 'Has alcanzado tu límite diario. Intenta nuevamente mañana.',
    
    // Errores de procesamiento de imágenes
    'image_processing_failed': 'No se pudo procesar la imagen. Intenta con otra foto.',
    'no_food_detected': 'No se detectaron alimentos en la imagen. Intenta con una foto más clara.',
    'image_too_dark': 'La imagen está muy oscura. Intenta con mejor iluminación.',
    'image_too_blurry': 'La imagen está muy borrosa. Mantén el teléfono firme al tomar la foto.',
  };

  /// Obtiene un mensaje amigable basado en el contexto y tipo de acción
  static String getContextualMessage(ErrorContext context, ActionType action) {
    return _contextualMessages[context]?[action] ?? 
           _contextualMessages[ErrorContext.general]?[action] ??
           'Ocurrió un problema inesperado. Por favor, intenta nuevamente.';
  }

  /// Obtiene un mensaje específico para un error conocido
  static String? getSpecificMessage(String errorKey) {
    return _specificMessages[errorKey];
  }

  /// Convierte cualquier error en un mensaje amigable usando IA contextual
  static String getSmartMessage(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customHint,
    bool hasNetworkConnectivity = true,
  }) {
    if (error == null) {
      return getContextualMessage(context, action);
    }

    final errorString = error.toString().toLowerCase();
    
    // Buscar mensajes específicos primero
    for (final entry in _specificMessages.entries) {
      if (errorString.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Detectar patrones comunes en el error
    if (_isConnectionError(errorString) || !hasNetworkConnectivity) {
      if (!hasNetworkConnectivity) {
        return 'Sin conexión a internet. Verifica que tu WiFi esté activado o que tengas datos móviles disponibles.';
      }
      return context == ErrorContext.network 
          ? getContextualMessage(ErrorContext.network, action)
          : 'Problema de conexión. Verifica tu internet e intenta nuevamente.';
    }

    if (_isAuthenticationError(errorString)) {
      return context == ErrorContext.auth 
          ? getContextualMessage(ErrorContext.auth, action)
          : 'Problema de autenticación. Por favor, inicia sesión nuevamente.';
    }

    if (_isValidationError(errorString)) {
      return 'Los datos ingresados no son válidos. Por favor, revísalos e intenta nuevamente.';
    }

    if (_isPermissionError(errorString)) {
      return 'No tienes permisos para realizar esta acción.';
    }

    if (_isServerError(errorString)) {
      return 'Nuestros servidores están experimentando problemas. Intenta nuevamente en unos minutos.';
    }

    if (_isTimeoutError(errorString)) {
      return 'La operación tardó demasiado. Verifica tu conexión e intenta nuevamente.';
    }

    // Si hay una pista personalizada, úsala
    if (customHint != null && customHint.isNotEmpty) {
      return customHint;
    }

    // Usar mensaje contextual como fallback
    return getContextualMessage(context, action);
  }

  /// Detecta errores de conexión
  static bool _isConnectionError(String error) {
    const connectionTerms = [
      'connection', 'network', 'internet', 'timeout', 'connectivity',
      'socketexception', 'httpclientexception', 'no route to host',
      'connection refused', 'connection timeout'
    ];
    
    return connectionTerms.any((term) => error.contains(term));
  }

  /// Detecta errores de autenticación
  static bool _isAuthenticationError(String error) {
    const authTerms = [
      'unauthorized', 'authentication', 'token', 'expired', 'invalid_token',
      'access_denied', 'forbidden', 'login', 'credential', '401', '403'
    ];
    
    return authTerms.any((term) => error.contains(term));
  }

  /// Detecta errores de validación
  static bool _isValidationError(String error) {
    const validationTerms = [
      'validation', 'invalid', 'required', 'format', 'missing',
      'malformed', 'bad_request', '400', 'invalid_data'
    ];
    
    return validationTerms.any((term) => error.contains(term));
  }

  /// Detecta errores de permisos
  static bool _isPermissionError(String error) {
    const permissionTerms = [
      'permission', 'denied', 'forbidden', 'access', 'unauthorized',
      'privilege', '403'
    ];
    
    return permissionTerms.any((term) => error.contains(term));
  }

  /// Detecta errores del servidor
  static bool _isServerError(String error) {
    const serverTerms = [
      'server error', 'internal server', '500', '502', '503', '504',
      'service unavailable', 'server unavailable', 'maintenance'
    ];
    
    return serverTerms.any((term) => error.contains(term));
  }

  /// Detecta errores de timeout
  static bool _isTimeoutError(String error) {
    const timeoutTerms = [
      'timeout', 'time out', 'deadline exceeded', 'request timeout',
      'connection timeout', 'read timeout'
    ];
    
    return timeoutTerms.any((term) => error.contains(term));
  }

  /// Genera sugerencias de acción basadas en el tipo de error
  static List<String> getActionSuggestions(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
  }) {
    final errorString = error.toString().toLowerCase();
    
    if (_isConnectionError(errorString)) {
      return [
        'Verifica tu conexión a internet',
        'Intenta nuevamente en unos segundos',
        'Cambia a datos móviles si usas WiFi (o viceversa)',
      ];
    }
    
    if (_isAuthenticationError(errorString)) {
      return [
        'Cierra sesión e inicia sesión nuevamente',
        'Verifica que tu correo y contraseña sean correctos',
        'Restablece tu contraseña si es necesario',
      ];
    }
    
    if (_isValidationError(errorString)) {
      return [
        'Revisa que todos los campos estén completos',
        'Verifica el formato de los datos ingresados',
        'Asegúrate de seguir las indicaciones de cada campo',
      ];
    }
    
    if (_isServerError(errorString)) {
      return [
        'Espera unos minutos e intenta nuevamente',
        'El problema es temporal y se resolverá pronto',
        'Contacta al soporte si el problema persiste',
      ];
    }
    
    // Sugerencias generales
    return [
      'Intenta nuevamente en unos segundos',
      'Verifica tu conexión a internet',
      'Contacta al soporte si el problema persiste',
    ];
  }
}