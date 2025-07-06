// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    _InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitType: json['unitType'] as String,
      expirationDate:
          json['expirationDate'] == null
              ? null
              : DateTime.parse(json['expirationDate'] as String),
      storageType: $enumDecode(_$StorageTypeEnumMap, json['storageType']),
      category: $enumDecode(_$ItemCategoryEnumMap, json['category']),
      imageUrl: json['imageUrl'] as String?,
      tips: json['tips'] as String?,
      addedDate: DateTime.parse(json['addedDate'] as String),
      description: json['description'] as String?,
      calories: (json['calories'] as num?)?.toInt(),
      servingQuantity: (json['servingQuantity'] as num?)?.toInt(),
      mainIngredients:
          (json['mainIngredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      foodCategory: json['foodCategory'] as String?,
      sustainabilityNote: json['sustainabilityNote'] as String?,
    );

Map<String, dynamic> _$InventoryItemToJson(_InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'quantity': instance.quantity,
      'unitType': instance.unitType,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'storageType': _$StorageTypeEnumMap[instance.storageType]!,
      'category': _$ItemCategoryEnumMap[instance.category]!,
      'imageUrl': instance.imageUrl,
      'tips': instance.tips,
      'addedDate': instance.addedDate.toIso8601String(),
      'description': instance.description,
      'calories': instance.calories,
      'servingQuantity': instance.servingQuantity,
      'mainIngredients': instance.mainIngredients,
      'foodCategory': instance.foodCategory,
      'sustainabilityNote': instance.sustainabilityNote,
    };

const _$StorageTypeEnumMap = {
  StorageType.refrigerated: 'refrigerated',
  StorageType.frozen: 'frozen',
  StorageType.dry: 'dry',
  StorageType.pantry: 'pantry',
  StorageType.cellar: 'cellar',
  StorageType.ambient: 'ambient',
  StorageType.sunlight: 'sunlight',
  StorageType.wineCellar: 'wineCellar',
  StorageType.bulk: 'bulk',
  StorageType.fermentation: 'fermentation',
};

const _$ItemCategoryEnumMap = {
  ItemCategory.food: 'food',
  ItemCategory.ingredient: 'ingredient',
  ItemCategory.all: 'all',
};
