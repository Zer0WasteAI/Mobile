/// INFO: Model for AI-generated recipe response
/// USAGE: Use to handle the response when generating recipes from inventory
/// ADVICE: Contains complete recipe information including ingredients and instructions
class GeneratedRecipe {
  final String id;
  final String name;
  final List<RecipeIngredient> ingredients;
  final String instructions;

  const GeneratedRecipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
  });

  /// INFO: Create GeneratedRecipe from API JSON response
  /// IMPORTANT: Handles nullable fields and provides safe defaults
  factory GeneratedRecipe.fromJson(Map<String, dynamic> json) {
    final recipeData = json['recipe'] as Map<String, dynamic>;

    return GeneratedRecipe(
      id: recipeData['id'] as String,
      name: recipeData['name'] as String,
      instructions: recipeData['instructions'] as String,
      ingredients:
          (recipeData['ingredients'] as List<dynamic>)
              .map(
                (ingredient) => RecipeIngredient.fromJson(
                  ingredient as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  /// INFO: Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'recipe': {
        'id': id,
        'name': name,
        'instructions': instructions,
        'ingredients':
            ingredients.map((ingredient) => ingredient.toJson()).toList(),
      },
    };
  }

  /// Helper method to get total ingredients count
  int get totalIngredients => ingredients.length;

  /// Helper method to check if recipe has any allergens
  bool get hasAllergens =>
      ingredients.any((ingredient) => ingredient.allergens.isNotEmpty);

  /// Helper method to get all allergens in the recipe
  List<String> get allAllergens {
    final allergens = <String>{};
    for (final ingredient in ingredients) {
      allergens.addAll(ingredient.allergens);
    }
    return allergens.toList();
  }
}

/// INFO: Model for recipe ingredient details
/// USAGE: Represents individual ingredients within a generated recipe
class RecipeIngredient {
  final String name;
  final double quantity;
  final String typeUnit;
  final String storageType;
  final int expirationTime;
  final String timeUnit;
  final String? tips; // ⚠️ NULLABLE - tips optional
  final String? imagePath; // ⚠️ NULLABLE - image optional
  final String imageStatus;
  final String addedAt;
  final String expirationDate;
  final double confidence;
  final bool? allergyAlert; // ⚠️ NULLABLE - allergy info optional
  final List<String> allergens;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.typeUnit,
    required this.storageType,
    required this.expirationTime,
    required this.timeUnit,
    this.tips, // ⚠️ NULLABLE
    this.imagePath, // ⚠️ NULLABLE
    required this.imageStatus,
    required this.addedAt,
    required this.expirationDate,
    required this.confidence,
    this.allergyAlert, // ⚠️ NULLABLE
    required this.allergens,
  });

  /// INFO: Create RecipeIngredient from API JSON response
  /// IMPORTANT: Handles all nullable fields safely
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      typeUnit: json['type_unit'] as String,
      storageType: json['storage_type'] as String,
      expirationTime: json['expiration_time'] as int,
      timeUnit: json['time_unit'] as String,
      tips: json['tips'] as String?, // ⚠️ NULLABLE
      imagePath: json['image_path'] as String?, // ⚠️ NULLABLE
      imageStatus: json['image_status'] as String,
      addedAt: json['added_at'] as String,
      expirationDate: json['expiration_date'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allergyAlert: json['allergy_alert'] as bool?, // ⚠️ NULLABLE
      allergens:
          (json['allergens'] as List<dynamic>?)
              ?.map((allergen) => allergen as String)
              .toList() ??
          [], // Safe default for nullable list
    );
  }

  /// INFO: Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'type_unit': typeUnit,
      'storage_type': storageType,
      'expiration_time': expirationTime,
      'time_unit': timeUnit,
      'tips': tips, // ⚠️ NULLABLE - can be null
      'image_path': imagePath, // ⚠️ NULLABLE - can be null
      'image_status': imageStatus,
      'added_at': addedAt,
      'expiration_date': expirationDate,
      'confidence': confidence,
      'allergy_alert': allergyAlert, // ⚠️ NULLABLE - can be null
      'allergens': allergens,
    };
  }

  /// Helper method to check if ingredient is expiring soon
  bool get isExpiringSoon {
    final expiration = DateTime.parse(expirationDate);
    final now = DateTime.now();
    final daysUntilExpiration = expiration.difference(now).inDays;
    return daysUntilExpiration <= 3;
  }

  /// Helper method to check if ingredient is expired
  bool get isExpired {
    final expiration = DateTime.parse(expirationDate);
    return DateTime.now().isAfter(expiration);
  }

  /// Helper method to get display quantity with unit
  String get displayQuantity => '$quantity $typeUnit';
}
