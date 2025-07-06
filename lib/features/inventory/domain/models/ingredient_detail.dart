class IngredientDetail {
  final String name;
  final String typeUnit;
  final String storageType;
  final String? tips; // ⚠️ NULLABLE - puede ser null
  final String? imagePath; // ⚠️ NULLABLE - puede ser null
  final List<IngredientStack> stacks;
  final double totalQuantity;
  final int stackCount;
  final String?
  nearestExpiration; // ⚠️ NULLABLE - puede ser null si no hay stacks con fecha
  final EnvironmentalImpact?
  environmentalImpact; // ⚠️ NULLABLE - puede fallar generación con IA
  final List<UtilizationIdea>?
  utilizationIdeas; // ⚠️ NULLABLE - puede fallar generación con IA
  final ConsumptionAdvice?
  consumptionAdvice; // ⚠️ NULLABLE - puede fallar generación con IA
  final ConsumptionAdvice?
  beforeConsumptionAdvice; // ⚠️ NULLABLE - puede fallar generación con IA
  final List<String> enrichedWith;
  final DateTime fetchedAt;

  IngredientDetail({
    required this.name,
    required this.typeUnit,
    required this.storageType,
    this.tips, // Optional
    this.imagePath, // Optional
    required this.stacks,
    required this.totalQuantity,
    required this.stackCount,
    this.nearestExpiration, // Optional
    this.environmentalImpact, // Optional
    this.utilizationIdeas, // Optional
    this.consumptionAdvice, // Optional
    this.beforeConsumptionAdvice, // Optional
    required this.enrichedWith,
    required this.fetchedAt,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: json['name'],
      typeUnit: json['type_unit'],
      storageType: json['storage_type'],
      tips: json['tips'], // Puede ser null
      imagePath: json['image_path'], // Puede ser null
      stacks:
          (json['stacks'] as List)
              .map((stack) => IngredientStack.fromJson(stack))
              .toList(),
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      stackCount: json['stack_count'],
      nearestExpiration: json['nearest_expiration'], // Puede ser null
      environmentalImpact:
          json['environmental_impact'] != null
              ? EnvironmentalImpact.fromJson(json['environmental_impact'])
              : null,
      utilizationIdeas:
          json['utilization_ideas'] != null
              ? (json['utilization_ideas'] as List)
                  .map((idea) => UtilizationIdea.fromJson(idea))
                  .toList()
              : null,
      consumptionAdvice:
          json['consumption_advice'] != null
              ? ConsumptionAdvice.fromJson(json['consumption_advice'])
              : null,
      beforeConsumptionAdvice:
          json['before_consumption_advice'] != null
              ? ConsumptionAdvice.fromJson(json['before_consumption_advice'])
              : null,
      enrichedWith: List<String>.from(json['enriched_with']),
      fetchedAt: DateTime.parse(json['fetched_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type_unit': typeUnit,
      'storage_type': storageType,
      'tips': tips,
      'image_path': imagePath,
      'stacks': stacks.map((stack) => stack.toJson()).toList(),
      'total_quantity': totalQuantity,
      'stack_count': stackCount,
      'nearest_expiration': nearestExpiration,
      'environmental_impact': environmentalImpact?.toJson(),
      'utilization_ideas':
          utilizationIdeas?.map((idea) => idea.toJson()).toList(),
      'consumption_advice': consumptionAdvice?.toJson(),
      'before_consumption_advice': beforeConsumptionAdvice?.toJson(),
      'enriched_with': enrichedWith,
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }
}

class IngredientStack {
  final double quantity;
  final String typeUnit;
  final String expirationDate;
  final String addedAt;
  final int daysToExpire;
  final bool isExpired;

  IngredientStack({
    required this.quantity,
    required this.typeUnit,
    required this.expirationDate,
    required this.addedAt,
    required this.daysToExpire,
    required this.isExpired,
  });

  factory IngredientStack.fromJson(Map<String, dynamic> json) {
    return IngredientStack(
      quantity: (json['quantity'] as num).toDouble(),
      typeUnit: json['type_unit'],
      expirationDate: json['expiration_date'],
      addedAt: json['added_at'],
      daysToExpire: json['days_to_expire'],
      isExpired: json['is_expired'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'type_unit': typeUnit,
      'expiration_date': expirationDate,
      'added_at': addedAt,
      'days_to_expire': daysToExpire,
      'is_expired': isExpired,
    };
  }
}

class EnvironmentalImpact {
  final CarbonFootprint? carbonFootprint; // ⚠️ NULLABLE
  final WaterFootprint? waterFootprint; // ⚠️ NULLABLE
  final String? sustainabilityMessage; // ⚠️ NULLABLE

  EnvironmentalImpact({
    this.carbonFootprint,
    this.waterFootprint,
    this.sustainabilityMessage,
  });

  factory EnvironmentalImpact.fromJson(Map<String, dynamic> json) {
    return EnvironmentalImpact(
      carbonFootprint:
          json['carbon_footprint'] != null
              ? CarbonFootprint.fromJson(json['carbon_footprint'])
              : null,
      waterFootprint:
          json['water_footprint'] != null
              ? WaterFootprint.fromJson(json['water_footprint'])
              : null,
      sustainabilityMessage: json['sustainability_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbon_footprint': carbonFootprint?.toJson(),
      'water_footprint': waterFootprint?.toJson(),
      'sustainability_message': sustainabilityMessage,
    };
  }
}

class CarbonFootprint {
  final double value;
  final String unit;
  final String description;

  CarbonFootprint({
    required this.value,
    required this.unit,
    required this.description,
  });

  factory CarbonFootprint.fromJson(Map<String, dynamic> json) {
    return CarbonFootprint(
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit, 'description': description};
  }
}

class WaterFootprint {
  final double value;
  final String unit;
  final String description;

  WaterFootprint({
    required this.value,
    required this.unit,
    required this.description,
  });

  factory WaterFootprint.fromJson(Map<String, dynamic> json) {
    return WaterFootprint(
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit, 'description': description};
  }
}

class UtilizationIdea {
  final String title;
  final String description;
  final String type;

  UtilizationIdea({
    required this.title,
    required this.description,
    required this.type,
  });

  factory UtilizationIdea.fromJson(Map<String, dynamic> json) {
    return UtilizationIdea(
      title: json['title'],
      description: json['description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'type': type};
  }
}

class ConsumptionAdvice {
  final String? optimalConsumption; // ⚠️ NULLABLE
  final String? preparationTips; // ⚠️ NULLABLE
  final String? nutritionalBenefits; // ⚠️ NULLABLE

  ConsumptionAdvice({
    this.optimalConsumption,
    this.preparationTips,
    this.nutritionalBenefits,
  });

  factory ConsumptionAdvice.fromJson(Map<String, dynamic> json) {
    return ConsumptionAdvice(
      optimalConsumption: json['optimal_consumption'],
      preparationTips: json['preparation_tips'],
      nutritionalBenefits: json['nutritional_benefits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optimal_consumption': optimalConsumption,
      'preparation_tips': preparationTips,
      'nutritional_benefits': nutritionalBenefits,
    };
  }
}
