
import 'dart:async';

import 'package:flutter/material.dart';

/// Clase que permite a GoRouter escuchar un stream para refrescar la navegación
class GoRouterRefreshStream extends ChangeNotifier {
  /// Constructor que toma un Stream
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
