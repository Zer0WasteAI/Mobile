import 'package:flutter/foundation.dart';

/// User preferences entity
class UserPreferencesEntity {
  /// Constructor
  const UserPreferencesEntity({
    this.language = 'es',
    this.cookingLevel,
    this.allergies = const [],
    this.allergyItems = const [],
    this.specialDiets = const [],
    this.specialDietItems = const [],
    this.preferredFoodTypes = const [],
    this.preferredFoodTypeItems = const [],
  });

  /// User preferred language
  final String language;

  /// User's cooking level
  final String? cookingLevel;

  /// User's allergies (legacy or simple list)
  final List<String> allergies;

  /// User's allergies items with custom metadata
  final List<Map<String, dynamic>> allergyItems;

  /// User's special diets (legacy or simple list)
  final List<String> specialDiets;

  /// User's special diet items with custom metadata
  final List<Map<String, dynamic>> specialDietItems;

  /// User's preferred food types (legacy or simple list)
  final List<String> preferredFoodTypes;

  /// User's preferred food type items with custom metadata
  final List<Map<String, dynamic>> preferredFoodTypeItems;

  // Consider adding equality and hashCode if needed for comparisons
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferencesEntity &&
        other.language == language &&
        other.cookingLevel == cookingLevel &&
        listEquals(other.allergies, allergies) &&
        listEquals(other.allergyItems, allergyItems) &&
        listEquals(other.specialDiets, specialDiets) &&
        listEquals(other.specialDietItems, specialDietItems) &&
        listEquals(other.preferredFoodTypes, preferredFoodTypes) &&
        listEquals(other.preferredFoodTypeItems, preferredFoodTypeItems);
  }

  @override
  int get hashCode {
    return Object.hash(
      language,
      cookingLevel,
      Object.hashAll(allergies),
      Object.hashAll(allergyItems),
      Object.hashAll(specialDiets),
      Object.hashAll(specialDietItems),
      Object.hashAll(preferredFoodTypes),
      Object.hashAll(preferredFoodTypeItems),
    );
  }
}
