// Temporary simple model without freezed for testing
class FavoriteRecipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<FavoriteIngredient> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final String? imagePath;
  final String category;
  final List<String> tags;
  final String? mealType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FavoriteRecipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.imagePath,
    this.category = '',
    this.tags = const [],
    this.mealType,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'imagePath': imagePath,
      'category': category,
      'tags': tags,
      'mealType': mealType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipe(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => FavoriteIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      prepTime: json['prepTime'] as int,
      cookTime: json['cookTime'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      imagePath: json['imagePath'] as String?,
      category: json['category'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mealType: json['mealType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

class FavoriteIngredient {
  final String name;
  final double quantity;
  final String unit;

  const FavoriteIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory FavoriteIngredient.fromJson(Map<String, dynamic> json) {
    return FavoriteIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}