// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/splash/presentation/providers/splash_provider.dart';
import 'package:zer0_waste_ai/features/splash/presentation/viewmodels/splash_controller.dart';
import 'dart:async';

/// Splash screen
class SplashScreen extends ConsumerStatefulWidget {
  /// Constructor
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _pulseAnimation;

  // Animation flags
  bool _showText = false;
  bool _showLoading = false;

  // Navigation flags
  bool _hasNavigated = false;
  bool _isTimeoutOccurred = false;

  // Failsafe timer
  Timer? _failsafeTimer;
  Timer? _hardTimeoutTimer;

  @override
  void initState() {
    super.initState();

    // Initialize main animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo animation (scale up)
    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Text animation (fade in)
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );

    // Loading animation (fade in)
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Pulse animation (subtle scale effect)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start main animation
    _controller.forward();

    // Start pulse animation with repeat
    _pulseController.repeat(reverse: true);

    // Show text after delay
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });

    // Show loading after delay
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoading = true;
        });
      }
    });

    // Delay before navigating - regular timeout
    _failsafeTimer = Timer(const Duration(milliseconds: 3000), () {
      print('⚠️ [SplashScreen] Failsafe timer triggered - normal timeout');
      if (mounted && !_hasNavigated) {
        _finishSplash();
      }
    });

    // Hard timeout - in case navigation gets stuck
    _hardTimeoutTimer = Timer(const Duration(milliseconds: 7000), () {
      print(
        '🚨 [SplashScreen] Hard timeout triggered! Navigation may be stuck.',
      );
      if (mounted && !_hasNavigated) {
        setState(() {
          _isTimeoutOccurred = true;
        });
        // Force navigation to login as fallback
        try {
          context.go('/login');
          _hasNavigated = true;
        } catch (e) {
          print('Error during hard timeout navigation: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _failsafeTimer?.cancel();
    _hardTimeoutTimer?.cancel();
    super.dispose();
  }

  // Método para finalizar la animación del splash
  void _finishSplash() {
    if (_hasNavigated || !mounted) return;

    print('🚀 [SplashScreen] Finalizing splash and navigating...');

    // Marcar que ya hemos navegado para evitar navegaciones múltiples
    _hasNavigated = true;

    try {
      // Dejar que el router decida adónde ir según el estado actual
      // El router ya tiene toda la lógica necesaria para determinar la ruta correcta
      context.go('/router-entry');
    } catch (e) {
      print('❌ [SplashScreen] Error during navigation: $e');
      // En caso de error, intentar ir a login como fallback
      if (mounted) {
        try {
          context.go('/login');
        } catch (e2) {
          print('❌ [SplashScreen] Error during fallback navigation: $e2');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen to splash state changes - only for onboarding status
    ref.listen<SplashState>(splashControllerProvider, (previous, current) {
      print('🔄 [SplashScreen] Splash state changed: ${current.status}');
      if (current.status == SplashStatus.completed && !_hasNavigated) {
        _finishSplash();
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with initial scale and continuous pulse
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _controller,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        // Apply both the initial scale animation and the continuous pulse animation
                        return Transform.scale(
                          scale:
                              _logoAnimation.value *
                              (_showText ? _pulseAnimation.value : 1.0),
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/splash/splash_image.png',
                          width: 220,
                          height: 220,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Animated subtitle
                    AnimatedOpacity(
                      opacity: _showText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'Smart food, zero waste',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Animated loading spinner
                    AnimatedOpacity(
                      opacity: _showLoading ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Mostrar mensaje de timeout si ocurre
              if (_isTimeoutOccurred)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Redirigiendo... Por favor espere',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
