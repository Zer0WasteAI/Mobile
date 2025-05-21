import 'package:flutter/material.dart';

/// Muestra un SnackBar con indicador de carga
void showLoadingSnackBar(
  BuildContext context, {
  String message = 'Guardando...',
  Duration duration = const Duration(seconds: 1),
}) {
  // Eliminar cualquier SnackBar existente para evitar colisión de GlobalKeys
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
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
    ),
  );
}
