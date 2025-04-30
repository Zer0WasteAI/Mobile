import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String name,
    required String image,
    required int quantity,
    DateTime? expirationDate,
    required StorageType storageType,
    required ItemCategory category,
    String? imageUrl,
    required DateTime addedDate,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}
