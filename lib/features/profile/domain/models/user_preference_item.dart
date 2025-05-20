import 'package:flutter/foundation.dart';

/// Base class for user preference items (allergies, diets, etc.)
@immutable
class UserPreferenceItem {
  /// Constructor
  const UserPreferenceItem({
    required this.name,
    required this.emoji,
    this.isCustom = false,
  });

  /// The name of the preference item
  final String name;

  /// The emoji representing the item
  final String emoji;

  /// Whether this is a custom item added by the user
  final bool isCustom;

  /// Create from JSON
  factory UserPreferenceItem.fromJson(Map<String, dynamic> json) {
    return UserPreferenceItem(
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🍽️',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'emoji': emoji, 'isCustom': isCustom};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferenceItem &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'UserPreferenceItem(name: $name, emoji: $emoji, isCustom: $isCustom)';
}
