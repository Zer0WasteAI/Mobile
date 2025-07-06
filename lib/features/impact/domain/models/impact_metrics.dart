/// Representa las métricas de impacto ambiental del usuario
class ImpactMetrics {
  /// Cantidad de alimentos salvados en kilogramos
  final double foodSavedKg;

  /// Emisiones de CO2 evitadas en kilogramos
  final double co2AvoidedKg;

  /// Litros de agua ahorrados en la producción
  final double waterSavedLiters;

  /// Fecha de la última actualización
  final DateTime lastUpdated;

  const ImpactMetrics({
    required this.foodSavedKg,
    required this.co2AvoidedKg,
    required this.waterSavedLiters,
    required this.lastUpdated,
  });

  /// Crea una instancia con valores por defecto
  factory ImpactMetrics.empty() {
    return ImpactMetrics(
      foodSavedKg: 0,
      co2AvoidedKg: 0,
      waterSavedLiters: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Convierte las métricas a un mapa
  Map<String, dynamic> toMap() {
    return {
      'foodSavedKg': foodSavedKg,
      'co2AvoidedKg': co2AvoidedKg,
      'waterSavedLiters': waterSavedLiters,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  /// Crea una instancia de ImpactMetrics desde un mapa
  factory ImpactMetrics.fromMap(Map<String, dynamic> map) {
    return ImpactMetrics(
      foodSavedKg: map['foodSavedKg'] ?? 0.0,
      co2AvoidedKg: map['co2AvoidedKg'] ?? 0.0,
      waterSavedLiters: map['waterSavedLiters'] ?? 0.0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Crea una copia de las métricas con valores actualizados
  ImpactMetrics copyWith({
    double? foodSavedKg,
    double? co2AvoidedKg,
    double? waterSavedLiters,
    DateTime? lastUpdated,
  }) {
    return ImpactMetrics(
      foodSavedKg: foodSavedKg ?? this.foodSavedKg,
      co2AvoidedKg: co2AvoidedKg ?? this.co2AvoidedKg,
      waterSavedLiters: waterSavedLiters ?? this.waterSavedLiters,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
