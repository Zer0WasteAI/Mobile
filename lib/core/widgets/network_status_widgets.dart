import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/network_connectivity_service.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Widget principal que envuelve la app y muestra el estado de conectividad
class NetworkAwareApp extends ConsumerWidget {
  final Widget child;
  final bool showOfflineOverlay;
  final bool showNetworkStatusIndicator;

  const NetworkAwareApp({
    super.key,
    required this.child,
    this.showOfflineOverlay = true,
    this.showNetworkStatusIndicator = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkStateProvider);

    return networkState.when(
      data: (state) => Stack(
        children: [
          child,
          
          // Overlay de sin conexión
          if (showOfflineOverlay && !state.hasInternet)
            _buildOfflineOverlay(context, state, ref),
          
          // Indicador de estado de red
          if (showNetworkStatusIndicator)
            _buildNetworkStatusIndicator(context, state),
        ],
      ),
      loading: () => child,
      error: (error, stack) => child,
    );
  }

  Widget _buildOfflineOverlay(BuildContext context, NetworkState state, WidgetRef ref) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: NoInternetScreen(
          networkState: state,
          onRetry: () => ref.read(networkConnectivityServiceProvider).checkConnectivityManually(),
        ),
      ),
    );
  }

  Widget _buildNetworkStatusIndicator(BuildContext context, NetworkState state) {
    if (state.hasInternet) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: NetworkStatusBanner(state: state),
    );
  }
}

/// Pantalla completa que se muestra cuando no hay internet
class NoInternetScreen extends ConsumerStatefulWidget {
  final NetworkState networkState;
  final VoidCallback? onRetry;

  const NoInternetScreen({
    super.key,
    required this.networkState,
    this.onRetry,
  });

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animación Lottie o icono animado
                  _buildConnectionAnimation(),
                  
                  const SizedBox(height: 32),
                  
                  // Título principal
                  Text(
                    '¡Oops! Sin conexión',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightMainText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descripción del problema
                  Text(
                    _getConnectionMessage(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightSecondaryText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sugerencias para el usuario
                  _buildSuggestionsList(),
                  
                  const SizedBox(height: 40),
                  
                  // Botones de acción
                  _buildActionButtons(),
                  
                  const SizedBox(height: 20),
                  
                  // Estado técnico (opcional, para debug)
                  if (widget.networkState.type != ConnectionType.none)
                    _buildTechnicalStatus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionAnimation() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ondas de conexión animadas
          ...List.generate(3, (index) => _buildWaveCircle(index)),
          
          // Icono central
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveCircle(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double scale = 1.0 + (index * 0.3) + 
            (_animationController.value * 0.2);
        final double opacity = (1.0 - _animationController.value) * 
            (1.0 - index * 0.3);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.error.withValues(alpha: opacity * 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        );
      },
    );
  }

  String _getConnectionMessage() {
    switch (widget.networkState.status) {
      case NetworkStatus.offline:
        return 'No tienes conexión a internet. Verifica que el WiFi esté activado o que tengas datos móviles disponibles.';
      case NetworkStatus.disconnected:
        return 'Estás conectado a una red, pero no hay acceso a internet. Verifica la configuración de tu red.';
      case NetworkStatus.unknown:
        return 'No se puede determinar el estado de tu conexión. Intenta nuevamente en unos momentos.';
      default:
        return 'Hay un problema con tu conexión a internet.';
    }
  }

  Widget _buildSuggestionsList() {
    final suggestions = _getConnectionSuggestions();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.lightPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Puedes intentar:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightMainText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    suggestion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightSecondaryText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getConnectionSuggestions() {
    switch (widget.networkState.status) {
      case NetworkStatus.offline:
        return [
          'Activar el WiFi en configuración',
          'Verificar que tengas datos móviles disponibles',
          'Moverte a un área con mejor señal',
          'Reiniciar el router si usas WiFi',
        ];
      case NetworkStatus.disconnected:
        return [
          'Desconectar y volver a conectar al WiFi',
          'Verificar la contraseña del WiFi',
          'Contactar a tu proveedor de internet',
          'Intentar con datos móviles temporalmente',
        ];
      default:
        return [
          'Verificar tu conexión a internet',
          'Reiniciar la aplicación',
          'Contactar al soporte técnico',
        ];
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal de reintentar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Verificar conexión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botón secundario para configuración
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openNetworkSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Abrir configuración'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lightPrimary,
              side: BorderSide(color: AppColors.lightPrimary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            'Estado: ${widget.networkState.description}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleRetry() async {
    // Mostrar indicador de carga
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Verificando conexión...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    widget.onRetry?.call();
  }

  void _openNetworkSettings() {
    // En una implementación real, abriría la configuración del sistema
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ve a Configuración > WiFi o Datos móviles'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

/// Banner que se muestra en la parte superior cuando hay problemas de red
class NetworkStatusBanner extends StatelessWidget {
  final NetworkState state;
  final bool showDetails;

  const NetworkStatusBanner({
    super.key,
    required this.state,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state.hasInternet) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getBannerColor(),
      child: Row(
        children: [
          Icon(
            _getBannerIcon(),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getBannerMessage(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showDetails)
            Icon(
              Icons.expand_more,
              color: Colors.white,
              size: 16,
            ),
        ],
      ),
    );
  }

  Color _getBannerColor() {
    switch (state.status) {
      case NetworkStatus.offline:
        return AppColors.error;
      case NetworkStatus.disconnected:
        return Colors.orange;
      case NetworkStatus.unknown:
        return Colors.grey;
      default:
        return AppColors.error;
    }
  }

  IconData _getBannerIcon() {
    switch (state.status) {
      case NetworkStatus.offline:
        return Icons.wifi_off;
      case NetworkStatus.disconnected:
        return Icons.signal_wifi_connected_no_internet_4;
      case NetworkStatus.unknown:
        return Icons.help_outline;
      default:
        return Icons.warning;
    }
  }

  String _getBannerMessage() {
    switch (state.status) {
      case NetworkStatus.offline:
        return 'Sin conexión a internet';
      case NetworkStatus.disconnected:
        return 'Sin acceso a internet';
      case NetworkStatus.unknown:
        return 'Verificando conexión...';
      default:
        return 'Problema de conexión';
    }
  }
}

/// Widget compacto para mostrar el estado de red en esquinas o headers
class NetworkStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final double size;

  const NetworkStatusIndicator({
    super.key,
    this.showLabel = false,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkStateProvider);

    return networkState.when(
      data: (state) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(state),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              _getStatusLabel(state),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(state),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      loading: () => Icon(
        Icons.help_outline,
        size: size,
        color: Colors.grey,
      ),
      error: (_, _) => Icon(
        Icons.error_outline,
        size: size,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildStatusIcon(NetworkState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Icon(
        _getStatusIcon(state),
        size: size,
        color: _getStatusColor(state),
      ),
    );
  }

  IconData _getStatusIcon(NetworkState state) {
    switch (state.status) {
      case NetworkStatus.connected:
        return state.type == ConnectionType.wifi
            ? Icons.wifi
            : Icons.signal_cellular_alt;
      case NetworkStatus.disconnected:
        return Icons.signal_wifi_connected_no_internet_4;
      case NetworkStatus.offline:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(NetworkState state) {
    switch (state.status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.orange;
      case NetworkStatus.offline:
        return AppColors.error;
      case NetworkStatus.unknown:
        return Colors.grey;
    }
  }

  String _getStatusLabel(NetworkState state) {
    switch (state.status) {
      case NetworkStatus.connected:
        return 'Conectado';
      case NetworkStatus.disconnected:
        return 'Sin internet';
      case NetworkStatus.offline:
        return 'Offline';
      case NetworkStatus.unknown:
        return 'Verificando...';
    }
  }
}

/// Dialog que se muestra cuando se detecta pérdida de conexión durante una operación
class NetworkLostDialog extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final String? customMessage;

  const NetworkLostDialog({
    super.key,
    this.onRetry,
    this.onCancel,
    this.customMessage,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
    String? customMessage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkLostDialog(
        onRetry: onRetry,
        onCancel: onCancel,
        customMessage: customMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Conexión perdida'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customMessage ?? 
            'Se perdió la conexión a internet durante la operación. '
            'Verifica tu conexión e intenta nuevamente.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tus datos se guardarán localmente y se sincronizarán cuando tengas conexión.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}