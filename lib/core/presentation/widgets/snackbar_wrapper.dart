import 'package:flutter/material.dart';

/// Wrapper seguro para mostrar SnackBars en la aplicación.
/// Esta función se asegura de eliminar cualquier SnackBar existente antes de mostrar uno nuevo
/// y utiliza claves únicas para evitar colisiones de GlobalKey.
void showSafeSnackBar(
  BuildContext context, {
  required Widget content,
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
  SnackBarAction? action,
  SnackBarBehavior behavior = SnackBarBehavior.fixed,
}) {
  // Eliminar cualquier SnackBar existente para evitar colisión de GlobalKeys
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Use timestamp-based ValueKey for better uniqueness than plain UniqueKey
  final uniqueKey = ValueKey(
    'snackbar_${DateTime.now().millisecondsSinceEpoch}',
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      key: uniqueKey,
      content: content,
      duration: duration,
      backgroundColor: backgroundColor,
      action: action,
      behavior: behavior,
    ),
  );
}

/// Muestra un SnackBar simple con un mensaje de texto
void showSimpleSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
  SnackBarAction? action,
  SnackBarBehavior behavior = SnackBarBehavior.fixed,
}) {
  showSafeSnackBar(
    context,
    content: Text(message),
    duration: duration,
    backgroundColor: backgroundColor,
    action: action,
    behavior: behavior,
  );
}

/// Muestra un SnackBar de error
void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarBehavior behavior = SnackBarBehavior.fixed,
}) {
  showSimpleSnackBar(
    context,
    message,
    duration: duration,
    backgroundColor: Colors.red,
    behavior: behavior,
  );
}

/// Muestra un SnackBar de éxito
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  SnackBarBehavior behavior = SnackBarBehavior.fixed,
}) {
  showSimpleSnackBar(
    context,
    message,
    duration: duration,
    backgroundColor: Colors.green,
    behavior: behavior,
  );
}

/// Muestra un SnackBar con indicador de carga
void showLoadingSnackBar(
  BuildContext context, {
  String message = 'Cargando...',
  Duration duration = const Duration(seconds: 5),
  SnackBarBehavior behavior = SnackBarBehavior.fixed,
}) {
  showSafeSnackBar(
    context,
    content: Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Text(message),
      ],
    ),
    duration: duration,
    backgroundColor: Colors.black54,
    behavior: behavior,
  );
}

/// Clase para gestionar SnackBars de forma centralizada en toda la aplicación
class SnackBarManager {
  static final SnackBarManager _instance = SnackBarManager._internal();

  factory SnackBarManager() {
    return _instance;
  }

  SnackBarManager._internal();

  /// Método para mostrar SnackBar usando la función segura
  void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    bool isError = false,
    bool isSuccess = false,
    bool isLoading = false,
  }) {
    if (isError) {
      showErrorSnackBar(
        context,
        message,
        duration: duration,
        behavior: behavior,
      );
    } else if (isSuccess) {
      showSuccessSnackBar(
        context,
        message,
        duration: duration,
        behavior: behavior,
      );
    } else if (isLoading) {
      showLoadingSnackBar(
        context,
        message: message,
        duration: duration,
        behavior: behavior,
      );
    } else {
      showSimpleSnackBar(
        context,
        message,
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
        behavior: behavior,
      );
    }
  }

  /// Método para ocultar cualquier SnackBar visible actualmente
  void hideCurrentSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

/// Acceso global al gestor de SnackBars
final snackBarManager = SnackBarManager();
