import 'package:flutter/material.dart';

enum StorageType {
  refrigerated(
    displayName: 'Refrigerado',
    icon: Icons.kitchen,
    daysToExpire: 7,
  ),
  frozen(displayName: 'Congelado', icon: Icons.ac_unit, daysToExpire: 90),
  pantry(
    displayName: 'Despensa',
    icon: Icons.kitchen_outlined,
    daysToExpire: 180,
  ),
  cellar(
    displayName: 'Bodega',
    icon: Icons.store_mall_directory_outlined,
    daysToExpire: 365,
  ),
  ambient(displayName: 'Ambiente', icon: Icons.home_outlined, daysToExpire: 30),
  sunlight(
    displayName: 'Exterior',
    icon: Icons.wb_sunny_outlined,
    daysToExpire: 14,
  ),
  wineCellar(
    displayName: 'Cava',
    icon: Icons.wine_bar_outlined,
    daysToExpire: 730,
  ),
  bulk(
    displayName: 'A granel',
    icon: Icons.inventory_2_outlined,
    daysToExpire: 90,
  ),
  fermentation(
    displayName: 'Fermentación',
    icon: Icons.science_outlined,
    daysToExpire: 60,
  );

  final String displayName;
  final IconData icon;
  final int daysToExpire;

  const StorageType({
    required this.displayName,
    required this.icon,
    required this.daysToExpire,
  });
}

// Optional: Add extension methods for display names or colors
extension StorageTypeExtension on StorageType {
  String get displayName {
    return this.displayName;
  }

  IconData get icon {
    return this.icon;
  }

  // Define colors for badges later if needed
  // Color get badgeColor { ... }
}
