import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zer0_waste_ai/features/profile/presentation/screens/preferred_food_type_screen.dart'; // Assuming FoodType model is here
import 'package:zer0_waste_ai/features/profile/domain/models/food_type.dart'; // Corrected import

// Asynchronous provider to load food types from assets
final foodTypesProvider = FutureProvider<List<FoodType>>((ref) async {
  try {
    final jsonString = await rootBundle.loadString(
      'lib/core/constants/food_types.json',
    );
    final List<dynamic> foodList = jsonDecode(jsonString)['food_types'];
    return foodList
        .map((data) => FoodType.fromJson(data as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Handle potential errors during file loading or parsing
    print("Error loading food types from JSON: $e");
    // Return an empty list or throw an error, depending on desired behavior
    return [];
  }
});
