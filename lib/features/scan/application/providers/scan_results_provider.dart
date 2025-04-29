import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/scan/domain/models/recognized_item.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

// Provider now takes a List of Maps representing the raw JSON data
final scanResultsProvider = StateNotifierProvider.autoDispose.family<
  ScanResultsNotifier,
  List<RecognizedItem>,
  List<Map<String, dynamic>>
>((ref, initialJsonData) {
  // Convert initial JSON data into RecognizedItem list
  var uuid = const Uuid();
  final initialItems =
      initialJsonData
          .map((json) => RecognizedItem.fromJson(json, uuid.v4()))
          .toList();
  return ScanResultsNotifier(initialItems);
});

class ScanResultsNotifier extends StateNotifier<List<RecognizedItem>> {
  ScanResultsNotifier(super.initialState);

  void incrementQuantity(String itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrementQuantity(String itemId) {
    state = [
      for (final item in state)
        // Only decrement if quantity is greater than 1
        if (item.id == itemId && item.quantity > 1)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ];
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
    // Or set quantity to 0 if you prefer to keep it but not add it
    // state = [
    //   for (final item in state)
    //     if (item.id == itemId) item.copyWith(quantity: 0) else item,
    // ];
  }

  // Get items with quantity > 0 to be added to inventory
  List<RecognizedItem> getItemsToAdd() {
    return state.where((item) => item.quantity > 0).toList();
  }
}
