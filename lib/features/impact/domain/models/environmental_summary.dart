import 'package:equatable/equatable.dart';

class EnvironmentalSummary extends Equatable {
  final double totalCarbonFootprint;
  final double totalWaterFootprint;
  final double totalEnergyFootprint;
  final double totalEconomicCost;
  final String unitCarbon;
  final String unitWater;
  final String unitEnergy;
  final String unitCost;

  const EnvironmentalSummary({
    required this.totalCarbonFootprint,
    required this.totalWaterFootprint,
    required this.totalEnergyFootprint,
    required this.totalEconomicCost,
    required this.unitCarbon,
    required this.unitWater,
    required this.unitEnergy,
    required this.unitCost,
  });

  factory EnvironmentalSummary.fromJson(Map<String, dynamic> json) {
    return EnvironmentalSummary(
      totalCarbonFootprint: (json['total_carbon_footprint'] as num).toDouble(),
      totalWaterFootprint: (json['total_water_footprint'] as num).toDouble(),
      totalEnergyFootprint: (json['total_energy_footprint'] as num).toDouble(),
      totalEconomicCost: (json['total_economic_cost'] as num).toDouble(),
      unitCarbon: json['unit_carbon'],
      unitWater: json['unit_water'],
      unitEnergy: json['unit_energy'],
      unitCost: json['unit_cost'],
    );
  }

  @override
  List<Object?> get props => [
    totalCarbonFootprint,
    totalWaterFootprint,
    totalEnergyFootprint,
    totalEconomicCost,
    unitCarbon,
    unitWater,
    unitEnergy,
    unitCost,
  ];
}
