import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart'; // Import material for icons
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';

part 'inventory_state.freezed.dart';

enum InventorySortCriteria {
  name,
  quantity,
  expirationDate,
  // addedDate removed
}

extension InventorySortCriteriaExtension on InventorySortCriteria {
  String get displayName {
    switch (this) {
      case InventorySortCriteria.name:
        return 'Nombre';
      case InventorySortCriteria.quantity:
        return 'Cantidad';
      case InventorySortCriteria.expirationDate:
        return 'Vencimiento';
    }
  }

  IconData get icon {
    switch (this) {
      case InventorySortCriteria.name:
        return Icons.sort_by_alpha;
      case InventorySortCriteria.quantity:
        return Icons.pin_outlined; // Placeholder
      case InventorySortCriteria.expirationDate:
        return Icons.event_available_outlined;
    }
  }
}

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState({
    @Default([]) List<InventoryItem> items,
    @Default('') String searchQuery,
    @Default(ItemCategory.all) ItemCategory categoryFilter,
    @Default({}) Set<StorageType> storageFilter,
    @Default(ExpirationStatus.all) ExpirationStatus expirationStatusFilter,
    @Default(InventorySortCriteria.name) // Default sort by name now
    InventorySortCriteria sortCriteria,
    @Default(true) bool sortAscending, // Default A-Z for name
    @Default({}) Set<String> recentlyAddedIds,
    @Default({}) Map<String, String> userSelectedBatchOverrides,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _InventoryState;
}
