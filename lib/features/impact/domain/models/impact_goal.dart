/// Representa un objetivo de impacto ambiental del usuario
class ImpactGoal {
  /// Identificador único del objetivo
  final String id;

  /// Título del objetivo
  final String title;

  /// Descripción del objetivo
  final String description;

  /// Tipo de métrica del objetivo (alimentos, CO2, agua)
  final GoalMetricType metricType;

  /// Valor objetivo a alcanzar
  final double targetValue;

  /// Valor actual alcanzado
  final double currentValue;

  /// Fecha de inicio del objetivo
  final DateTime startDate;

  /// Fecha límite para completar el objetivo
  final DateTime? endDate;

  /// Si el objetivo está completado
  final bool isCompleted;

  /// Si el objetivo está activo actualmente
  final bool isActive;

  const ImpactGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.metricType,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
    this.isActive = true,
  });

  /// Calcula el progreso actual del objetivo (0.0 - 1.0)
  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  /// Verifica si el objetivo está vencido
  bool get isExpired =>
      endDate != null && DateTime.now().isAfter(endDate!) && !isCompleted;

  /// Crea una instancia de ImpactGoal desde un mapa
  factory ImpactGoal.fromMap(Map<String, dynamic> map) {
    return ImpactGoal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      metricType: GoalMetricType.values[map['metricType'] ?? 0],
      targetValue: map['targetValue'] ?? 0.0,
      currentValue: map['currentValue'] ?? 0.0,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        map['startDate'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      endDate:
          map['endDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
              : null,
      isCompleted: map['isCompleted'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  /// Convierte el objetivo a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'metricType': metricType.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'isActive': isActive,
    };
  }

  /// Crea una copia del objetivo con valores actualizados
  ImpactGoal copyWith({
    String? id,
    String? title,
    String? description,
    GoalMetricType? metricType,
    double? targetValue,
    double? currentValue,
    DateTime? startDate,
    DateTime? endDate,
    bool? endDateRemoved,
    bool? isCompleted,
    bool? isActive,
  }) {
    return ImpactGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      metricType: metricType ?? this.metricType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      startDate: startDate ?? this.startDate,
      endDate: endDateRemoved == true ? null : (endDate ?? this.endDate),
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Tipos de métricas para los objetivos
enum GoalMetricType {
  /// Alimentos salvados en kilogramos
  foodSaved,

  /// Emisiones de CO2 evitadas en kilogramos
  co2Avoided,

  /// Litros de agua ahorrados
  waterSaved,

  /// Número de veces que se ha cocinado con ingredientes próximos a vencer
  cookingWithExpiring,

  /// Número de ingredientes salvados
  ingredientsSaved,
}

/// Duración predefinida para objetivos
enum GoalDuration {
  /// Objetivo diario
  daily,

  /// Objetivo semanal
  weekly,

  /// Objetivo mensual
  monthly,

  /// Objetivo trimestral
  quarterly,

  /// Objetivo anual
  yearly,

  /// Objetivo sin límite de tiempo
  noLimit,
}
