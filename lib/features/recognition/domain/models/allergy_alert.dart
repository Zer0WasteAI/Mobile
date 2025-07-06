class AllergyAlert {
  final String item;
  final List<String> allergens;
  final String message;
  final double confidence;

  const AllergyAlert({
    required this.item,
    required this.allergens,
    required this.message,
    required this.confidence,
  });

  factory AllergyAlert.fromJson(Map<String, dynamic> json) {
    return AllergyAlert(
      item: json['item'] as String,
      allergens: List<String>.from(json['allergens'] as List),
      message: json['message'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'allergens': allergens,
      'message': message,
      'confidence': confidence,
    };
  }
} 