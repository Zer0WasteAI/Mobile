// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart';

/// Modal for selecting scan options
class ScanOptionsModal extends ConsumerWidget {
  final VoidCallback onClose;

  const ScanOptionsModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final cardColor = theme.colorScheme.surface;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final headerColor = theme.colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor, // Background is the primary color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Take only needed height
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Elige una opción',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: headerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: headerColor),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Options Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(
                context: context,
                ref: ref,
                iconPath: 'assets/images/scan/ingredient.png', // Existing path
                label: 'Ingrediente',
                onPressed: () {
                  // Close modal
                  ref.read(isScanModalOpenProvider.notifier).state = false;
                  // Navigate to add ingredient screen
                  context.go('/scan/add/ingredient');
                },
              ),
              const SizedBox(width: 16),
              _buildOptionButton(
                context: context,
                ref: ref,
                iconPath: 'assets/images/scan/food.png', // Existing path
                label: 'Food',
                onPressed: () {
                  // Close modal
                  ref.read(isScanModalOpenProvider.notifier).state = false;
                  // Navigate to add food screen
                  context.go('/scan/add/food');
                },
              ),
            ],
          ),
          const SizedBox(height: 10), // Padding at the bottom
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required WidgetRef ref,
    required String iconPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 40; // Adjust padding/spacing
    final theme = Theme.of(context); // Get theme here

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                height: 80, // Adjust as needed
                fit: BoxFit.contain,
                errorBuilder:
                    (ctx, err, st) =>
                        const Icon(Icons.image_not_supported, size: 80),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
