// ignore_for_file: unused_element

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/add_scan_item_screen.dart'; // Import for ScanItemType
import 'package:zer0_waste_ai/features/scan/presentation/screens/scan_results_screen.dart'; // Import for ScanResultsScreen
import 'package:zer0_waste_ai/features/recognition/data/repositories/recognition_repository_impl.dart';
import 'package:zer0_waste_ai/features/recognition/domain/repositories/recognition_repository.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/lottie_loading_widget.dart';

// --- Design Constants ---
const Color _screenBackgroundColor = Color(0xFFFAF9F6);
const Color _primaryButtonColor = Color(0xFF00B894);
const Color _secondaryAccentColor = Color(0xFFF07548);
const Color _mainTextColor = Color(0xFF3A3A3A);
const Color _appBarTextColor = _mainTextColor;
const Color _indicatorDotColor = Colors.grey;
const Color _indicatorActiveDotColor = _primaryButtonColor;

// --- State Management (Local to this screen) ---

// Provider for the current page index of the carousel
final _currentPageProvider = StateProvider.autoDispose<int>((ref) => 0);

// Provider to manage the list of images shown *on this confirmation screen*
// It's initialized with the list passed via GoRouter's 'extra' parameter.
// Using autoDispose as this state is typically only relevant while the screen is active.
final _confirmImagesProvider = StateNotifierProvider.autoDispose
    .family<ImageListNotifier, List<File>, List<File>>((ref, initialImages) {
      return ImageListNotifier(initialImages);
    });

// Provider for RecognitionRepository
final _recognitionRepositoryProvider = Provider<RecognitionRepository>((ref) {
  return RecognitionRepositoryImpl();
});

// Simple StateNotifier to manage the list of images for this screen
class ImageListNotifier extends StateNotifier<List<File>> {
  ImageListNotifier(super.initialImages);

  void addImages(List<File> newImages) {
    state = [...state, ...newImages];
  }

  void removeImage(File imageToRemove) {
    state = state.where((image) => image.path != imageToRemove.path).toList();
  }

  // Optional: Replace all images (e.g., if user re-selects from gallery)
  // void setImages(List<File> images) {
  //   state = images;
  // }
}

// --- Screen Widget ---

class ScanConfirmScreen extends ConsumerStatefulWidget {
  final List<File> initialImages;
  final ScanItemType originType;
  static const int maxImages = 10; // Define max image limit
  static const String routeName = 'scanConfirm'; // Added routeName
  static const String routePath = '/scan/confirm'; // Added routePath

  const ScanConfirmScreen({
    super.key,
    required this.initialImages,
    required this.originType,
  });

  @override
  ConsumerState<ScanConfirmScreen> createState() => _ScanConfirmScreenState();
}

class _ScanConfirmScreenState extends ConsumerState<ScanConfirmScreen> {
  late PageController _pageController;
  final ImagePicker _picker = ImagePicker(); // Local picker instance

  @override
  void initState() {
    super.initState();
    // Initialize with viewportFraction (padEnds is not a valid parameter)
    _pageController = PageController(
      viewportFraction: 0.85,
      // padEnds: false, // Removed invalid parameter
    );
    // Note: The _confirmImagesProvider is initialized via the .family arg now
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- Image Picking Logic with Limit and Dialog ---

  // Shows the source selection using a Modal Bottom Sheet
  Future<void> _showImageSourceDialog() async {
    final currentImages = ref.read(
      _confirmImagesProvider(widget.initialImages),
    );
    if (currentImages.length >= ScanConfirmScreen.maxImages) {
      _showLimitReachedDialog();
      return;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    await showModalBottomSheet(
      context: context,
      // Make it rounded
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Use theme background color
      backgroundColor: colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Agregar imagen desde',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Use ListTile for standard look & feel
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    size: 30,
                    color: colorScheme.primary,
                  ),
                  title: Text('Cámara', style: textTheme.bodyLarge),
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(); // Close bottom sheet
                    _pickFromCamera();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    size: 30,
                    color: colorScheme.secondary,
                  ),
                  title: Text('Galería', style: textTheme.bodyLarge),
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(); // Close bottom sheet
                    _pickFromGallery();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
                const SizedBox(height: 10),
                // Optional Cancel Button
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 16.0),
                //     child: TextButton(
                //       child: Text('Cancelar', style: TextStyle(color: colorScheme.secondary)),
                //       onPressed: () => Navigator.of(bottomSheetContext).pop(),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Picks a single image from Camera, respecting the limit
  Future<void> _pickFromCamera() async {
    final currentImages = ref.read(
      _confirmImagesProvider(widget.initialImages),
    );
    if (currentImages.length >= ScanConfirmScreen.maxImages) {
      _showLimitReachedDialog();
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null && mounted) {
        final newFile = File(pickedFile.path);
        // Add the single image
        ref
            .read(_confirmImagesProvider(widget.initialImages).notifier)
            .addImages([newFile]);
        // Jump to the newly added image
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final lastIndex =
              ref.read(_confirmImagesProvider(widget.initialImages)).length - 1;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              lastIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      log('Error picking from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al usar la cámara: $e')));
      }
    }
  }

  // Picks multiple images from Gallery, respecting the limit
  Future<void> _pickFromGallery() async {
    final currentImages = ref.read(
      _confirmImagesProvider(widget.initialImages),
    );
    final remainingSlots = ScanConfirmScreen.maxImages - currentImages.length;

    if (remainingSlots <= 0) {
      _showLimitReachedDialog();
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultipleMedia();
      if (pickedFiles.isNotEmpty && mounted) {
        final newValidFiles =
            pickedFiles
                .where((file) => file.mimeType?.startsWith('image/') ?? true)
                .map((file) => File(file.path))
                .toList();

        // Check how many can be added
        final imagesToAdd =
            newValidFiles.length > remainingSlots
                ? newValidFiles.sublist(0, remainingSlots)
                : newValidFiles;

        if (imagesToAdd.isNotEmpty) {
          ref
              .read(_confirmImagesProvider(widget.initialImages).notifier)
              .addImages(imagesToAdd);

          // Show limit dialog if some images were discarded
          if (newValidFiles.length > imagesToAdd.length) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _showLimitReachedDialog(),
            );
          }

          // Jump to the first newly added image
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final firstNewImageIndex =
                currentImages.length; // Index before adding
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                firstNewImageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      log('Error picking from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar de galería: $e')),
        );
      }
    }
  }

  // Shows the limit reached dialog - Styled like the example image & using Theme
  void _showLimitReachedDialog() {
    if (!mounted) return;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AppDialog(
          icon: Icons.priority_high_rounded,
          iconColor: colorScheme.error,
          title: 'Límite de imágenes alcanzado',
          content: Text(
            'Puedes seleccionar un máximo de ${ScanConfirmScreen.maxImages} imágenes en total.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          primaryAction: AppDialog.createPrimaryButton(
            context: context,
            text: 'Entendido',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  // Real function for analyzing images using AI
  Future<void> _analyzeImages(List<File> images) async {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay imágenes para analizar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: LoadingWidgets.scanLoading,
              ),
            ),
          ),
    );

    try {
      log('Iniciando análisis de ${images.length} imágenes...');

      // Get the API service
      final apiService = ApiService.instance;

      // For now, we'll use mock image paths since we need to upload images first
      // In a real implementation, you'd upload images to Firebase Storage first
      final List<String> imagePaths = images.map((file) => file.path).toList();

      Map<String, dynamic> analysisResult;

      // Choose the appropriate recognition endpoint based on scan type
      if (widget.originType == ScanItemType.ingredient) {
        analysisResult = await apiService.recognizeIngredients(imagePaths);
      } else {
        analysisResult = await apiService.recognizeFoods(imagePaths);
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      log('Análisis completado exitosamente');
      log('Resultado: ${analysisResult.toString()}');

      // Navigate to results screen with the analysis data
      if (context.mounted) {
        // Convert the analysis result to the format expected by ScanResultsScreen
        final List<Map<String, dynamic>> recognizedItems = [];

        // Parse the API response based on the expected format
        if (analysisResult['recognized_items'] != null) {
          final items = analysisResult['recognized_items'] as List;
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              recognizedItems.add(item);
            }
          }
        }

        // Navigate to results screen
        context.go(
          '/scan/results',
          extra: {
            'recognizedItemsJson': recognizedItems,
            'itemType': widget.originType,
          },
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      log('Error en análisis de imágenes: $e');

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al analizar imágenes: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get Theme data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Watch the image list specific to this instance using the family provider
    final images = ref.watch(_confirmImagesProvider(widget.initialImages));
    final currentPage = ref.watch(_currentPageProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Check if limit is reached to disable add button
    final bool canAddMore = images.length < ScanConfirmScreen.maxImages;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Imágenes seleccionadas',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0, // Flat appbar
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ), // Back button color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              log(
                "Cannot pop from ScanConfirmScreen, navigating to fallback based on origin.",
              );
              // Use originType to determine the correct fallback route
              final fallbackRouteName =
                  widget.originType == ScanItemType.ingredient
                      ? 'ingredient'
                      : 'food';
              context.goNamed(
                'addScanItem',
                pathParameters: {'itemType': fallbackRouteName},
              );
            }
          },
          tooltip: 'Regresar', // Added tooltip for accessibility
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          // Use Column + Expanded + Align for bottom button pinning
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                // Make the content area scrollable
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10), // Padding below AppBar
                      if (images.isEmpty)
                        _buildEmptyState(context, screenHeight)
                      else
                        _buildCarousel(
                          context,
                          images,
                          screenHeight,
                          screenWidth,
                          currentPage,
                        ),

                      const SizedBox(height: 20), // Reduced space
                      // --- Image Count Indicator ---
                      if (images.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            'Has seleccionado ${images.length}/${ScanConfirmScreen.maxImages} imágenes',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                      // --- Action Buttons Row ---
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center buttons
                        children: [
                          // "Agregar más" Button (conditionally enabled)
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 18,
                              ),
                              label: const Text('Agregar más'), // Shorter label
                              onPressed:
                                  canAddMore ? _showImageSourceDialog : null,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: colorScheme.onSecondary,
                                backgroundColor: colorScheme.secondary,
                                disabledBackgroundColor: colorScheme.secondary
                                    .withValues(alpha: 0.5),
                                disabledForegroundColor: colorScheme.onSecondary
                                    .withValues(alpha: 0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ), // Adjust padding
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // "Volver a seleccionar" Button
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.replay_outlined, size: 18),
                              label: const Text(
                                'Re-seleccionar',
                              ), // Shorter label
                              onPressed: () {
                                final fallbackRouteName =
                                    widget.originType == ScanItemType.ingredient
                                        ? 'ingredient'
                                        : 'food';
                                context.goNamed(
                                  'addScanItem',
                                  pathParameters: {
                                    'itemType': fallbackRouteName,
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    colorScheme.primary, // Text/icon color
                                side: BorderSide(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ), // Border color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ), // Adjust padding
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30), // Spacing before explanation
                      // Explanation Text
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ), // Limit width slightly
                        child: Text(
                          'Analizaremos tus imágenes para ayudarte a organizar, conservar y aprovechar mejor tus alimentos.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Space before potential end
                    ],
                  ),
                ),
              ),
              // Pinned Bottom Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                child: ElevatedButton(
                  onPressed:
                      images.isEmpty
                          ? null
                          : () async {
                            log('Starting API analysis with fallback...');

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            List<Map<String, dynamic>> formattedResults = [];

                            try {
                              log('🔄 Attempting real API analysis...');
                              final recognitionRepository = ref.read(
                                _recognitionRepositoryProvider,
                              );

                              // 1. First upload all images and get their paths
                              List<String> uploadedImagePaths = [];
                              for (File imageFile in images) {
                                final uploadResult = await recognitionRepository
                                    .uploadImage(
                                      imageFile: imageFile,
                                      itemName:
                                          'scan_${DateTime.now().millisecondsSinceEpoch}',
                                      imageType:
                                          widget.originType ==
                                                  ScanItemType.ingredient
                                              ? 'ingredient'
                                              : 'food',
                                    );
                                uploadedImagePaths.add(
                                  uploadResult.image.imagePath,
                                );
                              }

                              // 2. Call the appropriate recognition endpoint
                              if (widget.originType ==
                                  ScanItemType.ingredient) {
                                final ingredientResult =
                                    await recognitionRepository
                                        .recognizeIngredients(
                                          uploadedImagePaths,
                                        );

                                // 3. Convert ingredient API response to the format expected by ScanResultsScreen
                                formattedResults =
                                    ingredientResult.ingredients.map((
                                      ingredient,
                                    ) {
                                      return {
                                        'name': ingredient.name,
                                        'image_path':
                                            ingredient.imagePath ?? '',
                                        'quantity': ingredient.quantity,
                                        'expiration_date':
                                            ingredient.expirationDate ??
                                            DateTime.now()
                                                .add(
                                                  Duration(
                                                    days:
                                                        ingredient
                                                            .expirationTime,
                                                  ),
                                                )
                                                .toIso8601String(),
                                        'confidence':
                                            ingredient.confidence ?? 1.0,
                                        'category': 'ingredient',
                                        'allergyAlert': ingredient.allergyAlert,
                                        'allergens': ingredient.allergens,
                                        'storage_type': ingredient.storageType,
                                        'tips': ingredient.tips,
                                        'type_unit': ingredient.typeUnit,
                                        'expiration_time':
                                            ingredient.expirationTime,
                                        'time_unit': ingredient.timeUnit,
                                        'added_at': ingredient.addedAt,
                                      };
                                    }).toList();

                                // Log allergy alerts if any
                                if (ingredientResult.hasAllergens &&
                                    ingredientResult.allergyAlerts.isNotEmpty) {
                                  log('⚠️ ALLERGY ALERTS DETECTED:');
                                  for (final alert
                                      in ingredientResult.allergyAlerts) {
                                    log('  - ${alert.item}: ${alert.message}');
                                  }
                                }
                              } else {
                                final foodResult = await recognitionRepository
                                    .recognizeFoods(uploadedImagePaths);

                                // 3. Convert food API response to the format expected by ScanResultsScreen
                                formattedResults =
                                    foodResult.foods.map((food) {
                                      return {
                                        'name': food.name,
                                        'image_path': food.imagePath ?? '',
                                        'quantity': food.servingQuantity,
                                        'expiration_date':
                                            food.expirationDate ??
                                            DateTime.now()
                                                .add(
                                                  Duration(
                                                    days: food.expirationTime,
                                                  ),
                                                )
                                                .toIso8601String(),
                                        'confidence': food.confidence ?? 1.0,
                                        'category': food.category,
                                        'allergyAlert': food.allergyAlert,
                                        'allergens': food.allergens,
                                        'storage_type': food.storageType,
                                        'tips': food.tips,
                                        'calories': food.calories,
                                        'description': food.description,
                                        'mainIngredients': food.mainIngredients,
                                        'type_unit':
                                            'porciones', // Default unit for foods
                                        'expiration_time':
                                            food.expirationTime, // Add this field
                                        'time_unit': food.timeUnit,
                                        'added_at': food.addedAt,
                                      };
                                    }).toList();

                                // Log allergy alerts if any
                                if (foodResult.hasAllergens &&
                                    foodResult.allergyAlerts.isNotEmpty) {
                                  log('⚠️ ALLERGY ALERTS DETECTED:');
                                  for (final alert
                                      in foodResult.allergyAlerts) {
                                    log('  - ${alert.item}: ${alert.message}');
                                  }
                                }
                              }

                              log(
                                '✅ Real API analysis completed. Found ${formattedResults.length} items.',
                              );
                            } catch (e) {
                              log('❌ Real API analysis failed: $e');

                              // Check if it's an authentication error
                              final isAuthError =
                                  e.toString().contains('401') ||
                                  e.toString().contains('Token has expired') ||
                                  e.toString().contains('unauthorized');

                              if (isAuthError) {
                                log(
                                  '🔄 Authentication error detected, falling back to dummy data...',
                                );
                              } else {
                                log(
                                  '🔄 API error detected, falling back to dummy data...',
                                );
                              }

                              // ✅ UPDATED: Proper error handling without dummy fallback
                              log('❌ Recognition API failed: $e');
                              formattedResults = []; // Return empty results

                              // Show error message to user
                              if (mounted) {
                                Navigator.of(
                                  context,
                                ).pop(); // Close loading dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al analizar las imágenes. Por favor, intenta nuevamente.',
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    action: SnackBarAction(
                                      label: 'Reintentar',
                                      onPressed: () {
                                        // User can tap the analyze button again
                                      },
                                    ),
                                  ),
                                );
                                return; // Exit early on error
                              }
                            }

                            // Close loading dialog
                            if (mounted) Navigator.of(context).pop();

                            // Navigate to ScanResultsScreen with results (real or dummy)
                            if (!mounted) return;
                            context.pushNamed(
                              ScanResultsScreen.routeName,
                              extra: {
                                'recognizedItemsJson': formattedResults,
                                'itemType': widget.originType,
                              },
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('🔍 Analizar imágenes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCarousel(
    BuildContext context,
    List<File> images,
    double screenHeight,
    double screenWidth,
    int currentPage,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imagesNotifier = ref.read(
      _confirmImagesProvider(widget.initialImages).notifier,
    );

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.30, // Reduced height from 0.45
          // Remove the Stack wrapper around PageView, no longer needed for arrows
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              ref.read(_currentPageProvider.notifier).state = index;
            },
            itemBuilder: (context, index) {
              final imageFile = images[index];
              final heroTag = 'scan_image_${imageFile.path}_confirm';

              // Re-add the Center wrapper
              return Center(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Add small horizontal padding along with vertical
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Hero(
                        tag: heroTag,
                        child: Material(
                          type: MaterialType.transparency,
                          elevation: 4.0,
                          shadowColor: theme.shadowColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 50,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      // Adjust positioning relative to the unpadded item
                      top: 8,
                      right: 4, // Closer to edge now
                      child: InkWell(
                        onTap: () => imagesNotifier.removeImage(imageFile),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Add Row for Arrows below PageView, before the indicator
        if (images.length > 1)
          Padding(
            // Add some padding to control arrow position/closeness
            padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20, // Slightly smaller arrows might look better here
                  ),
                  onPressed:
                      currentPage == 0
                          ? null
                          : () {
                            if (_pageController.hasClients) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                  tooltip: 'Anterior',
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20, // Slightly smaller arrows might look better here
                  ),
                  onPressed:
                      currentPage == images.length - 1
                          ? null
                          : () {
                            if (_pageController.hasClients) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                  tooltip: 'Siguiente',
                ),
              ],
            ),
          ),

        // Reduce spacing before indicator if arrows are now present
        SizedBox(height: images.length > 1 ? 8 : 20),

        // Smooth Page Indicator
        if (images.length > 1)
          SmoothPageIndicator(
            controller: _pageController,
            count: images.length,
            effect: ExpandingDotsEffect(
              dotColor: colorScheme.outline.withValues(
                alpha: 0.5,
              ), // Use theme colors
              activeDotColor: colorScheme.primary, // Use theme colors
              dotHeight: 8,
              dotWidth: 8,
              spacing: 6,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, double screenHeight) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: screenHeight * 0.45, // Match carousel height
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay imágenes para confirmar.',
            style: textTheme.bodyLarge?.copyWith(
              // Use theme style
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
