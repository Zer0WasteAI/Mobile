class FoodDetail {
  final String name;
  final String category;
  final int servingQuantity;
  final int calories;
  final String? description; // ⚠️ NULLABLE - puede ser null
  final String storageType;
  final String? tips; // ⚠️ NULLABLE - puede ser null
  final String? imagePath; // ⚠️ NULLABLE - puede ser null
  final String addedAt; // ⚠️ CRUCIAL: Identificador único junto con name
  final String expirationDate;
  final int expirationTime;
  final String timeUnit;
  final int daysToExpire;
  final bool isExpired;
  final List<String> mainIngredients;
  final double caloriesPerServing;
  final int totalCalories;
  final NutritionalAnalysis?
  nutritionalAnalysis; // ⚠️ NULLABLE - puede fallar generación con IA
  final List<ConsumptionIdea>?
  consumptionIdeas; // ⚠️ NULLABLE - puede fallar generación con IA
  final StorageAdvice?
  storageAdvice; // ⚠️ NULLABLE - puede fallar generación con IA
  final List<String> enrichedWith;
  final DateTime fetchedAt;

  FoodDetail({
    required this.name,
    required this.category,
    required this.servingQuantity,
    required this.calories,
    this.description, // Optional
    required this.storageType,
    this.tips, // Optional
    this.imagePath, // Optional
    required this.addedAt, // ⚠️ SIEMPRE requerido para identificación única
    required this.expirationDate,
    required this.expirationTime,
    required this.timeUnit,
    required this.daysToExpire,
    required this.isExpired,
    required this.mainIngredients,
    required this.caloriesPerServing,
    required this.totalCalories,
    this.nutritionalAnalysis, // Optional
    this.consumptionIdeas, // Optional
    this.storageAdvice, // Optional
    required this.enrichedWith,
    required this.fetchedAt,
  });

  // 🎯 ID único para diferenciar foods con mismo nombre
  String get uniqueId => '${name}_$addedAt';

  // 🎯 Nombre para mostrar en UI cuando hay duplicados
  String get displayName {
    final date = DateTime.parse(addedAt);
    return '$name (${_formatDate(date)})';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  factory FoodDetail.fromJson(Map<String, dynamic> json) {
    return FoodDetail(
      name: json['name'],
      category: json['category'],
      servingQuantity: json['serving_quantity'],
      calories: json['calories'],
      description: json['description'], // Puede ser null
      storageType: json['storage_type'],
      tips: json['tips'], // Puede ser null
      imagePath: json['image_path'], // Puede ser null
      addedAt: json['added_at'], // ⚠️ Clave para identificación única
      expirationDate: json['expiration_date'],
      expirationTime: json['expiration_time'],
      timeUnit: json['time_unit'],
      daysToExpire: json['days_to_expire'],
      isExpired: json['is_expired'],
      mainIngredients: List<String>.from(json['main_ingredients']),
      caloriesPerServing: (json['calories_per_serving'] as num).toDouble(),
      totalCalories: json['total_calories'],
      nutritionalAnalysis:
          json['nutritional_analysis'] != null
              ? NutritionalAnalysis.fromJson(json['nutritional_analysis'])
              : null,
      consumptionIdeas:
          json['consumption_ideas'] != null
              ? (json['consumption_ideas'] as List)
                  .map((idea) => ConsumptionIdea.fromJson(idea))
                  .toList()
              : null,
      storageAdvice:
          json['storage_advice'] != null
              ? StorageAdvice.fromJson(json['storage_advice'])
              : null,
      enrichedWith: List<String>.from(json['enriched_with']),
      fetchedAt: DateTime.parse(json['fetched_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'serving_quantity': servingQuantity,
      'calories': calories,
      'description': description,
      'storage_type': storageType,
      'tips': tips,
      'image_path': imagePath,
      'added_at': addedAt,
      'expiration_date': expirationDate,
      'expiration_time': expirationTime,
      'time_unit': timeUnit,
      'days_to_expire': daysToExpire,
      'is_expired': isExpired,
      'main_ingredients': mainIngredients,
      'calories_per_serving': caloriesPerServing,
      'total_calories': totalCalories,
      'nutritional_analysis': nutritionalAnalysis?.toJson(),
      'consumption_ideas':
          consumptionIdeas?.map((idea) => idea.toJson()).toList(),
      'storage_advice': storageAdvice?.toJson(),
      'enriched_with': enrichedWith,
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }
}

class NutritionalAnalysis {
  final Macronutrients? macronutrients; // ⚠️ NULLABLE
  final List<String>? vitaminsMinerals; // ⚠️ NULLABLE
  final String? healthBenefits; // ⚠️ NULLABLE
  final String? dietaryConsiderations; // ⚠️ NULLABLE

  NutritionalAnalysis({
    this.macronutrients,
    this.vitaminsMinerals,
    this.healthBenefits,
    this.dietaryConsiderations,
  });

  factory NutritionalAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionalAnalysis(
      macronutrients:
          json['macronutrients'] != null
              ? Macronutrients.fromJson(json['macronutrients'])
              : null,
      vitaminsMinerals:
          json['vitamins_minerals'] != null
              ? List<String>.from(json['vitamins_minerals'])
              : null,
      healthBenefits: json['health_benefits'],
      dietaryConsiderations: json['dietary_considerations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'macronutrients': macronutrients?.toJson(),
      'vitamins_minerals': vitaminsMinerals,
      'health_benefits': healthBenefits,
      'dietary_considerations': dietaryConsiderations,
    };
  }
}

class Macronutrients {
  final String? carbohydrates; // ⚠️ NULLABLE
  final String? proteins; // ⚠️ NULLABLE
  final String? fats; // ⚠️ NULLABLE

  Macronutrients({this.carbohydrates, this.proteins, this.fats});

  factory Macronutrients.fromJson(Map<String, dynamic> json) {
    return Macronutrients(
      carbohydrates: json['carbohydrates'],
      proteins: json['proteins'],
      fats: json['fats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'carbohydrates': carbohydrates, 'proteins': proteins, 'fats': fats};
  }
}

class ConsumptionIdea {
  final String title;
  final String description;
  final String type;

  ConsumptionIdea({
    required this.title,
    required this.description,
    required this.type,
  });

  factory ConsumptionIdea.fromJson(Map<String, dynamic> json) {
    return ConsumptionIdea(
      title: json['title'],
      description: json['description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'type': type};
  }
}

class StorageAdvice {
  final String? optimalTemperature; // ⚠️ NULLABLE
  final String? reheatingTips; // ⚠️ NULLABLE
  final String? shelfLifeExtension; // ⚠️ NULLABLE
  final String? qualityIndicators; // ⚠️ NULLABLE

  StorageAdvice({
    this.optimalTemperature,
    this.reheatingTips,
    this.shelfLifeExtension,
    this.qualityIndicators,
  });

  factory StorageAdvice.fromJson(Map<String, dynamic> json) {
    return StorageAdvice(
      optimalTemperature: json['optimal_temperature'],
      reheatingTips: json['reheating_tips'],
      shelfLifeExtension: json['shelf_life_extension'],
      qualityIndicators: json['quality_indicators'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optimal_temperature': optimalTemperature,
      'reheating_tips': reheatingTips,
      'shelf_life_extension': shelfLifeExtension,
      'quality_indicators': qualityIndicators,
    };
  }
}
