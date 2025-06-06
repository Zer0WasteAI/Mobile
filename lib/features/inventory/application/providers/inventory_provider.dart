// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_backend_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
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

// TODO: Replace with actual data persistence (e.g., Hive, Supabase)
// ignore: unused_element
final _uuid = Uuid();

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
    // TODO: Update persistence layer
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
    // TODO: Update persistence layer
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
    // TODO: Update persistence layer
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
    // TODO: Update persistence layer
  }

  void saveItemChanges(InventoryItem updatedItem) {
    final updatedItems =
        state.items.map((item) {
          return item.id == updatedItem.id ? updatedItem : item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // TODO: Update persistence layer
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
    // TODO: Update persistence layer
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
    // TODO: Update persistence layer
  }
}

// Provider definition
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

  InventoryRealNotifier(this._backendNotifier) : super(const InventoryState()) {
    loadInventoryFromBackend();
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
      log('✅ DEBUG - loadInventoryFromBackend completed successfully');
    } catch (e) {
      log('❌ DEBUG - Error in loadInventoryFromBackend: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
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

  /// Update ingredient in real backend
  Future<void> updateIngredientInBackend(InventoryItem item) async {
    try {
      final updateData = _convertItemToAPI(item);
      await _backendNotifier.updateIngredient(
        item.name,
        item.addedDate.toIso8601String(),
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
      await _backendNotifier.deleteIngredient(
        item.name,
        item.addedDate.toIso8601String(),
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

  /// Refresh inventory data from backend manually
  /// Use this when entering inventory screen or after significant changes
  Future<void> refreshInventory() async {
    await loadInventoryFromBackend();
  }

  /// Convert API inventory data to InventoryItem list
  List<InventoryItem> _parseInventoryFromAPI(Map<String, dynamic> data) {
    final List<InventoryItem> items = [];

    // DEBUG: Log raw API response
    log('🔍 DEBUG - Raw API response: $data');

    // API returns: {"ingredients": [{"name": "...", "stacks": [...], ...}]}
    final ingredients = data['ingredients'] as List<dynamic>? ?? [];

    // DEBUG: Log ingredients array
    log('🔍 DEBUG - Ingredients found: ${ingredients.length}');
    log('🔍 DEBUG - Ingredients data: $ingredients');

    for (final ingredientData in ingredients) {
      final ingredient = ingredientData as Map<String, dynamic>;
      final name = ingredient['name'] ?? 'Ingrediente';
      final stacks = ingredient['stacks'] as List<dynamic>? ?? [];

      // DEBUG: Log each ingredient processing
      log(
        '🔍 DEBUG - Processing ingredient: $name with ${stacks.length} stacks',
      );
      log('🔍 DEBUG - Ingredient data: $ingredient');
      log('🔍 DEBUG - Stacks data: $stacks');

      // Each ingredient can have multiple stacks (batches)
      for (final stackData in stacks) {
        final stack = stackData as Map<String, dynamic>;
        log('🔍 DEBUG - Processing stack: $stack');

        final item = _parseStackFromAPI(name, ingredient, stack);
        if (item != null) {
          items.add(item);
          log('✅ DEBUG - Successfully created item: ${item.name} (${item.id})');
        } else {
          log('❌ DEBUG - Failed to create item from stack: $stack');
        }
      }
    }

    log('🔍 DEBUG - Final items count: ${items.length}');
    log(
      '🔍 DEBUG - Final items: ${items.map((i) => '${i.name} (${i.quantity} ${i.unitType})').toList()}',
    );

    return items;
  }

  /// Convert single API stack to InventoryItem
  InventoryItem? _parseStackFromAPI(
    String name,
    Map<String, dynamic> ingredientData,
    Map<String, dynamic> stackData,
  ) {
    try {
      // DEBUG: Log parsing details
      log('🔍 DEBUG - Parsing stack for $name');
      log('🔍 DEBUG - Stack data: $stackData');
      log('🔍 DEBUG - Ingredient data: $ingredientData');

      final id =
          '${name}_${stackData['added_at'] ?? DateTime.now().toIso8601String()}';
      final quantity = (stackData['quantity'] ?? 0).toDouble();
      final expirationDateStr = stackData['expiration_date'];
      final addedAtStr = stackData['added_at'];
      final storageType = _parseStorageType(ingredientData['storage_type']);
      final unitType = ingredientData['type_unit'] ?? 'unidades';
      final tips = ingredientData['tips'] ?? _getTipsForItem(name);

      log('🔍 DEBUG - Parsed values:');
      log('   - id: $id');
      log('   - quantity: $quantity');
      log('   - expirationDateStr: $expirationDateStr');
      log('   - addedAtStr: $addedAtStr');
      log('   - storageType: $storageType');
      log('   - unitType: $unitType');

      final item = InventoryItem(
        id: id,
        name: name,
        image: _getEmojiForItem(name),
        quantity: quantity,
        expirationDate:
            expirationDateStr != null
                ? DateTime.parse(expirationDateStr)
                : DateTime.now().add(const Duration(days: 30)),
        storageType: storageType,
        category: ItemCategory.ingredient, // Backend only handles ingredients
        addedDate:
            addedAtStr != null ? DateTime.parse(addedAtStr) : DateTime.now(),
        unitType: unitType,
        tips: tips,
      );

      log(
        '✅ DEBUG - Successfully created InventoryItem: ${item.name} (${item.id})',
      );
      return item;
    } catch (e) {
      log('❌ Error parsing stack for $name: $e');
      log('❌ Stack data that caused error: $stackData');
      log('❌ Ingredient data that caused error: $ingredientData');
      return null;
    }
  }

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

  /// Parse storage type from API
  StorageType _parseStorageType(String? storageType) {
    switch (storageType?.toLowerCase()) {
      case 'refrigerated':
        return StorageType.refrigerated;
      case 'frozen':
        return StorageType.frozen;
      case 'dry':
        return StorageType.dry;
      default:
        return StorageType.dry;
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
    return inventoryState.sortAscending ? comparison : -comparison;
  });

  return filteredDisplayInfo;
});
