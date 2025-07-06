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
          item.copyWith(
            quantity: item.quantity + _getQuantityStep(item.typeUnit),
          )
        else
          item,
    ];
  }

  void decrementQuantity(String itemId) {
    state = [
      for (final item in state)
        // Only decrement if quantity is greater than minimum
        if (item.id == itemId &&
            item.quantity > _getMinimumQuantity(item.typeUnit))
          item.copyWith(
            quantity: ((item.quantity * 10 -
                            _getQuantityStep(item.typeUnit) * 10)
                        .round() /
                    10.0)
                .clamp(_getMinimumQuantity(item.typeUnit), double.infinity),
          )
        else
          item,
    ];
  }

  // Helper method to get quantity step based on unit type
  double _getQuantityStep(String? unit) {
    if (unit == null) return 1.0;
    switch (unit.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
      case 'gramos':
      case 'kilogramos':
      case 'litros':
      case 'mililitros':
        return 0.1;
      case 'unidades':
      case 'unidad':
      default:
        return 1.0;
    }
  }

  // Helper method to get minimum quantity based on unit type
  double _getMinimumQuantity(String? unit) {
    if (unit == null) return 1.0;
    switch (unit.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
      case 'gramos':
      case 'kilogramos':
      case 'litros':
      case 'mililitros':
        return 0.1;
      case 'unidades':
      case 'unidad':
      default:
        return 1.0;
    }
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

  // Update a specific item (useful for syncing images)
  void updateItem(RecognizedItem updatedItem) {
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item,
    ];
  }
}
