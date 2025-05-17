/// Representa las métricas de impacto ambiental del usuario
class ImpactMetrics {
  /// Cantidad de alimentos salvados en kilogramos
  final double foodSavedKg;

  /// Emisiones de CO2 evitadas en kilogramos
  final double co2AvoidedKg;

  /// Litros de agua ahorrados en la producción
  final double waterSavedLiters;

  /// Nivel actual del usuario (1-10)
  final int level;

  /// Progreso hacia el siguiente nivel (0.0 - 1.0)
  final double levelProgress;

  /// Fecha de la última actualización
  final DateTime lastUpdated;

  /// Lista de insignias obtenidas
  final List<UserBadge> badges;

  /// Lista de logros alcanzados
  final List<UserAchievement> achievements;

  const ImpactMetrics({
    required this.foodSavedKg,
    required this.co2AvoidedKg,
    required this.waterSavedLiters,
    required this.level,
    required this.levelProgress,
    required this.lastUpdated,
    required this.badges,
    required this.achievements,
  });

  /// Crea una instancia con valores por defecto
  factory ImpactMetrics.empty() {
    return ImpactMetrics(
      foodSavedKg: 0,
      co2AvoidedKg: 0,
      waterSavedLiters: 0,
      level: 1,
      levelProgress: 0,
      lastUpdated: DateTime.now(),
      badges: [],
      achievements: [],
    );
  }

  /// Convierte las métricas a un mapa
  Map<String, dynamic> toMap() {
    return {
      'foodSavedKg': foodSavedKg,
      'co2AvoidedKg': co2AvoidedKg,
      'waterSavedLiters': waterSavedLiters,
      'level': level,
      'levelProgress': levelProgress,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'badges': badges.map((b) => b.toMap()).toList(),
      'achievements': achievements.map((a) => a.toMap()).toList(),
    };
  }

  /// Crea una instancia de ImpactMetrics desde un mapa
  factory ImpactMetrics.fromMap(Map<String, dynamic> map) {
    return ImpactMetrics(
      foodSavedKg: map['foodSavedKg'] ?? 0.0,
      co2AvoidedKg: map['co2AvoidedKg'] ?? 0.0,
      waterSavedLiters: map['waterSavedLiters'] ?? 0.0,
      level: map['level'] ?? 1,
      levelProgress: map['levelProgress'] ?? 0.0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      badges:
          (map['badges'] as List?)?.map((b) => UserBadge.fromMap(b)).toList() ??
          [],
      achievements:
          (map['achievements'] as List?)
              ?.map((a) => UserAchievement.fromMap(a))
              .toList() ??
          [],
    );
  }

  /// Crea una copia de las métricas con valores actualizados
  ImpactMetrics copyWith({
    double? foodSavedKg,
    double? co2AvoidedKg,
    double? waterSavedLiters,
    int? level,
    double? levelProgress,
    DateTime? lastUpdated,
    List<UserBadge>? badges,
    List<UserAchievement>? achievements,
  }) {
    return ImpactMetrics(
      foodSavedKg: foodSavedKg ?? this.foodSavedKg,
      co2AvoidedKg: co2AvoidedKg ?? this.co2AvoidedKg,
      waterSavedLiters: waterSavedLiters ?? this.waterSavedLiters,
      level: level ?? this.level,
      levelProgress: levelProgress ?? this.levelProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      badges: badges ?? this.badges,
      achievements: achievements ?? this.achievements,
    );
  }
}

/// Representa una insignia que el usuario ha ganado
class UserBadge {
  /// Identificador único de la insignia
  final String id;

  /// Título de la insignia
  final String title;

  /// Descripción de la insignia
  final String description;

  /// Ruta del icono de la insignia
  final String iconPath;

  /// Fecha en que se obtuvo la insignia
  final DateTime obtainedAt;

  const UserBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.obtainedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'obtainedAt': obtainedAt.millisecondsSinceEpoch,
    };
  }

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconPath: map['iconPath'] ?? '',
      obtainedAt: DateTime.fromMillisecondsSinceEpoch(
        map['obtainedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

/// Representa un logro que el usuario ha alcanzado
class UserAchievement {
  /// Identificador único del logro
  final String id;

  /// Título del logro
  final String title;

  /// Descripción del logro
  final String description;

  /// Valor numérico del logro
  final double value;

  /// Fecha en que se alcanzó el logro
  final DateTime achievedAt;

  const UserAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.value,
    required this.achievedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'value': value,
      'achievedAt': achievedAt.millisecondsSinceEpoch,
    };
  }

  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      value: map['value'] ?? 0.0,
      achievedAt: DateTime.fromMillisecondsSinceEpoch(
        map['achievedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
