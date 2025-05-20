import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/profile/domain/models/special_diet.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

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

  // Special constant for easier handling
  static const String addDietName = "Agregar otra dieta";

  void toggleDiet(SpecialDiet diet, List<SpecialDiet> allPredefined) {
    final isAdding = diet.name == addDietName;

    if (isAdding) {
      // Don't modify state for "Add" option - UI should handle this
      return;
    }

    var newState = {...state};
    // Toggle the selected diet
    if (newState.contains(diet)) {
      newState.remove(diet);
    } else {
      newState.add(diet);
    }
    state = newState;
  }

  void addCustomDiet(SpecialDiet customDiet) {
    // Check if the diet already exists
    if (!state.any(
      (d) => d.name.toLowerCase() == customDiet.name.toLowerCase(),
    )) {
      state = {...state, customDiet};
    }
  }

  // Initialize from a list of diet names and/or structured diet items
  void initializeFromUserProfile(
    List<String> dietNames,
    List<SpecialDiet> availableDiets,
  ) {
    final Set<SpecialDiet> selectedDiets = {};

    print('Initializing special diets with names: $dietNames');
    print(
      'Available predefined diets: ${availableDiets.map((d) => d.name).toList()}',
    );

    for (final dietName in dietNames) {
      // Try to find the diet in the predefined list
      final matchingDiets =
          availableDiets
              .where(
                (diet) => diet.name.toLowerCase() == dietName.toLowerCase(),
              )
              .toList();

      if (matchingDiets.isNotEmpty) {
        // Found matching predefined diet
        selectedDiets.add(matchingDiets.first);
        print('Added predefined diet: ${matchingDiets.first.name}');
      } else {
        // If not found, add as custom diet with a default emoji
        final customDiet = SpecialDiet(
          name: dietName,
          emoji: '🍽️',
          isCustom: true,
        );
        selectedDiets.add(customDiet);
        print('Added custom diet: ${customDiet.name}');
      }
    }

    print('Setting state with ${selectedDiets.length} diets');
    state = selectedDiets;
  }

  // Reset method
  void reset() {
    state = {};
  }
}

// Provider with persistence for the SpecialDietsNotifier
final specialDietsProviderWithPersistence = StateNotifierProvider<
  SpecialDietsNotifier,
  Set<SpecialDiet>
>((ref) {
  // Create the notifier - the initialization will be handled in the specific screens
  // that need to load user preferences from Firestore
  return SpecialDietsNotifier();
});

// Provider for selected diet names for easier persistence
final selectedDietNamesProvider = Provider<List<String>>((ref) {
  final selectedDiets = ref.watch(specialDietsProviderWithPersistence);
  return selectedDiets.map((diet) => diet.name).toList();
});
