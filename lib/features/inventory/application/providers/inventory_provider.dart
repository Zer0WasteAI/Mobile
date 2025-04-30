import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

// TODO: Replace with actual data persistence (e.g., Hive, Supabase)
final _uuid = Uuid();

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState()) {
    // Load initial data (replace with actual data loading)
    _loadMockData();
  }

  void _loadMockData() {
    // Simulate loading initial data
    state = state.copyWith(isLoading: true);
    // Example data based on new structure
    final mockItems = [
      InventoryItem(
        id: _uuid.v4(),
        name: 'Manzanas',
        image: '🍎', // Emoji example
        quantity: 5,
        expirationDate: DateTime.now().add(const Duration(days: 7)),
        storageType: StorageType.refrigerated,
        category: ItemCategory.food,
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InventoryItem(
        id: _uuid.v4(),
        name: 'Pollo Congelado',
        image: '🍗',
        quantity: 2,
        expirationDate: DateTime.now().add(const Duration(days: 90)),
        storageType: StorageType.frozen,
        category: ItemCategory.food,
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      InventoryItem(
        id: _uuid.v4(),
        name: 'Arroz',
        image: '🍚',
        quantity: 1,
        storageType: StorageType.dry,
        category: ItemCategory.ingredient,
        addedDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      // Item expiring soon (e.g., 2 days from now)
      InventoryItem(
        id: _uuid.v4(),
        name: 'Yogurt',
        image: '🥛',
        quantity: 3,
        expirationDate: DateTime.now().add(const Duration(days: 2)),
        storageType: StorageType.refrigerated,
        category: ItemCategory.food,
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // Expired item (e.g., 3 days ago)
      InventoryItem(
        id: _uuid.v4(),
        name: 'Lechuga Vieja',
        image: '🥬',
        quantity: 1,
        expirationDate: DateTime.now().subtract(const Duration(days: 3)),
        storageType: StorageType.refrigerated,
        category: ItemCategory.ingredient,
        addedDate: DateTime.now().subtract(const Duration(days: 8)),
      ),
      // Add more mock items if needed
    ];
    state = state.copyWith(items: mockItems, isLoading: false);
  }

  // --- Item Management ---
  void addItems(List<InventoryItem> itemsToAdd) {
    final newIds = itemsToAdd.map((item) => item.id).toSet();
    final updatedItems = [...state.items, ...itemsToAdd];
    state = state.copyWith(
      items: updatedItems,
      recentlyAddedIds: newIds, // Store the IDs of the newly added items
    );
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
            return item.copyWith(quantity: item.quantity + 1);
          }
          return item;
        }).toList();
    state = state.copyWith(items: updatedItems);
    // TODO: Update persistence layer
  }

  void decrementQuantity(String itemId) {
    final updatedItems =
        state.items.map((item) {
          if (item.id == itemId && item.quantity > 1) {
            return item.copyWith(quantity: item.quantity - 1);
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

  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  // --- Highlight Management ---
  void _scheduleHighlightClear(Set<String> idsToClear) {
    Future.delayed(const Duration(seconds: 3), () {
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
}

// Provider definition
final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
      return InventoryNotifier();
    });

// Optional: Provider for the filtered and sorted list
final filteredSortedInventoryProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryState = ref.watch(inventoryProvider);
  final items = inventoryState.items;

  // Updated helper function
  bool _matchesExpirationFilter(InventoryItem item, ExpirationStatus filter) {
    if (filter == ExpirationStatus.all)
      return true; // Show all if filter is .all

    final currentStatus = ExpirationStatusExtension.fromDate(
      item.expirationDate,
    );
    return currentStatus == filter; // Match the specific selected status
  }

  // Apply filtering
  List<InventoryItem> filteredItems =
      items.where((item) {
        final matchesSearch = item.name.toLowerCase().contains(
          inventoryState.searchQuery.toLowerCase(),
        );
        final matchesCategory =
            inventoryState.categoryFilter == ItemCategory.all ||
            item.category == inventoryState.categoryFilter;
        final matchesStorage =
            inventoryState.storageFilter.isEmpty ||
            inventoryState.storageFilter.contains(item.storageType);

        // Updated expiration check
        final matchesExpiration = _matchesExpirationFilter(
          item,
          inventoryState.expirationStatusFilter,
        );

        return matchesSearch &&
            matchesCategory &&
            matchesStorage &&
            matchesExpiration;
      }).toList();

  // Apply sorting (removed addedDate)
  filteredItems.sort((a, b) {
    int comparison = 0;
    switch (inventoryState.sortCriteria) {
      case InventorySortCriteria.name:
        comparison = a.name.compareTo(b.name);
        break;
      case InventorySortCriteria.quantity:
        comparison = a.quantity.compareTo(b.quantity);
        break;
      case InventorySortCriteria.expirationDate:
        if (a.expirationDate == null && b.expirationDate == null)
          comparison = 0;
        else if (a.expirationDate == null)
          comparison = 1;
        else if (b.expirationDate == null)
          comparison = -1;
        else
          comparison = a.expirationDate!.compareTo(b.expirationDate!);
        break;
      // case InventorySortCriteria.addedDate: // Removed
      //   comparison = a.addedDate.compareTo(b.addedDate);
      //   break;
    }
    return inventoryState.sortAscending ? comparison : -comparison;
  });

  return filteredItems;
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
