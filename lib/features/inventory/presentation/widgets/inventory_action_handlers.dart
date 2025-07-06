import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'inventory_search_manager.dart';

/// Handlers for inventory screen actions and lifecycle events
class InventoryActionHandlers {
  /// Initialize inventory screen lifecycle
  static Future<void> initializeInventoryScreen(
    WidgetRef ref,
    ScrollController scrollController, {
    bool mounted = true,
  }) async {
    // Smart inventory loading with cache
    await InventorySearchManager.loadInventorySmartly(ref);

    // Check for highlighted elements when starting the screen
    final recentlyAddedIds = ref.read(inventoryProvider).recentlyAddedIds;
    log('initState: Found highlighted IDs: ${recentlyAddedIds.length}');

    if (recentlyAddedIds.isEmpty) {
      // If no highlighted elements, clear any pending highlighting
      ref.read(inventoryProvider.notifier).clearHighlightsImmediately();
    } else {
      // If there are highlighted elements, scroll to last element
      log('initState: Scrolling to last element in list');
      
      // Immediate scroll without artificial delay
      InventorySearchManager.scrollToLastItem(
        scrollController,
        ref,
        mounted: mounted,
      );
    }
  }

  /// Handle widget updates in didUpdateWidget
  static void handleWidgetUpdate(
    WidgetRef ref,
    ScrollController scrollController,
    Set<String> previousRecentlyAddedIds, {
    bool mounted = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InventorySearchManager.checkHighlightedItemsAndScroll(
        ref,
        scrollController,
        previousRecentlyAddedIds,
        mounted: mounted,
      );
    });
  }

  /// Initialize tab controller with proper expiration status
  static TabController initializeTabController(
    WidgetRef ref,
    TickerProvider vsync,
  ) {
    final initialFilterStatus = ref.read(inventoryRealProvider).expirationStatusFilter;
    final initialTabIndex = ExpirationStatus.values.indexOf(initialFilterStatus);
    
    return TabController(
      length: ExpirationStatus.values.length,
      vsync: vsync,
      initialIndex: initialTabIndex >= 0 ? initialTabIndex : 0,
    );
  }

  /// Handle tab controller changes
  static void setupTabControllerListener(
    TabController tabController,
    WidgetRef ref,
  ) {
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        InventorySearchManager.handleTabChange(tabController.index, ref);
      }
    });
  }

  /// Handle navigation to recipe generation
  static void navigateToRecipeGeneration(
    BuildContext context,
    WidgetRef ref,
  ) {
    // Clear AI recipe state to force regeneration
    ref.read(aiRecipeProvider.notifier).clearState();
    context.pushNamed('AIRecipeGenerationScreen');
  }

  /// Handle navigation to add inventory item
  static void navigateToAddInventoryItem(BuildContext context) {
    context.pushNamed('addInventoryItem');
  }

  /// Show filter bottom sheet
  static void showFilterBottomSheet(
    BuildContext context,
    WidgetRef ref,
  ) {
    InventorySearchManager.showFilterBottomSheet(context, ref);
  }

  /// Check if item is expired (utility method)
  static bool isItemExpired(DateTime? expirationDate) {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate);
  }

  /// Format quantity for editing based on unit type
  static String formatQuantityForEditing(double quantity, String unitType) {
    if (unitType == 'unidades' || unitType == 'u') {
      return quantity.toInt().toString();
    } else {
      if (quantity == quantity.roundToDouble()) {
        return quantity.toInt().toString();
      } else {
        return quantity.toStringAsFixed(1);
      }
    }
  }

  /// Get active filters count for badge display
  static int getActiveFiltersCount(WidgetRef ref) {
    final inventoryState = ref.watch(inventoryRealProvider);
    int count = 0;

    // Category filter (if not "all")
    if (inventoryState.categoryFilter != ItemCategory.all) {
      count++;
    }

    // Storage filter (if not empty)
    if (inventoryState.storageFilter.isNotEmpty) {
      count++;
    }

    // Search query filter (if not empty)
    if (inventoryState.searchQuery.isNotEmpty) {
      count++;
    }

    // Sort direction (if not default 'ascending')
    if (!inventoryState.sortAscending) {
      count++;
    }

    return count;
  }

  /// Handle search focus changes
  static void handleSearchFocus(
    FocusNode searchFocusNode,
    bool hasFocus,
  ) {
    // Can be used to trigger UI changes when search is focused/unfocused
    log('Search focus changed: $hasFocus');
  }

  /// Handle search controller text changes
  static void handleSearchTextChange(
    String searchText,
    WidgetRef ref,
  ) {
    // Sync search query to both providers
    ref.read(inventoryProvider.notifier).setSearchQuery(searchText);
    ref.read(inventoryRealProvider.notifier).setSearchQuery(searchText);
  }

  /// Toggle summary expansion state
  static void toggleSummaryExpansion(
    bool currentState,
    Function(bool) setState,
  ) {
    setState(!currentState);
  }

  /// Handle batch selection for multi-batch items
  static Future<void> showBatchSelectionDialog(
    BuildContext context,
    InventoryItem currentDisplayBatch,
    List<InventoryItem> allBatches,
    WidgetRef ref,
  ) async {
    // This method would show a dialog to select between different batches
    // of the same ingredient. The implementation would be similar to what
    // was in the original screen.
    
    log('Showing batch selection dialog for ${currentDisplayBatch.name}');
    log('Available batches: ${allBatches.length}');
    
    // Show batch selection dialog
    // Implementation would go here...
  }

  /// Handle refresh action
  static Future<void> handleRefresh(WidgetRef ref) async {
    log('Refreshing inventory data...');
    
    // Force reload from backend
    await ref.read(inventoryRealProvider.notifier).loadInventoryIfNeeded();
    
    // Sync with UI provider
    final realItems = ref.read(inventoryRealProvider).items;
    ref.read(inventoryProvider.notifier).clearAllItems();
    
    if (realItems.isNotEmpty) {
      ref.read(inventoryProvider.notifier).addItems(realItems);
    }
    
    log('Inventory refresh completed');
  }

  /// Clear all highlights immediately
  static void clearHighlights(WidgetRef ref) {
    ref.read(inventoryProvider.notifier).clearHighlightsImmediately();
  }

  /// Dispose resources
  static void disposeResources(
    TabController tabController,
    TextEditingController searchController,
    ScrollController scrollController,
    FocusNode searchFocusNode,
    WidgetRef ref,
  ) {
    tabController.dispose();
    InventorySearchManager.disposeSearchController(searchController, ref);
    scrollController.dispose();
    searchFocusNode.dispose();
  }
}