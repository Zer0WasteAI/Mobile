import 'package:flutter/foundation.dart';

@immutable
class RecognizedItem {
  final String
  id; // Unique ID for this instance, e.g., generated UUID or from API
  final String name;
  final String? imageUrl; // Renamed from 'imagen' for convention
  final int quantity;
  final String? expiryDate; // Renamed from 'fecha_de_caducidad'
  final String? category; // Optional category (e.g., fruit, vegetable, dairy)

  // New fields for detailed ingredient/food information
  final String? typeUnit; // e.g., 'gramos', 'unidades', 'litros'
  final int? expirationTime; // e.g., 1, 7, 30
  final String? timeUnit; // e.g., 'Días', 'Semanas', 'Meses'
  final String? storageType; // e.g., 'Refrigerado', 'Ambiente'
  final String? tips; // Storage/preparation tips

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
    this.allergyAlert = false,
    this.allergens = const [],
  });

  // Factory constructor for creating from JSON map
  factory RecognizedItem.fromJson(Map<String, dynamic> json, String id) {
    return RecognizedItem(
      id: id,
      name: json['nombre'] as String? ?? 'Desconocido', // Handle potential null
      imageUrl: json['imagen'] as String?,
      quantity: json['cantidad'] as int? ?? 1, // Default quantity if null
      expiryDate: json['fecha_de_caducidad'] as String?,
      category: json['category'] as String?,
      typeUnit: json['typeUnit'] as String?,
      expirationTime: json['expiration_time'] as int?,
      timeUnit: json['timeUnit'] as String?,
      storageType: json['storageType'] as String?,
      tips: json['tips'] as String?,
      allergyAlert: json['allergyAlert'] as bool? ?? false,
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  // Helper method to create a copy with updated quantity
  RecognizedItem copyWith({
    int? quantity,
    String? expiryDate,
    String? typeUnit,
    int? expirationTime,
    String? timeUnit,
    String? storageType,
    String? tips,
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
