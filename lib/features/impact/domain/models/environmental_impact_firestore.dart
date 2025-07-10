import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Modelo para el impacto ambiental almacenado en Firestore
class EnvironmentalImpactFirestore extends Equatable {
  final String id;
  final String recipeTitle;
  final String recipeName;
  final double co2Emissions;
  final double waterUsage;
  final double sustainabilityScore;
  final double wastePreventionScore;
  final double transportationImpact;
  final int localIngredients;
  final int needToBuy;
  final bool isCooked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const EnvironmentalImpactFirestore({
    required this.id,
    required this.recipeTitle,
    required this.recipeName,
    required this.co2Emissions,
    required this.waterUsage,
    required this.sustainabilityScore,
    required this.wastePreventionScore,
    required this.transportationImpact,
    required this.localIngredients,
    required this.needToBuy,
    required this.isCooked,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  /// Crear desde los datos calculados localmente
  factory EnvironmentalImpactFirestore.fromLocal({
    required String recipeTitle,
    required Map<String, dynamic> impactData,
    required String userId,
    String? id,
  }) {
    final now = DateTime.now();
    return EnvironmentalImpactFirestore(
      id: id ?? '', // Se asignará automáticamente por Firestore
      recipeTitle: recipeTitle,
      recipeName: recipeTitle,
      co2Emissions: (impactData['co2Emissions'] as double? ?? 0.0),
      waterUsage: (impactData['waterUsage'] as double? ?? 0.0),
      sustainabilityScore: (impactData['sustainabilityScore'] as double? ?? 0.0),
      wastePreventionScore: (impactData['wastePreventionScore'] as double? ?? 0.0),
      transportationImpact: (impactData['transportationImpact'] as double? ?? 0.0),
      localIngredients: (impactData['localIngredients'] as int? ?? 0),
      needToBuy: (impactData['needToBuy'] as int? ?? 0),
      isCooked: true, // Siempre true cuando se registra desde la app
      createdAt: now,
      updatedAt: now,
      userId: userId,
    );
  }

  /// Crear desde documento de Firestore
  factory EnvironmentalImpactFirestore.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return EnvironmentalImpactFirestore(
      id: doc.id,
      recipeTitle: data['recipeTitle'] ?? '',
      recipeName: data['recipeName'] ?? data['recipeTitle'] ?? '',
      co2Emissions: (data['co2Emissions'] as num?)?.toDouble() ?? 0.0,
      waterUsage: (data['waterUsage'] as num?)?.toDouble() ?? 0.0,
      sustainabilityScore: (data['sustainabilityScore'] as num?)?.toDouble() ?? 0.0,
      wastePreventionScore: (data['wastePreventionScore'] as num?)?.toDouble() ?? 0.0,
      transportationImpact: (data['transportationImpact'] as num?)?.toDouble() ?? 0.0,
      localIngredients: (data['localIngredients'] as num?)?.toInt() ?? 0,
      needToBuy: (data['needToBuy'] as num?)?.toInt() ?? 0,
      isCooked: data['isCooked'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'recipeTitle': recipeTitle,
      'recipeName': recipeName,
      'co2Emissions': co2Emissions,
      'waterUsage': waterUsage,
      'sustainabilityScore': sustainabilityScore,
      'wastePreventionScore': wastePreventionScore,
      'transportationImpact': transportationImpact,
      'localIngredients': localIngredients,
      'needToBuy': needToBuy,
      'isCooked': isCooked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  /// Convertir al formato que usa el sistema local actual
  Map<String, dynamic> toLocalFormat() {
    return {
      'title': recipeTitle,
      'date': createdAt.toIso8601String(),
      'sustainabilityScore': sustainabilityScore,
      'co2Emissions': co2Emissions,
      'waterUsage': waterUsage,
      'wastePreventionScore': wastePreventionScore,
      'isCooked': isCooked,
      'isFromFirestore': true,
    };
  }

  // Getters formatteados para UI
  String get formattedDate {
    return DateFormat('dd MMM yyyy, HH:mm', 'es_PE').format(createdAt);
  }

  String get formattedCO2 {
    return '${co2Emissions.toStringAsFixed(1)} kg';
  }

  String get formattedWater {
    return '${waterUsage.toStringAsFixed(0)} L';
  }

  String get formattedSustainability {
    return '${sustainabilityScore.toStringAsFixed(0)}/100';
  }

  /// Copia con modificaciones
  EnvironmentalImpactFirestore copyWith({
    String? id,
    String? recipeTitle,
    String? recipeName,
    double? co2Emissions,
    double? waterUsage,
    double? sustainabilityScore,
    double? wastePreventionScore,
    double? transportationImpact,
    int? localIngredients,
    int? needToBuy,
    bool? isCooked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return EnvironmentalImpactFirestore(
      id: id ?? this.id,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeName: recipeName ?? this.recipeName,
      co2Emissions: co2Emissions ?? this.co2Emissions,
      waterUsage: waterUsage ?? this.waterUsage,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      wastePreventionScore: wastePreventionScore ?? this.wastePreventionScore,
      transportationImpact: transportationImpact ?? this.transportationImpact,
      localIngredients: localIngredients ?? this.localIngredients,
      needToBuy: needToBuy ?? this.needToBuy,
      isCooked: isCooked ?? this.isCooked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipeTitle,
        recipeName,
        co2Emissions,
        waterUsage,
        sustainabilityScore,
        wastePreventionScore,
        transportationImpact,
        localIngredients,
        needToBuy,
        isCooked,
        createdAt,
        updatedAt,
        userId,
      ];
}