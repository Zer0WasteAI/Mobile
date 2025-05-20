import 'package:flutter/foundation.dart';

@immutable
class Allergy {
  final String emoji;
  final String name;
  final bool isCustom;

  const Allergy({
    required this.emoji,
    required this.name,
    this.isCustom = false,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'name': name, 'isCustom': isCustom};
  }

  // Display string combines emoji and name
  String get displayName => '$emoji $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Allergy &&
          runtimeType == other.runtimeType &&
          emoji == other.emoji &&
          name == other.name;

  @override
  int get hashCode => emoji.hashCode ^ name.hashCode;
}
