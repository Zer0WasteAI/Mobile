import 'package:flutter/foundation.dart';

@immutable
class Allergy {
  final String emoji;
  final String name;

  const Allergy({required this.emoji, required this.name});

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      emoji: json['emoji'] as String,
      name: json['name'] as String,
    );
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
