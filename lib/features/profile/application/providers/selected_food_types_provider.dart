import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/food_type.dart';

// --- State Management --- (Moved from preferred_food_type_screen.dart)

final selectedFoodTypesProvider =
    StateNotifierProvider.autoDispose<SelectedFoodTypesNotifier, Set<FoodType>>(
      (ref) {
        // Using autoDispose to ensure state is reset when leaving the screen
        return SelectedFoodTypesNotifier();
      },
    );

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
    log("Selected food types: ${state.map((f) => f.name).toList()}");
  }

  void reset() {
    state = {};
    log("Resetting food type selections");
  }
}

// Update provider definition to use autoDispose
final selectedFoodTypesProviderWithPersistence = StateNotifierProvider<
  SelectedFoodTypesNotifier,
  Set<FoodType>
>((ref) {
  // Create the notifier - initialization will be handled by the screens that use it
  return SelectedFoodTypesNotifier();
});
