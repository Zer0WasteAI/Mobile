import 'package:flutter/foundation.dart';

/// Special diet model for displaying in selection screen
@immutable
class SpecialDiet {
  /// Constructor
  const SpecialDiet({
    required this.name,
    required this.emoji,
    this.isCustom = false,
  });

  /// Emoji representation
  final String emoji;

  /// Name of the diet
  final String name;

  /// Whether this is a custom diet added by user
  final bool isCustom;

  /// Create SpecialDiet from JSON object
  factory SpecialDiet.fromJson(Map<String, dynamic> json) {
    return SpecialDiet(
      emoji: json['emoji'] as String? ?? '🍽️',
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  /// Convert SpecialDiet to JSON
  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'name': name, 'isCustom': isCustom};
  }

  /// Display representation
  String get displayName => '$emoji $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecialDiet && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'SpecialDiet($emoji $name, isCustom: $isCustom)';
}
