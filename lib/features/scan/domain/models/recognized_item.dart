// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

@immutable
class RecognizedItem {
  final String
  id; // Unique ID for this instance, e.g., generated UUID or from API
  final String name;
  final String? imageUrl; // Renamed from 'imagen' for convention
  final double quantity;
  final String? expiryDate; // Renamed from 'fecha_de_caducidad'
  final String? category; // Optional category (e.g., fruit, vegetable, dairy)

  // New fields for detailed ingredient/food information
  final String? typeUnit; // e.g., 'gramos', 'unidades', 'litros'
  final int? expirationTime; // e.g., 1, 7, 30
  final String? timeUnit; // e.g., 'Días', 'Semanas', 'Meses'
  final String? storageType; // e.g., 'Refrigerado', 'Ambiente'
  final String? tips; // Storage/preparation tips
  final String? addedAt; // When the item was added

  // Allergy alert fields
  final bool allergyAlert; // Whether this item triggers an allergy alert
  final List<String> allergens; // List of allergens in this item

  const RecognizedItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity, // Quantity now required, will come from JSON
    this.expiryDate,
    this.category,
    this.typeUnit,
    this.expirationTime,
    this.timeUnit,
    this.storageType,
    this.tips,
    this.addedAt,
    this.allergyAlert = false,
    this.allergens = const [],
  });

  // Factory constructor for creating from JSON map
  factory RecognizedItem.fromJson(Map<String, dynamic> json, String id) {
    // DEBUG: Log the raw JSON to see what fields are actually coming from the API
    print('🔍 DEBUG RecognizedItem.fromJson - id: $id');
    print('🔍 DEBUG RecognizedItem.fromJson - json: $json');

    // API sends fields in English
    final expiryDate = json['expiration_date'] as String?;
    print('🔍 DEBUG RecognizedItem.fromJson - expiryDate: $expiryDate');

    return RecognizedItem(
      id: id,
      name:
          json['name'] as String? ??
          'Desconocido', // API uses 'name', not 'nombre'
      imageUrl:
          json['image_path'] as String?, // API uses 'image_path', not 'imagen'
      quantity:
          (json['quantity'] as num?)?.toDouble() ??
          1.0, // API uses 'quantity', supports double
      expiryDate: expiryDate, // API uses 'expiration_date'
      category: json['category'] as String?,
      typeUnit: json['type_unit'] as String?, // API uses 'type_unit'
      expirationTime:
          json['expiration_time'] as int?, // API uses 'expiration_time'
      timeUnit: json['time_unit'] as String?, // API uses 'time_unit'
      storageType: json['storage_type'] as String?, // API uses 'storage_type'
      tips: json['tips'] as String?, // API uses 'tips'
      addedAt: json['added_at'] as String?, // API uses 'added_at'
      allergyAlert: json['allergyAlert'] as bool? ?? false,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  // Static method to parse the new JSON format with ingredients wrapper
  static List<RecognizedItem> fromJsonResponse(Map<String, dynamic> response) {
    print('🔍 DEBUG RecognizedItem.fromJsonResponse - response: $response');

    final ingredientsList = response['ingredients'] as List<dynamic>?;
    if (ingredientsList == null) {
      print('🔍 DEBUG RecognizedItem.fromJsonResponse - No ingredients found');
      return [];
    }

    return ingredientsList.asMap().entries.map((entry) {
      final index = entry.key;
      final ingredientJson = entry.value as Map<String, dynamic>;
      final id =
          'ingredient_$index'; // Generate a unique ID for each ingredient
      return RecognizedItem.fromJson(ingredientJson, id);
    }).toList();
  }

  // Helper method to create a copy with updated quantity
  RecognizedItem copyWith({
    double? quantity,
    String? expiryDate,
    String? typeUnit,
    int? expirationTime,
    String? timeUnit,
    String? storageType,
    String? tips,
    String? addedAt,
    bool? allergyAlert,
    List<String>? allergens,
  }) {
    return RecognizedItem(
      id: id,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category,
      typeUnit: typeUnit ?? this.typeUnit,
      expirationTime: expirationTime ?? this.expirationTime,
      timeUnit: timeUnit ?? this.timeUnit,
      storageType: storageType ?? this.storageType,
      tips: tips ?? this.tips,
      addedAt: addedAt ?? this.addedAt,
      allergyAlert: allergyAlert ?? this.allergyAlert,
      allergens: allergens ?? this.allergens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecognizedItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
