import 'package:flutter/foundation.dart';

@immutable
class SpecialDiet {
  final String emoji;
  final String name;
  final bool isCustom; // To differentiate predefined from user-added

  const SpecialDiet({
    required this.emoji,
    required this.name,
    this.isCustom = false,
  });

  // From JSON factory
  factory SpecialDiet.fromJson(Map<String, dynamic> json) {
    return SpecialDiet(
      emoji: json['emoji'] as String? ?? '➕', // Default emoji if missing
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  // To JSON method (useful for saving custom diets)
  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'name': name, 'isCustom': isCustom};
  }

  // Override equality and hashCode for Set operations
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialDiet &&
          runtimeType == other.runtimeType &&
          emoji == other.emoji &&
          name == other.name &&
          isCustom == other.isCustom;

  @override
  int get hashCode => emoji.hashCode ^ name.hashCode ^ isCustom.hashCode;

  @override
  String toString() {
    return 'SpecialDiet(emoji: $emoji, name: $name, isCustom: $isCustom)';
  }
}
