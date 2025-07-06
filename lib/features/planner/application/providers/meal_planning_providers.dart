import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';
import 'package:zer0_waste_ai/features/planner/application/providers/meal_plan_providers.dart';

/// INFO: Provider for meal planning state management
/// USAGE: Use this for complete meal planning operations with state management
final mealPlanningProvider =
    StateNotifierProvider<MealPlanningNotifier, MealPlanningState>((ref) {
      final backendNotifier = ref.watch(mealPlanBackendProvider);
      return MealPlanningNotifier(backendNotifier);
    });

/// INFO: State for meal planning
class MealPlanningState {
  final Map<String, MealPlanModel> mealPlans;
  final List<String> availableDates;
  final bool isLoading;
  final String? error;
  final MealPlanModel? selectedMealPlan;
  final String? selectedDate;

  const MealPlanningState({
    this.mealPlans = const {},
    this.availableDates = const [],
    this.isLoading = false,
    this.error,
    this.selectedMealPlan,
    this.selectedDate,
  });

  MealPlanningState copyWith({
    Map<String, MealPlanModel>? mealPlans,
    List<String>? availableDates,
    bool? isLoading,
    String? error,
    MealPlanModel? selectedMealPlan,
    String? selectedDate,
  }) {
    return MealPlanningState(
      mealPlans: mealPlans ?? this.mealPlans,
      availableDates: availableDates ?? this.availableDates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMealPlan: selectedMealPlan,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  /// INFO: Clear error state
  MealPlanningState clearError() {
    return copyWith(error: null);
  }

  /// INFO: Get meal plan for specific date
  MealPlanModel? getMealPlanForDate(String date) {
    return mealPlans[date];
  }

  /// INFO: Check if date has meal plan
  bool hasDateMealPlan(String date) {
    return mealPlans.containsKey(date);
  }
}

/// INFO: Notifier for meal planning operations
class MealPlanningNotifier extends StateNotifier<MealPlanningState> {
  final MealPlanBackendNotifier _backendNotifier;

  MealPlanningNotifier(this._backendNotifier)
    : super(const MealPlanningState());

  /// INFO: Load all meal plans from backend
  Future<void> loadAllMealPlans() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _backendNotifier.getAllMealPlans();
      final allPlansResponse = GetAllMealPlansResponse.fromJson(response);

      // Convert list to map with date as key
      final Map<String, MealPlanModel> mealPlansMap = {};
      for (final plan in allPlansResponse.mealPlans) {
        mealPlansMap[plan.date] = plan;
      }

      state = state.copyWith(mealPlans: mealPlansMap, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading meal plans: ${e.toString()}',
      );
    }
  }

  /// INFO: Load available dates with meal plans
  Future<void> loadAvailableDates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _backendNotifier.getMealPlanDates();
      final datesResponse = GetMealPlanDatesResponse.fromJson(response);

      state = state.copyWith(
        availableDates: datesResponse.dates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading available dates: ${e.toString()}',
      );
    }
  }

  /// INFO: Load meal plan for specific date
  Future<void> loadMealPlanForDate(String date) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _backendNotifier.getMealPlanByDate(date);
      final mealPlanResponse = GetMealPlanResponse.fromJson(response);

      if (mealPlanResponse.mealPlan != null) {
        final updatedMealPlans = Map<String, MealPlanModel>.from(
          state.mealPlans,
        );
        updatedMealPlans[date] = mealPlanResponse.mealPlan!;

        state = state.copyWith(
          mealPlans: updatedMealPlans,
          selectedMealPlan: mealPlanResponse.mealPlan,
          selectedDate: date,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          selectedMealPlan: null,
          selectedDate: date,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading meal plan for $date: ${e.toString()}',
      );
    }
  }

  /// INFO: Save new meal plan
  Future<bool> saveMealPlan({
    required String date,
    required DailyMeals meals,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _backendNotifier.saveMealPlan(
        date: date,
        meals: meals.toJson(),
      );
      final saveResponse = MealPlanResponse.fromJson(response);

      // Update local state with new meal plan
      final updatedMealPlans = Map<String, MealPlanModel>.from(state.mealPlans);
      updatedMealPlans[date] = saveResponse.mealPlan;

      // Update available dates if not already present
      final updatedDates = List<String>.from(state.availableDates);
      if (!updatedDates.contains(date)) {
        updatedDates.add(date);
        updatedDates.sort();
      }

      state = state.copyWith(
        mealPlans: updatedMealPlans,
        availableDates: updatedDates,
        selectedMealPlan: saveResponse.mealPlan,
        selectedDate: date,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error saving meal plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// INFO: Update existing meal plan
  Future<bool> updateMealPlan({
    required String date,
    required DailyMeals meals,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _backendNotifier.updateMealPlan(
        date: date,
        meals: meals.toJson(),
      );
      final updateResponse = MealPlanResponse.fromJson(response);

      // Update local state with updated meal plan
      final updatedMealPlans = Map<String, MealPlanModel>.from(state.mealPlans);
      updatedMealPlans[date] = updateResponse.mealPlan;

      state = state.copyWith(
        mealPlans: updatedMealPlans,
        selectedMealPlan: updateResponse.mealPlan,
        selectedDate: date,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error updating meal plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// INFO: Delete meal plan for specific date
  Future<bool> deleteMealPlan(String date) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _backendNotifier.deleteMealPlan(date);

      // Remove from local state
      final updatedMealPlans = Map<String, MealPlanModel>.from(state.mealPlans);
      updatedMealPlans.remove(date);

      // Remove from available dates
      final updatedDates = List<String>.from(state.availableDates);
      updatedDates.remove(date);

      // Clear selection if deleted date was selected
      MealPlanModel? selectedPlan = state.selectedMealPlan;
      String? selectedDate = state.selectedDate;
      if (state.selectedDate == date) {
        selectedPlan = null;
        selectedDate = null;
      }

      state = state.copyWith(
        mealPlans: updatedMealPlans,
        availableDates: updatedDates,
        selectedMealPlan: selectedPlan,
        selectedDate: selectedDate,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error deleting meal plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// INFO: Select meal plan for specific date
  void selectMealPlan(String date) {
    final mealPlan = state.mealPlans[date];
    state = state.copyWith(selectedMealPlan: mealPlan, selectedDate: date);
  }

  /// INFO: Clear selection
  void clearSelection() {
    state = state.copyWith(selectedMealPlan: null, selectedDate: null);
  }

  /// INFO: Clear error state
  void clearError() {
    state = state.clearError();
  }

  /// INFO: Save or update meal plan (automatically determines which to use)
  Future<bool> saveOrUpdateMealPlan({
    required String date,
    required DailyMeals meals,
  }) async {
    final existingPlan = state.mealPlans[date];

    if (existingPlan != null) {
      return await updateMealPlan(date: date, meals: meals);
    } else {
      return await saveMealPlan(date: date, meals: meals);
    }
  }
}

/// INFO: Provider for selected date in meal planning
final selectedMealPlanDateProvider = StateProvider<String?>((ref) => null);

/// INFO: Provider for meal plan creation/editing state
final mealPlanEditingProvider =
    StateNotifierProvider<MealPlanEditingNotifier, MealPlanEditingState>((ref) {
      return MealPlanEditingNotifier();
    });

/// INFO: State for meal plan editing
class MealPlanEditingState {
  final String? date;
  final DailyMeals meals;
  final bool isEditing;
  final bool hasChanges;

  const MealPlanEditingState({
    this.date,
    this.meals = const DailyMeals(),
    this.isEditing = false,
    this.hasChanges = false,
  });

  MealPlanEditingState copyWith({
    String? date,
    DailyMeals? meals,
    bool? isEditing,
    bool? hasChanges,
  }) {
    return MealPlanEditingState(
      date: date ?? this.date,
      meals: meals ?? this.meals,
      isEditing: isEditing ?? this.isEditing,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}

/// INFO: Notifier for meal plan editing
class MealPlanEditingNotifier extends StateNotifier<MealPlanEditingState> {
  MealPlanEditingNotifier() : super(const MealPlanEditingState());

  /// INFO: Start editing meal plan for date
  void startEditing(String date, {MealPlanModel? existingPlan}) {
    state = MealPlanEditingState(
      date: date,
      meals: existingPlan?.meals ?? const DailyMeals(),
      isEditing: true,
      hasChanges: false,
    );
  }

  /// INFO: Update breakfast
  void updateBreakfast(Meal? breakfast) {
    final updatedMeals = DailyMeals(
      breakfast: breakfast,
      lunch: state.meals.lunch,
      dinner: state.meals.dinner,
    );

    state = state.copyWith(meals: updatedMeals, hasChanges: true);
  }

  /// INFO: Update lunch
  void updateLunch(Meal? lunch) {
    final updatedMeals = DailyMeals(
      breakfast: state.meals.breakfast,
      lunch: lunch,
      dinner: state.meals.dinner,
    );

    state = state.copyWith(meals: updatedMeals, hasChanges: true);
  }

  /// INFO: Update dinner
  void updateDinner(Meal? dinner) {
    final updatedMeals = DailyMeals(
      breakfast: state.meals.breakfast,
      lunch: state.meals.lunch,
      dinner: dinner,
    );

    state = state.copyWith(meals: updatedMeals, hasChanges: true);
  }

  /// INFO: Cancel editing
  void cancelEditing() {
    state = const MealPlanEditingState();
  }

  /// INFO: Reset changes
  void resetChanges(MealPlanModel? originalPlan) {
    if (state.date != null) {
      state = state.copyWith(
        meals: originalPlan?.meals ?? const DailyMeals(),
        hasChanges: false,
      );
    }
  }
}

/// INFO: Provider for meal plan statistics
final mealPlanStatsProvider = Provider<MealPlanStats>((ref) {
  final mealPlanningState = ref.watch(mealPlanningProvider);
  return MealPlanStats.fromMealPlans(
    mealPlanningState.mealPlans.values.toList(),
  );
});

/// INFO: Statistics for meal plans
class MealPlanStats {
  final int totalMealPlans;
  final int totalMeals;
  final int averageCaloriesPerDay;
  final int totalCalories;
  final Map<String, int> mealTypeCount;
  final List<String> mostUsedIngredients;

  const MealPlanStats({
    required this.totalMealPlans,
    required this.totalMeals,
    required this.averageCaloriesPerDay,
    required this.totalCalories,
    required this.mealTypeCount,
    required this.mostUsedIngredients,
  });

  factory MealPlanStats.fromMealPlans(List<MealPlanModel> mealPlans) {
    if (mealPlans.isEmpty) {
      return const MealPlanStats(
        totalMealPlans: 0,
        totalMeals: 0,
        averageCaloriesPerDay: 0,
        totalCalories: 0,
        mealTypeCount: {},
        mostUsedIngredients: [],
      );
    }

    int totalMeals = 0;
    int totalCalories = 0;
    final Map<String, int> mealTypeCount = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };
    final Map<String, int> ingredientCount = {};

    for (final plan in mealPlans) {
      totalCalories += plan.totalCalories;

      if (plan.meals.breakfast != null) {
        totalMeals++;
        mealTypeCount['breakfast'] = mealTypeCount['breakfast']! + 1;
        for (final ingredient in plan.meals.breakfast!.ingredientsNeeded) {
          ingredientCount[ingredient.name] =
              (ingredientCount[ingredient.name] ?? 0) + 1;
        }
      }

      if (plan.meals.lunch != null) {
        totalMeals++;
        mealTypeCount['lunch'] = mealTypeCount['lunch']! + 1;
        for (final ingredient in plan.meals.lunch!.ingredientsNeeded) {
          ingredientCount[ingredient.name] =
              (ingredientCount[ingredient.name] ?? 0) + 1;
        }
      }

      if (plan.meals.dinner != null) {
        totalMeals++;
        mealTypeCount['dinner'] = mealTypeCount['dinner']! + 1;
        for (final ingredient in plan.meals.dinner!.ingredientsNeeded) {
          ingredientCount[ingredient.name] =
              (ingredientCount[ingredient.name] ?? 0) + 1;
        }
      }
    }

    // Get most used ingredients (top 10)
    final sortedIngredients =
        ingredientCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final mostUsedIngredients =
        sortedIngredients.take(10).map((entry) => entry.key).toList();

    return MealPlanStats(
      totalMealPlans: mealPlans.length,
      totalMeals: totalMeals,
      averageCaloriesPerDay:
          mealPlans.isNotEmpty ? (totalCalories / mealPlans.length).round() : 0,
      totalCalories: totalCalories,
      mealTypeCount: mealTypeCount,
      mostUsedIngredients: mostUsedIngredients,
    );
  }
}
