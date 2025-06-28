import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/inventory_filter_bottom_sheet.dart';

/// Manager for inventory search, filtering, and navigation functionality
class InventorySearchManager {
  /// Show filter bottom sheet
  static void showFilterBottomSheet(
    BuildContext context,
    WidgetRef ref,
  ) {
    final inventoryState = ref.read(inventoryRealProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InventoryFilterBottomSheet(
        initialCategoryFilter: inventoryState.categoryFilter,
        initialStorageFilter: inventoryState.storageFilter,
        initialSortCriteria: inventoryState.sortCriteria,
        initialSortAscending: inventoryState.sortAscending,
        onApply: ({
          required category,
          required storageTypes,
          required sortCriteria,
          required sortAscending,
        }) {
          final notifier = ref.read(inventoryRealProvider.notifier);
          notifier.setCategoryFilter(category);
          notifier.setStorageFilter(storageTypes);
          notifier.setSortCriteria(sortCriteria);
          notifier.setSortDirection(sortAscending);
        },
      ),
    );
  }

  /// Scroll to the last item in the inventory list
  static void scrollToLastItem(
    ScrollController scrollController,
    WidgetRef ref, {
    bool mounted = true,
  }) {
    // Reduced delay for better performance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      // Get filtered items
      final filteredItems = ref.read(filteredSortedInventoryRealProvider);

      if (filteredItems.isEmpty) {
        log('The list is empty, cannot scroll');
        return;
      }

      log('Attempting to scroll to end of ${filteredItems.length} elements');

      try {
        // METHOD 1: Try using maxScrollExtent to go to end of list
        // This is the most reliable method to scroll to the end of the list
        if (scrollController.hasClients) {
          log('Using maxScrollExtent for scroll: ${scrollController.position.maxScrollExtent}');

          // Immediate scroll without additional delay
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
          return;
        }
      } catch (e) {
        log('Error using maxScrollExtent: $e');
      }

      // METHOD 2: Calculation based on indices (fallback)
      try {
        // As fallback, try to calculate position of last element
        int lastIndex = filteredItems.length - 1;

        // Higher values to ensure sufficient scrolling
        const double searchBarHeight = 200.0;
        const double tabBarHeight = 70.0;
        const double itemHeight = 90.0;

        final double scrollPosition =
            searchBarHeight + tabBarHeight + (lastIndex * itemHeight) + 100;

        log('Using position calculation: $scrollPosition');

        // Scroll to calculated position
        scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
        );
      } catch (e) {
        log('Error in position calculation: $e');

        // METHOD 3: Last attempt using arbitrary large value
        try {
          log('Final attempt with fixed large value');
          scrollController.animateTo(
            10000.0, // Large value to try to reach the end
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
        } catch (e) {
          log('Error in final attempt: $e');
        }
      }
    });
  }

  /// Scroll to a specific highlighted item by ID
  static void scrollToHighlightedItem(
    String itemId,
    ScrollController scrollController,
    WidgetRef ref, {
    bool mounted = true,
  }) {
    // Increase wait time to ensure list is fully built
    // and filtered elements are available
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      // Get most updated filtered items
      final filteredItems = ref.read(filteredSortedInventoryRealProvider);

      log('Attempting to scroll to item: $itemId');
      log('Total items in list: ${filteredItems.length}');

      // Find index of highlighted item
      int highlightedIndex = -1;
      for (int i = 0; i < filteredItems.length; i++) {
        if (filteredItems[i].displayBatch.id == itemId) {
          highlightedIndex = i;
          log('Item found at index: $i');
          break;
        }
      }

      if (highlightedIndex >= 0) {
        // Calculate position with more precise values adjusted to current UI
        const double searchBarHeight = 180.0; // Increase to ensure visibility
        const double tabBarHeight = 60.0; // Increase for greater margin
        const double itemHeight = 85.0; // Adjust according to actual item size

        // Add small offset to ensure item is visible
        final double scrollPosition = searchBarHeight +
            tabBarHeight +
            (highlightedIndex * itemHeight) -
            40;

        log('Scrolling to position: $scrollPosition');

        // Try to scroll with longer duration for greater smoothness
        try {
          scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuint,
          );
        } catch (e) {
          log('Error scrolling: $e');
          // Alternative attempt with fixed position if calculation fails
          if (highlightedIndex > 0) {
            scrollController.animateTo(
              highlightedIndex * 100.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutQuint,
            );
          }
        }
      } else {
        log('Item with ID: $itemId not found in filtered list');
        // If specific item not found, scroll to last element
        scrollToLastItem(scrollController, ref, mounted: mounted);
      }
    });
  }

  /// Smart inventory loading logic
  /// Only loads from backend when necessary
  static Future<void> loadInventorySmartly(WidgetRef ref) async {
    // Use the new smart loading method from the provider
    await ref.read(inventoryRealProvider.notifier).loadInventoryIfNeeded();

    // Sync with UI provider
    final realItems = ref.read(inventoryRealProvider).items;
    ref.read(inventoryProvider.notifier).clearAllItems();

    if (realItems.isNotEmpty) {
      ref.read(inventoryProvider.notifier).addItems(realItems);
    }
  }

  /// Check for highlighted items and scroll if needed
  static void checkHighlightedItemsAndScroll(
    WidgetRef ref,
    ScrollController scrollController,
    Set<String> previousRecentlyAddedIds, {
    bool mounted = true,
  }) {
    if (!mounted) return;

    final currentRecentlyAddedIds = ref.read(inventoryProvider).recentlyAddedIds;
    log('checkHighlightedItemsAndScroll called: ${currentRecentlyAddedIds.length} highlighted items');

    if (currentRecentlyAddedIds.isNotEmpty) {
      // Check if there are new items that weren't previously highlighted
      final newIds = currentRecentlyAddedIds.difference(previousRecentlyAddedIds);
      log('New highlighted items detected: ${newIds.length}');

      if (newIds.isNotEmpty) {
        // Get the last added item ID for scrolling
        final lastAddedId = newIds.last;
        log('Scrolling to last added item: $lastAddedId');

        // Wait a bit longer for UI to update
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            scrollToHighlightedItem(
              lastAddedId,
              scrollController,
              ref,
              mounted: mounted,
            );
          }
        });
      }
    }
  }

  /// Initialize search controller listener
  static void initializeSearchListener(
    TextEditingController searchController,
    WidgetRef ref,
  ) {
    searchController.addListener(() {
      // Sync search query to both providers
      ref
          .read(inventoryProvider.notifier)
          .setSearchQuery(searchController.text);
      ref
          .read(inventoryRealProvider.notifier)
          .setSearchQuery(searchController.text);
    });
  }

  /// Dispose search controller and clean up
  static void disposeSearchController(
    TextEditingController searchController,
    WidgetRef ref,
  ) {
    searchController.removeListener(() {
      ref
          .read(inventoryProvider.notifier)
          .setSearchQuery(searchController.text);
      ref
          .read(inventoryRealProvider.notifier)
          .setSearchQuery(searchController.text);
    });
    searchController.dispose();
  }

  /// Handle tab controller changes for expiration status filtering
  static void handleTabChange(
    int tabIndex,
    WidgetRef ref,
  ) {
    final expirationStatus = ExpirationStatus.values[tabIndex];
    ref.read(inventoryRealProvider.notifier).setExpirationStatusFilter(expirationStatus);
  }

  /// Get initial tab index based on current filter
  static int getInitialTabIndex(WidgetRef ref) {
    final initialFilterStatus = ref.read(inventoryRealProvider).expirationStatusFilter;
    final initialTabIndex = ExpirationStatus.values.indexOf(initialFilterStatus);
    return initialTabIndex >= 0 ? initialTabIndex : 0;
  }
}