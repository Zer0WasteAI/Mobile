// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/splash/presentation/providers/splash_provider.dart';
import 'package:zer0_waste_ai/features/splash/presentation/viewmodels/splash_controller.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/lottie_loading_widget.dart';
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen to splash state changes
    ref.listen<SplashState>(splashControllerProvider, (previous, current) {
      // Navigate based on onboarding status when splash is completed
      if (current.status == SplashStatus.completed) {
        if (current.onboardingSeen) {
          // If onboarding has been seen, go to login
          context.go('/login');
        } else {
          // If onboarding has not been seen, go to onboarding
          context.go('/onboarding');
        }
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with initial scale and continuous pulse
                AnimatedBuilder(
                  animation: Listenable.merge([_controller, _pulseController]),
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
                  child: const LottieLoadingWidget.food(
                    width: 80,
                    height: 80,
                    showMessage: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
