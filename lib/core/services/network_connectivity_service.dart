import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum para los estados de conectividad de red
enum NetworkStatus {
  /// Conectado a internet (WiFi o datos móviles)
  connected,
  
  /// Conectado a una red pero sin acceso a internet
  disconnected,
  
  /// Sin conectividad de red
  offline,
  
  /// Estado desconocido o verificando
  unknown,
}

/// Enum para el tipo de conexión
enum ConnectionType {
  /// Conexión WiFi
  wifi,
  
  /// Datos móviles
  mobile,
  
  /// Ethernet (poco común en móviles)
  ethernet,
  
  /// Sin conexión
  none,
  
  /// Tipo desconocido
  unknown,
}

/// Clase que encapsula el estado completo de la red
class NetworkState {
  final NetworkStatus status;
  final ConnectionType type;
  final bool isStable;
  final DateTime lastChecked;
  final String? errorMessage;

  const NetworkState({
    required this.status,
    required this.type,
    this.isStable = true,
    required this.lastChecked,
    this.errorMessage,
  });

  /// Crear estado offline
  factory NetworkState.offline() => NetworkState(
    status: NetworkStatus.offline,
    type: ConnectionType.none,
    isStable: true,
    lastChecked: DateTime.now(),
  );

  /// Crear estado conectado
  factory NetworkState.connected(ConnectionType type) => NetworkState(
    status: NetworkStatus.connected,
    type: type,
    isStable: true,
    lastChecked: DateTime.now(),
  );

  /// Crear estado desconectado (red disponible pero sin internet)
  factory NetworkState.disconnected(ConnectionType type) => NetworkState(
    status: NetworkStatus.disconnected,
    type: type,
    isStable: false,
    lastChecked: DateTime.now(),
  );

  /// Crear estado desconocido
  factory NetworkState.unknown() => NetworkState(
    status: NetworkStatus.unknown,
    type: ConnectionType.unknown,
    isStable: false,
    lastChecked: DateTime.now(),
  );

  /// Copiar con nuevos valores
  NetworkState copyWith({
    NetworkStatus? status,
    ConnectionType? type,
    bool? isStable,
    DateTime? lastChecked,
    String? errorMessage,
  }) {
    return NetworkState(
      status: status ?? this.status,
      type: type ?? this.type,
      isStable: isStable ?? this.isStable,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Verificar si hay conexión a internet
  bool get hasInternet => status == NetworkStatus.connected;

  /// Verificar si hay conectividad de red (aunque sea sin internet)
  bool get hasNetworkConnectivity => 
    type != ConnectionType.none && status != NetworkStatus.offline;

  /// Obtener descripción amigable del estado
  String get description {
    switch (status) {
      case NetworkStatus.connected:
        return 'Conectado a internet via $_typeDescription';
      case NetworkStatus.disconnected:
        return 'Conectado a red pero sin acceso a internet';
      case NetworkStatus.offline:
        return 'Sin conexión de red';
      case NetworkStatus.unknown:
        return 'Estado de conexión desconocido';
    }
  }

  String get _typeDescription {
    switch (type) {
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'datos móviles';
      case ConnectionType.ethernet:
        return 'ethernet';
      case ConnectionType.none:
        return 'ninguna';
      case ConnectionType.unknown:
        return 'desconocida';
    }
  }

  @override
  String toString() => 'NetworkState(status: $status, type: $type, isStable: $isStable)';
}

/// Servicio principal para monitorear la conectividad de red
class NetworkConnectivityService {
  static final NetworkConnectivityService _instance = NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();
  
  /// Stream controller para el estado de la red
  final StreamController<NetworkState> _networkStateController = 
      StreamController<NetworkState>.broadcast();

  /// Estado actual de la red
  NetworkState _currentState = NetworkState.unknown();

  /// Timer para verificaciones periódicas
  Timer? _periodicCheckTimer;

  /// Subscription para cambios de conectividad
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Stream público del estado de la red
  Stream<NetworkState> get networkStateStream => _networkStateController.stream;

  /// Estado actual de la red
  NetworkState get currentState => _currentState;

  /// Inicializar el servicio
  Future<void> initialize() async {
    log('🌐 NetworkConnectivityService: Iniciando servicio de conectividad');
    
    try {
      // Verificar estado inicial
      await _checkConnectivity();
      
      // Escuchar cambios de conectividad
      _startConnectivityListener();
      
      // Iniciar verificaciones periódicas
      _startPeriodicChecks();
      
      log('✅ NetworkConnectivityService: Servicio iniciado correctamente');
    } catch (e) {
      log('❌ NetworkConnectivityService: Error al inicializar: $e');
      _updateState(NetworkState.unknown());
    }
  }

  /// Iniciar listener de cambios de conectividad
  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        log('🔄 NetworkConnectivityService: Cambio de conectividad detectado: $results');
        _checkConnectivity();
      },
      onError: (error) {
        log('❌ NetworkConnectivityService: Error en listener de conectividad: $error');
        _updateState(_currentState.copyWith(
          errorMessage: 'Error monitoreando conectividad: $error',
        ));
      },
    );
  }

  /// Iniciar verificaciones periódicas
  void _startPeriodicChecks() {
    _periodicCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_currentState.status == NetworkStatus.disconnected || 
          _currentState.status == NetworkStatus.unknown) {
        log('🔄 NetworkConnectivityService: Verificación periódica de conectividad');
        _checkConnectivity();
      }
    });
  }

  /// Verificar el estado actual de la conectividad
  Future<void> _checkConnectivity() async {
    try {
      // Obtener tipo de conexión
      final List<ConnectivityResult> connectivityResults = 
          await _connectivity.checkConnectivity();
      
      final ConnectionType connectionType = _mapConnectivityResult(connectivityResults);
      
      if (connectionType == ConnectionType.none) {
        _updateState(NetworkState.offline());
        return;
      }

      // Verificar si hay acceso real a internet
      final bool hasInternet = await _checkInternetAccess();
      
      if (hasInternet) {
        _updateState(NetworkState.connected(connectionType));
      } else {
        _updateState(NetworkState.disconnected(connectionType));
      }
      
    } catch (e) {
      log('❌ NetworkConnectivityService: Error verificando conectividad: $e');
      _updateState(NetworkState.unknown());
    }
  }

  /// Verificar acceso real a internet
  Future<bool> _checkInternetAccess() async {
    try {
      final bool hasConnection = await _internetChecker.hasInternetAccess;
      log('🌐 NetworkConnectivityService: Acceso a internet: $hasConnection');
      return hasConnection;
    } catch (e) {
      log('❌ NetworkConnectivityService: Error verificando acceso a internet: $e');
      return false;
    }
  }

  /// Mapear resultado de conectividad a nuestro enum
  ConnectionType _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectionType.none;
    
    // Priorizar WiFi si está disponible
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    }
    
    // Luego datos móviles
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    }
    
    // Ethernet (raro en móviles)
    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    }
    
    // Sin conexión
    if (results.contains(ConnectivityResult.none)) {
      return ConnectionType.none;
    }
    
    return ConnectionType.unknown;
  }

  /// Actualizar estado y notificar listeners
  void _updateState(NetworkState newState) {
    if (_currentState.status != newState.status || 
        _currentState.type != newState.type) {
      
      log('📡 NetworkConnectivityService: Estado actualizado: ${newState.description}');
      
      _currentState = newState;
      _networkStateController.add(newState);
    }
  }

  /// Verificación manual de conectividad
  Future<NetworkState> checkConnectivityManually() async {
    log('🔄 NetworkConnectivityService: Verificación manual solicitada');
    await _checkConnectivity();
    return _currentState;
  }

  /// Verificar si una URL específica es accesible
  Future<bool> canReachUrl(String url) async {
    try {
      final result = await _internetChecker.hasInternetAccess;
      return result;
    } catch (e) {
      log('❌ NetworkConnectivityService: Error verificando URL $url: $e');
      return false;
    }
  }

  /// Esperar hasta que haya conexión a internet
  Future<void> waitForConnection({Duration? timeout}) async {
    if (_currentState.hasInternet) return;
    
    final completer = Completer<void>();
    late StreamSubscription subscription;
    
    subscription = networkStateStream.listen((state) {
      if (state.hasInternet) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    if (timeout != null) {
      Timer(timeout, () {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Timeout esperando conexión', timeout));
        }
      });
    }
    
    return completer.future;
  }

  /// Limpiar recursos
  void dispose() {
    log('🧹 NetworkConnectivityService: Limpiando recursos');
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    _networkStateController.close();
  }
}

/// Provider de Riverpod para el servicio de conectividad
final networkConnectivityServiceProvider = Provider<NetworkConnectivityService>((ref) {
  final service = NetworkConnectivityService();
  
  // Inicializar el servicio
  service.initialize();
  
  // Limpiar cuando el provider se dispose
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider para el estado actual de la red
final networkStateProvider = StreamProvider<NetworkState>((ref) {
  final service = ref.watch(networkConnectivityServiceProvider);
  return service.networkStateStream;
});

/// Provider para verificar si hay conexión a internet
final hasInternetProvider = Provider<bool>((ref) {
  final networkState = ref.watch(networkStateProvider);
  return networkState.when(
    data: (state) => state.hasInternet,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider para el tipo de conexión actual
final connectionTypeProvider = Provider<ConnectionType>((ref) {
  final networkState = ref.watch(networkStateProvider);
  return networkState.when(
    data: (state) => state.type,
    loading: () => ConnectionType.unknown,
    error: (_, _) => ConnectionType.unknown,
  );
});

/// Extension para manejo de timeouts
class TimeoutException implements Exception {
  final String message;
  final Duration? duration;
  
  const TimeoutException(this.message, [this.duration]);
  
  @override
  String toString() => 'TimeoutException: $message';
}