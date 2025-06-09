/// INFO: Model for tracking food consumption response
/// USAGE: Use to handle the response when marking food as consumed
/// ADVICE: Contains information about what was consumed and environmental impact
class ConsumptionTracking {
  final String? food; // ⚠️ NULLABLE - null if ingredient was consumed
  final double? consumedPortions; // ⚠️ NULLABLE - for ingredients use quantity
  final double? remainingPortions; // ⚠️ NULLABLE - food completely consumed
  final bool? foodRemoved; // ⚠️ NULLABLE - information optional
  final Map<String, dynamic>?
  foodDetails; // ⚠️ NULLABLE - additional details optional
  final String consumptionDate; // Date when the food was consumed
  final Map<String, dynamic>?
  environmentalImpact; // ⚠️ NULLABLE - environmental data
  final int? coinsEarned; // ⚠️ NULLABLE - eco coins earned from consumption

  ConsumptionTracking({
    this.food, // Optional
    this.consumedPortions, // Optional
    this.remainingPortions, // Optional
    this.foodRemoved, // Optional
    this.foodDetails, // Optional
    required this.consumptionDate,
    this.environmentalImpact, // Optional
    this.coinsEarned, // Optional
  });

  factory ConsumptionTracking.fromJson(Map<String, dynamic> json) {
    return ConsumptionTracking(
      food: json['food'],
      consumedPortions: json['consumed_portions']?.toDouble(),
      remainingPortions: json['remaining_portions']?.toDouble(),
      foodRemoved: json['food_removed'],
      foodDetails: json['food_details'],
      consumptionDate:
          json['consumption_date'] ?? DateTime.now().toIso8601String(),
      environmentalImpact: json['environmental_impact'],
      coinsEarned: json['coins_earned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'consumed_portions': consumedPortions,
      'remaining_portions': remainingPortions,
      'food_removed': foodRemoved,
      'food_details': foodDetails,
      'consumption_date': consumptionDate,
      'environmental_impact': environmentalImpact,
      'coins_earned': coinsEarned,
    };
  }

  /// Helper method to check if the food was completely consumed
  bool get isCompletelyConsumed =>
      remainingPortions == null || remainingPortions! <= 0;

  /// Helper method to get the food name for display
  String get displayFood => food ?? 'Food item';

  /// Helper method to get environmental impact summary
  String get environmentalSummary {
    if (environmentalImpact == null) {
      return 'Environmental impact data not available';
    }

    final co2Saved = environmentalImpact!['co2_saved']?.toString() ?? '0';
    final waterSaved = environmentalImpact!['water_saved']?.toString() ?? '0';

    return 'Saved $co2Saved kg CO2 and ${waterSaved}L water';
  }
}
