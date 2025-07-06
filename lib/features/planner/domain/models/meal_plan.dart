import 'package:flutter/material.dart';

// Tipos de comida
enum MealType { breakfast, lunch, dinner, snack }

// Extensión para obtener el nombre del tipo de comida
extension MealTypeExtension on MealType {
  String get name {
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

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  Color get color {
    switch (this) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return Colors.blue;
    }
  }
}

// Modelo para representar un plan de comida
class MealPlan {
  final String id;
  final String name;
  final String imageUrl;
  final MealType type;
  final List<String> ingredients;
  final List<String>? reminders;
  final List<String>
  dietaryTags; // Por ejemplo: vegetariano, vegano, sin gluten
  final int prepTimeMinutes; // Tiempo de preparación en minutos
  final int calories; // Calorías aproximadas
  final String difficulty; // Fácil, Media, Difícil
  final bool isFavorite; // Si la receta es favorita del usuario
  final bool isCustom; // Si es una receta propia del usuario
  final DateTime? lastUsed; // Última vez que se usó

  MealPlan({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.ingredients,
    this.reminders,
    this.dietaryTags = const [],
    this.prepTimeMinutes = 0,
    this.calories = 0,
    this.difficulty = 'Media',
    this.isFavorite = false,
    this.isCustom = false,
    this.lastUsed,
  });

  // Método para crear una copia con algunos cambios
  MealPlan copyWith({
    String? name,
    String? imageUrl,
    MealType? type,
    List<String>? ingredients,
    List<String>? reminders,
    List<String>? dietaryTags,
    int? prepTimeMinutes,
    int? calories,
    String? difficulty,
    bool? isFavorite,
    bool? isCustom,
    DateTime? lastUsed,
  }) {
    return MealPlan(
      id: id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      ingredients: ingredients ?? this.ingredients,
      reminders: reminders ?? this.reminders,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      calories: calories ?? this.calories,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
