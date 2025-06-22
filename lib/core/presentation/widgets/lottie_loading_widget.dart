import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Reusable Lottie loading widget for better UX during long operations
class LottieLoadingWidget extends StatelessWidget {
  final LottieAnimationType animationType;
  final double? width;
  final double? height;
  final String? message;
  final Color? messageColor;
  final bool showMessage;
  final bool showPulseEffect;
  final bool showGradientBackground;

  const LottieLoadingWidget({
    super.key,
    this.animationType = LottieAnimationType.general,
    this.width,
    this.height,
    this.message,
    this.messageColor,
    this.showMessage = false,
    this.showPulseEffect = false,
    this.showGradientBackground = false,
  });

  /// Factory for food-related loading (scanning, recipes, inventory)
  const LottieLoadingWidget.food({
    super.key,
    this.width = 120,
    this.height = 120,
    this.message = 'Procesando alimentos...',
    this.messageColor,
    this.showMessage = true,
    this.showPulseEffect = false,
    this.showGradientBackground = false,
  }) : animationType = LottieAnimationType.food;

  /// Factory for AI-related loading (recipe generation, analysis)
  const LottieLoadingWidget.ai({
    super.key,
    this.width = 100,
    this.height = 100,
    this.message = 'IA analizando...',
    this.messageColor,
    this.showMessage = true,
    this.showPulseEffect = true,
    this.showGradientBackground = true,
  }) : animationType = LottieAnimationType.ai;

  /// ✨ NEW: Awesome AI Analysis loading with enhanced visual effects
  const LottieLoadingWidget.aiAnalysis({
    super.key,
    this.width = 140,
    this.height = 140,
    this.message = '🤖 Analizando con IA...',
    this.messageColor,
    this.showMessage = true,
    this.showPulseEffect = true,
    this.showGradientBackground = true,
  }) : animationType = LottieAnimationType.ai;

  /// Factory for email verification
  const LottieLoadingWidget.email({
    super.key,
    this.width = 150,
    this.height = 150,
    this.message = 'Verificando email...',
    this.messageColor,
    this.showMessage = true,
    this.showPulseEffect = false,
    this.showGradientBackground = false,
  }) : animationType = LottieAnimationType.email;

  /// Factory for small inline loading (buttons, cards)
  const LottieLoadingWidget.small({
    super.key,
    this.width = 24,
    this.height = 24,
    this.message,
    this.messageColor,
    this.showMessage = false,
    this.showPulseEffect = false,
    this.showGradientBackground = false,
  }) : animationType = LottieAnimationType.general;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget animationWidget = SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        _getAnimationPath(),
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );

    // Add pulse effect if enabled
    if (showPulseEffect) {
      animationWidget = _PulseAnimation(child: animationWidget);
    }

    // Add gradient background if enabled
    if (showGradientBackground) {
      animationWidget = Container(
        width: (width ?? 100) + 40,
        height: (height ?? 100) + 40,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.secondary.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(child: animationWidget),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        animationWidget,
        if (showMessage && message != null) ...[
          const SizedBox(height: 20),
          // Enhanced message with shimmer effect for AI analysis
          if (animationType == LottieAnimationType.ai)
            _buildShimmerText(context, message!)
          else
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    messageColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ],
    );
  }

  Widget _buildShimmerText(BuildContext context, String text) {
    final theme = Theme.of(context);
    return _ShimmerText(
      text: text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  String _getAnimationPath() {
    switch (animationType) {
      case LottieAnimationType.food:
        return 'assets/animations/food-loading.json';
      case LottieAnimationType.ai:
        return 'assets/animations/ai_thinking.json';
      case LottieAnimationType.email:
        return 'assets/animations/email_verification.json';
      case LottieAnimationType.general:
        return 'assets/animations/food-loading.json'; // Default fallback
    }
  }
}

/// Types of Lottie animations available
enum LottieAnimationType { general, food, ai, email }

/// Extension for easy access to loading widgets
extension LottieLoadingExtension on Widget {
  /// Replace CircularProgressIndicator with Lottie animation
  static Widget lottieLoading({
    LottieAnimationType type = LottieAnimationType.general,
    double? size,
    String? message,
    Color? messageColor,
  }) {
    return LottieLoadingWidget(
      animationType: type,
      width: size,
      height: size,
      message: message,
      messageColor: messageColor,
      showMessage: message != null,
    );
  }
}

/// Predefined loading widgets for common use cases
class LoadingWidgets {
  /// For scan/recognition operations
  static const scanLoading = LottieLoadingWidget.food(
    message: '🔍 Analizando imágenes...',
  );

  /// For recipe operations
  static const recipeLoading = LottieLoadingWidget.food(
    message: '🍽️ Cargando recetas...',
  );

  /// For AI recipe generation
  static const aiRecipeLoading = LottieLoadingWidget.ai(
    message: '🤖 Generando recetas con IA...',
  );

  /// ✨ NEW: Enhanced AI analysis loading
  static const aiAnalysisLoading = LottieLoadingWidget.aiAnalysis(
    message: '🧠 Analizando con inteligencia artificial...',
  );

  /// For inventory operations
  static const inventoryLoading = LottieLoadingWidget.food(
    message: '📦 Actualizando inventario...',
  );

  /// For authentication
  static const authLoading = LottieLoadingWidget.email(
    message: '🔐 Autenticando...',
  );

  /// For general operations
  static const generalLoading = LottieLoadingWidget(
    width: 80,
    height: 80,
    message: 'Cargando...',
    showMessage: true,
  );

  /// Small loading for buttons
  static const buttonLoading = LottieLoadingWidget.small();
}

/// ✨ Continuous pulse animation widget
class _PulseAnimation extends StatefulWidget {
  final Widget child;

  const _PulseAnimation({required this.child});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}

/// ✨ Continuous shimmer text animation widget
class _ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _ShimmerText({required this.text, this.style});

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _animation.value,
          duration: const Duration(milliseconds: 100),
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
