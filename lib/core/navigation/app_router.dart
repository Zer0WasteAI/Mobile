import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/home/presentation/screens/home_screen.dart';
import 'package:zer0_waste_ai/features/splash/presentation/screens/splash_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// App router configuration
class AppRouter {
  /// GoRouter instance
  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}

/// Extension to easily access the router from BuildContext
extension RouterExtension on BuildContext {
  /// Navigate to a named route
  void goNamed(String name, {Map<String, String> params = const {}}) {
    GoRouter.of(this).goNamed(name, pathParameters: params);
  }

  /// Navigate to a path
  void go(String path) {
    GoRouter.of(this).go(path);
  }

  /// Replace the current route with a named route
  void replaceNamed(String name, {Map<String, String> params = const {}}) {
    GoRouter.of(this).replaceNamed(name, pathParameters: params);
  }

  /// Replace the current route with a path
  void replace(String path) {
    GoRouter.of(this).replace(path);
  }
}