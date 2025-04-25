import 'dart:io'; // Import dart:io for File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Assuming AppColors exist
// Import the new provider
import 'package:zer0_waste_ai/features/scan/presentation/providers/add_scan_item_provider.dart';

// Enum to differentiate between item types
enum ScanItemType { ingredient, food }

class AddScanItemScreen extends ConsumerWidget {
  final ScanItemType itemType;

  const AddScanItemScreen({required this.itemType, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Watch the controller state
    final scanState = ref.watch(addScanItemControllerProvider);
    // Get the controller notifier
    final scanController = ref.read(addScanItemControllerProvider.notifier);

    // Determine dynamic text and potentially image based on itemType
    final String itemTypeName =
        itemType == ScanItemType.ingredient ? 'un ingrediente' : 'una comida';
    // Placeholder for dynamic image - adjust path as needed
    final String centralImagePath =
        itemType == ScanItemType.ingredient
            ? 'assets/images/scan/scan_ingredients.png' // Assuming this exists
            : 'assets/images/scan/scan_foods.png'; // Assuming this exists

    final double imageHeight = screenHeight * 0.35;

    return Scaffold(
      // Keep background consistent with the app theme
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Title
              Text(
                '¡Organicemos la despensa!',
                style: textTheme.displayLarge?.copyWith(
                  color:
                      isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  fontSize: 28, // Adjust size as needed
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Display selected image OR the default image
              scanState.selectedImage != null
                  ? _buildSelectedImagePreview(
                    scanState.selectedImage!,
                    screenHeight,
                  )
                  : _buildDefaultImage(centralImagePath, imageHeight),

              // Show loading indicator during picking
              if (scanState.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),

              // Show error message if any
              if (scanState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    scanState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),

              // Description Text
              Text(
                'Toma una foto o selecciona\n$itemTypeName desde tu galería.',
                style: textTheme.bodyLarge?.copyWith(
                  color:
                      isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                  fontSize: 16, // Adjust size as needed
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Action Buttons (Camera & Gallery)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    onPressed: () {
                      // Call controller method
                      scanController.pickImage(ImageSource.camera);
                    },
                    // Disable button while loading
                    enabled: !scanState.isLoading,
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.photo_library_outlined,
                    onPressed: () {
                      // Call controller method
                      scanController.pickImage(ImageSource.gallery);
                    },
                    // Disable button while loading
                    enabled: !scanState.isLoading,
                  ),
                ],
              ),
              // Optionally add a clear button if an image is selected
              if (scanState.selectedImage != null && !scanState.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear), // Or Icons.delete
                    label: const Text('Clear Selection'),
                    onPressed: () => scanController.clearSelection(),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Widget to display the default placeholder image
  Widget _buildDefaultImage(String imagePath, double height) {
    return Image.asset(
      imagePath,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return const Text('✨', style: TextStyle(fontSize: 60));
      },
    );
  }

  // Widget to display the selected image preview
  Widget _buildSelectedImagePreview(File imageFile, double screenHeight) {
    // Calculate a reasonable max height for the preview
    final double previewMaxHeight = screenHeight * 0.4;
    return Container(
      constraints: BoxConstraints(maxHeight: previewMaxHeight),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
          // Add error builder for File image too
          errorBuilder: (context, error, stackTrace) {
            print("Error loading file image: $error");
            return const Center(
              child: Icon(Icons.error_outline, size: 50, color: Colors.red),
            );
          },
        ),
      ),
    );
  }

  // Helper widget for action buttons (updated)
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true, // Add enabled flag
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Define button colors - using secondary color for background
    final Color buttonBackgroundColor = colorScheme.secondary;
    final Color iconColor =
        isDark
            ? AppColors.darkMainText
            : AppColors.lightMainText; // Or choose a specific color

    return ElevatedButton(
      // Use null onPressed to disable the button
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
        // Optionally change style when disabled
        disabledBackgroundColor: buttonBackgroundColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(
          20,
        ), // Increase padding for larger buttons
        elevation: 2, // Add subtle shadow
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 40, // Increase icon size
      ),
    );
  }
}
