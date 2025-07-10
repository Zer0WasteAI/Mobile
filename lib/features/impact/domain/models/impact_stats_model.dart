/// Modelo para estadísticas de impacto ambiental
class ImpactStats {
  final double co2Emissions;
  final double waterUsage;
  final double sustainabilityScore;
  final double inventoryUsage;
  final double wastePreventionScore;
  final double transportationImpact;
  final int localIngredients;
  final int needToBuy;
  final int timestamp;

  ImpactStats({
    required this.co2Emissions,
    required this.waterUsage,
    required this.sustainabilityScore,
    required this.inventoryUsage,
    required this.wastePreventionScore,
    required this.transportationImpact,
    required this.localIngredients,
    required this.needToBuy,
    required this.timestamp,
  });

  /// Crear desde un mapa de datos
  factory ImpactStats.fromMap(Map<String, dynamic> map) {
    return ImpactStats(
      co2Emissions: map['co2Emissions'] as double? ?? 0.0,
      waterUsage: map['waterUsage'] as double? ?? 0.0,
      sustainabilityScore: map['sustainabilityScore'] as double? ?? 0.0,
      inventoryUsage: map['inventoryUsage'] as double? ?? 0.0,
      wastePreventionScore: map['wastePreventionScore'] as double? ?? 0.0,
      transportationImpact: map['transportationImpact'] as double? ?? 0.0,
      localIngredients: map['localIngredients'] as int? ?? 0,
      needToBuy: map['needToBuy'] as int? ?? 0,
      timestamp:
          map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convertir a un mapa de datos
  Map<String, dynamic> toMap() {
    return {
      'co2Emissions': co2Emissions,
      'waterUsage': waterUsage,
      'sustainabilityScore': sustainabilityScore,
      'inventoryUsage': inventoryUsage,
      'wastePreventionScore': wastePreventionScore,
      'transportationImpact': transportationImpact,
      'localIngredients': localIngredients,
      'needToBuy': needToBuy,
      'timestamp': timestamp,
    };
  }
}
