// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_backend_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/core/utils/url_encoding_helper.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:collection/collection.dart'; // For groupBy

// Helper class to bundle display batch info
class DisplayBatchInfo {
  final InventoryItem
  displayBatch; // The batch currently shown in the main list
  final List<InventoryItem>
  allBatchesForIngredient; // All available batches for this ingredient

  DisplayBatchInfo({
    required this.displayBatch,
    required this.allBatchesForIngredient,
  });
}

// INFO: This is the legacy local/mock inventory notifier
// ADVICE: Use inventoryRealProvider for production with backend persistence
// ignore: unused_element
final _uuid = Uuid();

/// DEPRECATED: Legacy local inventory notifier without backend persistence
/// ADVICE: Use InventoryRealNotifier (inventoryRealProvider) for production
/// This class is kept for testing and development purposes only
class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState()) {
    // Load initial data (replace with actual data loading)
    // DEPRECATED: Mock data no longer used - using real backend instead
    // _loadMockData();
  }

  // DEPRECATED: Mock data no longer used - keeping for reference only
  /*
  void _loadMockData() {
    // Simulate loading initial data
    state = state.copyWith(isLoading: true);
    // Example data based on new structure
    final mockItems = [
      // ... existing mock data ...
    ];
    state = state.copyWith(items: mockItems, isLoading: false);
  }
  */

  // --- Item Management ---
  void addItems(List<InventoryItem> itemsToAdd) {
    // If itemsToAdd might contain duplicates internally, filter them first if needed
    // final uniqueNewItems = itemsToAdd.toSet().toList(); // Example if needed

    final newIds = itemsToAdd.map((item) => item.id).toSet();
    final updatedItems = [
      ...state.items,
      ...itemsToAdd,
    ]; // Simply append new batches

    state = state.copyWith(items: updatedItems, recentlyAddedIds: newIds);
    // Schedule clearing of highlight
    _scheduleHighlightClear(newIds);
  }

  void removeItem(String itemId) {
    final updatedItems =
        state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.removeItem() for backend persistence
  }

  void incrementQuantity(String itemId) {
    final updatedItems =
        state.items.map((item) {
          if (item.id == itemId) {
            final step = getQuantityStep(item.unitType);
            // Round to avoid floating point inaccuracies if needed, e.g., after multiple 0.1 adds
            final newQuantity = (item.quantity + step);
            // Consider adding rounding: (item.quantity * 10 + step * 10).round() / 10.0;
            return item.copyWith(quantity: newQuantity);
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.updateItemQuantityInBackend() for backend persistence
  }

  void decrementQuantity(String itemId) {
    final updatedItems =
        state.items.map((item) {
          if (item.id == itemId) {
            final step = getQuantityStep(item.unitType);
            final minimum = getMinimumQuantity(item.unitType);
            if (item.quantity > minimum) {
              // Round to avoid floating point inaccuracies
              final newQuantity = ((item.quantity * 10 - step * 10).round() /
                      10.0)
                  .clamp(minimum, double.infinity); // Ensure minimum
              return item.copyWith(quantity: newQuantity);
            }
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.updateItemQuantityInBackend() for backend persistence
  }

  double getQuantityStep(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }

  double getMinimumQuantity(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }

  void updateExpirationDate(String itemId, DateTime newDate) {
    final updatedItems =
        state.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(expirationDate: newDate);
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.updateExpirationDateInBackend() for backend persistence
  }

  void saveItemChanges(InventoryItem updatedItem) {
    final updatedItems =
        state.items.map((item) {
          return item.id == updatedItem.id ? updatedItem : item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.updateItemInBackend() for backend persistence
  }

  void setQuantity(String batchId, double newQuantity) {
    final updatedItems =
        state.items.map((item) {
          if (item.id == batchId) {
            // Ensure quantity doesn't go below the minimum allowed for the unit type
            final minimum = getMinimumQuantity(item.unitType);
            return item.copyWith(
              quantity: newQuantity.clamp(minimum, double.infinity),
            );
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.updateItemQuantityInBackend() for backend persistence
  }

  // --- Filtering & Sorting ---
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(ItemCategory category) {
    state = state.copyWith(categoryFilter: category);
  }

  // Updated to accept a Set for multi-select
  void setStorageFilter(Set<StorageType> storageTypes) {
    state = state.copyWith(storageFilter: storageTypes);
  }

  // Updated method to accept single ExpirationStatus
  void setExpirationStatusFilter(ExpirationStatus status) {
    state = state.copyWith(expirationStatusFilter: status);
  }

  void setSortCriteria(InventorySortCriteria criteria) {
    if (state.sortCriteria == criteria) {
      // Toggle direction if same criteria is selected again
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      // Set new criteria and default direction (ascending for name, descending for date)
      bool ascending = true;
      if (criteria == InventorySortCriteria.expirationDate) {
        ascending = false; // Default closest expiration first
      }
      // For name/quantity, default is ascending
      state = state.copyWith(sortCriteria: criteria, sortAscending: ascending);
    }
  }

  void setSortDirection(bool ascending) {
    state = state.copyWith(sortAscending: ascending);
  }

  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  void setUserSelectedBatch(String ingredientName, String batchId) {
    final lowerCaseName = ingredientName.toLowerCase();
    final currentOverrides = Map<String, String>.from(
      state.userSelectedBatchOverrides,
    );

    // Update or add the override for this ingredient
    currentOverrides[lowerCaseName] = batchId;

    state = state.copyWith(userSelectedBatchOverrides: currentOverrides);
  }

  // --- Highlight Management ---
  void _scheduleHighlightClear(Set<String> idsToClear) {
    // Aumentar el tiempo del efecto visual a 15 segundos para mayor visibilidad
    Future.delayed(const Duration(seconds: 15), () {
      final currentHighlights = state.recentlyAddedIds;
      // Remove only the specific IDs that were highlighted in this batch
      final updatedHighlights = currentHighlights.difference(idsToClear);
      if (mounted) {
        // Ensure the notifier is still active
        state = state.copyWith(recentlyAddedIds: updatedHighlights);
      }
    });
  }

  void clearHighlightsImmediately() {
    if (mounted) {
      state = state.copyWith(recentlyAddedIds: {});
    }
  }

  // --- Clear all items ---
  void clearAllItems() {
    state = state.copyWith(items: []);
  }

  // --- Item Removal ---
  void removeItemById(String itemId) {
    final updatedItems =
        state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    // INFO: Local-only operation - use InventoryRealNotifier.removeItem() for backend persistence
  }
}

// DEPRECATED: Legacy provider for local/mock inventory (no backend persistence)
// ADVICE: Use inventoryRealProvider for production with backend persistence
final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
      return InventoryNotifier();
    });

// Optional: Provider for the filtered and sorted list
final filteredSortedInventoryProvider = Provider<List<DisplayBatchInfo>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  final allItems = inventoryState.items;
  final overrides = inventoryState.userSelectedBatchOverrides;

  // 1. Group all items by name
  final groupedByName = groupBy(allItems, (item) => item.name.toLowerCase());

  // 2. Select the single batch to display for each group based on rules or overrides
  final List<DisplayBatchInfo> displayBatchInfos = [];
  groupedByName.forEach((nameKey, batchList) {
    if (batchList.isEmpty) return;

    InventoryItem? batchToShow;

    // Check for user override first
    final String? overriddenBatchId =
        overrides[nameKey]; // Use lowercase name key
    if (overriddenBatchId != null) {
      batchToShow = batchList.firstWhereOrNull(
        (b) => b.id == overriddenBatchId,
      );
    }

    // If no override or override ID not found, use default logic
    if (batchToShow == null) {
      // Filter out expired batches
      final nonExpiredBatches =
          batchList.where((batch) {
            final status = ExpirationStatusExtension.fromDate(
              batch.expirationDate,
            );
            return status != ExpirationStatus.expired;
          }).toList();

      if (nonExpiredBatches.isNotEmpty) {
        // Sort non-expired by expiration date ascending
        nonExpiredBatches.sort((a, b) {
          if (a.expirationDate == null && b.expirationDate == null) return 0;
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return a.expirationDate!.compareTo(b.expirationDate!);
        });
        batchToShow = nonExpiredBatches.first;
      } else {
        // If ALL batches are expired, show the most recently expired one
        batchList.sort((a, b) {
          if (a.expirationDate == null && b.expirationDate == null) return 0;
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return b.expirationDate!.compareTo(a.expirationDate!); // Descending
        });
        batchToShow = batchList.first;
      }
    }

    if (batchToShow != null) {
      // Add the DisplayBatchInfo object containing the selected batch and all batches
      displayBatchInfos.add(
        DisplayBatchInfo(
          displayBatch: batchToShow,
          allBatchesForIngredient:
              batchList, // Pass the full list for the selector
        ),
      );
    }
  });

  // 3. Apply user's filters TO THE DISPLAY BATCH INFO OBJECTS
  bool matchesExpirationFilter(InventoryItem item, ExpirationStatus filter) {
    if (filter == ExpirationStatus.all) return true;
    final currentStatus = ExpirationStatusExtension.fromDate(
      item.expirationDate,
    );
    return currentStatus == filter;
  }

  // 4. Apply user's filters to the filtered display batch info objects
  List<DisplayBatchInfo> filteredDisplayInfo =
      displayBatchInfos.where((info) {
        final item =
            info.displayBatch; // Filter based on the batch being displayed
        final matchesSearch = item.name.toLowerCase().contains(
          inventoryState.searchQuery.toLowerCase(),
        );
        final matchesCategory =
            inventoryState.categoryFilter == ItemCategory.all ||
            item.category == inventoryState.categoryFilter;
        final matchesStorage =
            inventoryState.storageFilter.isEmpty ||
            inventoryState.storageFilter.contains(item.storageType);
        final matchesExpiration = matchesExpirationFilter(
          item,
          inventoryState.expirationStatusFilter,
        );
        return matchesSearch &&
            matchesCategory &&
            matchesStorage &&
            matchesExpiration;
      }).toList();

  // 5. Apply user's sorting to the filtered display batch info objects
  filteredDisplayInfo.sort((infoA, infoB) {
    final a = infoA.displayBatch; // Sort based on the batch being displayed
    final b = infoB.displayBatch;
    int comparison = 0;
    switch (inventoryState.sortCriteria) {
      case InventorySortCriteria.name:
        comparison = a.name.compareTo(b.name);
        break;
      case InventorySortCriteria.quantity:
        comparison = a.quantity.compareTo(b.quantity);
        break;
      case InventorySortCriteria.expirationDate:
        if (a.expirationDate == null && b.expirationDate == null) {
          comparison = 0;
        } else if (a.expirationDate == null) {
          comparison = 1;
        } else if (b.expirationDate == null) {
          comparison = -1;
        } else {
          comparison = a.expirationDate!.compareTo(b.expirationDate!);
        }
        break;
      case InventorySortCriteria.addedDate:
        // Ordenar por fecha de adición (más reciente primero por defecto)
        if (a.addedDate == null && b.addedDate == null) {
          comparison = 0;
        } else if (a.addedDate == null) {
          comparison = 1;
        } else if (b.addedDate == null) {
          comparison = -1;
        } else {
          comparison = a.addedDate.compareTo(b.addedDate);
        }
        break;
    }

    // 🔧 STABLE SORT: If primary comparison is equal, use name as secondary sort
    // This prevents items from jumping positions when batch selection changes
    if (comparison == 0) {
      comparison = a.name.compareTo(b.name);
    }

    return inventoryState.sortAscending ? comparison : -comparison;
  });

  return filteredDisplayInfo;
});

// Provider for total item count
final totalItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryProvider).items;
  return items.length;
});

// Provider for count of items expiring within 5 days (and not expired)
final expiringSoonCountProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryProvider).items;
  return items
      .where(
        (item) =>
            ExpirationStatusExtension.fromDate(item.expirationDate) ==
            ExpirationStatus.expiringSoon,
      )
      .length;
});

// Provider for count of expired items
final expiredCountProvider = Provider<int>((ref) {
  final items = ref.watch(inventoryProvider).items;
  return items
      .where(
        (item) =>
            ExpirationStatusExtension.fromDate(item.expirationDate) ==
            ExpirationStatus.expired,
      )
      .length;
});

// --- BACKEND INVENTORY NOTIFIER ---
/// Real backend inventory notifier that connects to the API
class InventoryRealNotifier extends StateNotifier<InventoryState> {
  final InventoryBackendNotifier _backendNotifier;

  // 🚀 CACHE: Track when data was last loaded
  DateTime? _lastLoadTime;
  static const Duration _cacheValidDuration = Duration(
    seconds: 30,
  ); // 30 seconds cache for immediate experience

  InventoryRealNotifier(this._backendNotifier) : super(const InventoryState()) {
    // DON'T auto-load on construction - let screens decide when to load
    log('🔧 InventoryRealNotifier initialized (cache-optimized)');
  }

  /// 🧠 Check if cached data is still valid
  bool get _isCacheValid {
    if (_lastLoadTime == null) return false;
    final now = DateTime.now();
    final cacheAge = now.difference(_lastLoadTime!);
    final isValid = cacheAge < _cacheValidDuration;
    log('📦 Cache check: age=${cacheAge.inSeconds}s, valid=$isValid');
    return isValid;
  }

  /// 🚀 Smart load: only load if cache is invalid or empty
  Future<void> loadInventoryIfNeeded() async {
    // Skip if already loading
    if (state.isLoading) {
      log('⏳ Already loading inventory, skipping');
      return;
    }

    // Skip if cache is valid and has data
    if (_isCacheValid && state.items.isNotEmpty) {
      log('📦 Using valid cached data (${state.items.length} items)');
      return;
    }

    // Load fresh data - use fast endpoint for initial load
    log('🌐 Cache invalid or empty, loading fresh data');
    if (state.items.isEmpty) {
      // First load: use fast endpoint
      log('🚀 First load - using fast endpoint');
      await loadInventoryFromBackend();
    } else {
      // Subsequent loads: use complete endpoint for enhanced data
      log('🔄 Subsequent load - using complete endpoint');
      await loadCompleteInventoryFromBackend();
    }
  }

  // Helper methods for quantity logic (shared with local notifier)
  double getQuantityStep(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }

  double getMinimumQuantity(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }

  /// Set user selected batch for an ingredient (UI state management)
  void setUserSelectedBatch(String ingredientName, String batchId) {
    final lowerCaseName = ingredientName.toLowerCase();
    final currentOverrides = Map<String, String>.from(
      state.userSelectedBatchOverrides,
    );

    // Update or add the override for this ingredient
    currentOverrides[lowerCaseName] = batchId;

    state = state.copyWith(userSelectedBatchOverrides: currentOverrides);
  }

  /// Filter and sorting methods (mirrored from InventoryNotifier for UI consistency)
  void setCategoryFilter(ItemCategory category) {
    state = state.copyWith(categoryFilter: category);
  }

  void setStorageFilter(Set<StorageType> storageTypes) {
    state = state.copyWith(storageFilter: storageTypes);
  }

  void setSortCriteria(InventorySortCriteria criteria) {
    state = state.copyWith(sortCriteria: criteria);
  }

  void setSortDirection(bool ascending) {
    state = state.copyWith(sortAscending: ascending);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setExpirationStatusFilter(ExpirationStatus status) {
    state = state.copyWith(expirationStatusFilter: status);
  }

  /// Load inventory from real backend
  Future<void> loadInventoryFromBackend() async {
    log('🔄 DEBUG - Starting loadInventoryFromBackend');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      log('📡 DEBUG - Calling backend getInventory');
      final inventoryData = await _backendNotifier.getInventory();
      log('📡 DEBUG - Backend response received: $inventoryData');

      log('🔧 DEBUG - Parsing inventory data');
      final items = _parseInventoryFromAPI(inventoryData);
      log('🔧 DEBUG - Parsing completed, ${items.length} items created');

      state = state.copyWith(items: items, isLoading: false);
      _lastLoadTime = DateTime.now(); // 🚀 Update cache timestamp
      log('✅ DEBUG - loadInventoryFromBackend completed successfully');
    } catch (e) {
      log('❌ DEBUG - Error in loadInventoryFromBackend: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Load complete inventory with environmental impact and utilization ideas
  Future<void> loadCompleteInventoryFromBackend() async {
    log('🔄 DEBUG - Starting loadCompleteInventoryFromBackend');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      log('📡 DEBUG - Calling backend getInventoryComplete');
      final inventoryData = await _backendNotifier.getInventoryComplete();
      log('📡 DEBUG - Complete inventory response received: $inventoryData');

      log('🔧 DEBUG - Parsing complete inventory data');
      final items = _parseInventoryFromAPI(inventoryData);
      log('🔧 DEBUG - Parsing completed, ${items.length} items created');

      state = state.copyWith(items: items, isLoading: false);
      _lastLoadTime = DateTime.now(); // 🚀 Update cache timestamp
      log('✅ DEBUG - loadCompleteInventoryFromBackend completed successfully');
    } catch (e) {
      log('❌ DEBUG - Error in loadCompleteInventoryFromBackend: $e');
      // Fallback to regular inventory if complete fails
      log('🔄 DEBUG - Falling back to regular inventory');
      await loadInventoryFromBackend();
    }
  }

  /// Add ingredients to real backend
  Future<void> addIngredientsToBackend(List<InventoryItem> items) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final ingredientsData =
          items.map((item) => _convertItemToAPI(item)).toList();
      await _backendNotifier.addIngredients(ingredientsData);

      // Reload inventory after adding
      await loadInventoryFromBackend();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// INFO: Add single item to inventory from recognition results
  /// USAGE: Direct API call to add individual item to backend inventory
  Future<Map<String, dynamic>> addSingleItemToInventory(
    Map<String, dynamic> itemData,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _backendNotifier.addInventoryItem(itemData);

      // Reload inventory after adding
      await loadInventoryFromBackend();

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Update ingredient in real backend
  Future<void> updateIngredientInBackend(InventoryItem item) async {
    try {
      final updateData = _convertItemToAPI(item);
      final safeIngredientName = UrlEncodingHelper.encodeItemName(item.name);
      await _backendNotifier.updateIngredient(
        safeIngredientName,
        _formatTimestampForBackend(item.addedDate),
        updateData,
      );

      // Reload inventory after updating
      await loadInventoryFromBackend();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Delete ingredient from real backend
  Future<void> deleteIngredientFromBackend(InventoryItem item) async {
    try {
      final safeIngredientName = UrlEncodingHelper.encodeItemName(item.name);
      await _backendNotifier.deleteIngredient(
        safeIngredientName,
        _formatTimestampForBackend(item.addedDate),
      );

      // Reload inventory after deleting
      await loadInventoryFromBackend();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Get expiring items from backend
  Future<List<String>> getExpiringItemsFromBackend(int days) async {
    try {
      final result = await _backendNotifier.getExpiringItems(days);
      // API returns: {"expiring_items": [...], "within_days": 3, "count": 1}
      final expiringItems = result['expiring_items'] as List<dynamic>? ?? [];
      return expiringItems
          .map((item) => (item as Map<String, dynamic>)['name'] as String)
          .toList();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return [];
    }
  }

  /// Get detailed expiring items with full information
  Future<List<Map<String, dynamic>>> getDetailedExpiringItems(int days) async {
    try {
      final response = await _backendNotifier.getExpiringItems(days);
      final expiringItems = response['expiring_items'] as List<dynamic>? ?? [];
      return expiringItems.cast<Map<String, dynamic>>();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return [];
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Format DateTime to backend-compatible timestamp format
  /// CRITICAL: Preserves local time, does NOT convert to UTC
  /// Backend expects the exact timestamp from the database (local time with Z suffix)
  String _formatTimestampForBackend(DateTime dateTime) {
    final formattedTimestamp = UrlEncodingHelper.formatTimestamp(dateTime);

    log('🔍 DEBUG - Original DateTime: $dateTime');
    log('🔍 DEBUG - Formatted timestamp (LOCAL + Z): $formattedTimestamp');

    // ✅ VALIDATION: Check if this looks like UTC conversion (for debugging)
    if (formattedTimestamp.contains('01:29:12') ||
        formattedTimestamp.contains('2025-06-23T01:')) {
      log(
        '🚨 WARNING: Timestamp looks like UTC conversion! This will cause 404',
      );
      log('   └─ Expected: 2025-06-22T20:29:12.000Z');
      log('   └─ Got: $formattedTimestamp');
    }

    return formattedTimestamp;
  }

  /// Parse timestamp from API response preserving local time
  /// CRITICAL: Ensures we don't lose the original timestamp format
  DateTime _parseTimestampFromAPI(String timestampStr) {
    log('🔍 DEBUG - Parsing timestamp from API: $timestampStr');

    // Parse the timestamp - Dart will handle the Z suffix correctly
    DateTime parsed = DateTime.parse(timestampStr);

    // If the original had Z (UTC), convert to local to preserve the time values
    // This ensures that 2025-06-22T20:29:12.000Z stays as 20:29:12 local time
    if (timestampStr.endsWith('Z')) {
      parsed = parsed.toLocal();
      log('🔍 DEBUG - Converted UTC timestamp to local: $parsed');
    }

    return parsed;
  }

  /// Remove item from inventory (with backend synchronization)
  /// Uses the correct DELETE endpoints based on item type
  Future<void> removeItem(String itemId) async {
    log('🗑️ PROVIDER: Starting removeItem for ID: $itemId');
    log('🗑️ PROVIDER: Current items count: ${state.items.length}');

    // Find item to remove for logging
    final itemToRemove =
        state.items.where((item) => item.id == itemId).firstOrNull;
    if (itemToRemove == null) {
      log('🗑️ PROVIDER: ERROR - Item not found in state: $itemId');
      return;
    }
    log('🗑️ PROVIDER: Found item to remove: ${itemToRemove.name}');
    log('🗑️ PROVIDER: Item category: ${itemToRemove.category}');
    log(
      '🗑️ PROVIDER: Item addedDate: ${itemToRemove.addedDate.toIso8601String()}',
    );

    // 1. Remove from local state immediately for responsiveness
    final updatedItems =
        state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    log('🗑️ PROVIDER: Updated local state, new count: ${updatedItems.length}');

    try {
      // 2. Use the correct endpoint - for now, both ingredients and foods use the same endpoint
      log('🗑️ PROVIDER: Calling deleteIngredient for: ${itemToRemove.name}');

      // 🔥 CRITICAL: Encode ingredient name to handle special characters like "/"
      String safeIngredientName = UrlEncodingHelper.encodeItemName(
        itemToRemove.name,
      );

      // Format timestamp to match backend expectations (must end with Z)
      String formattedTimestamp = _formatTimestampForBackend(
        itemToRemove.addedDate,
      );

      // Debug encoding transformation
      UrlEncodingHelper.debugEncoding(itemToRemove.name);

      log(
        '🗑️ PROVIDER: Using name: "${itemToRemove.name}" -> "$safeIngredientName" and addedDate: "$formattedTimestamp"',
      );

      await _backendNotifier.deleteIngredient(
        safeIngredientName, // Use encoded name
        formattedTimestamp,
      );
      log(
        '✅ PROVIDER: Item deleted from backend successfully: $itemId (${itemToRemove.category})',
      );
    } catch (e) {
      log('❌ PROVIDER: Failed to delete item from backend: $e');
      log('❌ PROVIDER: Error type: ${e.runtimeType}');
      log('❌ PROVIDER: Full error: ${e.toString()}');

      // 3. Restore item if backend deletion failed
      log('🗑️ PROVIDER: Reloading inventory to restore state...');
      await loadInventoryFromBackend(); // Reload to restore accurate state
      state = state.copyWith(
        errorMessage: 'Failed to delete item: ${e.toString()}',
      );
      log('🗑️ PROVIDER: State restored after backend failure');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  /// Update item quantity in backend (async operation)
  Future<void> updateItemQuantityInBackend(
    String itemId,
    double newQuantity,
  ) async {
    // 1. Update local state immediately for responsiveness
    final originalItem = state.items.firstWhere((item) => item.id == itemId);
    final minimum = getMinimumQuantity(originalItem.unitType);
    final clampedQuantity = newQuantity.clamp(minimum, double.infinity);

    final updatedItems =
        state.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(quantity: clampedQuantity);
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);

    try {
      // 2. Sync with backend
      final updateData = _convertItemToAPI(
        originalItem.copyWith(quantity: clampedQuantity),
      );
      await _backendNotifier.updateInventoryItem(itemId, updateData);
      log('✅ Item quantity updated in backend: $itemId -> $clampedQuantity');
    } catch (e) {
      log('❌ Failed to update quantity in backend: $e');

      // 3. Rollback if backend update failed
      await loadInventoryFromBackend(); // Restore accurate state
      state = state.copyWith(
        errorMessage: 'Failed to update quantity: ${e.toString()}',
      );
    }
  }

  /// Quick update item quantity using PATCH endpoint (faster)
  /// Works for both ingredients and foods
  Future<void> updateItemQuantityQuick(
    String itemId,
    double newQuantity,
  ) async {
    try {
      // Find the item to get its name and addedDate
      final originalItem = state.items.firstWhere((item) => item.id == itemId);
      final minimum = getMinimumQuantity(originalItem.unitType);
      final clampedQuantity = newQuantity.clamp(minimum, double.infinity);

      // 1. Update local state immediately for better UX
      final updatedItems =
          state.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(quantity: clampedQuantity);
            }
            return item;
          }).toList();
      state = state.copyWith(items: updatedItems);

      // 2. Use the appropriate endpoint based on item category
      if (originalItem.category == ItemCategory.ingredient) {
        final safeIngredientName = UrlEncodingHelper.encodeItemName(
          originalItem.name,
        );
        await _backendNotifier.updateIngredientQuantity(
          safeIngredientName,
          _formatTimestampForBackend(originalItem.addedDate),
          clampedQuantity,
        );
        log(
          '✅ Ingredient quantity updated quickly: $itemId -> $clampedQuantity',
        );
      } else if (originalItem.category == ItemCategory.food) {
        final safeFoodName = UrlEncodingHelper.encodeItemName(
          originalItem.name,
        );
        await _backendNotifier.updateFoodQuantity(
          safeFoodName,
          _formatTimestampForBackend(originalItem.addedDate),
          clampedQuantity,
        );
        log('✅ Food quantity updated quickly: $itemId -> $clampedQuantity');
      } else {
        throw Exception('Unknown item category: ${originalItem.category}');
      }
    } catch (e) {
      log('❌ Failed to update item quantity quickly: $e');
      state = state.copyWith(
        errorMessage: 'Failed to update quantity: ${e.toString()}',
      );
      // Reload to restore accurate state
      await loadInventoryFromBackend();
    }
  }

  /// Quick update ingredient quantity using PATCH endpoint (faster)
  /// DEPRECATED: Use updateItemQuantityQuick instead
  @Deprecated('Use updateItemQuantityQuick instead')
  Future<void> updateIngredientQuantityQuick(
    String itemId,
    double newQuantity,
  ) async {
    return updateItemQuantityQuick(itemId, newQuantity);
  }

  /// Update expiration date in backend (async operation)
  Future<void> updateExpirationDateInBackend(
    String itemId,
    DateTime newDate,
  ) async {
    // 1. Update local state immediately
    final originalItem = state.items.firstWhere((item) => item.id == itemId);
    final updatedItems =
        state.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(expirationDate: newDate);
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);

    try {
      // 2. Sync with backend
      final updateData = _convertItemToAPI(
        originalItem.copyWith(expirationDate: newDate),
      );
      await _backendNotifier.updateInventoryItem(itemId, updateData);
      log('✅ Item expiration date updated in backend: $itemId -> $newDate');
    } catch (e) {
      log('❌ Failed to update expiration date in backend: $e');

      // 3. Rollback if backend update failed
      await loadInventoryFromBackend(); // Restore accurate state
      state = state.copyWith(
        errorMessage: 'Failed to update expiration date: ${e.toString()}',
      );
    }
  }

  /// Update complete item in backend (async operation)
  Future<void> updateItemInBackend(InventoryItem updatedItem) async {
    try {
      final updateData = _convertItemToAPI(updatedItem);
      await _backendNotifier.updateInventoryItem(updatedItem.id, updateData);

      // Reload inventory after updating
      await loadInventoryFromBackend();
      log('✅ Item updated in backend successfully: ${updatedItem.id}');
    } catch (e) {
      log('❌ Failed to update item in backend: $e');
      state = state.copyWith(
        errorMessage: 'Failed to update item: ${e.toString()}',
      );
    }
  }

  /// Refresh inventory data from backend manually
  /// Use this when entering inventory screen or after significant changes
  Future<void> refreshInventory() async {
    await loadInventoryFromBackend();
  }

  /// Mark ingredient as consumed with consumption details
  Future<void> markIngredientAsConsumed(
    String itemId, {
    required double consumedQuantity,
    String? consumptionReason,
    String? recipeUsed,
  }) async {
    try {
      // Find the item to get its name and addedDate
      final originalItem = state.items.firstWhere((item) => item.id == itemId);

      // Call the backend to mark as consumed
      final safeIngredientName = UrlEncodingHelper.encodeItemName(
        originalItem.name,
      );
      final result = await _backendNotifier.markIngredientConsumed(
        safeIngredientName,
        _formatTimestampForBackend(originalItem.addedDate),
        consumedQuantity: consumedQuantity,
        consumptionReason: consumptionReason,
        recipeUsed: recipeUsed,
      );

      log('✅ Ingredient marked as consumed: $itemId');
      log('📊 Consumption data: $result');

      // Reload inventory to reflect changes
      await loadInventoryFromBackend();

      // Show success message with consumption details
      final consumptionData =
          result['consumption_data'] as Map<String, dynamic>?;
      if (consumptionData != null) {
        final remainingQuantity = consumptionData['remaining_quantity'] ?? 0;
        log('📈 Remaining quantity: $remainingQuantity');
      }
    } catch (e) {
      log('❌ Failed to mark ingredient as consumed: $e');
      state = state.copyWith(
        errorMessage: 'Failed to mark as consumed: ${e.toString()}',
      );
    }
  }

  /// Add ingredients from recognition results
  Future<void> addIngredientsFromRecognition(
    List<Map<String, dynamic>> ingredients,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _backendNotifier.addIngredientsFromRecognition(
        ingredients,
      );
      log('✅ Ingredients added from recognition: $result');

      // Reload inventory to show new items
      await loadInventoryFromBackend();
    } catch (e) {
      log('❌ Failed to add ingredients from recognition: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add ingredients: ${e.toString()}',
      );
    }
  }

  /// Get list of ingredient names for quick access
  Future<List<String>> getIngredientNamesList() async {
    try {
      final result = await _backendNotifier.getIngredientsList();
      final ingredients = result['ingredients'] as List<dynamic>? ?? [];
      return ingredients.cast<String>();
    } catch (e) {
      log('❌ Failed to get ingredients list: $e');
      return [];
    }
  }

  /// Convert API inventory data to InventoryItem list
  /// UPDATED: Parse actual backend structure with ingredients and food_items
  List<InventoryItem> _parseInventoryFromAPI(Map<String, dynamic> data) {
    final List<InventoryItem> items = [];

    // DEBUG: Log raw API response
    log('🔍 DEBUG - Raw API response: $data');

    // 🚀 FIX: Backend returns: {"ingredients": [...], "food_items": [...]}
    final ingredients = data['ingredients'] as List<dynamic>? ?? [];
    final foodItems = data['food_items'] as List<dynamic>? ?? [];

    // DEBUG: Log arrays
    log('🔍 DEBUG - Ingredients found: ${ingredients.length}');
    log('🔍 DEBUG - Food items found: ${foodItems.length}');

    // 🧩 Process ingredients (each has multiple stacks)
    for (final ingredientData in ingredients) {
      final ingredientMap = ingredientData as Map<String, dynamic>;
      log('🔍 DEBUG - Processing ingredient: ${ingredientMap['name']}');

      final parsedItems = _parseIngredientWithStacks(ingredientMap);
      items.addAll(parsedItems);
      log(
        '✅ DEBUG - Created ${parsedItems.length} items from ingredient ${ingredientMap['name']}',
      );
    }

    // 🧩 Process food items (if any)
    for (final foodData in foodItems) {
      final foodMap = foodData as Map<String, dynamic>;
      log('🔍 DEBUG - Processing food item: ${foodMap['name']}');

      final parsedItems = _parseFoodWithStacks(foodMap);
      items.addAll(parsedItems);
      log(
        '✅ DEBUG - Created ${parsedItems.length} items from food ${foodMap['name']}',
      );
    }

    log('🔍 DEBUG - Final items count: ${items.length}');
    log(
      '🔍 DEBUG - Final items: ${items.map((i) => '${i.name} (${i.quantity} ${i.unitType})').toList()}',
    );

    return items;
  }

  /// 🧩 Parse ingredient with multiple stacks into individual InventoryItems
  List<InventoryItem> _parseIngredientWithStacks(
    Map<String, dynamic> ingredientData,
  ) {
    final List<InventoryItem> items = [];

    try {
      final name = ingredientData['name'] ?? 'Ingrediente sin nombre';
      final imagePath = ingredientData['image_path']; // Can be null or URL
      final storageType = _parseStorageType(ingredientData['storage_type']);
      final tips = ingredientData['tips'] ?? _getTipsForItem(name);
      final typeUnit = ingredientData['type_unit'] ?? 'unidades';

      // Get stacks array
      final stacks = ingredientData['stacks'] as List<dynamic>? ?? [];
      log(
        '🔍 DEBUG - Processing ${stacks.length} stacks for ingredient: $name',
      );

      // Create one InventoryItem per stack
      for (int i = 0; i < stacks.length; i++) {
        final stackData = stacks[i] as Map<String, dynamic>;
        final quantity = (stackData['quantity'] ?? 0).toDouble();
        final stackTypeUnit = stackData['type_unit'] ?? typeUnit;
        final addedAtStr = stackData['added_at'];
        final expirationDateStr = stackData['expiration_date'];

        // DEBUG: Log original timestamp from API
        log('🔍 DEBUG - Original timestamp from API: $addedAtStr');

        // Create unique ID for each stack
        final stackId = '${name.toLowerCase().replaceAll(' ', '_')}_stack_$i';

        final item = InventoryItem(
          id: stackId,
          name: name,
          image: _getEmojiForItem(name),
          imageUrl: imagePath,
          quantity: quantity,
          unitType: stackTypeUnit,
          expirationDate:
              expirationDateStr != null
                  ? DateTime.parse(expirationDateStr)
                  : DateTime.now().add(const Duration(days: 30)),
          storageType: storageType,
          category: ItemCategory.ingredient,
          addedDate:
              addedAtStr != null
                  ? _parseTimestampFromAPI(addedAtStr)
                  : DateTime.now(),
          tips: tips,
          description: 'Lote ${i + 1}',
        );

        // DEBUG: Log how the timestamp will be formatted for backend
        if (addedAtStr != null) {
          final formattedForBackend = _formatTimestampForBackend(
            item.addedDate,
          );
          log('🔍 DEBUG - Formatted for backend: $formattedForBackend');
        }

        items.add(item);
        log(
          '✅ DEBUG - Created stack item: ${item.name} - ${item.quantity} ${item.unitType}',
        );
      }
    } catch (e) {
      log('❌ Error parsing ingredient with stacks: $e');
      log('❌ Ingredient data that caused error: $ingredientData');
    }

    return items;
  }

  /// 🧩 Parse food item with multiple stacks into individual InventoryItems
  List<InventoryItem> _parseFoodWithStacks(Map<String, dynamic> foodData) {
    final List<InventoryItem> items = [];

    try {
      final name = foodData['name'] ?? 'Comida sin nombre';
      final imagePath = foodData['image_path']; // Can be null or URL
      final storageType = _parseStorageType(foodData['storage_type']);
      final tips = foodData['tips'] ?? _getTipsForItem(name);
      final typeUnit = foodData['type_unit'] ?? 'unidades';

      // Get stacks array
      final stacks = foodData['stacks'] as List<dynamic>? ?? [];
      log('🔍 DEBUG - Processing ${stacks.length} stacks for food: $name');

      // Create one InventoryItem per stack
      for (int i = 0; i < stacks.length; i++) {
        final stackData = stacks[i] as Map<String, dynamic>;
        final quantity = (stackData['quantity'] ?? 0).toDouble();
        final stackTypeUnit = stackData['type_unit'] ?? typeUnit;
        final addedAtStr = stackData['added_at'];
        final expirationDateStr = stackData['expiration_date'];

        // DEBUG: Log original timestamp from API
        log('🔍 DEBUG - Original food timestamp from API: $addedAtStr');

        // Create unique ID for each stack
        final stackId =
            '${name.toLowerCase().replaceAll(' ', '_')}_food_stack_$i';

        final item = InventoryItem(
          id: stackId,
          name: name,
          image: _getEmojiForItem(name),
          imageUrl: imagePath,
          quantity: quantity,
          unitType: stackTypeUnit,
          expirationDate:
              expirationDateStr != null
                  ? DateTime.parse(expirationDateStr)
                  : DateTime.now().add(const Duration(days: 30)),
          storageType: storageType,
          category: ItemCategory.food,
          addedDate:
              addedAtStr != null
                  ? _parseTimestampFromAPI(addedAtStr)
                  : DateTime.now(),
          tips: tips,
          description: 'Lote ${i + 1}',
        );

        // DEBUG: Log how the timestamp will be formatted for backend
        if (addedAtStr != null) {
          final formattedForBackend = _formatTimestampForBackend(
            item.addedDate,
          );
          log('🔍 DEBUG - Food formatted for backend: $formattedForBackend');
        }

        items.add(item);
        log(
          '✅ DEBUG - Created food stack item: ${item.name} - ${item.quantity} ${item.unitType}',
        );
      }
    } catch (e) {
      log('❌ Error parsing food with stacks: $e');
      log('❌ Food data that caused error: $foodData');
    }

    return items;
  }

  /// Convert single API item to InventoryItem (according to README.md structure)
  // ignore: unused_element
  InventoryItem? _parseItemFromAPI(Map<String, dynamic> itemData) {
    try {
      // DEBUG: Log parsing details
      log('🔍 DEBUG - Parsing item: $itemData');

      final id = itemData['id'] ?? 'unknown_id';
      final name = itemData['name'] ?? 'Item sin nombre';
      final quantity = (itemData['quantity'] ?? 0).toDouble();
      final typeUnit = itemData['type_unit'] ?? 'unidades';
      final storageType = _parseStorageType(itemData['storage_type']);
      final tips = itemData['tips'] ?? _getTipsForItem(name);
      final expirationDateStr = itemData['expiration_date'];
      final addedAtStr = itemData['added_at'];
      final imagePath = itemData['image_path']; // Can be null or URL
      final imageStatus =
          itemData['image_status']; // generating/generated/failed
      final confidence = (itemData['confidence'] ?? 0.0).toDouble();
      final allergyAlert = itemData['allergy_alert'] ?? false;
      // final allergens = List<String>.from(itemData['allergens'] ?? []); // Available but not used yet

      log('🔍 DEBUG - Parsed values:');
      log('   - id: $id');
      log('   - name: $name');
      log('   - quantity: $quantity');
      log('   - typeUnit: $typeUnit');
      log('   - storageType: $storageType');
      log('   - imagePath: $imagePath');
      log('   - imageStatus: $imageStatus');
      log('   - confidence: $confidence');

      final item = InventoryItem(
        id: id,
        name: name,
        image: _getEmojiForItem(name), // Keep emoji as fallback
        imageUrl: imagePath, // NEW: Store actual image URL
        quantity: quantity,
        unitType: typeUnit,
        expirationDate:
            expirationDateStr != null
                ? DateTime.parse(expirationDateStr)
                : DateTime.now().add(const Duration(days: 30)),
        storageType: storageType,
        category: ItemCategory.ingredient, // Default to ingredient
        addedDate:
            addedAtStr != null
                ? _parseTimestampFromAPI(addedAtStr)
                : DateTime.now(),
        tips: tips,
        // Additional metadata (could be used for displaying confidence, etc.)
        description:
            'Confianza: ${(confidence * 100).toInt()}%${allergyAlert ? " ⚠️ Alerta de alergia" : ""}',
      );

      log(
        '✅ DEBUG - Successfully created InventoryItem: ${item.name} (${item.id})',
      );
      return item;
    } catch (e) {
      log('❌ Error parsing item: $e');
      log('❌ Item data that caused error: $itemData');
      return null;
    }
  }

  // DEPRECATED method removed - now using _parseItemFromAPI() for README.md structure

  /// Convert InventoryItem to API format
  Map<String, dynamic> _convertItemToAPI(InventoryItem item) {
    return {
      'name': item.name,
      'quantity': item.quantity,
      'expiration_date':
          item.expirationDate?.toIso8601String(), // Send as ISO date string
      'type_unit': item.unitType,
      'storage_type': _convertStorageTypeToAPI(item.storageType),
      'tips': item.tips ?? _getTipsForItem(item.name),
      'image_path': '', // Will be handled separately by image upload
    };
  }

  /// Parse storage type from API (updated for README.md format)
  StorageType _parseStorageType(String? storageType) {
    switch (storageType?.toLowerCase()) {
      case 'refrigerador':
      case 'refrigerated':
        return StorageType.refrigerated;
      case 'congelador':
      case 'frozen':
        return StorageType.frozen;
      case 'despensa':
      case 'pantry':
        return StorageType.pantry;
      case 'dry':
        return StorageType.dry;
      default:
        return StorageType.refrigerated; // Default to refrigerated for safety
    }
  }

  /// Convert storage type to API format
  String _convertStorageTypeToAPI(StorageType storageType) {
    switch (storageType) {
      case StorageType.refrigerated:
        return 'refrigerated';
      case StorageType.frozen:
        return 'frozen';
      case StorageType.dry:
        return 'dry';
      case StorageType.pantry:
        return 'dry'; // Map pantry to dry for API compatibility
      case StorageType.cellar:
        return 'dry'; // Map cellar to dry for API compatibility
      case StorageType.ambient:
        return 'dry'; // Map ambient to dry for API compatibility
      case StorageType.sunlight:
        return 'dry'; // Map sunlight to dry for API compatibility
      case StorageType.wineCellar:
        return 'dry'; // Map wine cellar to dry for API compatibility
      case StorageType.bulk:
        return 'dry'; // Map bulk to dry for API compatibility
      case StorageType.fermentation:
        return 'dry'; // Map fermentation to dry for API compatibility
    }
  }

  /// Get emoji for item based on name
  String _getEmojiForItem(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('tomate')) return '🍅';
    if (nameLower.contains('cebolla')) return '🧅';
    if (nameLower.contains('arroz')) return '🍚';
    if (nameLower.contains('lechuga')) return '🥬';
    if (nameLower.contains('zanahoria')) return '🥕';
    if (nameLower.contains('papa') || nameLower.contains('patata')) return '🥔';
    if (nameLower.contains('ajo')) return '🧄';
    if (nameLower.contains('limón') || nameLower.contains('limon')) return '🍋';
    if (nameLower.contains('manzana')) return '🍎';
    if (nameLower.contains('plátano') || nameLower.contains('banana')) {
      return '🍌';
    }
    if (nameLower.contains('naranja')) return '🍊';
    if (nameLower.contains('pimiento') || nameLower.contains('chile')) {
      return '🌶️';
    }
    if (nameLower.contains('brócoli') || nameLower.contains('brocoli')) {
      return '🥦';
    }
    if (nameLower.contains('espinaca')) return '🍃';
    if (nameLower.contains('apio')) return '🥬';
    if (nameLower.contains('leche')) return '🥛';
    if (nameLower.contains('queso')) return '🧀';
    if (nameLower.contains('huevo')) return '🥚';
    if (nameLower.contains('pollo')) return '🍗';
    if (nameLower.contains('carne')) return '🥩';
    if (nameLower.contains('pescado') || nameLower.contains('atún')) {
      return '🐟';
    }
    if (nameLower.contains('pan')) return '🍞';
    if (nameLower.contains('pasta')) return '🍝';
    if (nameLower.contains('aceite')) return '🫒';
    if (nameLower.contains('sal')) return '🧂';
    if (nameLower.contains('azúcar') || nameLower.contains('azucar')) {
      return '🍯';
    }
    if (nameLower.contains('agua')) return '💧';

    return '🥘'; // Default emoji for food items
  }

  /// Get tips for item based on name
  String _getTipsForItem(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('tomate')) {
      return 'Guarda los tomates a temperatura ambiente para conservar su sabor, o en el refrigerador para extender su vida útil.';
    }
    if (nameLower.contains('cebolla')) {
      return 'Almacena en un lugar fresco y seco, separadas de las papas para evitar que ambas se deterioren más rápido.';
    }
    if (nameLower.contains('arroz')) {
      return 'Guarda en un recipiente hermético para evitar la humedad y los insectos.';
    }
    if (nameLower.contains('lechuga')) {
      return 'Lava solo cuando vayas a utilizarla. Guarda en el refrigerador envuelta en papel toalla para absorber la humedad.';
    }
    if (nameLower.contains('zanahoria')) {
      return 'Guarda en el refrigerador, preferiblemente en un recipiente con agua para mantener su frescura.';
    }

    return 'Almacena según las recomendaciones del producto para mantener su frescura.';
  }
}

/// Provider for real backend inventory
final inventoryRealProvider =
    StateNotifierProvider<InventoryRealNotifier, InventoryState>((ref) {
      final backendNotifier = ref.watch(inventoryBackendProvider);
      return InventoryRealNotifier(backendNotifier);
    });

/// Filtered and sorted provider for real backend inventory (mirrors the mock provider logic)
final filteredSortedInventoryRealProvider = Provider<List<DisplayBatchInfo>>((
  ref,
) {
  final inventoryState = ref.watch(inventoryRealProvider);
  final allItems = inventoryState.items;
  final overrides = inventoryState.userSelectedBatchOverrides;

  // 1. Group all items by name
  final groupedByName = groupBy(allItems, (item) => item.name.toLowerCase());

  // 2. Select the single batch to display for each group based on rules or overrides
  final List<DisplayBatchInfo> displayBatchInfos = [];
  groupedByName.forEach((nameKey, batchList) {
    if (batchList.isEmpty) return;

    InventoryItem? batchToShow;

    // Check for user override first
    final String? overriddenBatchId =
        overrides[nameKey]; // Use lowercase name key
    if (overriddenBatchId != null) {
      batchToShow = batchList.firstWhereOrNull(
        (b) => b.id == overriddenBatchId,
      );
    }

    // If no override or override ID not found, use default logic
    if (batchToShow == null) {
      // Filter out expired batches
      final nonExpiredBatches =
          batchList.where((batch) {
            final status = ExpirationStatusExtension.fromDate(
              batch.expirationDate,
            );
            return status != ExpirationStatus.expired;
          }).toList();

      if (nonExpiredBatches.isNotEmpty) {
        // Sort non-expired by expiration date ascending
        nonExpiredBatches.sort((a, b) {
          if (a.expirationDate == null && b.expirationDate == null) return 0;
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return a.expirationDate!.compareTo(b.expirationDate!);
        });
        batchToShow = nonExpiredBatches.first;
      } else {
        // If ALL batches are expired, show the most recently expired one
        batchList.sort((a, b) {
          if (a.expirationDate == null && b.expirationDate == null) return 0;
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return b.expirationDate!.compareTo(a.expirationDate!); // Descending
        });
        batchToShow = batchList.first;
      }
    }

    if (batchToShow != null) {
      // Add the DisplayBatchInfo object containing the selected batch and all batches
      displayBatchInfos.add(
        DisplayBatchInfo(
          displayBatch: batchToShow,
          allBatchesForIngredient:
              batchList, // Pass the full list for the selector
        ),
      );
    }
  });

  // 3. Apply user's filters TO THE DISPLAY BATCH INFO OBJECTS
  bool matchesExpirationFilter(InventoryItem item, ExpirationStatus filter) {
    if (filter == ExpirationStatus.all) return true;
    final currentStatus = ExpirationStatusExtension.fromDate(
      item.expirationDate,
    );
    return currentStatus == filter;
  }

  // 4. Apply user's filters to the filtered display batch info objects
  List<DisplayBatchInfo> filteredDisplayInfo =
      displayBatchInfos.where((info) {
        final item =
            info.displayBatch; // Filter based on the batch being displayed
        final matchesSearch = item.name.toLowerCase().contains(
          inventoryState.searchQuery.toLowerCase(),
        );
        final matchesCategory =
            inventoryState.categoryFilter == ItemCategory.all ||
            item.category == inventoryState.categoryFilter;
        final matchesStorage =
            inventoryState.storageFilter.isEmpty ||
            inventoryState.storageFilter.contains(item.storageType);
        final matchesExpiration = matchesExpirationFilter(
          item,
          inventoryState.expirationStatusFilter,
        );
        return matchesSearch &&
            matchesCategory &&
            matchesStorage &&
            matchesExpiration;
      }).toList();

  // 5. Apply user's sorting to the filtered display batch info objects
  filteredDisplayInfo.sort((infoA, infoB) {
    final a = infoA.displayBatch; // Sort based on the batch being displayed
    final b = infoB.displayBatch;
    int comparison = 0;
    switch (inventoryState.sortCriteria) {
      case InventorySortCriteria.name:
        comparison = a.name.compareTo(b.name);
        break;
      case InventorySortCriteria.quantity:
        comparison = a.quantity.compareTo(b.quantity);
        break;
      case InventorySortCriteria.expirationDate:
        if (a.expirationDate == null && b.expirationDate == null) {
          comparison = 0;
        } else if (a.expirationDate == null) {
          comparison = 1;
        } else if (b.expirationDate == null) {
          comparison = -1;
        } else {
          comparison = a.expirationDate!.compareTo(b.expirationDate!);
        }
        break;
      case InventorySortCriteria.addedDate:
        // Ordenar por fecha de adición (más reciente primero por defecto)
        if (a.addedDate == null && b.addedDate == null) {
          comparison = 0;
        } else if (a.addedDate == null) {
          comparison = 1;
        } else if (b.addedDate == null) {
          comparison = -1;
        } else {
          comparison = a.addedDate.compareTo(b.addedDate);
        }
        break;
    }

    // 🔧 STABLE SORT: If primary comparison is equal, use name as secondary sort
    // This prevents items from jumping positions when batch selection changes
    if (comparison == 0) {
      comparison = a.name.compareTo(b.name);
    }

    return inventoryState.sortAscending ? comparison : -comparison;
  });

  return filteredDisplayInfo;
});

// ============================================================================
// PROVIDER USAGE GUIDE
// ============================================================================
//
// 🚀 PRODUCTION USE:
//   - Use `inventoryRealProvider` for all production features
//   - Use `filteredSortedInventoryRealProvider` for filtered/sorted lists
//   - These providers have full backend persistence and synchronization
//
// 🧪 DEVELOPMENT/TESTING USE:
//   - Use `inventoryProvider` for local testing without backend
//   - Use `filteredSortedInventoryProvider` for filtered/sorted lists
//   - These providers are local-only and don't persist data
//
// 📋 AVAILABLE METHODS IN InventoryRealNotifier:
//   - loadInventoryFromBackend() - Load all items from API
//   - addIngredientsToBackend() - Add multiple items with backend sync
//   - removeItem() - Delete item with backend sync
//   - updateItemQuantityInBackend() - Update quantity with backend sync
//   - updateExpirationDateInBackend() - Update expiration with backend sync
//   - markIngredientAsConsumed() - Mark as consumed with tracking
//   - refreshInventory() - Manual refresh from backend
//
// ============================================================================
