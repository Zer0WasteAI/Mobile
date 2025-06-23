import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/core/services/secure_token_service.dart';
import 'dart:developer';

/// Provider for AuthErrorHandler singleton
final authErrorHandlerProvider = Provider<AuthErrorHandler>((ref) {
  return AuthErrorHandler(ref);
});

/// Handles authentication errors and provides user-friendly feedback
class AuthErrorHandler {
  final Ref _ref;

  AuthErrorHandler(this._ref);

  /// Handle 401 authentication errors with user-friendly messaging
  Future<void> handle401Error(
    BuildContext context, {
    String? customMessage,
    bool showSnackbar = true,
    bool forceLogout = true,
  }) async {
    log('🚨 AuthErrorHandler: Handling 401 authentication error');

    final message =
        customMessage ??
        'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';

    // Show user-friendly message
    if (showSnackbar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Iniciar Sesión',
            textColor: Colors.white,
            onPressed: () => _navigateToLogin(context),
          ),
        ),
      );
    }

    // Force logout if requested
    if (forceLogout) {
      await _performSecureLogout();
    }
  }

  /// Handle token refresh failures
  Future<bool> handleTokenRefreshFailure({
    required BuildContext context,
    bool attemptAutoRelogin = true,
  }) async {
    log('🔄 AuthErrorHandler: Handling token refresh failure');

    if (attemptAutoRelogin) {
      log('🔄 Attempting auto-relogin after token refresh failure...');

      try {
        final authController = _ref.read(authControllerProvider.notifier);
        await authController.refreshUserFromFirestore();
        log('✅ Auto-relogin successful after token refresh failure');
        return true;
      } catch (e) {
        log('❌ Auto-relogin failed: $e');
      }
    }

    // If auto-relogin fails or is not attempted, handle as 401 error
    await handle401Error(
      context,
      customMessage:
          'No se pudo renovar tu sesión. Por favor, inicia sesión nuevamente.',
    );

    return false;
  }

  /// Check if tokens are expired and handle accordingly
  Future<bool> checkAndHandleTokenExpiration(BuildContext context) async {
    try {
      final secureTokenService = _ref.read(secureTokenServiceProvider);

      // Check if we have tokens
      final hasTokens = await secureTokenService.hasValidTokens();
      if (!hasTokens) {
        log('⚠️ AuthErrorHandler: No valid tokens found');
        await handle401Error(
          context,
          customMessage:
              'No se encontraron credenciales válidas. Por favor, inicia sesión.',
        );
        return false;
      }

      // Check if tokens are expired
      final isExpired = await secureTokenService.isAccessTokenExpired();
      if (isExpired) {
        log('⚠️ AuthErrorHandler: Access token is expired');

        // Try to refresh tokens first
        try {
          final authRepository = _ref.read(authRepositoryProvider);
          await authRepository.refreshApplicationTokens();
          log('✅ AuthErrorHandler: Token refresh successful');
          return true;
        } catch (e) {
          log('❌ AuthErrorHandler: Token refresh failed: $e');
          return await handleTokenRefreshFailure(context: context);
        }
      }

      return true; // Tokens are valid
    } catch (e) {
      log('❌ AuthErrorHandler: Error checking token expiration: $e');
      await handle401Error(
        context,
        customMessage:
            'Error al verificar la sesión. Por favor, inicia sesión nuevamente.',
      );
      return false;
    }
  }

  /// Perform secure logout clearing all tokens and state
  Future<void> _performSecureLogout() async {
    try {
      log('🔒 AuthErrorHandler: Performing secure logout...');

      // Clear tokens from secure storage
      final secureTokenService = _ref.read(secureTokenServiceProvider);
      await secureTokenService.clearTokens();

      // Sign out through auth controller
      final authController = _ref.read(authControllerProvider.notifier);
      await authController.signOut();

      log('✅ AuthErrorHandler: Secure logout completed');
    } catch (e) {
      log('❌ AuthErrorHandler: Error during secure logout: $e');
    }
  }

  /// Navigate to login screen
  void _navigateToLogin(BuildContext context) {
    // This will be handled by the router when auth state changes
    log('🔄 AuthErrorHandler: Navigation to login will be handled by router');
  }

  /// Show authentication error dialog
  Future<void> showAuthErrorDialog(
    BuildContext context, {
    String? title,
    String? message,
    bool showRetryButton = true,
  }) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title ?? 'Sesión Expirada'),
            content: Text(
              message ??
                  'Tu sesión ha expirado. Por favor, inicia sesión nuevamente para continuar.',
            ),
            actions: [
              if (showRetryButton)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Try to refresh the current screen
                  },
                  child: const Text('Reintentar'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performSecureLogout();
                },
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
    );
  }

  /// Create a user-friendly error message from exception
  String createUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
    } else if (errorString.contains('403') ||
        errorString.contains('forbidden')) {
      return 'No tienes permisos para realizar esta acción.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
    } else if (errorString.contains('timeout')) {
      return 'La operación tardó demasiado. Intenta nuevamente.';
    } else {
      return 'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
    }
  }
}
