import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/core/utils/url_encoding_helper.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
abstract class InventoryItem with _$InventoryItem {
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
    storageType: StorageType.ambient,
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

/// Extension for InventoryItem to handle URL encoding and timestamp formatting
extension InventoryItemExtension on InventoryItem {
  /// Get the safe name for URL encoding (handles special characters like "/")
  String get safeNameForUrl => UrlEncodingHelper.encodeItemName(name);

  /// Get the display name for UI (decodes special characters)
  String get displayName => UrlEncodingHelper.decodeItemName(name);

  /// Get the properly formatted timestamp for DELETE operations
  String get deleteTimestamp => UrlEncodingHelper.formatTimestamp(addedDate);

  /// Check if the item name contains special characters that need encoding
  bool get hasSpecialCharacters => name.contains('/');
}
