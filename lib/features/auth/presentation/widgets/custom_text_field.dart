import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Custom text field for login form
class CustomTextField extends StatelessWidget {
  /// Label text
  final String label;

  /// Hint text
  final String hint;

  /// Icon
  final IconData icon;

  /// Error text
  final String? errorText;

  /// Is password field
  final bool isPassword;

  /// On changed callback
  final Function(String) onChanged;

  /// Toggle password visibility callback
  final VoidCallback? onToggleVisibility;

  /// Is password visible
  final bool isPasswordVisible;

  /// Is input valid
  final bool isValid;

  /// Text editing controller
  final TextEditingController? controller;

  /// Constructor
  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.errorText,
    this.isPassword = false,
    this.onToggleVisibility,
    this.isPasswordVisible = false,
    this.isValid = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkFormBackground : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            onChanged: onChanged,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color:
                    isDark
                        ? AppColors.darkSecondaryText.withValues(alpha: 0.6)
                        : Colors.black38,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FaIcon(
                  icon,
                  size: 18,
                  color:
                      hasError
                          ? (isDark
                              ? AppColors.darkError
                              : AppColors.lightError)
                          : (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary),
                ),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: FaIcon(
                          isPasswordVisible
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                          size: 18,
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : Colors.black54,
                        ),
                        onPressed: onToggleVisibility,
                      )
                      : (isValid && !hasError)
                      ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FaIcon(
                          FontAwesomeIcons.circleCheck,
                          size: 18,
                          color:
                              isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                        ),
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      (isValid && !hasError)
                          ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary)
                          : (isDark
                              ? AppColors.darkSecondaryText.withValues(
                                alpha: 0.3,
                              )
                              : Colors.black26),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkError : AppColors.lightError,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkError : AppColors.lightError,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkFormBackground : Colors.white,
              errorText: errorText,
              errorStyle: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkError : AppColors.lightError,
              ),
              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}
