import 'package:flutter/material.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Smooth card widget with consistent styling and hover effects
class SmoothCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;
  final bool enableHoverEffect;
  final double? width;
  final double? height;

  const SmoothCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.onTap,
    this.enableHoverEffect = true,
    this.width,
    this.height,
  });

  @override
  State<SmoothCard> createState() => _SmoothCardState();
}

class _SmoothCardState extends State<SmoothCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    if (widget.enableHoverEffect && widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onHoverEnd() {
    if (widget.enableHoverEffect) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        widget.backgroundColor ??
        (isDark ? AppColors.darkSurface : Colors.white);

    final defaultBoxShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHover: (hovering) {
                  if (hovering) {
                    _onHoverStart();
                  } else {
                    _onHoverEnd();
                  }
                },
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(16),
                    border: widget.border,
                    boxShadow:
                        widget.boxShadow ??
                        defaultBoxShadow
                            .map(
                              (shadow) => BoxShadow(
                                color: shadow.color,
                                blurRadius:
                                    shadow.blurRadius *
                                    _elevationAnimation.value,
                                offset:
                                    shadow.offset * _elevationAnimation.value,
                              ),
                            )
                            .toList(),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
