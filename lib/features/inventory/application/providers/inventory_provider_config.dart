import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';

/// Configuration for inventory provider
/// Set to true to use real backend, false to use mock data
// ignore: constant_identifier_names
const bool USE_REAL_BACKEND = true;

/// Get the current inventory state
final inventoryStateProvider = Provider<InventoryState>((ref) {
  if (USE_REAL_BACKEND) {
    return ref.watch(inventoryRealProvider);
  } else {
    return ref.watch(inventoryProvider);
  }
});

/// Get the inventory notifier (for making changes)
final inventoryNotifierProvider = Provider((ref) {
  if (USE_REAL_BACKEND) {
    return ref.watch(inventoryRealProvider.notifier);
  } else {
    return ref.watch(inventoryProvider.notifier);
  }
});

/// Get filtered and sorted inventory items
final filteredInventoryProvider = Provider<List<DisplayBatchInfo>>((ref) {
  if (USE_REAL_BACKEND) {
    return ref.watch(filteredSortedInventoryRealProvider);
  } else {
    return ref.watch(filteredSortedInventoryProvider);
  }
});
