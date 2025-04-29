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

  const RecognizedItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity, // Quantity now required, will come from JSON
    this.expiryDate,
    this.category,
  });

  // Factory constructor for creating from JSON map
  factory RecognizedItem.fromJson(Map<String, dynamic> json, String id) {
    return RecognizedItem(
      id: id,
      name: json['nombre'] as String? ?? 'Desconocido', // Handle potential null
      imageUrl: json['imagen'] as String?,
      quantity: json['cantidad'] as int? ?? 1, // Default quantity if null
      expiryDate: json['fecha_de_caducidad'] as String?,
      // category: json['category'] as String?, // Add if category is in JSON
    );
  }

  // Helper method to create a copy with updated quantity
  RecognizedItem copyWith({
    int? quantity,
    // Add other fields if needed
  }) {
    return RecognizedItem(
      id: id,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate,
      category: category,
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
