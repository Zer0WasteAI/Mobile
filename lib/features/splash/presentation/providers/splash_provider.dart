import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/splash/presentation/viewmodels/splash_controller.dart';

/// Provider for the splash controller
final splashControllerProvider = StateNotifierProvider<SplashController, SplashState>(
  (ref) => SplashController(ref),
);