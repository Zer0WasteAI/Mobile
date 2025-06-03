import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Social login button
class SocialButton extends StatelessWidget {
  /// Icon
  final IconData icon;

  /// Color
  final Color color;

  /// On tap callback
  final VoidCallback onTap;

  /// Constructor
  const SocialButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            color:
                isDark
                    ? AppColors.darkFormBackground.withValues(alpha: 0.5)
                    : Colors.white,
          ),
          child: Center(child: FaIcon(icon, color: color, size: 24)),
        ),
      ),
    );
  }
}

/// Row of social login buttons
/// Apple button only appears on iOS devices
class SocialButtonsRow extends StatelessWidget {
  /// Google login callback
  final VoidCallback onGoogleTap;

  /// Facebook login callback
  final VoidCallback onFacebookTap;

  /// Apple login callback
  final VoidCallback onAppleTap;

  /// Constructor
  const SocialButtonsRow({
    super.key,
    required this.onGoogleTap,
    required this.onFacebookTap,
    required this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Create list of buttons based on platform
    final List<Widget> buttons = [
      SocialButton(
        icon: FontAwesomeIcons.google,
        color: const Color(0xFFDB4437),
        onTap: onGoogleTap,
      ),
      SocialButton(
        icon: FontAwesomeIcons.facebook,
        color: const Color(0xFF4267B2),
        onTap: onFacebookTap,
      ),
    ];

    // Only add Apple button on iOS devices
    if (Platform.isIOS) {
      buttons.add(
        SocialButton(
          icon: FontAwesomeIcons.apple,
          color: isDark ? Colors.white : Colors.black,
          onTap: onAppleTap,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}
