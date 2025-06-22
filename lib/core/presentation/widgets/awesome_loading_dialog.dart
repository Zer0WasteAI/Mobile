import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'lottie_loading_widget.dart';

/// ✨ Awesome loading dialog with enhanced visual effects
class AwesomeLoadingDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? itemType;
  final bool showProgressIndicator;
  final VoidCallback? onCancel;

  const AwesomeLoadingDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.itemType,
    this.showProgressIndicator = false,
    this.onCancel,
  });

  /// Factory for AI analysis
  const AwesomeLoadingDialog.aiAnalysis({
    super.key,
    required String itemType,
    this.onCancel,
  }) : title = 'Analizando con IA 🤖',
       subtitle = 'Procesando tus imágenes...',
       itemType = itemType,
       showProgressIndicator = true;

  @override
  State<AwesomeLoadingDialog> createState() => _AwesomeLoadingDialogState();
}

class _AwesomeLoadingDialogState extends State<AwesomeLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the background
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for decorative elements
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Scale animation for the main content
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated background gradient
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: _pulseAnimation.value,
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.05),
                              colorScheme.secondary.withValues(alpha: 0.02),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      );
                    },
                  ),

                  // Decorative rotating elements
                  Positioned(
                    top: -20,
                    right: -20,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.1),
                                  colorScheme.secondary.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enhanced Lottie animation
                        const LottieLoadingWidget.aiAnalysis(),

                        const SizedBox(height: 24),

                        // Title with gradient text effect
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ).createShader(bounds),
                          child: Text(
                            widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle with typing animation effect
                        _buildTypingText(
                          context,
                          '${widget.subtitle}\n${_getItemTypeMessage()}',
                        ),

                        const SizedBox(height: 24),

                        // Progress indicator with pulse effect
                        if (widget.showProgressIndicator)
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      _pulseAnimation.value * 0.3 + 0.1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.secondary,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        if (widget.showProgressIndicator)
                          const SizedBox(height: 16),

                        // Fun facts or tips while loading
                        _buildLoadingTip(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingText(BuildContext context, String text) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<int>(
      duration: const Duration(milliseconds: 2000),
      tween: IntTween(begin: 0, end: text.length),
      builder: (context, value, child) {
        return Text(
          text.substring(0, value),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Widget _buildLoadingTip(BuildContext context) {
    final theme = Theme.of(context);
    return _CyclingTips(theme: theme);
  }

  String _getItemTypeMessage() {
    if (widget.itemType == null) return '';

    switch (widget.itemType!.toLowerCase()) {
      case 'food':
        return 'Identificando comidas preparadas...';
      case 'ingredient':
        return 'Reconociendo ingredientes...';
      default:
        return 'Analizando elementos...';
    }
  }
}

/// Helper function to show the awesome loading dialog
Future<void> showAwesomeLoadingDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? itemType,
  bool showProgressIndicator = false,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AwesomeLoadingDialog(
          title: title,
          subtitle: subtitle,
          itemType: itemType,
          showProgressIndicator: showProgressIndicator,
          onCancel: onCancel,
        ),
  );
}

/// Helper function to show AI analysis dialog
Future<void> showAIAnalysisDialog(
  BuildContext context, {
  required String itemType,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AwesomeLoadingDialog.aiAnalysis(
          itemType: itemType,
          onCancel: onCancel,
        ),
  );
}

/// ✨ Widget for cycling through loading tips with smooth animations
class _CyclingTips extends StatefulWidget {
  final ThemeData theme;

  const _CyclingTips({required this.theme});

  @override
  State<_CyclingTips> createState() => _CyclingTipsState();
}

class _CyclingTipsState extends State<_CyclingTips>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentTipIndex = 0;

  final List<String> _tips = [
    '💡 La IA puede identificar más de 1000 tipos de alimentos',
    '🌱 Reducir el desperdicio alimentario ayuda al planeta',
    '📊 La IA aprende de cada imagen que procesas',
    '⚡ Procesando con tecnología de vanguardia',
    '🎯 Optimizando la precisión del reconocimiento',
    '🔬 Analizando patrones visuales complejos',
    '🌟 Cada análisis mejora nuestro sistema',
    '🚀 Tecnología AI de última generación',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _startCycling();
  }

  void _startCycling() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentTipIndex),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.primaryContainer.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          _tips[_currentTipIndex],
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: widget.theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
