import 'package:flutter/material.dart';

enum StorageType {
  refrigerated,
  frozen,
  dry,
  pantry,
  cellar,
  ambient,
  sunlight,
  wineCellar,
  bulk,
  fermentation,
  // 'all' removed as multi-select bottom sheet handles this
}

// Optional: Add extension methods for display names or colors
extension StorageTypeExtension on StorageType {
  String get displayName {
    switch (this) {
      case StorageType.refrigerated:
        return 'Refrigerado';
      case StorageType.frozen:
        return 'Congelado';
      case StorageType.dry:
        return 'Seco';
      case StorageType.pantry:
        return 'Despensa';
      case StorageType.cellar:
        return 'Bodega';
      case StorageType.ambient:
        return 'Ambiente';
      case StorageType.sunlight:
        return 'Exterior'; // or Luz Solar?
      case StorageType.wineCellar:
        return 'Cava';
      case StorageType.bulk:
        return 'A granel';
      case StorageType.fermentation:
        return 'Fermentación';
    }
  }

  IconData get icon {
    switch (this) {
      case StorageType.refrigerated:
        return Icons.ac_unit;
      case StorageType.frozen:
        return Icons
            .severe_cold_outlined; // or Icons.ac_unit with different color?
      case StorageType.dry:
        return Icons.emoji_nature_outlined; // Placeholder, find better
      case StorageType.pantry:
        return Icons.kitchen_outlined;
      case StorageType.cellar:
        return Icons.store_mall_directory_outlined;
      case StorageType.ambient:
        return Icons.home_outlined;
      case StorageType.sunlight:
        return Icons.wb_sunny_outlined;
      case StorageType.wineCellar:
        return Icons.wine_bar_outlined;
      case StorageType.bulk:
        return Icons.inventory_2_outlined;
      case StorageType.fermentation:
        return Icons.science_outlined;
    }
  }

  // Define colors for badges later if needed
  // Color get badgeColor { ... }
}
