import 'package:flutter/material.dart';

enum ItemCategory {
  food,
  ingredient,
  all, // Added for filtering purposes
}

// Optional: Add extension methods for display names if needed
extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.food:
        return 'Comidas';
      case ItemCategory.ingredient:
        return 'Ingredientes';
      case ItemCategory.all:
        return 'Todos';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.food:
        return Icons.restaurant_menu_outlined;
      case ItemCategory.ingredient:
        return Icons.spa_outlined; // Placeholder, maybe energy_savings_leaf?
      case ItemCategory.all:
        return Icons.list_alt_outlined;
    }
  }
}
