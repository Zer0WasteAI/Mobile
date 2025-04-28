import 'package:flutter/foundation.dart';

// --- Data Model --- (Moved from preferred_food_type_screen.dart)
@immutable // Good practice for models used in immutable state
class FoodType {
  final String emoji;
  final String name;

  const FoodType({required this.emoji, required this.name});

  // Override equality and hashCode for Set operations
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodType &&
          runtimeType == other.runtimeType &&
          emoji == other.emoji &&
          name == other.name;

  @override
  int get hashCode => emoji.hashCode ^ name.hashCode;

  factory FoodType.fromJson(Map<String, dynamic> json) {
    return FoodType(
      emoji: json['emoji'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'emoji': emoji, 'name': name};
}
