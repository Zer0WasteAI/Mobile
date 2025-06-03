import 'package:flutter/material.dart';

/// Widget que detecta toques en cualquier lugar de la pantalla y quita el foco
/// de cualquier campo de texto que lo tenga.
class UnfocusDetector extends StatelessWidget {
  final Widget child;

  const UnfocusDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Quitar el foco de cualquier campo de texto que lo tenga
        FocusScope.of(context).unfocus();
      },
      // Aseguramos que los gestos sean detectados incluso en áreas transparentes
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
