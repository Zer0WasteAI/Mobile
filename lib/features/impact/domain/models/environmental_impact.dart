import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class EnvironmentalImpact extends Equatable {
  final String recipeUid;
  final String recipeTitle;
  final double carbonFootprint;
  final double waterFootprint;
  final double energyFootprint;
  final double economicCost;
  final String unitCarbon;
  final String unitWater;
  final String unitEnergy;
  final String unitCost;
  final bool isCooked;
  final DateTime? savedAt;

  const EnvironmentalImpact({
    required this.recipeUid,
    required this.recipeTitle,
    required this.carbonFootprint,
    required this.waterFootprint,
    required this.energyFootprint,
    required this.economicCost,
    required this.unitCarbon,
    required this.unitWater,
    required this.unitEnergy,
    required this.unitCost,
    required this.isCooked,
    this.savedAt,
  });

  factory EnvironmentalImpact.fromJson(Map<String, dynamic> json) {
    return EnvironmentalImpact(
      recipeUid: json['recipe_uid'],
      recipeTitle: json['recipe_title'],
      carbonFootprint: (json['carbon_footprint'] as num).toDouble(),
      waterFootprint: (json['water_footprint'] as num).toDouble(),
      energyFootprint: (json['energy_footprint'] as num).toDouble(),
      economicCost: (json['economic_cost'] as num).toDouble(),
      unitCarbon: json['unit_carbon'],
      unitWater: json['unit_water'],
      unitEnergy: json['unit_energy'],
      unitCost: json['unit_cost'],
      isCooked: json['is_cooked'],
      savedAt:
          json['saved_at'] != null ? DateTime.parse(json['saved_at']) : null,
    );
  }

  // Formatted getters for better display
  String get formattedCost {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );
    return currencyFormat.format(economicCost);
  }

  String get formattedCarbonFootprint {
    return '${carbonFootprint.toStringAsFixed(1)} $unitCarbon';
  }

  String get formattedWaterFootprint {
    return '${waterFootprint.toStringAsFixed(0)} $unitWater';
  }

  String get formattedEnergyFootprint {
    return '${energyFootprint.toStringAsFixed(1)} $unitEnergy';
  }

  String get formattedDate {
    return savedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'es_PE').format(savedAt!)
        : 'Fecha no disponible';
  }

  @override
  List<Object?> get props => [
    recipeUid,
    recipeTitle,
    carbonFootprint,
    waterFootprint,
    energyFootprint,
    economicCost,
    unitCarbon,
    unitWater,
    unitEnergy,
    unitCost,
    isCooked,
    savedAt,
  ];
}

class EnvironmentalCalculations extends Equatable {
  final List<EnvironmentalImpact> calculations;
  final int count;

  const EnvironmentalCalculations({
    required this.calculations,
    required this.count,
  });

  factory EnvironmentalCalculations.fromJson(Map<String, dynamic> json) {
    return EnvironmentalCalculations(
      calculations:
          (json['calculations'] as List)
              .map(
                (i) => EnvironmentalImpact.fromJson(i as Map<String, dynamic>),
              )
              .toList(),
      count: json['count'],
    );
  }

  double get totalEconomicCost {
    return calculations.fold(0.0, (sum, calc) => sum + calc.economicCost);
  }

  String get formattedTotalCost {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/',
      decimalDigits: 2,
    );
    return currencyFormat.format(totalEconomicCost);
  }

  @override
  List<Object?> get props => [calculations, count];
}
