// ignore_for_file: unused_local_variable, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/screens/add_inventory_item_screen.dart';
import 'package:zer0_waste_ai/features/scan/application/providers/scan_results_provider.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/add_scan_item_screen.dart'; // For ScanItemType
import 'package:zer0_waste_ai/features/scan/presentation/widgets/recognized_item_card.dart';
import 'package:zer0_waste_ai/features/scan/domain/models/recognized_item.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/simplified_recognition_provider.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/simplified_food_recognition_provider.dart';
import 'dart:developer';

// Assume Uuid instance is available or create one
final _uuid = Uuid();

class ScanResultsScreen extends ConsumerStatefulWidget {
  // Now expects the raw JSON data list and itemType
  final List<Map<String, dynamic>> initialJsonData;
  final ScanItemType itemType;

  const ScanResultsScreen({
    super.key,
    required this.initialJsonData,
    required this.itemType,
  });

  @override
  ConsumerState<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends ConsumerState<ScanResultsScreen>
    with TickerProviderStateMixin {
  // Animation states
  bool _isLoading = false;
  bool _isSuccess = false;
  late AnimationController _animationController;
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  static const String routeName = 'scan_results';
  static const String routePath = '/scan/results';

  @override
  Widget build(BuildContext context) {
    // Use the family provider, passing the initial JSON data list
    final itemsState = ref.watch(scanResultsProvider(widget.initialJsonData));
    final itemsNotifier = ref.read(
      scanResultsProvider(widget.initialJsonData).notifier,
    );

    // Watch appropriate recognition state based on itemType
    if (widget.itemType == ScanItemType.ingredient) {
      final simplifiedState = ref.watch(simplifiedRecognitionProvider);

      // Initial sync after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncImagesFromIngredientProvider(ref, simplifiedState, itemsNotifier);
      });

      // Listen for changes in SimplifiedRecognitionProvider to sync images and show notifications
      ref.listen(simplifiedRecognitionProvider, (previous, current) {
        // Sync images when recognition results change
        _syncImagesFromIngredientProvider(ref, current, itemsNotifier);

        // Show notification when all images are ready - with delay to ensure UI updates complete
        if (previous?.imagesStatus == 'generating' &&
            current.imagesStatus == 'ready' &&
            context.mounted) {
          // Wait for UI to complete the image updates before showing notification
          Future.delayed(Duration(milliseconds: 1500), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('¡Imágenes de ingredientes listas!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      });
    } else {
      final foodState = ref.watch(simplifiedFoodRecognitionProvider);

      // Initial sync after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncImagesFromFoodProvider(ref, foodState, itemsNotifier);
      });

      // Listen for changes in SimplifiedFoodRecognitionProvider to sync images and show notifications
      ref.listen(simplifiedFoodRecognitionProvider, (previous, current) {
        log('🎧 [FOOD LISTENER] State change detected');
        log('   Previous status: ${previous?.imagesStatus}');
        log('   Current status: ${current.imagesStatus}');
        log('   Foods count: ${current.result?.foods.length ?? 0}');

        // Sync images when recognition results change
        _syncImagesFromFoodProvider(ref, current, itemsNotifier);

        // Show notification when all images are ready - with delay to ensure UI updates complete
        if (previous?.imagesStatus == 'generating' &&
            current.imagesStatus == 'ready' &&
            context.mounted) {
          log('🎉 [FOOD LISTENER] Scheduling notification after UI sync...');

          // Wait for UI to complete the image updates before showing notification
          Future.delayed(Duration(milliseconds: 1500), () {
            if (context.mounted) {
              log('🎉 [FOOD LISTENER] Showing notification: Images ready!');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('¡Imágenes de comidas listas!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      });
    }

    // Determine if the add button should be enabled
    final bool canAdd = itemsState.any((item) => item.quantity > 0);

    // Get theme and colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor = const Color(0xFFFAF9F6);
    final Color mainTextColor = const Color(0xFF3A3A3A);
    final Color primaryColor = const Color(0xFF00B894);
    final Color onPrimaryColor = Colors.white;
    final Color secondaryTextColor = const Color(0xFF70605A);

    final String title =
        widget.itemType == ScanItemType.food
            ? "Comidas Reconocidas"
            : "Ingredientes Reconocidos";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: mainTextColor,
            // Use a headline style if available, otherwise adjust size
            fontSize:
                Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)
                    .fontSize ??
                22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor), // Back button color
        leading:
            itemsState.isEmpty
                ? null
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _handleBackNavigation(context),
                ),
        automaticallyImplyLeading:
            itemsState.isNotEmpty, // Only show back button if we have items
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Allergy Alert Banner
            _buildAllergyBanner(itemsState, colorScheme, context),

            // Image Refresh Button
            _buildImageRefreshButton(ref, context),

            Expanded(
              child:
                  itemsState.isEmpty
                      ? _buildNoResultsFound(context, widget.itemType)
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: itemsState.length,
                        itemBuilder: (context, index) {
                          final item = itemsState[index];
                          return RecognizedItemCard(
                            item: item,
                            onIncrement:
                                () => itemsNotifier.incrementQuantity(item.id),
                            onDecrement:
                                () => itemsNotifier.decrementQuantity(item.id),
                            onRemove: () => itemsNotifier.removeItem(item.id),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          itemsState.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                child: _buildAnimatedAddButton(
                  canAdd,
                  itemsNotifier,
                  primaryColor,
                  onPrimaryColor,
                ),
              ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context, ScanItemType itemType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              widget.itemType == ScanItemType.food
                  ? 'No se reconocieron comidas'
                  : 'No se reconocieron ingredientes',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3A3A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.itemType == ScanItemType.food
                  ? 'Prueba con otra imagen o agrega las comidas manualmente para continuar.'
                  : 'Prueba con otra imagen o agrega los ingredientes manualmente para continuar.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF70605A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Primary action - highlighted
            ElevatedButton.icon(
              onPressed: () {
                context.push(AddInventoryItemScreen.routePath);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                widget.itemType == ScanItemType.food
                    ? 'Agregar comidas manualmente'
                    : 'Agregar ingredientes manualmente',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Secondary action - outlined style for consistency
            OutlinedButton.icon(
              onPressed: () {
                _handleBackNavigation(context);
              },
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Volver a intentar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF70605A),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: const Color(0xFF70605A).withValues(alpha: 0.3),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tertiary action - text button for less emphasis
            TextButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.home, size: 18),
              label: const Text('Regresar al inicio'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF70605A).withValues(alpha: 0.7),
                minimumSize: const Size(double.infinity, 44),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyBanner(
    List<RecognizedItem> itemsState,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    // Filter items that have allergy alerts
    final allergenicItems =
        itemsState.where((item) => item.allergyAlert).toList();

    if (allergenicItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final allergenCount = allergenicItems.length;
    final uniqueAllergens =
        allergenicItems.expand((item) => item.allergens).toSet().toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Warning icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: colorScheme.onError, size: 16),
            ),
            const SizedBox(width: 12),

            // Alert text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ ALERTA DE ALERGIA',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    allergenCount == 1
                        ? 'Detectado 1 ingrediente alergénico'
                        : 'Detectados $allergenCount ingredientes alergénicos',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (uniqueAllergens.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Contiene: ${uniqueAllergens.join(', ')}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: colorScheme.error.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Info button (optional - for showing more details)
            IconButton(
              onPressed: () {
                _showAllergyDetailsDialog(
                  context,
                  allergenicItems,
                  colorScheme,
                );
              },
              icon: Icon(
                Icons.info_outline,
                color: colorScheme.error,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageRefreshButton(WidgetRef ref, BuildContext context) {
    // Get current items to check if we have any recognized items
    final itemsState = ref.watch(scanResultsProvider(widget.initialJsonData));

    // Don't show refresh button if no items were recognized
    if (itemsState.isEmpty) {
      return const SizedBox.shrink();
    }

    // Watch appropriate provider based on itemType
    if (widget.itemType == ScanItemType.ingredient) {
      final simplifiedState = ref.watch(simplifiedRecognitionProvider);
      final simplifiedNotifier = ref.read(
        simplifiedRecognitionProvider.notifier,
      );

      // Only show if we have a recognition ID (meaning we have active recognition results)
      if (simplifiedState.recognitionId == null ||
          simplifiedState.recognitionId!.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildRefreshButtonWidget(
        context,
        ref,
        isLoading: simplifiedState.isLoading,
        imagesStatus: simplifiedState.imagesStatus,
        onPressed: () {
          // Trigger a manual check by clearing and re-syncing
          _syncImagesFromIngredientProvider(
            ref,
            simplifiedState,
            ref.read(scanResultsProvider(widget.initialJsonData).notifier),
          );
          _showRefreshResult(context, simplifiedState.error);
        },
      );
    } else {
      final foodState = ref.watch(simplifiedFoodRecognitionProvider);

      // Only show if we have a recognition ID (meaning we have active recognition results)
      if (foodState.recognitionId == null || foodState.recognitionId!.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildRefreshButtonWidget(
        context,
        ref,
        isLoading: foodState.isLoading,
        imagesStatus: foodState.imagesStatus,
        onPressed: () {
          // Trigger a manual check by clearing and re-syncing
          _syncImagesFromFoodProvider(
            ref,
            foodState,
            ref.read(scanResultsProvider(widget.initialJsonData).notifier),
          );
          _showRefreshResult(context, foodState.error);
        },
      );
    }
  }

  Widget _buildRefreshButtonWidget(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoading,
    required String? imagesStatus,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon:
                  isLoading
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : imagesStatus == 'generating'
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      )
                      : Icon(Icons.refresh),
              label: Text(
                isLoading
                    ? 'Actualizando...'
                    : imagesStatus == 'generating'
                    ? 'Generando automáticamente...'
                    : 'Actualizar imágenes',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllergyDetailsDialog(
    BuildContext context,
    List<RecognizedItem> allergenicItems,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Alertas de Alergia',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Los siguientes ingredientes contienen alérgenos a los que podrías ser sensible:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...allergenicItems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: colorScheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Contiene: ${item.allergens.join(', ')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.inter(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Sync images from SimplifiedRecognitionProvider to scan results items (for ingredients)
  void _syncImagesFromIngredientProvider(
    WidgetRef ref,
    SimplifiedRecognitionState simplifiedState,
    dynamic itemsNotifier,
  ) {
    // Only sync if we have recognition results
    if (simplifiedState.result == null ||
        simplifiedState.result!.ingredients.isEmpty) {
      return;
    }

    final ingredients = simplifiedState.result!.ingredients;
    final currentItems = ref.read(scanResultsProvider(widget.initialJsonData));

    // Update items with images from SimplifiedRecognitionProvider
    for (int i = 0; i < ingredients.length && i < currentItems.length; i++) {
      final ingredient = ingredients[i];
      final currentItem = currentItems[i];

      // Update image URL if it's different
      if (ingredient.imagePath != null &&
          ingredient.imagePath!.isNotEmpty &&
          currentItem.imageUrl != ingredient.imagePath) {
        log(
          '🖼️ [SYNC INGREDIENTS] Updating image for ${currentItem.name}: ${ingredient.imagePath}',
        );

        // Create updated item with new image URL using copyWith
        final updatedItem = currentItem.copyWith(
          imageUrl: ingredient.imagePath, // Update with new image
        );

        // Update the item in the provider
        itemsNotifier.updateItem(updatedItem);
      }
    }
  }

  /// Sync images from SimplifiedFoodRecognitionProvider to scan results items (for foods)
  void _syncImagesFromFoodProvider(
    WidgetRef ref,
    SimplifiedFoodRecognitionState foodState,
    dynamic itemsNotifier,
  ) {
    log('🔄 [SYNC FOODS] Starting sync process...');

    // Only sync if we have recognition results
    if (foodState.result == null || foodState.result!.foods.isEmpty) {
      log(
        '❌ [SYNC FOODS] No results to sync (result: ${foodState.result}, foods: ${foodState.result?.foods.length})',
      );
      return;
    }

    final foods = foodState.result!.foods;
    final currentItems = ref.read(scanResultsProvider(widget.initialJsonData));

    log(
      '🔍 [SYNC FOODS] Found ${foods.length} foods and ${currentItems.length} current items',
    );

    // Try to match foods by name first, then by index as fallback
    for (int i = 0; i < foods.length && i < currentItems.length; i++) {
      final food = foods[i];

      // Try to find matching item by name first
      RecognizedItem? targetItem;
      int targetIndex = -1;

      // Look for exact name match
      for (int j = 0; j < currentItems.length; j++) {
        if (currentItems[j].name.toLowerCase().trim() ==
            food.name.toLowerCase().trim()) {
          targetItem = currentItems[j];
          targetIndex = j;
          break;
        }
      }

      // If no name match, use index-based matching as fallback
      if (targetItem == null && i < currentItems.length) {
        targetItem = currentItems[i];
        targetIndex = i;
      }

      if (targetItem == null) {
        log('❌ [SYNC FOODS] No target item found for food: ${food.name}');
        continue;
      }

      log(
        '🔍 [SYNC FOODS] Food ${i + 1}: ${food.name} -> Item ${targetIndex + 1}: ${targetItem.name}',
      );
      log('   📷 Food imagePath: ${food.imagePath}');
      log('   📊 Food imageStatus: ${food.imageStatus}');
      log('   🎯 Current item imageUrl: ${targetItem.imageUrl}');
      log('   🆔 Current item ID: ${targetItem.id}');

      // Update image URL if it's different and not empty
      if (food.imagePath != null &&
          food.imagePath!.isNotEmpty &&
          targetItem.imageUrl != food.imagePath) {
        log(
          '🖼️ [SYNC FOODS] Updating image for ${targetItem.name}: ${food.imagePath}',
        );

        // Create updated item with new image URL using copyWith
        final updatedItem = targetItem.copyWith(
          imageUrl: food.imagePath, // Update with new image
        );

        log(
          '🔧 [SYNC FOODS] Created updated item with imageUrl: ${updatedItem.imageUrl}',
        );

        // Update the item in the provider
        itemsNotifier.updateItem(updatedItem);
        log('✅ [SYNC FOODS] Image updated successfully for ${targetItem.name}');

        // Verify the update worked by reading the state again
        final updatedItems = ref.read(
          scanResultsProvider(widget.initialJsonData),
        );
        final verifyItem = updatedItems.firstWhere(
          (item) => item.id == targetItem!.id,
          orElse: () => targetItem!,
        );
        log(
          '🔍 [SYNC FOODS] Verification - Item ${verifyItem.name} now has imageUrl: ${verifyItem.imageUrl}',
        );
      } else {
        String reason = '';
        if (food.imagePath == null) {
          reason = 'imagePath is null';
        } else if (food.imagePath!.isEmpty) {
          reason = 'imagePath is empty';
        } else if (targetItem.imageUrl == food.imagePath) {
          reason = 'same image URL';
        }

        log(
          '⏭️ [SYNC FOODS] No update needed for ${targetItem.name} ($reason)',
        );
      }
    }

    log('🏁 [SYNC FOODS] Sync process completed');
  }

  /// Show result message after manual refresh
  void _showRefreshResult(BuildContext context, String? error) {
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error al actualizar imágenes'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 8),
              Text('Imágenes actualizadas'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle back navigation safely - pop if possible, otherwise go to appropriate scan screen
  void _handleBackNavigation(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      // If we can't pop, navigate back to the appropriate scan screen based on itemType
      if (widget.itemType == ScanItemType.food) {
        context.go('/scan/add/food');
      } else {
        context.go('/scan/add/ingredient');
      }
    }
  }

  // Animated add button with cool loading and success states
  Widget _buildAnimatedAddButton(
    bool canAdd,
    dynamic itemsNotifier,
    Color primaryColor,
    Color onPrimaryColor,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _successController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient:
                  _isSuccess
                      ? const LinearGradient(
                        colors: [Color(0xFF00B894), Color(0xFF00A085)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : LinearGradient(
                        colors:
                            canAdd
                                ? [
                                  primaryColor,
                                  primaryColor.withValues(alpha: 0.8),
                                ]
                                : [
                                  primaryColor.withValues(alpha: 0.5),
                                  primaryColor.withValues(alpha: 0.3),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              boxShadow:
                  canAdd && !_isLoading
                      ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap:
                    canAdd && !_isLoading
                        ? () => _handleAddToInventory(itemsNotifier)
                        : null,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildButtonContent(onPrimaryColor),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(Color onPrimaryColor) {
    if (_isSuccess) {
      return Transform.scale(
        scale: _successAnimation.value,
        child: Row(
          key: const ValueKey('success'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              '¡Agregado con éxito!',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Row(
        key: const ValueKey('loading'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(onPrimaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Agregando al inventario...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: onPrimaryColor,
            ),
          ),
        ],
      );
    }

    return Row(
      key: const ValueKey('normal'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(FontAwesomeIcons.squarePlus, size: 20, color: onPrimaryColor),
        const SizedBox(width: 12),
        Text(
          widget.itemType == ScanItemType.food
              ? 'Agregar comidas al inventario'
              : 'Agregar ingredientes al inventario',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onPrimaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddToInventory(dynamic itemsNotifier) async {
    // Start loading animation
    setState(() {
      _isLoading = true;
    });
    _animationController.forward();

    try {
      final itemsToAddRaw = itemsNotifier.getItemsToAdd();

      // Map RecognizedItem to InventoryItem
      final List<InventoryItem> itemsToAddInventory =
          itemsToAddRaw.map((recognizedItem) {
            // Determine category based on ScanItemType
            final ItemCategory category =
                widget.itemType == ScanItemType.food
                    ? ItemCategory.food
                    : ItemCategory.ingredient;

            // Parse storage type from recognition result
            StorageType storageType = StorageType.dry; // default
            if (recognizedItem.storageType != null) {
              switch (recognizedItem.storageType?.toLowerCase()) {
                case 'refrigerated':
                case 'refrigerado':
                  storageType = StorageType.refrigerated;
                  break;
                case 'frozen':
                case 'congelado':
                  storageType = StorageType.frozen;
                  break;
                case 'dry':
                case 'seco':
                  storageType = StorageType.dry;
                  break;
                default:
                  storageType = StorageType.dry;
              }
            }

            // Parse expiration date from recognition result
            DateTime? expirationDate;
            if (recognizedItem.expiryDate != null &&
                recognizedItem.expiryDate!.isNotEmpty) {
              try {
                expirationDate = DateTime.parse(recognizedItem.expiryDate!);
              } catch (e) {
                log(
                  'Error parsing expiration date: ${recognizedItem.expiryDate} - $e',
                );
                expirationDate = null;
              }
            }

            return InventoryItem(
              id: _uuid.v4(), // Generate a unique ID
              name: recognizedItem.name,
              image:
                  recognizedItem.name.isNotEmpty
                      ? recognizedItem.name[0]
                      : '❓', // Use first letter or default emoji
              quantity: recognizedItem.quantity.toDouble(),
              category: category,
              storageType: storageType, // Use parsed storage type
              addedDate: DateTime.now(),
              unitType:
                  recognizedItem.typeUnit ??
                  'unidades', // Use recognition unit type
              expirationDate: expirationDate, // Use parsed expiration date
              tips: recognizedItem.tips, // Use recognition tips
              // imageUrl: recognizedItem.imageUrl, // Use this if actual image URL available
            );
          }).toList();

      // Add to backend
      await ref
          .read(inventoryRealProvider.notifier)
          .addIngredientsToBackend(itemsToAddInventory);

      // Show success state
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      _animationController.reverse();
      _successController.forward();

      // Wait for success animation
      await Future.delayed(const Duration(milliseconds: 1200));

      // Navigate to inventory
      if (context.mounted) {
        context.go('/inventory');
      }
    } catch (e) {
      // Reset states on error
      setState(() {
        _isLoading = false;
        _isSuccess = false;
      });
      _animationController.reverse();

      // Show error feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al agregar al inventario: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
