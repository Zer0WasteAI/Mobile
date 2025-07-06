import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';

/// INFO: Converts recognition results to inventory format
/// USAGE: Use these functions to prepare data for inventory API calls
class RecognitionToInventoryConverter {
  /// INFO: Converts RecognizedIngredientModel to inventory item format
  /// BASED ON: README.md - POST /api/inventory/items body structure
  static Map<String, dynamic> ingredientToInventoryItem(
    RecognizedIngredientModel ingredient, {
    int quantity = 1,
    String typeUnit = "Unidades",
    String storageType = "Refrigerador",
    int expirationTime = 7,
    String timeUnit = "Días",
  }) {
    return {
      "name": ingredient.name,
      "quantity": quantity,
      "type_unit": typeUnit,
      "storage_type": storageType,
      "expiration_time": expirationTime,
      "time_unit": timeUnit,
      "tips":
          ingredient.tips.isNotEmpty
              ? ingredient.tips
              : "Mantén en lugar fresco y seco.",
    };
  }

  /// INFO: Converts RecognizedFoodModel to inventory item format
  /// BASED ON: README.md - POST /api/inventory/items body structure
  static Map<String, dynamic> foodToInventoryItem(
    RecognizedFoodModel food, {
    int quantity = 1,
    String typeUnit = "Unidades",
    String storageType = "Refrigerador",
    int expirationTime = 7,
    String timeUnit = "Días",
  }) {
    return {
      "name": food.name,
      "quantity": quantity,
      "type_unit": typeUnit,
      "storage_type": storageType,
      "expiration_time": expirationTime,
      "time_unit": timeUnit,
      "tips":
          food.tips.isNotEmpty ? food.tips : "Mantén en lugar fresco y seco.",
    };
  }

  /// INFO: Gets default storage type based on food/ingredient type
  /// ADVICE: You can enhance this with AI or lookup tables
  static String getDefaultStorageType(String name) {
    final lowerName = name.toLowerCase();

    // Common refrigerated items
    if (lowerName.contains('leche') ||
        lowerName.contains('yogur') ||
        lowerName.contains('queso') ||
        lowerName.contains('carne') ||
        lowerName.contains('pollo') ||
        lowerName.contains('pescado') ||
        lowerName.contains('lechuga') ||
        lowerName.contains('tomate')) {
      return "Refrigerador";
    }

    // Common pantry items
    if (lowerName.contains('arroz') ||
        lowerName.contains('pasta') ||
        lowerName.contains('aceite') ||
        lowerName.contains('sal') ||
        lowerName.contains('azúcar') ||
        lowerName.contains('harina')) {
      return "Despensa";
    }

    // Common freezer items
    if (lowerName.contains('helado') || lowerName.contains('congelado')) {
      return "Congelador";
    }

    // Default to refrigerator for safety
    return "Refrigerador";
  }

  /// INFO: Gets default expiration time based on food/ingredient type
  /// ADVICE: You can enhance this with AI or lookup tables
  static int getDefaultExpirationTime(String name) {
    final lowerName = name.toLowerCase();

    // Very perishable (1-3 days)
    if (lowerName.contains('pescado') ||
        lowerName.contains('carne picada') ||
        lowerName.contains('lechuga') ||
        lowerName.contains('espinaca')) {
      return 2;
    }

    // Perishable (3-7 days)
    if (lowerName.contains('leche') ||
        lowerName.contains('yogur') ||
        lowerName.contains('tomate') ||
        lowerName.contains('pollo') ||
        lowerName.contains('carne')) {
      return 5;
    }

    // Medium shelf life (1-2 weeks)
    if (lowerName.contains('queso duro') ||
        lowerName.contains('huevos') ||
        lowerName.contains('manzana')) {
      return 14;
    }

    // Long shelf life (weeks to months)
    if (lowerName.contains('arroz') ||
        lowerName.contains('pasta') ||
        lowerName.contains('aceite') ||
        lowerName.contains('sal') ||
        lowerName.contains('azúcar') ||
        lowerName.contains('harina')) {
      return 90;
    }

    // Default to 7 days
    return 7;
  }

  /// INFO: Gets default type unit based on food/ingredient type
  static String getDefaultTypeUnit(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('leche') ||
        lowerName.contains('aceite') ||
        lowerName.contains('agua')) {
      return "Litros";
    }

    if (lowerName.contains('harina') ||
        lowerName.contains('azúcar') ||
        lowerName.contains('sal') ||
        lowerName.contains('arroz')) {
      return "Kilogramos";
    }

    if (lowerName.contains('lechuga') || lowerName.contains('repollo')) {
      return "Cabeza";
    }

    // Default to units
    return "Unidades";
  }

  /// INFO: Smart conversion that uses AI-like logic for defaults
  /// USAGE: This method combines all smart defaults for best UX
  static Map<String, dynamic> smartConvertToInventoryItem(
    dynamic recognizedItem,
  ) {
    String name;
    String tips;

    // Handle both ingredient and food models
    if (recognizedItem is RecognizedIngredientModel) {
      name = recognizedItem.name;
      tips = recognizedItem.tips;
    } else if (recognizedItem is RecognizedFoodModel) {
      name = recognizedItem.name;
      tips = recognizedItem.tips;
    } else {
      throw ArgumentError('Unknown recognition type');
    }

    return {
      "name": name,
      "quantity": 1, // User can edit this
      "type_unit": getDefaultTypeUnit(name),
      "storage_type": getDefaultStorageType(name),
      "expiration_time": getDefaultExpirationTime(name),
      "time_unit": getDefaultExpirationTime(name) > 30 ? "Días" : "Días",
      "tips":
          tips.isNotEmpty
              ? tips
              : "Mantén en lugar adecuado según el tipo de alimento.",
    };
  }
}
