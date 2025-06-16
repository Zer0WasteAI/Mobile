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

  const LottieLoadingWidget({
    super.key,
    this.animationType = LottieAnimationType.general,
    this.width,
    this.height,
    this.message,
    this.messageColor,
    this.showMessage = false,
  });

  /// Factory for food-related loading (scanning, recipes, inventory)
  const LottieLoadingWidget.food({
    super.key,
    this.width = 120,
    this.height = 120,
    this.message = 'Procesando alimentos...',
    this.messageColor,
    this.showMessage = true,
  }) : animationType = LottieAnimationType.food;

  /// Factory for AI-related loading (recipe generation, analysis)
  const LottieLoadingWidget.ai({
    super.key,
    this.width = 100,
    this.height = 100,
    this.message = 'IA analizando...',
    this.messageColor,
    this.showMessage = true,
  }) : animationType = LottieAnimationType.ai;

  /// Factory for email verification
  const LottieLoadingWidget.email({
    super.key,
    this.width = 150,
    this.height = 150,
    this.message = 'Verificando email...',
    this.messageColor,
    this.showMessage = true,
  }) : animationType = LottieAnimationType.email;

  /// Factory for small inline loading (buttons, cards)
  const LottieLoadingWidget.small({
    super.key,
    this.width = 24,
    this.height = 24,
    this.message,
    this.messageColor,
    this.showMessage = false,
  }) : animationType = LottieAnimationType.general;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Lottie.asset(
            _getAnimationPath(),
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
          ),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  messageColor ??
                  theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
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
