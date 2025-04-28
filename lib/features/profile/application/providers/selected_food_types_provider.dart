import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/food_type.dart';

// --- State Management --- (Moved from preferred_food_type_screen.dart)

final selectedFoodTypesProvider =
    StateNotifierProvider<SelectedFoodTypesNotifier, Set<FoodType>>((ref) {
      // TODO: Load saved preferences if available
      return SelectedFoodTypesNotifier();
    });

class SelectedFoodTypesNotifier extends StateNotifier<Set<FoodType>> {
  SelectedFoodTypesNotifier() : super({});

  void toggleFoodType(FoodType foodType) {
    final newState = Set<FoodType>.from(state);
    if (newState.contains(foodType)) {
      newState.remove(foodType);
    } else {
      newState.add(foodType);
    }
    state = newState;
    // TODO: Save updated preferences (e.g., using SharedPreferences)
    _savePreferences();
    print("Selected food types: $state");
  }

  // Placeholder for saving logic
  Future<void> _savePreferences() async {
    // Example: Convert Set<FoodType> to List<Map> and save as JSON string
    // final List<Map<String, dynamic>> dataToSave = state.map((ft) => ft.toJson()).toList();
    // final String jsonString = jsonEncode(dataToSave);
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('selectedFoodTypes', jsonString);
    print("Simulating saving preferences...");
  }

  // Placeholder for loading logic (call in provider definition)
  Future<void> loadPreferences() async {
    // Example:
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? jsonString = prefs.getString('selectedFoodTypes');
    // if (jsonString != null) {
    //   final List<dynamic> jsonData = jsonDecode(jsonString);
    //   state = jsonData.map((item) => FoodType.fromJson(item as Map<String, dynamic>)).toSet();
    //   print("Loaded preferences: $state");
    // } else {
    //   state = {};
    //   print("No preferences found.");
    // }
    print("Simulating loading preferences...");
    // Load initial empty set for now
    state = {};
  }
}

// Update provider definition to load preferences
final selectedFoodTypesProviderWithPersistence =
    StateNotifierProvider<SelectedFoodTypesNotifier, Set<FoodType>>((ref) {
      final notifier = SelectedFoodTypesNotifier();
      // Don't await here, let it load in the background
      notifier.loadPreferences();
      return notifier;
    });
