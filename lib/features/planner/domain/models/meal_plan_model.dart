class MealPlanModel {
  final String uid;
  final String date;
  final DailyMeals meals;
  final int totalCalories;
  final int totalMeals;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const MealPlanModel({
    required this.uid,
    required this.date,
    required this.meals,
    this.totalCalories = 0,
    this.totalMeals = 0,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      uid: json['uid'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      date: json['date'] ?? '',
      meals: DailyMeals.fromJson(json['meals'] ?? {}),
      totalCalories: json['total_calories'] ?? 0,
      totalMeals: json['total_meals'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
      'meals': meals.toJson(),
      'total_calories': totalCalories,
      'total_meals': totalMeals,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  MealPlanModel copyWith({
    String? uid,
    String? date,
    DailyMeals? meals,
    int? totalCalories,
    int? totalMeals,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MealPlanModel(
      uid: uid ?? this.uid,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalMeals: totalMeals ?? this.totalMeals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Create an empty meal plan for a specific date
  factory MealPlanModel.empty({required String date}) {
    return MealPlanModel(
      uid: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      meals: const DailyMeals(),
      totalCalories: 0,
      totalMeals: 0,
      createdAt: DateTime.now(),
    );
  }
}

class DailyMeals {
  final List<Map<String, dynamic>> breakfast;
  final List<Map<String, dynamic>> lunch;
  final List<Map<String, dynamic>> dinner;
  final List<Map<String, dynamic>> snacks;

  const DailyMeals({
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
  });

  factory DailyMeals.fromJson(Map<String, dynamic> json) {
    return DailyMeals(
      breakfast: List<Map<String, dynamic>>.from(json['breakfast'] ?? []),
      lunch: List<Map<String, dynamic>>.from(json['lunch'] ?? []),
      dinner: List<Map<String, dynamic>>.from(json['dinner'] ?? []),
      snacks: List<Map<String, dynamic>>.from(json['snacks'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'snacks': snacks,
    };
  }

  DailyMeals copyWith({
    List<Map<String, dynamic>>? breakfast,
    List<Map<String, dynamic>>? lunch,
    List<Map<String, dynamic>>? dinner,
    List<Map<String, dynamic>>? snacks,
  }) {
    return DailyMeals(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
    );
  }
}

// Meal type enum
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  // Get display name in Spanish
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Almuerzo';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
    }
  }

  // Get icon for meal type
  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '🍽️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '☕';
    }
  }

  // Get typical time for meal type
  String get typicalTime {
    switch (this) {
      case MealType.breakfast:
        return '7:00 - 9:00';
      case MealType.lunch:
        return '12:00 - 14:00';
      case MealType.dinner:
        return '19:00 - 21:00';
      case MealType.snack:
        return 'Cualquier hora';
    }
  }
}