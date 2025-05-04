import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
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
    required double quantity,
    required String unitType,
    DateTime? expirationDate,
    required StorageType storageType,
    required ItemCategory category,
    String? imageUrl,
    String? tips,
    required DateTime addedDate,
    String? description,
    int? calories,
    int? servingQuantity,
    List<String>? mainIngredients,
    String? foodCategory,
    String? sustainabilityNote,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);

  factory InventoryItem.empty() => InventoryItem(
    id: '',
    name: '',
    image: '',
    quantity: 0.0,
    unitType: 'unidades',
    storageType: StorageType.dry,
    category: ItemCategory.food,
    addedDate: DateTime.now(),
    expirationDate: null,
    imageUrl: null,
    tips: null,
    description: null,
    calories: null,
    servingQuantity: null,
    mainIngredients: null,
    foodCategory: null,
    sustainabilityNote: null,
  );
}
