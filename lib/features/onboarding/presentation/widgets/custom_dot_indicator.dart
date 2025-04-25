import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Custom dot indicator widget
class CustomDotIndicator extends StatelessWidget {
  /// Page controller
  final PageController controller;
  
  /// Number of pages
  final int count;
  
  /// Constructor
  const CustomDotIndicator({
    super.key,
    required this.controller,
    required this.count,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        activeDotColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        dotColor: isDark ? AppColors.darkPrimary.withValues(alpha: 0.3) : AppColors.lightPrimary.withValues(alpha: 0.3),
        dotHeight: 8,
        dotWidth: 8,
        spacing: 8,
        expansionFactor: 3,
      ),
    );
  }
}