import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/meal_plan_models.dart';
import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../application/providers/meal_planning_providers.dart' as app_providers;

/// Provider for meal plan repository
final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepositoryImpl();
});

/// Provider for meal plan by date
final mealPlanByDateProvider = FutureProvider.family<MealPlanModel?, String>((
  ref,
  date,
) async {
  final repository = ref.read(mealPlanRepositoryProvider);
  try {
    print('[DEBUG] Fetching meal plan for date: $date');
    final response = await repository.getMealPlanByDate(date);
    print('[DEBUG] Response received: $response');
    
    if (response['meal_plan'] != null) {
      // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
      final mealPlanData = Map<String, dynamic>.from(response['meal_plan'] as Map);
      
      // Verificamos si la respuesta API tiene la estructura esperada (no es una estructura con 'meals')
      if (mealPlanData.containsKey('breakfast') || mealPlanData.containsKey('lunch') || 
          mealPlanData.containsKey('dinner')) {
        print('[DEBUG] API returned direct meal data without meals wrapper');
        
        // Primero creamos el objeto DailyMeals para poder calcular las calorías
        final dailyMeals = DailyMeals.fromJson(mealPlanData);
        
        // Calculamos las calorías totales
        int totalCalories = 0;
        if (dailyMeals.breakfast != null) totalCalories += dailyMeals.breakfast!.calories;
        if (dailyMeals.lunch != null) totalCalories += dailyMeals.lunch!.calories;
        if (dailyMeals.dinner != null) totalCalories += dailyMeals.dinner!.calories;
        
        print('[DEBUG] Calculated total calories: $totalCalories');
        
        // Necesitamos adaptar la estructura para nuestro modelo
        final adaptedData = {
          'uid': '',  // Generará un ID automático
          'date': date,
          'meals': mealPlanData,  // Los datos de comidas están en el nivel superior
          'total_calories': totalCalories  // Usamos el valor calculado
        };
        
        final mealPlan = MealPlanModel.fromJson(adaptedData);
        print('[DEBUG] Successfully parsed meal plan: ${mealPlan.date}, calories: ${mealPlan.totalCalories}');
        return mealPlan;
      } else {
        // Formato normal
        final mealPlan = MealPlanModel.fromJson(mealPlanData);
        print('[DEBUG] Successfully parsed meal plan: ${mealPlan.date}, calories: ${mealPlan.totalCalories}');
        return mealPlan;
      }
    }
    return null;
  } catch (e) {
    print('[DEBUG] Error fetching meal plan: $e');
    return null;
  }
});

/// Provider for all meal plans
final allMealPlansProvider = FutureProvider<List<MealPlanModel>>((ref) async {
  final repository = ref.read(mealPlanRepositoryProvider);
  try {
    final response = await repository.getAllMealPlans();
    final mealPlansData = response['meal_plans'] as List<dynamic>;
    return mealPlansData.map((plan) {
      // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
      final planData = Map<String, dynamic>.from(plan as Map);
      return MealPlanModel.fromJson(planData);
    }).toList();
  } catch (e) {
    return [];
  }
});

/// Provider for meal plan dates
final mealPlanDatesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(mealPlanRepositoryProvider);
  try {
    final response = await repository.getMealPlanDates();
    final datesData = response['dates'] as List<dynamic>;
    return datesData.map((date) => date.toString()).toList();
  } catch (e) {
    return [];
  }
});

/// Provider for selected date
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

/// Provider for meal planning operations
final mealPlanningProvider =
    StateNotifierProvider<MealPlanningNotifier, AsyncValue<MealPlanModel?>>((
      ref,
    ) {
      final repository = ref.read(mealPlanRepositoryProvider);
      return MealPlanningNotifier(repository, ref);
    });

/// State notifier for meal planning operations
class MealPlanningNotifier extends StateNotifier<AsyncValue<MealPlanModel?>> {
  final MealPlanRepository _repository;
  final Ref _ref;

  MealPlanningNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Save a new meal plan
  Future<void> saveMealPlan(String date, DailyMeals meals) async {
    state = const AsyncValue.loading();
    try {
      // Calcular calorías totales antes de enviar
      int totalCalories = 0;
      if (meals.breakfast != null) totalCalories += meals.breakfast!.calories;
      if (meals.lunch != null) totalCalories += meals.lunch!.calories;
      if (meals.dinner != null) totalCalories += meals.dinner!.calories;
      
      print('[DEBUG] Saving meal plan with calculated calories: $totalCalories');
      
      final response = await _repository.saveMealPlan(
        date: date,
        meals: meals.toJson(),
      );
      if (response['meal_plan'] != null) {
        // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
        final mealPlanData = Map<String, dynamic>.from(response['meal_plan'] as Map);
        
        // Si la respuesta no incluye calorías totales, las añadimos
        if (!mealPlanData.containsKey('total_calories') || mealPlanData['total_calories'] == 0) {
          mealPlanData['total_calories'] = totalCalories;
        }
        
        final mealPlan = MealPlanModel.fromJson(mealPlanData);
        state = AsyncValue.data(mealPlan);
        // Invalidate both providers to refresh UI
        _ref.invalidate(mealPlanByDateProvider(date));
        _ref.invalidate(app_providers.mealPlanningProvider);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing meal plan
  Future<void> updateMealPlan(String date, DailyMeals meals) async {
    state = const AsyncValue.loading();
    try {
      // Calcular calorías totales antes de enviar
      int totalCalories = 0;
      if (meals.breakfast != null) totalCalories += meals.breakfast!.calories;
      if (meals.lunch != null) totalCalories += meals.lunch!.calories;
      if (meals.dinner != null) totalCalories += meals.dinner!.calories;
      
      print('[DEBUG] Updating meal plan with calculated calories: $totalCalories');
      
      final response = await _repository.updateMealPlan(
        date: date,
        meals: meals.toJson(),
      );
      if (response['meal_plan'] != null) {
        // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
        final mealPlanData = Map<String, dynamic>.from(response['meal_plan'] as Map);
        
        // Si la respuesta no incluye calorías totales, las añadimos
        if (!mealPlanData.containsKey('total_calories') || mealPlanData['total_calories'] == 0) {
          mealPlanData['total_calories'] = totalCalories;
        }
        
        final mealPlan = MealPlanModel.fromJson(mealPlanData);
        state = AsyncValue.data(mealPlan);
        // Invalidate both providers to refresh UI
        _ref.invalidate(mealPlanByDateProvider(date));
        _ref.invalidate(app_providers.mealPlanningProvider);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a meal plan
  Future<void> deleteMealPlan(String date) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMealPlan(date);
      state = const AsyncValue.data(null);
      // Invalidate both providers to refresh UI
      _ref.invalidate(mealPlanByDateProvider(date));
      _ref.invalidate(mealPlanningProvider);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Generate meal plan with AI
  Future<void> generateMealPlan(List<Map<String, dynamic>> ingredients) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.generateMealPlan(
        ingredients: ingredients,
      );
      if (response['meal_plan'] != null) {
        // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
        final mealPlanData = Map<String, dynamic>.from(response['meal_plan'] as Map);
        
        // Verificar si necesitamos calcular calorías
        if (!mealPlanData.containsKey('total_calories') || mealPlanData['total_calories'] == 0) {
          // Crear temporalmente el objeto para calcular calorías
          final tempMealPlan = MealPlanModel.fromJson(mealPlanData);
          
          // Calcular calorías totales
          int totalCalories = 0;
          if (tempMealPlan.meals.breakfast != null) totalCalories += tempMealPlan.meals.breakfast!.calories;
          if (tempMealPlan.meals.lunch != null) totalCalories += tempMealPlan.meals.lunch!.calories;
          if (tempMealPlan.meals.dinner != null) totalCalories += tempMealPlan.meals.dinner!.calories;
          
          // Actualizar el mapa con las calorías calculadas
          mealPlanData['total_calories'] = totalCalories;
          print('[DEBUG] Generated meal plan with calculated calories: $totalCalories');
        }
        
        final mealPlan = MealPlanModel.fromJson(mealPlanData);
        state = AsyncValue.data(mealPlan);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Load meal plan by date
  Future<void> loadMealPlan(String date) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getMealPlanByDate(date);
      if (response['meal_plan'] != null) {
        // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
        final mealPlanData = Map<String, dynamic>.from(response['meal_plan'] as Map);
        
        // Verificar si necesitamos calcular calorías
        if (!mealPlanData.containsKey('total_calories') || mealPlanData['total_calories'] == 0) {
          // Primero verificamos si es una estructura directa de comidas o tiene wrapper 'meals'
          Map<String, dynamic> mealsData;
          if (mealPlanData.containsKey('meals')) {
            mealsData = Map<String, dynamic>.from(mealPlanData['meals'] as Map);
          } else if (mealPlanData.containsKey('breakfast') || mealPlanData.containsKey('lunch') || 
                    mealPlanData.containsKey('dinner')) {
            mealsData = mealPlanData;
          } else {
            mealsData = {};
          }
          
          // Crear objeto DailyMeals para calcular calorías
          final dailyMeals = DailyMeals.fromJson(mealsData);
          
          // Calcular calorías totales
          int totalCalories = 0;
          if (dailyMeals.breakfast != null) totalCalories += dailyMeals.breakfast!.calories;
          if (dailyMeals.lunch != null) totalCalories += dailyMeals.lunch!.calories;
          if (dailyMeals.dinner != null) totalCalories += dailyMeals.dinner!.calories;
          
          // Actualizar el mapa con las calorías calculadas
          mealPlanData['total_calories'] = totalCalories;
          print('[DEBUG] Loaded meal plan with calculated calories: $totalCalories');
        }
        
        final mealPlan = MealPlanModel.fromJson(mealPlanData);
        state = AsyncValue.data(mealPlan);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider for editing state
class EditingState {
  final bool isEditing;
  final String? editingDate;
  final MealType? editingMealType;

  const EditingState({
    this.isEditing = false,
    this.editingDate,
    this.editingMealType,
  });

  EditingState copyWith({
    bool? isEditing,
    String? editingDate,
    MealType? editingMealType,
  }) {
    return EditingState(
      isEditing: isEditing ?? this.isEditing,
      editingDate: editingDate ?? this.editingDate,
      editingMealType: editingMealType ?? this.editingMealType,
    );
  }
}

/// Provider for editing state
final editingStateProvider = StateProvider<EditingState>((ref) {
  return const EditingState();
});

/// Provider for temporary meal data during editing
final tempMealProvider = StateProvider<Meal?>((ref) => null);

/// Provider for weekly meal plans
final weeklyMealPlansProvider =
    FutureProvider.family<List<MealPlanModel>, DateTime>((
      ref,
      startDate,
    ) async {
      final repository = ref.read(mealPlanRepositoryProvider);
      final plans = <MealPlanModel>[];

      // Get 7 days starting from startDate
      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(date);

        try {
          final response = await repository.getMealPlanByDate(dateString);
          if (response['meal_plan'] != null) {
            final mealPlanData = Map<String, dynamic>.from(response['meal_plan'] as Map);
            final mealPlan = MealPlanModel.fromJson(mealPlanData);
            plans.add(mealPlan);
          }
        } catch (e) {
          // Continue if individual day fails
        }
      }

      return plans;
    });

/// Provider for meal plan history
final mealPlanHistoryProvider = FutureProvider<List<MealPlanModel>>((
  ref,
) async {
  final repository = ref.read(mealPlanRepositoryProvider);
  try {
    final response = await repository.getMealPlanHistory();
    final mealPlansData = response['meal_plans'] as List<dynamic>;
    return mealPlansData.map((plan) {
      // Convertir explícitamente el mapa dinámico a Map<String, dynamic>
      final planData = Map<String, dynamic>.from(plan as Map);
      return MealPlanModel.fromJson(planData);
    }).toList();
  } catch (e) {
    return [];
  }
});

/// Utility functions for date management
class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(date);
  }

  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static List<DateTime> getWeekDates(DateTime startDate) {
    return List.generate(7, (index) => startDate.add(Duration(days: index)));
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }
}

/// Provider for date utilities
final dateUtilsProvider = Provider<DateUtils>((ref) => DateUtils());
