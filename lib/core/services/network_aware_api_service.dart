import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/network_connectivity_service.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/core/error/user_friendly_error_messages.dart';
import 'package:zer0_waste_ai/core/error/error_handler.dart';
import 'package:zer0_waste_ai/core/error/exceptions.dart' hide TimeoutException;
import 'package:zer0_waste_ai/core/widgets/network_status_widgets.dart';

/// Configuración para operaciones de red
class NetworkOperationConfig {
  /// Tiempo máximo de espera para obtener conexión
  final Duration connectionTimeout;
  
  /// Número máximo de reintentos
  final int maxRetries;
  
  /// Retraso entre reintentos
  final Duration retryDelay;
  
  /// Si debe mostrar UI de progreso al usuario
  final bool showProgressToUser;
  
  /// Si debe funcionar en modo offline (usando cache)
  final bool allowOfflineMode;
  
  /// Contexto de error para mensajes específicos
  final ErrorContext errorContext;
  
  /// Tipo de acción para mensajes específicos
  final ActionType actionType;

  const NetworkOperationConfig({
    this.connectionTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.showProgressToUser = false,
    this.allowOfflineMode = false,
    this.errorContext = ErrorContext.network,
    this.actionType = ActionType.load,
  });

  NetworkOperationConfig copyWith({
    Duration? connectionTimeout,
    int? maxRetries,
    Duration? retryDelay,
    bool? showProgressToUser,
    bool? allowOfflineMode,
    ErrorContext? errorContext,
    ActionType? actionType,
  }) {
    return NetworkOperationConfig(
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      showProgressToUser: showProgressToUser ?? this.showProgressToUser,
      allowOfflineMode: allowOfflineMode ?? this.allowOfflineMode,
      errorContext: errorContext ?? this.errorContext,
      actionType: actionType ?? this.actionType,
    );
  }
}

/// Resultado de una operación de red
class NetworkOperationResult<T> {
  final T? data;
  final bool success;
  final String? error;
  final bool wasFromCache;
  final NetworkState? networkState;

  const NetworkOperationResult({
    this.data,
    required this.success,
    this.error,
    this.wasFromCache = false,
    this.networkState,
  });

  factory NetworkOperationResult.success(T data, {bool wasFromCache = false}) {
    return NetworkOperationResult(
      data: data,
      success: true,
      wasFromCache: wasFromCache,
    );
  }

  factory NetworkOperationResult.failure(String error, {NetworkState? networkState}) {
    return NetworkOperationResult(
      success: false,
      error: error,
      networkState: networkState,
    );
  }
}

/// Servicio que envuelve las llamadas API con awareness de conectividad
class NetworkAwareApiService {
  final ApiService _apiService;
  final NetworkConnectivityService _networkService;

  NetworkAwareApiService(this._apiService, this._networkService, Ref ref);

  /// Realizar una operación GET con awareness de red
  Future<NetworkOperationResult<Map<String, dynamic>>> getInventory({
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
  }) async {
    return _executeNetworkOperation(
      () => _apiService.getInventory(),
      config: config,
      context: context,
      operationName: 'GET Inventory',
    );
  }

  /// Realizar operación GET genérica (para endpoints específicos)
  Future<NetworkOperationResult<Map<String, dynamic>>> executeGet(
    Future<Map<String, dynamic>> Function() operation, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
    required String operationName,
  }) async {
    return _executeNetworkOperation(
      operation,
      config: config,
      context: context,
      operationName: operationName,
    );
  }

  /// Realizar una operación POST para agregar item al inventario
  Future<NetworkOperationResult<Map<String, dynamic>>> addInventoryItem(
    Map<String, dynamic> itemData, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
  }) async {
    return _executeNetworkOperation(
      () => _apiService.addInventoryItem(itemData),
      config: config.copyWith(actionType: ActionType.create),
      context: context,
      operationName: 'POST Add Inventory Item',
    );
  }

  /// Realizar operación POST genérica (para endpoints específicos)
  Future<NetworkOperationResult<Map<String, dynamic>>> executePost(
    Future<Map<String, dynamic>> Function() operation, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
    required String operationName,
  }) async {
    return _executeNetworkOperation(
      operation,
      config: config.copyWith(actionType: ActionType.create),
      context: context,
      operationName: operationName,
    );
  }

  /// Realizar una operación PUT para actualizar item del inventario
  Future<NetworkOperationResult<Map<String, dynamic>>> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
  }) async {
    return _executeNetworkOperation(
      () => _apiService.updateInventoryItem(itemId, updateData),
      config: config.copyWith(actionType: ActionType.update),
      context: context,
      operationName: 'PUT Update Inventory Item',
    );
  }

  /// Realizar una operación DELETE para eliminar item del inventario
  Future<NetworkOperationResult<Map<String, dynamic>>> deleteInventoryItem(
    String itemId, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
  }) async {
    return _executeNetworkOperation(
      () => _apiService.deleteInventoryItem(itemId),
      config: config.copyWith(actionType: ActionType.delete),
      context: context,
      operationName: 'DELETE Inventory Item',
    );
  }

  /// Realizar operación PUT genérica (para endpoints específicos)
  Future<NetworkOperationResult<Map<String, dynamic>>> executePut(
    Future<Map<String, dynamic>> Function() operation, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
    required String operationName,
  }) async {
    return _executeNetworkOperation(
      operation,
      config: config.copyWith(actionType: ActionType.update),
      context: context,
      operationName: operationName,
    );
  }

  /// Realizar operación DELETE genérica (para endpoints específicos)
  Future<NetworkOperationResult<Map<String, dynamic>>> executeDelete(
    Future<Map<String, dynamic>> Function() operation, {
    NetworkOperationConfig config = const NetworkOperationConfig(),
    BuildContext? context,
    required String operationName,
  }) async {
    return _executeNetworkOperation(
      operation,
      config: config.copyWith(actionType: ActionType.delete),
      context: context,
      operationName: operationName,
    );
  }

  /// Ejecutar una operación de red con manejo completo de conectividad
  Future<NetworkOperationResult<Map<String, dynamic>>> _executeNetworkOperation(
    Future<Map<String, dynamic>> Function() operation, {
    required NetworkOperationConfig config,
    BuildContext? context,
    required String operationName,
  }) async {
    log('🌐 NetworkAwareApiService: Iniciando $operationName');

    // Verificar conectividad inicial
    final networkState = _networkService.currentState;
    
    if (!networkState.hasInternet) {
      log('❌ NetworkAwareApiService: Sin conexión para $operationName');
      
      if (config.allowOfflineMode) {
        // Intentar obtener de cache (implementación futura)
        return _handleOfflineMode(operationName, config);
      }
      
      // Mostrar dialog de sin conexión si hay contexto
      if (context != null && context.mounted) {
        _showNoConnectionDialog(context, config, () => 
          _executeNetworkOperation(operation, config: config, context: context, operationName: operationName)
        );
      }
      
      return NetworkOperationResult.failure(
        UserFriendlyErrorMessages.getSmartMessage(
          null,
          context: config.errorContext,
          action: config.actionType,
          hasNetworkConnectivity: false,
        ),
        networkState: networkState,
      );
    }

    // Ejecutar operación con reintentos
    return _executeWithRetries(
      operation,
      config: config,
      context: context,
      operationName: operationName,
    );
  }

  /// Ejecutar operación con sistema de reintentos
  Future<NetworkOperationResult<Map<String, dynamic>>> _executeWithRetries(
    Future<Map<String, dynamic>> Function() operation, {
    required NetworkOperationConfig config,
    BuildContext? context,
    required String operationName,
  }) async {
    Exception? lastError;
    
    for (int attempt = 1; attempt <= config.maxRetries; attempt++) {
      try {
        log('🔄 NetworkAwareApiService: Intento $attempt/$config.maxRetries para $operationName');
        
        // Verificar conexión antes de cada intento
        final networkState = _networkService.currentState;
        if (!networkState.hasInternet && attempt > 1) {
          // Esperar conexión con timeout
          try {
            await _networkService.waitForConnection(timeout: config.connectionTimeout);
          } catch (e) {
            log('⏰ NetworkAwareApiService: Timeout esperando conexión: $e');
            return NetworkOperationResult.failure(
              'Sin conexión a internet. La operación no pudo completarse.',
              networkState: networkState,
            );
          }
        }

        // Ejecutar la operación
        final result = await operation();
        
        log('✅ NetworkAwareApiService: $operationName completado exitosamente');
        return NetworkOperationResult.success(result);
        
      } catch (error) {
        lastError = error is Exception ? error : Exception(error.toString());
        log('❌ NetworkAwareApiService: Error en intento $attempt para $operationName: $error');
        
        // Verificar si es un error de red
        if (_isNetworkError(error)) {
          // Si perdimos conexión durante la operación, mostrar dialog
          if (context != null && context.mounted && attempt == 1) {
            _showConnectionLostDialog(context, config, () => 
              _executeWithRetries(operation, config: config, context: context, operationName: operationName)
            );
          }
          
          // Esperar antes del siguiente intento (solo para errores de red)
          if (attempt < config.maxRetries) {
            log('⏳ NetworkAwareApiService: Esperando ${config.retryDelay.inSeconds}s antes del siguiente intento');
            await Future.delayed(config.retryDelay);
          }
        } else {
          // Para errores que no son de red, no reintentar
          break;
        }
      }
    }

    // Todos los intentos fallaron
    final errorMessage = ErrorHandler.getUserFriendlyMessage(
      lastError,
      context: config.errorContext,
      action: config.actionType,
    );

    log('💥 NetworkAwareApiService: $operationName falló después de ${config.maxRetries} intentos');
    
    return NetworkOperationResult.failure(
      errorMessage,
      networkState: _networkService.currentState,
    );
  }

  /// Manejar modo offline (implementación básica)
  Future<NetworkOperationResult<Map<String, dynamic>>> _handleOfflineMode(
    String operationName,
    NetworkOperationConfig config,
  ) async {
    log('📱 NetworkAwareApiService: Modo offline para $operationName');
    
    // Aquí podrías implementar lógica de cache
    // Por ahora, retornamos un error amigable
    return NetworkOperationResult.failure(
      'Sin conexión a internet. Los datos se sincronizarán cuando tengas conexión.',
      networkState: _networkService.currentState,
    );
  }

  /// Verificar si un error es relacionado con la red
  bool _isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.sendTimeout ||
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.connectionError;
    }
    
    if (error is NetworkException || error is TimeoutException) {
      return true;
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('internet');
  }

  /// Mostrar dialog cuando no hay conexión inicial
  void _showNoConnectionDialog(
    BuildContext context,
    NetworkOperationConfig config,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Sin conexión'),
          ],
        ),
        content: const Text(
          'No tienes conexión a internet. Esta operación requiere conectividad. '
          'Verifica tu conexión e intenta nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar dialog cuando se pierde conexión durante la operación
  void _showConnectionLostDialog(
    BuildContext context,
    NetworkOperationConfig config,
    VoidCallback onRetry,
  ) {
    NetworkLostDialog.show(
      context,
      onRetry: onRetry,
      customMessage: 'Se perdió la conexión durante la operación. '
                    'Verifica tu internet e intenta nuevamente.',
    );
  }
}

/// Provider para el servicio network-aware
final networkAwareApiServiceProvider = Provider<NetworkAwareApiService>((ref) {
  final apiService = ApiService.instance;
  final networkService = ref.watch(networkConnectivityServiceProvider);
  
  return NetworkAwareApiService(apiService, networkService, ref);
});

/// Extension methods para facilitar el uso en repositories
extension NetworkAwareRepository on Ref {
  /// Obtener el servicio network-aware
  NetworkAwareApiService get networkApi => read(networkAwareApiServiceProvider);
  
  /// Verificar si hay conexión a internet
  bool get hasInternet => read(hasInternetProvider);
  
  /// Obtener el estado actual de la red
  NetworkState get networkState => read(networkConnectivityServiceProvider).currentState;
}