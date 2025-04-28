import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/special_diet.dart';

// Removed static JSON data

// Asynchronous provider to load diets from assets
final predefinedDietsProvider = FutureProvider<List<SpecialDiet>>((ref) async {
  try {
    final jsonString = await rootBundle.loadString(
      'lib/core/constants/special_diets.json',
    );
    final List<dynamic> dietList = jsonDecode(jsonString)['special_diets'];
    return dietList
        .map((data) => SpecialDiet.fromJson(data as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Handle potential errors during file loading or parsing
    print("Error loading special diets from JSON: $e");
    // Return an empty list or throw an error, depending on desired behavior
    return [];
  }
});

// StateNotifier for managing selected diets
class SpecialDietsNotifier extends StateNotifier<Set<SpecialDiet>> {
  SpecialDietsNotifier() : super({});

  // Special constants for easier handling
  static const String addDietName = "Agregar otra dieta";
  static const String noDietName = "No sigo ninguna";

  void toggleDiet(SpecialDiet diet, List<SpecialDiet> allPredefined) {
    final isAdding = diet.name == addDietName;
    final isSelectingNone = diet.name == noDietName;
    final isNoneCurrentlySelected = state.any((d) => d.name == noDietName);

    if (isAdding) {
      // Handle adding a custom diet (implementation needed, e.g., show dialog)
      print("Add custom diet action triggered");
      // We don't modify the state here, the UI should trigger the adding flow
      return;
    }

    if (isSelectingNone) {
      // If selecting "None", clear all others and select only "None"
      state = {diet};
    } else {
      var newState = {...state};
      // If "None" was selected, remove it when selecting something else
      if (isNoneCurrentlySelected) {
        newState.removeWhere((d) => d.name == noDietName);
      }

      // Toggle the selected diet
      if (newState.contains(diet)) {
        newState.remove(diet);
      } else {
        newState.add(diet);
      }
      state = newState;
    }

    // TODO: Persist state (e.g., using SharedPreferences or a database)
    print("Selected diets: $state");
  }

  void addCustomDiet(SpecialDiet customDiet) {
    // Ensure the custom diet isn't a predefined one and isn't "None"
    if (customDiet.name != noDietName && !state.contains(customDiet)) {
      var newState = {...state};
      // Remove "None" if adding a custom diet
      newState.removeWhere((d) => d.name == noDietName);
      newState.add(customDiet);
      state = newState;
      // TODO: Persist state
      print("Added custom diet: $customDiet");
      print("Selected diets: $state");
    }
  }
}

// Provider for the SpecialDietsNotifier
final specialDietsProvider =
    StateNotifierProvider<SpecialDietsNotifier, Set<SpecialDiet>>((ref) {
      // TODO: Load persisted state if available
      return SpecialDietsNotifier();
    });
