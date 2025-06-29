import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/auth_service.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Provider global para manejar la expiración de sesiones
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(ref);
});

class SessionManager {
  final Ref _ref;
  
  SessionManager(this._ref);
  
  /// Detecta y maneja errores de sesión expirada
  void handleError(dynamic error) {
    if (error is SessionExpiredException) {
      log('🚪 Session expired detected: ${error.message}');
      _handleSessionExpired(error.message);
    }
  }
  
  /// Fuerza logout cuando la sesión expira
  void _handleSessionExpired(String message) {
    try {
      // Llamar al método del AuthController para manejar la expiración
      _ref.read(authControllerProvider.notifier).handleSessionExpired(message);
      log('✅ Session expired handled - user will be redirected to login');
    } catch (e) {
      log('❌ Error handling session expiration: $e');
    }
  }
  
  /// Método para ser llamado desde interceptores o servicios
  static void notifySessionExpired(Ref ref, String message) {
    try {
      ref.read(sessionManagerProvider).handleError(
        SessionExpiredException(message)
      );
    } catch (e) {
      log('❌ Error notifying session expired: $e');
    }
  }
}