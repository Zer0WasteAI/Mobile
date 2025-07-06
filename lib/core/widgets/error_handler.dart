import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Global error handler for authentication errors
/// Shows a user-friendly dialog instead of raw error messages
class AuthErrorHandler extends ConsumerStatefulWidget {
  final Widget child;

  const AuthErrorHandler({super.key, required this.child});

  @override
  ConsumerState<AuthErrorHandler> createState() => _AuthErrorHandlerState();
}

class _AuthErrorHandlerState extends ConsumerState<AuthErrorHandler> {
  bool _hasShownErrorDialog = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes to handle errors globally
    ref.listen(authControllerProvider, (previous, next) {
      // Only show error dialog if there's an error and we haven't shown it yet
      if (next.hasError && !_hasShownErrorDialog) {
        _hasShownErrorDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAuthErrorOverlay(context, next.error.toString());
        });
      }

      // Reset the flag when auth state is no longer in error
      if (!next.hasError) {
        _hasShownErrorDialog = false;
        _removeOverlay();
      }
    });

    return widget.child;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showAuthErrorOverlay(BuildContext context, String errorMessage) {
    // Check if context is mounted
    if (!context.mounted) {
      debugPrint('⚠️ AuthErrorHandler: Context not mounted, skipping dialog');
      return;
    }

    // Remove any existing overlay
    _removeOverlay();

    // Determine if this is a backend connection error
    final isBackendError =
        errorMessage.contains('404') ||
        errorMessage.contains('DioException') ||
        errorMessage.contains('bad response') ||
        errorMessage.contains('Failed to sign in') ||
        errorMessage.contains('500');

    final title =
        isBackendError ? 'Error de Conexión' : 'Error de Autenticación';
    final message =
        isBackendError
            ? 'No se pudo conectar con el servidor. Por favor, vuelva a intentarlo más tarde.'
            : 'Ocurrió un error durante la autenticación. Inténtelo nuevamente.';

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                child: AlertDialog(
                  title: Row(
                    children: [
                      Icon(
                        isBackendError ? Icons.cloud_off : Icons.error_outline,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Flexible(child: Text(title)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message, style: const TextStyle(fontSize: 16)),
                      if (isBackendError) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Detalles técnicos:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'El servidor no está disponible (Error ${isBackendError ? "500/404" : ""})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _removeOverlay();
                        // Reset error flag but don't sign out
                        _hasShownErrorDialog = false;
                      },
                      child: const Text('Reintentar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        _removeOverlay();
                        // Sign out and redirect to login
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

/// Simple error dialog for specific error messages
class ErrorDialogHelper {
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? technicalDetails,
    VoidCallback? onAccept,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 16)),
              if (technicalDetails != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Detalles técnicos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  technicalDetails,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onAccept?.call();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  static void showBackendErrorDialog(
    BuildContext context, {
    VoidCallback? onSignOut,
  }) {
    showErrorDialog(
      context,
      title: 'Error de Conexión',
      message:
          'No se pudo conectar con el servidor. '
          'Por favor, vuelva a intentarlo más tarde.',
      technicalDetails: 'El servidor no está disponible (Error 404)',
      onAccept: onSignOut,
    );
  }
}
