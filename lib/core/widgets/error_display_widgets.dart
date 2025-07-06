import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zer0_waste_ai/core/error/error_handler.dart';
import 'package:zer0_waste_ai/core/error/user_friendly_error_messages.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Widget para mostrar errores de forma consistente en toda la app
class ErrorDisplayWidget extends StatelessWidget {
  final dynamic error;
  final ErrorContext context;
  final ActionType action;
  final String? customMessage;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final bool showSuggestions;
  final Widget? customIcon;
  final double? height;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.context = ErrorContext.general,
    this.action = ActionType.load,
    this.customMessage,
    this.onRetry,
    this.showRetryButton = true,
    this.showSuggestions = false,
    this.customIcon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? 
        ErrorHandler.getDisplayMessage(
          error,
          context: this.context,
          action: action,
        );

    final suggestions = showSuggestions
        ? ErrorHandler.getActionSuggestions(error, context: this.context)
        : <String>[];

    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono de error
          customIcon ?? 
          Icon(
            _getErrorIcon(),
            size: 64,
            color: AppColors.error.withValues(alpha: 0.7),
          ),
          
          const SizedBox(height: 16),
          
          // Mensaje principal
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.lightSecondaryText,
            ),
          ),
          
          // Sugerencias (opcional)
          if (showSuggestions && suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.lightSecondaryText)),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          // Botón de reintentar
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (context) {
      case ErrorContext.network:
        return Icons.wifi_off;
      case ErrorContext.auth:
        return Icons.lock_outline;
      case ErrorContext.recognition:
      case ErrorContext.scan:
        return Icons.camera_alt_outlined;
      case ErrorContext.inventory:
        return Icons.inventory_2_outlined;
      case ErrorContext.recipes:
        return Icons.restaurant_outlined;
      case ErrorContext.profile:
        return Icons.person_outline;
      case ErrorContext.planner:
        return Icons.calendar_today_outlined;
      case ErrorContext.impact:
        return Icons.eco_outlined;
      default:
        return Icons.error_outline;
    }
  }
}

/// SnackBar de error personalizado
class ErrorSnackBar {
  static void show(
    BuildContext context,
    dynamic error, {
    ErrorContext errorContext = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customMessage,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = customMessage ?? 
        ErrorHandler.getDisplayMessage(
          error,
          context: errorContext,
          action: action,
        );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
              )
            : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Dialog de error detallado
class ErrorDialog extends StatelessWidget {
  final dynamic error;
  final ErrorContext context;
  final ActionType action;
  final String? customMessage;
  final VoidCallback? onRetry;
  final bool showSuggestions;

  const ErrorDialog({
    super.key,
    required this.error,
    this.context = ErrorContext.general,
    this.action = ActionType.load,
    this.customMessage,
    this.onRetry,
    this.showSuggestions = true,
  });

  static Future<void> show(
    BuildContext context,
    dynamic error, {
    ErrorContext errorContext = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customMessage,
    VoidCallback? onRetry,
    bool showSuggestions = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        error: error,
        context: errorContext,
        action: action,
        customMessage: customMessage,
        onRetry: onRetry,
        showSuggestions: showSuggestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? 
        ErrorHandler.getDisplayMessage(
          error,
          context: this.context,
          action: action,
        );

    final suggestions = showSuggestions
        ? ErrorHandler.getActionSuggestions(error, context: this.context)
        : <String>[];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Oops, algo salió mal',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Puedes intentar:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(suggestion)),
                ],
              ),
            )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
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

/// Widget compacto para mostrar errores inline
class InlineErrorWidget extends StatelessWidget {
  final dynamic error;
  final ErrorContext context;
  final ActionType action;
  final String? customMessage;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    super.key,
    required this.error,
    this.context = ErrorContext.general,
    this.action = ActionType.load,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? 
        ErrorHandler.getDisplayMessage(
          error,
          context: this.context,
          action: action,
        );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRetry,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.refresh,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Toast de error ligero
class ErrorToast {
  static void show(
    BuildContext context,
    dynamic error, {
    ErrorContext errorContext = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customMessage,
  }) {
    final message = customMessage ?? 
        ErrorHandler.getDisplayMessage(
          error,
          context: errorContext,
          action: action,
        );

    // Usar HapticFeedback para indicar error
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Extension methods para facilitar el uso
extension ErrorDisplayExtension on BuildContext {
  void showErrorSnackBar(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    ErrorSnackBar.show(
      this,
      error,
      errorContext: context,
      action: action,
      customMessage: customMessage,
      onRetry: onRetry,
    );
  }

  Future<void> showErrorDialog(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customMessage,
    VoidCallback? onRetry,
    bool showSuggestions = true,
  }) {
    return ErrorDialog.show(
      this,
      error,
      errorContext: context,
      action: action,
      customMessage: customMessage,
      onRetry: onRetry,
      showSuggestions: showSuggestions,
    );
  }

  void showErrorToast(
    dynamic error, {
    ErrorContext context = ErrorContext.general,
    ActionType action = ActionType.load,
    String? customMessage,
  }) {
    ErrorToast.show(
      this,
      error,
      errorContext: context,
      action: action,
      customMessage: customMessage,
    );
  }
}