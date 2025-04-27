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

              // Display image previews or default image
              scanState.selectedImages.isEmpty
                  // Show default image if no images are selected
                  ? _buildDefaultImage(centralImagePath, imageHeight)
                  // Show previews if images are selected
                  : _buildImagePreviews(
                    scanState.selectedImages,
                    scanController,
                    screenHeight,
                  ),

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
                      // Pass context and this screen's itemType
                      scanController.pickImages(
                        ImageSource.camera,
                        context,
                        itemType,
                      );
                    },
                    // Disable button while loading
                    enabled: !scanState.isLoading,
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.photo_library_outlined,
                    onPressed: () {
                      // Pass context and this screen's itemType
                      scanController.pickImages(
                        ImageSource.gallery,
                        context,
                        itemType,
                      );
                    },
                    // Disable button while loading
                    enabled: !scanState.isLoading,
                  ),
                ],
              ),
              // Show clear button only if images are selected
              if (scanState.selectedImages.isNotEmpty && !scanState.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                    ), // Changed icon
                    label: const Text('Clear All'), // Changed label
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

  // Widget to display multiple selected image previews in a Wrap
  Widget _buildImagePreviews(
    List<File> images,
    AddScanItemController controller,
    double screenHeight,
  ) {
    // Calculate max height for the preview area
    final double previewMaxHeight = screenHeight * 0.4; // Adjust as needed

    return Container(
      constraints: BoxConstraints(maxHeight: previewMaxHeight),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        // Clip the scroll view
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          // Make it scrollable
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0, // Horizontal space between images
              runSpacing: 8.0, // Vertical space between rows
              children:
                  images.map((imageFile) {
                    return Stack(
                      children: [
                        // Image preview
                        Container(
                          width: 80, // Adjust size as needed
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Remove button (top right corner)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => controller.removeImage(imageFile),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
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
