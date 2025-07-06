import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal_plan_model.dart';
import '../../../../core/services/meal_planning_service.dart';

// State class for unified meal planner
class UnifiedMealPlannerState {
  final bool isLoading;
  final Map<DateTime, MealPlanModel> mealPlans;
  final Map<DateTime, bool> weeklyIndicators;
  final MealPlanModel? selectedDayPlan;
  final DateTime? selectedDate;
  final DateTime? currentWeekStart;
  final String? error;

  const UnifiedMealPlannerState({
    this.isLoading = false,
    this.mealPlans = const {},
    this.weeklyIndicators = const {},
    this.selectedDayPlan,
    this.selectedDate,
    this.currentWeekStart,
    this.error,
  });

  UnifiedMealPlannerState copyWith({
    bool? isLoading,
    Map<DateTime, MealPlanModel>? mealPlans,
    Map<DateTime, bool>? weeklyIndicators,
    MealPlanModel? selectedDayPlan,
    DateTime? selectedDate,
    DateTime? currentWeekStart,
    String? error,
  }) {
    return UnifiedMealPlannerState(
      isLoading: isLoading ?? this.isLoading,
      mealPlans: mealPlans ?? this.mealPlans,
      weeklyIndicators: weeklyIndicators ?? this.weeklyIndicators,
      selectedDayPlan: selectedDayPlan ?? this.selectedDayPlan,
      selectedDate: selectedDate ?? this.selectedDate,
      currentWeekStart: currentWeekStart ?? this.currentWeekStart,
      error: error,
    );
  }
}

// Provider for the unified meal planner
final unifiedMealPlannerProvider = StateNotifierProvider<UnifiedMealPlannerNotifier, UnifiedMealPlannerState>(
  (ref) => UnifiedMealPlannerNotifier(),
);

class UnifiedMealPlannerNotifier extends StateNotifier<UnifiedMealPlannerState> {
  UnifiedMealPlannerNotifier() : super(const UnifiedMealPlannerState()) {
    _initializeWithToday();
  }

  final MealPlanningService _mealPlanningService = MealPlanningService.instance;

  // Initialize with today's date
  void _initializeWithToday() {
    final today = DateTime.now();
    final weekStart = _getWeekStart(today);
    
    state = state.copyWith(
      selectedDate: today,
      currentWeekStart: weekStart,
    );
    
    _loadWeeklyData(weekStart);
  }

  // Get the start of the week (Monday)
  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get formatted date string for API
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  // Parse date from API string
  DateTime _parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  // Select a specific date
  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      isLoading: true,
      error: null,
    );

    try {
      // Check if we already have this day's plan
      final existingPlan = state.mealPlans[date];
      if (existingPlan != null) {
        state = state.copyWith(
          selectedDayPlan: existingPlan,
          isLoading: false,
        );
        return;
      }

      // Load the meal plan for this specific date
      final dateStr = _formatDate(date);
      final response = await _mealPlanningService.getMealPlanByDate(dateStr);
      
      if (response.isNotEmpty) {
        final mealPlan = MealPlanModel.fromJson(response);
        
        // Update the state with the new meal plan
        final updatedPlans = Map<DateTime, MealPlanModel>.from(state.mealPlans);
        updatedPlans[date] = mealPlan;
        
        state = state.copyWith(
          mealPlans: updatedPlans,
          selectedDayPlan: mealPlan,
          isLoading: false,
        );
        
        _updateWeeklyIndicators();
      } else {
        // No meal plan for this date, create an empty one
        final emptyPlan = MealPlanModel.empty(date: dateStr);
        state = state.copyWith(
          selectedDayPlan: emptyPlan,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        selectedDayPlan: MealPlanModel.empty(date: _formatDate(date)),
      );
    }
  }

  // Navigate week (previous: -1, next: 1)
  Future<void> navigateWeek(int direction) async {
    final currentWeekStart = state.currentWeekStart ?? DateTime.now();
    final newWeekStart = currentWeekStart.add(Duration(days: 7 * direction));
    
    state = state.copyWith(
      currentWeekStart: newWeekStart,
      isLoading: true,
    );
    
    await _loadWeeklyData(newWeekStart);
  }

  // Load weekly data
  Future<void> _loadWeeklyData(DateTime weekStart) async {
    try {
      final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));
      final startDate = _formatDate(weekDays.first);
      final endDate = _formatDate(weekDays.last);
      
      // Load meal plans for the week range
      final response = await _mealPlanningService.getMealPlansForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (response['meal_plans'] != null) {
        final weeklyPlans = <DateTime, MealPlanModel>{};
        final plans = response['meal_plans'] as List;
        
        for (final planData in plans) {
          final mealPlan = MealPlanModel.fromJson(planData);
          final planDate = _parseDate(mealPlan.date);
          weeklyPlans[planDate] = mealPlan;
        }
        
        // Update state with weekly plans
        final updatedPlans = Map<DateTime, MealPlanModel>.from(state.mealPlans);
        updatedPlans.addAll(weeklyPlans);
        
        state = state.copyWith(
          mealPlans: updatedPlans,
          isLoading: false,
        );
        
        _updateWeeklyIndicators();
        
        // Update selected day plan if it's in this week
        final selectedDate = state.selectedDate;
        if (selectedDate != null && weeklyPlans.containsKey(selectedDate)) {
          state = state.copyWith(selectedDayPlan: weeklyPlans[selectedDate]);
        }
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Update weekly indicators (dots showing which days have plans)
  void _updateWeeklyIndicators() {
    final indicators = <DateTime, bool>{};
    
    for (final entry in state.mealPlans.entries) {
      final date = entry.key;
      final plan = entry.value;
      
      // Check if the day has any meals planned
      final hasMeals = plan.meals.breakfast.isNotEmpty ||
                      plan.meals.lunch.isNotEmpty ||
                      plan.meals.dinner.isNotEmpty ||
                      plan.meals.snacks.isNotEmpty;
      
      indicators[date] = hasMeals;
    }
    
    state = state.copyWith(weeklyIndicators: indicators);
  }

  // Add meal to a specific day
  Future<void> addMealToDay(
    DateTime date,
    MealType mealType,
    Map<String, dynamic> meal,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Get current meal plan for the date or create empty one
      final currentPlan = state.mealPlans[date] ?? MealPlanModel.empty(date: _formatDate(date));
      
      // Add meal to the appropriate meal type
      DailyMeals updatedMeals;
      
      switch (mealType) {
        case MealType.breakfast:
          updatedMeals = currentPlan.meals.copyWith(
            breakfast: [...currentPlan.meals.breakfast, meal],
          );
          break;
        case MealType.lunch:
          updatedMeals = currentPlan.meals.copyWith(
            lunch: [...currentPlan.meals.lunch, meal],
          );
          break;
        case MealType.dinner:
          updatedMeals = currentPlan.meals.copyWith(
            dinner: [...currentPlan.meals.dinner, meal],
          );
          break;
        case MealType.snack:
          updatedMeals = currentPlan.meals.copyWith(
            snacks: [...currentPlan.meals.snacks, meal],
          );
          break;
      }
      
      // Create updated meal plan
      final updatedPlan = currentPlan.copyWith(meals: updatedMeals);
      
      // Save to backend
      await _saveMealPlanToBackend(date, updatedPlan);
      
      // Update local state
      final updatedPlans = Map<DateTime, MealPlanModel>.from(state.mealPlans);
      updatedPlans[date] = updatedPlan;
      
      state = state.copyWith(
        mealPlans: updatedPlans,
        selectedDayPlan: date == state.selectedDate ? updatedPlan : state.selectedDayPlan,
        isLoading: false,
      );
      
      _updateWeeklyIndicators();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Edit a meal
  Future<void> editMeal(
    DateTime date,
    String mealId,
    Map<String, dynamic> updatedMeal,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final currentPlan = state.mealPlans[date];
      if (currentPlan == null) return;
      
      // Find and update the meal in the appropriate list
      DailyMeals updatedMeals = currentPlan.meals;
      bool mealFound = false;
      
      // Search in breakfast
      List<Map<String, dynamic>> breakfast = [...currentPlan.meals.breakfast];
      final breakfastIndex = breakfast.indexWhere((meal) => meal['id'] == mealId);
      if (breakfastIndex != -1) {
        breakfast[breakfastIndex] = updatedMeal;
        updatedMeals = currentPlan.meals.copyWith(breakfast: breakfast);
        mealFound = true;
      }
      
      // Search in lunch
      if (!mealFound) {
        List<Map<String, dynamic>> lunch = [...currentPlan.meals.lunch];
        final lunchIndex = lunch.indexWhere((meal) => meal['id'] == mealId);
        if (lunchIndex != -1) {
          lunch[lunchIndex] = updatedMeal;
          updatedMeals = currentPlan.meals.copyWith(lunch: lunch);
          mealFound = true;
        }
      }
      
      // Search in dinner
      if (!mealFound) {
        List<Map<String, dynamic>> dinner = [...currentPlan.meals.dinner];
        final dinnerIndex = dinner.indexWhere((meal) => meal['id'] == mealId);
        if (dinnerIndex != -1) {
          dinner[dinnerIndex] = updatedMeal;
          updatedMeals = currentPlan.meals.copyWith(dinner: dinner);
          mealFound = true;
        }
      }
      
      // Search in snacks
      if (!mealFound) {
        List<Map<String, dynamic>> snacks = [...currentPlan.meals.snacks];
        final snacksIndex = snacks.indexWhere((meal) => meal['id'] == mealId);
        if (snacksIndex != -1) {
          snacks[snacksIndex] = updatedMeal;
          updatedMeals = currentPlan.meals.copyWith(snacks: snacks);
          mealFound = true;
        }
      }
      
      if (!mealFound) return;
      
      // Create updated meal plan
      final updatedPlan = currentPlan.copyWith(meals: updatedMeals);
      
      // Save to backend
      await _saveMealPlanToBackend(date, updatedPlan);
      
      // Update local state
      final updatedPlans = Map<DateTime, MealPlanModel>.from(state.mealPlans);
      updatedPlans[date] = updatedPlan;
      
      state = state.copyWith(
        mealPlans: updatedPlans,
        selectedDayPlan: date == state.selectedDate ? updatedPlan : state.selectedDayPlan,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Delete a meal
  Future<void> deleteMeal(DateTime date, String mealId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final currentPlan = state.mealPlans[date];
      if (currentPlan == null) return;
      
      // Find and remove the meal from the appropriate list
      DailyMeals updatedMeals = currentPlan.meals;
      bool mealFound = false;
      
      // Search in breakfast
      List<Map<String, dynamic>> breakfast = [...currentPlan.meals.breakfast];
      final breakfastIndex = breakfast.indexWhere((meal) => meal['id'] == mealId);
      if (breakfastIndex != -1) {
        breakfast.removeAt(breakfastIndex);
        updatedMeals = currentPlan.meals.copyWith(breakfast: breakfast);
        mealFound = true;
      }
      
      // Search in lunch
      if (!mealFound) {
        List<Map<String, dynamic>> lunch = [...currentPlan.meals.lunch];
        final lunchIndex = lunch.indexWhere((meal) => meal['id'] == mealId);
        if (lunchIndex != -1) {
          lunch.removeAt(lunchIndex);
          updatedMeals = currentPlan.meals.copyWith(lunch: lunch);
          mealFound = true;
        }
      }
      
      // Search in dinner
      if (!mealFound) {
        List<Map<String, dynamic>> dinner = [...currentPlan.meals.dinner];
        final dinnerIndex = dinner.indexWhere((meal) => meal['id'] == mealId);
        if (dinnerIndex != -1) {
          dinner.removeAt(dinnerIndex);
          updatedMeals = currentPlan.meals.copyWith(dinner: dinner);
          mealFound = true;
        }
      }
      
      // Search in snacks
      if (!mealFound) {
        List<Map<String, dynamic>> snacks = [...currentPlan.meals.snacks];
        final snacksIndex = snacks.indexWhere((meal) => meal['id'] == mealId);
        if (snacksIndex != -1) {
          snacks.removeAt(snacksIndex);
          updatedMeals = currentPlan.meals.copyWith(snacks: snacks);
          mealFound = true;
        }
      }
      
      if (!mealFound) return;
      
      // Create updated meal plan
      final updatedPlan = currentPlan.copyWith(meals: updatedMeals);
      
      // Save to backend
      await _saveMealPlanToBackend(date, updatedPlan);
      
      // Update local state
      final updatedPlans = Map<DateTime, MealPlanModel>.from(state.mealPlans);
      updatedPlans[date] = updatedPlan;
      
      state = state.copyWith(
        mealPlans: updatedPlans,
        selectedDayPlan: date == state.selectedDate ? updatedPlan : state.selectedDayPlan,
        isLoading: false,
      );
      
      _updateWeeklyIndicators();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Save meal plan to backend
  Future<void> _saveMealPlanToBackend(DateTime date, MealPlanModel mealPlan) async {
    final dateStr = _formatDate(date);
    
    // Convert to backend format
    final mealsData = {
      'breakfast': mealPlan.meals.breakfast,
      'lunch': mealPlan.meals.lunch,
      'dinner': mealPlan.meals.dinner,
      'snacks': mealPlan.meals.snacks,
    };
    
    await _mealPlanningService.saveMealPlan(
      date: dateStr,
      meals: mealsData,
    );
  }

  // Refresh data
  Future<void> refresh() async {
    final selectedDate = state.selectedDate;
    final currentWeekStart = state.currentWeekStart;
    
    if (selectedDate != null) {
      await selectDate(selectedDate);
    }
    
    if (currentWeekStart != null) {
      await _loadWeeklyData(currentWeekStart);
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}