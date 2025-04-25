import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  final void Function(String)? onCompleted;
  final String? errorText;
  final int length;
  final bool enabled;

  const OtpInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onCompleted,
    this.errorText,
    this.length = 6,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final defaultBorderColor = isDark ? Colors.white30 : Colors.black26;
    final fillColor = isDark ? AppColors.darkOtpFill : AppColors.lightOtpFill;
    final hasError = errorText != null && errorText!.isNotEmpty;

    // Calculate dynamic width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust padding based on your layout (e.g., screen padding)
    final availableWidth =
        screenWidth -
        (2 * 24); // Assuming 24px horizontal padding on the screen
    final pinSpacing =
        (length - 1) *
        8; // Estimate spacing based on MainAxisAlignment.spaceBetween
    final calculatedPinWidth = (availableWidth - pinSpacing) / length;
    // Ensure minimum and maximum width for pins
    final pinWidth = calculatedPinWidth.clamp(40.0, 56.0);

    final defaultPinTheme = PinTheme(
      width: pinWidth, // Use calculated width
      height: 60,
      textStyle: theme.textTheme.titleLarge?.copyWith(
        fontSize: 22,
        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? errorColor : defaultBorderColor),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: hasError ? errorColor : primaryColor,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: hasError ? errorColor : primaryColor),
        // Optionally change background color on submit
        // color: primaryColor.withOpacity(0.1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: errorColor),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pinput(
          length: length,
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          onCompleted: onCompleted,
          keyboardType: TextInputType.number,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: hasError ? errorPinTheme : defaultPinTheme,
          errorTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: errorColor,
          ),
          pinAnimationType: PinAnimationType.fade,
          errorText: errorText,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          showCursor: true,
        ),
        // Optionally display error text separately below
        // if (hasError)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 8.0, left: 8.0),
        //     child: Text(
        //       errorText!,
        //       style: TextStyle(color: errorColor, fontSize: 12),
        //     ),
        //   ),
      ],
    );
  }
}
