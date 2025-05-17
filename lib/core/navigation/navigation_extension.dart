import 'package:flutter/material.dart';

/// Extensión para proporcionar métodos de navegación seguros
/// que no causen errores al intentar hacer pop() en la última página
extension SafeNavigator on BuildContext {
  /// Método seguro para hacer pop, verifica primero si es posible
  void safePop() {
    if (Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }
}
