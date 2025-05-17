import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:intl/intl.dart';

/// Proveedor para la comida seleccionada
/// Utilizado para comunicación entre DailyPlannerWidget y PlannerScreen
final selectedMealProvider = StateProvider<MealPlan?>((ref) => null);

/// Proveedor para la fecha seleccionada en el planificador
/// Permite navegar directamente a una fecha específica
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

/// Proveedor para el día seleccionado dentro de la semana en el planificador
/// Por defecto es el día actual si está en la semana mostrada
final selectedDayProvider = StateProvider<DateTime?>((ref) {
  final today = DateTime.now();
  return today;
});

/// Proveedor para verificar si es la primera vez que el usuario planifica
/// Esto permite mostrar instrucciones y limitar la planificación a semanas pasadas
final isFirstPlanningProvider = StateProvider<bool>((ref) {
  // Verificar si hay alguna planificación previa
  final allMealPlans = ref.watch(mealPlansProvider);
  return allMealPlans.isEmpty; // Si no hay planes, es la primera vez
});

/// Proveedor para el historial de planificación
/// Mantiene un registro de semanas que han sido planificadas
final planningHistoryProvider =
    StateNotifierProvider<PlanningHistoryNotifier, List<String>>((ref) {
      return PlanningHistoryNotifier();
    });

/// Notifier para el historial de planificación
class PlanningHistoryNotifier extends StateNotifier<List<String>> {
  PlanningHistoryNotifier() : super([]);

  /// Añadir una semana al historial
  void addWeekToHistory(String weekKey) {
    if (!state.contains(weekKey)) {
      state = [...state, weekKey];
    }
  }

  /// Verificar si una semana está en el historial
  bool hasWeekInHistory(String weekKey) {
    return state.contains(weekKey);
  }
}

/// Clase para las preferencias de usuario en cuanto a planificación
class UserPlanningPreferences {
  final List<String> dietaryRestrictions; // Alergias, intolerancias, etc.
  final List<String> favoriteIngredients;
  final List<String> dislikedIngredients;
  final int maxMealsPerDay; // Límite de comidas por día

  UserPlanningPreferences({
    this.dietaryRestrictions = const [],
    this.favoriteIngredients = const [],
    this.dislikedIngredients = const [],
    this.maxMealsPerDay = 5, // Por defecto, máximo 5 comidas por día
  });
}

/// Proveedor para las preferencias de usuario
final userPlanningPreferencesProvider = StateProvider<UserPlanningPreferences>((
  ref,
) {
  return UserPlanningPreferences(); // Valores por defecto
});

/// Sistema de validaciones para la planificación de comidas
class MealPlanValidation {
  final bool isValid;
  final String message;
  final ValidationSeverity severity;

  MealPlanValidation({
    required this.isValid,
    required this.message,
    required this.severity,
  });

  /// Crear una validación exitosa
  factory MealPlanValidation.success() {
    return MealPlanValidation(
      isValid: true,
      message: 'Validación exitosa',
      severity: ValidationSeverity.success,
    );
  }

  /// Crear una advertencia
  factory MealPlanValidation.warning(String message) {
    return MealPlanValidation(
      isValid: true, // Aún es válido, pero con advertencia
      message: message,
      severity: ValidationSeverity.warning,
    );
  }

  /// Crear un error
  factory MealPlanValidation.error(String message) {
    return MealPlanValidation(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
    );
  }
}

/// Niveles de severidad para las validaciones
enum ValidationSeverity { success, info, warning, error }

/// Clase para el sistema de validaciones
class MealPlanValidator {
  /// Validar que no haya comidas duplicadas en un día
  static MealPlanValidation validateDuplicateMeals(
    MealPlan newMeal,
    List<MealPlan> existingMeals,
  ) {
    final duplicates =
        existingMeals.where((meal) => meal.name == newMeal.name).toList();

    if (duplicates.isNotEmpty) {
      return MealPlanValidation.warning(
        'Ya tienes planificada esta comida para este día. ¿Deseas agregarla de todos modos?',
      );
    }

    return MealPlanValidation.success();
  }

  /// Validar límite de comidas por tipo
  static MealPlanValidation validateMealTypeLimit(
    MealPlan newMeal,
    List<MealPlan> existingMeals,
  ) {
    final mealsOfSameType =
        existingMeals.where((meal) => meal.type == newMeal.type).toList();

    // Límites por tipo de comida
    final typeLimits = {
      MealType.breakfast: 1,
      MealType.lunch: 1,
      MealType.dinner: 1,
      MealType.snack: 3,
    };

    final limit = typeLimits[newMeal.type] ?? 1;

    if (mealsOfSameType.length >= limit) {
      // Para desayuno, almuerzo y cena, devolver error (no permitir más de 1)
      if (newMeal.type != MealType.snack) {
        return MealPlanValidation.error(
          'Solo puedes tener un ${newMeal.type.name.toLowerCase()} por día. '
          'Por favor, elimina el actual antes de agregar uno nuevo.',
        );
      }

      // Para snacks, mantener como advertencia (permitir continuar)
      return MealPlanValidation.warning(
        'Ya tienes ${mealsOfSameType.length} ${newMeal.type.name.toLowerCase()}(s) planificado(s). '
        'Se recomienda no exceder los ${limit} snacks por día.',
      );
    }

    return MealPlanValidation.success();
  }

  /// Validar planificación en fechas pasadas
  static MealPlanValidation validatePastDate(DateTime date) {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    if (date.isBefore(today) && !isToday) {
      return MealPlanValidation.error(
        'No puedes planificar comidas para fechas pasadas.',
      );
    }

    return MealPlanValidation.success();
  }

  /// Validar que los recordatorios sean para fechas futuras
  static MealPlanValidation validateReminders(
    DateTime date,
    List<String>? reminders,
  ) {
    if (reminders == null || reminders.isEmpty) {
      return MealPlanValidation.success();
    }

    final now = DateTime.now();

    // Si la fecha es hoy, verificar que aún haya tiempo para los recordatorios
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      // Buscar recordatorios que podrían ser inválidos
      final invalidReminders =
          reminders.where((reminder) {
            // Analizar el recordatorio para extraer el tiempo
            if (reminder.contains('hora')) {
              return true; // Para simplificar, solo verificamos la presencia
            }
            return false;
          }).toList();

      if (invalidReminders.isNotEmpty) {
        return MealPlanValidation.warning(
          'Algunos recordatorios podrían no tener tiempo suficiente para hoy.',
        );
      }
    }

    return MealPlanValidation.success();
  }

  /// Validar ingredientes contra restricciones dietéticas
  static MealPlanValidation validateDietaryRestrictions(
    MealPlan meal,
    List<String> dietaryRestrictions,
  ) {
    if (dietaryRestrictions.isEmpty) {
      return MealPlanValidation.success();
    }

    final conflictingIngredients =
        meal.ingredients
            .where(
              (ingredient) => dietaryRestrictions.any(
                (restriction) => ingredient.toLowerCase().contains(
                  restriction.toLowerCase(),
                ),
              ),
            )
            .toList();

    if (conflictingIngredients.isNotEmpty) {
      return MealPlanValidation.warning(
        'Esta comida contiene ingredientes que podrían no cumplir con tus restricciones dietéticas: '
        '${conflictingIngredients.join(', ')}.',
      );
    }

    return MealPlanValidation.success();
  }

  /// Validar la repetición de comidas en días consecutivos
  static MealPlanValidation validateConsecutiveMeals(
    String mealName,
    Map<String, List<MealPlan>> allMealPlans,
    String currentDateKey,
  ) {
    final date = DateFormat('yyyy-MM-dd').parse(currentDateKey);
    final yesterdayKey = DateFormat(
      'yyyy-MM-dd',
    ).format(date.subtract(const Duration(days: 1)));
    final tomorrowKey = DateFormat(
      'yyyy-MM-dd',
    ).format(date.add(const Duration(days: 1)));

    final yesterdayMeals = allMealPlans[yesterdayKey] ?? [];
    final tomorrowMeals = allMealPlans[tomorrowKey] ?? [];

    final repeatedYesterday = yesterdayMeals.any(
      (meal) => meal.name == mealName,
    );
    final repeatedTomorrow = tomorrowMeals.any((meal) => meal.name == mealName);

    if (repeatedYesterday || repeatedTomorrow) {
      return MealPlanValidation.warning(
        'Esta comida está planificada también para ${repeatedYesterday ? 'ayer' : 'mañana'}. '
        'Considera variar tu dieta.',
      );
    }

    return MealPlanValidation.success();
  }

  /// Validar que no se excedan las comidas máximas por día
  static MealPlanValidation validateMaxMealsPerDay(
    List<MealPlan> existingMeals,
    int maxMealsPerDay,
  ) {
    if (existingMeals.length >= maxMealsPerDay) {
      return MealPlanValidation.warning(
        'Ya tienes ${existingMeals.length} comidas planificadas para este día. '
        'Se recomienda no exceder las ${maxMealsPerDay} comidas diarias.',
      );
    }

    return MealPlanValidation.success();
  }

  /// Realizar todas las validaciones en conjunto
  static List<MealPlanValidation> validateMealPlan({
    required MealPlan newMeal,
    required String dateKey,
    required Map<String, List<MealPlan>> allMealPlans,
    required UserPlanningPreferences preferences,
  }) {
    final date = DateFormat('yyyy-MM-dd').parse(dateKey);
    final existingMeals = allMealPlans[dateKey] ?? [];
    final validations = <MealPlanValidation>[];

    // Validar fecha pasada
    validations.add(validatePastDate(date));

    // Si es una fecha inválida (pasada), no seguir con otras validaciones
    if (validations.any((v) => !v.isValid)) {
      return validations;
    }

    // Validar comidas duplicadas
    validations.add(validateDuplicateMeals(newMeal, existingMeals));

    // Validar límite por tipo de comida
    validations.add(validateMealTypeLimit(newMeal, existingMeals));

    // Validar máximo de comidas por día
    validations.add(
      validateMaxMealsPerDay(existingMeals, preferences.maxMealsPerDay),
    );

    // Validar repetición en días consecutivos
    validations.add(
      validateConsecutiveMeals(newMeal.name, allMealPlans, dateKey),
    );

    // Validar restricciones dietéticas
    validations.add(
      validateDietaryRestrictions(newMeal, preferences.dietaryRestrictions),
    );

    // Validar recordatorios
    validations.add(validateReminders(date, newMeal.reminders));

    return validations;
  }
}

/// Proveedor para los resultados de la última validación
final lastValidationResultsProvider = StateProvider<List<MealPlanValidation>>((
  ref,
) {
  return []; // No hay validaciones al inicio
});

/// Proveedor para almacenar todas las recetas disponibles
final allRecipesProvider =
    StateNotifierProvider<RecipeNotifier, List<MealPlan>>((ref) {
      return RecipeNotifier();
    });

/// Notifier para gestionar recetas
class RecipeNotifier extends StateNotifier<List<MealPlan>> {
  RecipeNotifier() : super(_getInitialRecipes());

  // Método para obtener recetas iniciales predefinidas
  static List<MealPlan> _getInitialRecipes() {
    return [
      MealPlan(
        id: '1',
        name: 'Ensalada mediterránea',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.lunch,
        ingredients: [
          'Tomate',
          'Pepino',
          'Aceitunas',
          'Queso feta',
          'Aceite de oliva',
        ],
        dietaryTags: ['Vegetariano', 'Sin gluten'],
        prepTimeMinutes: 15,
        calories: 320,
        difficulty: 'Fácil',
      ),
      MealPlan(
        id: '2',
        name: 'Omelette de espinacas y champiñones',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.breakfast,
        ingredients: ['Huevos', 'Espinacas', 'Champiñones', 'Queso', 'Leche'],
        dietaryTags: ['Vegetariano', 'Sin azúcar'],
        prepTimeMinutes: 20,
        calories: 280,
        difficulty: 'Media',
      ),
      MealPlan(
        id: '3',
        name: 'Bowl de quinoa con verduras asadas',
        imageUrl: 'assets/images/meal3.jpg',
        type: MealType.dinner,
        ingredients: [
          'Quinoa',
          'Calabacín',
          'Berenjena',
          'Pimientos',
          'Garbanzos',
        ],
        dietaryTags: ['Vegano', 'Sin gluten'],
        prepTimeMinutes: 35,
        calories: 410,
        difficulty: 'Media',
      ),
      // Nuevos desayunos
      MealPlan(
        id: '4',
        name: 'Tostadas de aguacate y huevo',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.breakfast,
        ingredients: [
          'Pan integral',
          'Aguacate',
          'Huevo',
          'Tomate cherry',
          'Cilantro',
          'Limón',
        ],
        dietaryTags: ['Vegetariano', 'Alto en proteínas'],
        prepTimeMinutes: 15,
        calories: 350,
        difficulty: 'Fácil',
      ),
      MealPlan(
        id: '5',
        name: 'Yogur griego con frutas y granola',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.breakfast,
        ingredients: [
          'Yogur griego',
          'Fresas',
          'Arándanos',
          'Plátano',
          'Granola',
          'Miel',
        ],
        dietaryTags: ['Vegetariano', 'Alto en proteínas'],
        prepTimeMinutes: 5,
        calories: 280,
        difficulty: 'Fácil',
      ),
      MealPlan(
        id: '6',
        name: 'Smoothie verde energético',
        imageUrl: 'assets/images/meal3.jpg',
        type: MealType.breakfast,
        ingredients: [
          'Espinacas',
          'Plátano',
          'Manzana verde',
          'Semillas de chía',
          'Leche de almendras',
          'Miel',
        ],
        dietaryTags: ['Vegetariano', 'Sin gluten', 'Sin lácteos'],
        prepTimeMinutes: 10,
        calories: 220,
        difficulty: 'Fácil',
      ),
      // Nuevos almuerzos
      MealPlan(
        id: '7',
        name: 'Wrap de pollo y aguacate',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.lunch,
        ingredients: [
          'Tortilla integral',
          'Pechuga de pollo',
          'Aguacate',
          'Lechuga',
          'Tomate',
          'Cebolla morada',
          'Yogur griego',
        ],
        dietaryTags: ['Alto en proteínas'],
        prepTimeMinutes: 20,
        calories: 420,
        difficulty: 'Media',
      ),
      MealPlan(
        id: '8',
        name: 'Pasta integral con pesto casero',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.lunch,
        ingredients: [
          'Pasta integral',
          'Albahaca',
          'Piñones',
          'Ajo',
          'Queso parmesano',
          'Aceite de oliva',
          'Limón',
        ],
        dietaryTags: ['Vegetariano'],
        prepTimeMinutes: 25,
        calories: 480,
        difficulty: 'Media',
      ),
      MealPlan(
        id: '9',
        name: 'Buddha bowl de garbanzos y vegetales',
        imageUrl: 'assets/images/meal3.jpg',
        type: MealType.lunch,
        ingredients: [
          'Garbanzos',
          'Batata asada',
          'Brócoli',
          'Aguacate',
          'Hummus',
          'Semillas de sésamo',
          'Quinoa',
        ],
        dietaryTags: ['Vegano', 'Sin gluten', 'Alto en proteínas'],
        prepTimeMinutes: 30,
        calories: 450,
        difficulty: 'Media',
      ),
      // Nuevas cenas
      MealPlan(
        id: '10',
        name: 'Salmón al horno con espárragos',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.dinner,
        ingredients: [
          'Filete de salmón',
          'Espárragos',
          'Limón',
          'Ajo',
          'Aceite de oliva',
          'Eneldo',
          'Pimienta negra',
        ],
        dietaryTags: [
          'Sin gluten',
          'Alto en proteínas',
          'Bajo en carbohidratos',
        ],
        prepTimeMinutes: 25,
        calories: 380,
        difficulty: 'Media',
      ),
      MealPlan(
        id: '11',
        name: 'Curry de lentejas y verduras',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.dinner,
        ingredients: [
          'Lentejas',
          'Leche de coco',
          'Cebolla',
          'Zanahoria',
          'Espinacas',
          'Curry en polvo',
          'Arroz basmati',
        ],
        dietaryTags: ['Vegano', 'Sin gluten'],
        prepTimeMinutes: 35,
        calories: 410,
        difficulty: 'Media',
      ),
      MealPlan(
        id: '12',
        name: 'Pollo al limón con verduras salteadas',
        imageUrl: 'assets/images/meal3.jpg',
        type: MealType.dinner,
        ingredients: [
          'Pechuga de pollo',
          'Limón',
          'Ajo',
          'Brócoli',
          'Pimiento rojo',
          'Cebolla',
          'Jengibre',
          'Salsa de soja',
        ],
        dietaryTags: [
          'Sin lácteos',
          'Alto en proteínas',
          'Bajo en carbohidratos',
        ],
        prepTimeMinutes: 30,
        calories: 350,
        difficulty: 'Media',
      ),
      // Nuevos snacks
      MealPlan(
        id: '13',
        name: 'Hummus casero con crudités',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.snack,
        ingredients: [
          'Garbanzos',
          'Tahini',
          'Limón',
          'Ajo',
          'Aceite de oliva',
          'Zanahoria',
          'Pepino',
          'Pimiento',
        ],
        dietaryTags: ['Vegano', 'Sin gluten'],
        prepTimeMinutes: 15,
        calories: 180,
        difficulty: 'Fácil',
      ),
      MealPlan(
        id: '14',
        name: 'Tostadas de plátano y mantequilla de almendras',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.snack,
        ingredients: [
          'Pan integral',
          'Plátano',
          'Mantequilla de almendras',
          'Canela',
          'Miel',
        ],
        dietaryTags: ['Vegetariano', 'Sin lácteos'],
        prepTimeMinutes: 5,
        calories: 220,
        difficulty: 'Fácil',
      ),
      MealPlan(
        id: '15',
        name: 'Trail mix energético',
        imageUrl: 'assets/images/meal3.jpg',
        type: MealType.snack,
        ingredients: [
          'Almendras',
          'Nueces',
          'Arándanos secos',
          'Pasas',
          'Semillas de calabaza',
          'Chips de coco',
        ],
        dietaryTags: ['Vegano', 'Sin gluten', 'Alto en proteínas'],
        prepTimeMinutes: 5,
        calories: 210,
        difficulty: 'Fácil',
      ),
      MealPlan(
        id: '16',
        name: 'Batido de proteínas con frutos rojos',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.snack,
        ingredients: [
          'Proteína en polvo',
          'Fresas',
          'Arándanos',
          'Plátano',
          'Leche de almendras',
          'Hielo',
        ],
        dietaryTags: ['Vegetariano', 'Sin gluten', 'Alto en proteínas'],
        prepTimeMinutes: 5,
        calories: 180,
        difficulty: 'Fácil',
      ),
      // Recetas más elaboradas
      MealPlan(
        id: '17',
        name: 'Risotto de champiñones y espárragos',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.dinner,
        ingredients: [
          'Arroz arborio',
          'Champiñones',
          'Espárragos',
          'Cebolla',
          'Ajo',
          'Vino blanco',
          'Caldo vegetal',
          'Queso parmesano',
          'Mantequilla',
        ],
        dietaryTags: ['Vegetariano'],
        prepTimeMinutes: 45,
        calories: 520,
        difficulty: 'Difícil',
      ),
      MealPlan(
        id: '18',
        name: 'Lasaña vegetal sin gluten',
        imageUrl: 'assets/images/meal3.jpg',
        type: MealType.dinner,
        ingredients: [
          'Láminas de lasaña sin gluten',
          'Berenjena',
          'Calabacín',
          'Espinacas',
          'Tomate',
          'Cebolla',
          'Ajo',
          'Queso ricotta',
          'Queso mozzarella',
          'Albahaca',
        ],
        dietaryTags: ['Vegetariano', 'Sin gluten'],
        prepTimeMinutes: 60,
        calories: 480,
        difficulty: 'Difícil',
      ),
      MealPlan(
        id: '19',
        name: 'Tacos saludables de pescado',
        imageUrl: 'assets/images/meal1.jpg',
        type: MealType.lunch,
        ingredients: [
          'Tilapia o pescado blanco',
          'Tortillas de maíz',
          'Col morada',
          'Aguacate',
          'Cilantro',
          'Lima',
          'Yogur griego',
          'Chiles',
          'Comino',
        ],
        dietaryTags: ['Sin gluten', 'Alto en proteínas'],
        prepTimeMinutes: 30,
        calories: 380,
        difficulty: 'Media',
      ),
      MealPlan(
        id: '20',
        name: 'Pancakes de avena y plátano',
        imageUrl: 'assets/images/meal2.jpg',
        type: MealType.breakfast,
        ingredients: [
          'Avena',
          'Plátano maduro',
          'Huevos',
          'Canela',
          'Extracto de vainilla',
          'Frutos rojos',
          'Miel o sirope de arce',
        ],
        dietaryTags: ['Vegetariano', 'Sin gluten', 'Sin azúcar refinado'],
        prepTimeMinutes: 20,
        calories: 340,
        difficulty: 'Media',
        isFavorite: true,
      ),
    ];
  }

  // Añadir una nueva receta
  void addRecipe(MealPlan recipe) {
    state = [...state, recipe];
  }

  // Eliminar una receta
  void removeRecipe(String id) {
    state = state.where((recipe) => recipe.id != id).toList();
  }

  // Editar una receta existente
  void editRecipe(String id, MealPlan updatedRecipe) {
    state =
        state
            .map((recipe) => recipe.id == id ? updatedRecipe : recipe)
            .toList();
  }

  // Marcar/desmarcar como favorita
  void toggleFavorite(String id) {
    state =
        state.map((recipe) {
          if (recipe.id == id) {
            return recipe.copyWith(isFavorite: !recipe.isFavorite);
          }
          return recipe;
        }).toList();
  }

  // Actualizar fecha de último uso
  void updateLastUsed(String id) {
    state =
        state.map((recipe) {
          if (recipe.id == id) {
            return recipe.copyWith(lastUsed: DateTime.now());
          }
          return recipe;
        }).toList();
  }

  // Obtener recetas por tipo
  List<MealPlan> getByType(MealType type) {
    return state.where((recipe) => recipe.type == type).toList();
  }

  // Obtener recetas favoritas
  List<MealPlan> getFavorites() {
    return state.where((recipe) => recipe.isFavorite).toList();
  }

  // Obtener recetas recientes
  List<MealPlan> getRecent() {
    final recipesCopy = [...state];
    recipesCopy.sort((a, b) {
      if (a.lastUsed == null && b.lastUsed == null) return 0;
      if (a.lastUsed == null) return 1;
      if (b.lastUsed == null) return -1;
      return b.lastUsed!.compareTo(a.lastUsed!);
    });
    return recipesCopy.take(5).toList(); // Retornar las 5 recetas más recientes
  }

  // Filtrar recetas por etiquetas dietéticas
  List<MealPlan> filterByDietaryTags(List<String> tags) {
    if (tags.isEmpty) return state;
    return state.where((recipe) {
      for (final tag in tags) {
        if (recipe.dietaryTags.contains(tag)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  // Filtrar por tiempo de preparación máximo (en minutos)
  List<MealPlan> filterByMaxPrepTime(int maxMinutes) {
    return state
        .where((recipe) => recipe.prepTimeMinutes <= maxMinutes)
        .toList();
  }

  // Filtrar por calorías máximas
  List<MealPlan> filterByMaxCalories(int maxCalories) {
    return state.where((recipe) => recipe.calories <= maxCalories).toList();
  }

  // Buscar recetas por nombre o ingredientes
  List<MealPlan> searchRecipes(String query) {
    if (query.isEmpty) return state;
    query = query.toLowerCase();
    return state.where((recipe) {
      final nameMatch = recipe.name.toLowerCase().contains(query);
      final ingredientMatch = recipe.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(query),
      );
      return nameMatch || ingredientMatch;
    }).toList();
  }
}

/// Proveedor para filtros de recetas activos
final recipeFiltersProvider = StateProvider<RecipeFilters>((ref) {
  return RecipeFilters();
});

/// Clase para almacenar filtros de recetas
class RecipeFilters {
  final List<String> dietaryTags;
  final int? maxPrepTimeMinutes;
  final int? maxCalories;
  final String? searchQuery;
  final MealType? mealType;

  RecipeFilters({
    this.dietaryTags = const [],
    this.maxPrepTimeMinutes,
    this.maxCalories,
    this.searchQuery,
    this.mealType,
  });

  RecipeFilters copyWith({
    List<String>? dietaryTags,
    int? maxPrepTimeMinutes,
    int? maxCalories,
    String? searchQuery,
    MealType? mealType,
    bool clearPrepTime = false,
    bool clearCalories = false,
    bool clearSearch = false,
    bool clearMealType = false,
  }) {
    return RecipeFilters(
      dietaryTags: dietaryTags ?? this.dietaryTags,
      maxPrepTimeMinutes:
          clearPrepTime ? null : maxPrepTimeMinutes ?? this.maxPrepTimeMinutes,
      maxCalories: clearCalories ? null : maxCalories ?? this.maxCalories,
      searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
      mealType: clearMealType ? null : mealType ?? this.mealType,
    );
  }

  bool get hasFilters =>
      dietaryTags.isNotEmpty ||
      maxPrepTimeMinutes != null ||
      maxCalories != null ||
      searchQuery != null ||
      mealType != null;
}

/// Proveedor para recetas filtradas
final filteredRecipesProvider = Provider<List<MealPlan>>((ref) {
  final allRecipes = ref.watch(allRecipesProvider);
  final filters = ref.watch(recipeFiltersProvider);

  var result = allRecipes;

  // Aplicar filtros
  if (filters.dietaryTags.isNotEmpty) {
    result =
        result.where((recipe) {
          for (final tag in filters.dietaryTags) {
            if (recipe.dietaryTags.contains(tag)) {
              return true;
            }
          }
          return false;
        }).toList();
  }

  if (filters.maxPrepTimeMinutes != null) {
    result =
        result
            .where(
              (recipe) => recipe.prepTimeMinutes <= filters.maxPrepTimeMinutes!,
            )
            .toList();
  }

  if (filters.maxCalories != null) {
    result =
        result
            .where((recipe) => recipe.calories <= filters.maxCalories!)
            .toList();
  }

  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    final query = filters.searchQuery!.toLowerCase();
    result =
        result.where((recipe) {
          final nameMatch = recipe.name.toLowerCase().contains(query);
          final ingredientMatch = recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(query),
          );
          return nameMatch || ingredientMatch;
        }).toList();
  }

  if (filters.mealType != null) {
    result = result.where((recipe) => recipe.type == filters.mealType).toList();
  }

  return result;
});

/// Proveedor para recetas favoritas
final favoriteRecipesProvider = Provider<List<MealPlan>>((ref) {
  final allRecipes = ref.watch(allRecipesProvider);
  return allRecipes.where((recipe) => recipe.isFavorite).toList();
});

/// Proveedor para recetas recientes
final recentRecipesProvider = Provider<List<MealPlan>>((ref) {
  final allRecipes = ref.watch(allRecipesProvider);
  final recipesCopy = [...allRecipes];
  recipesCopy.sort((a, b) {
    if (a.lastUsed == null && b.lastUsed == null) return 0;
    if (a.lastUsed == null) return 1;
    if (b.lastUsed == null) return -1;
    return b.lastUsed!.compareTo(a.lastUsed!);
  });
  return recipesCopy.take(5).toList(); // Retornar las 5 recetas más recientes
});

/// Proveedor para sugerencias de IA
final aiSuggestionsProvider = FutureProvider.family<
  List<MealPlan>,
  Map<String, dynamic>
>((ref, parameters) async {
  // Aquí llamaríamos a un servicio de AI real
  // Por ahora, simularemos las sugerencias basadas en parámetros

  final allRecipes = ref.read(allRecipesProvider);
  final MealType? mealType = parameters['mealType'] as MealType?;
  final List<String>? dietaryTags = parameters['dietaryTags'] as List<String>?;
  final List<String>? availableIngredients =
      parameters['availableIngredients'] as List<String>?;

  // Simular tiempo de procesamiento
  await Future.delayed(const Duration(seconds: 1));

  // Filtrar recetas
  var suggestions = [...allRecipes];

  // Filtrar por tipo de comida
  if (mealType != null) {
    suggestions =
        suggestions.where((recipe) => recipe.type == mealType).toList();
  }

  // Filtrar por etiquetas dietéticas
  if (dietaryTags != null && dietaryTags.isNotEmpty) {
    suggestions =
        suggestions.where((recipe) {
          for (final tag in dietaryTags) {
            if (recipe.dietaryTags.contains(tag)) {
              return true;
            }
          }
          return false;
        }).toList();
  }

  // Filtrar por ingredientes disponibles
  if (availableIngredients != null && availableIngredients.isNotEmpty) {
    // Calcular un puntaje basado en cuántos ingredientes coinciden
    suggestions.sort((a, b) {
      int aMatches = 0;
      int bMatches = 0;

      for (final ingredient in a.ingredients) {
        if (availableIngredients.any(
          (i) =>
              ingredient.toLowerCase().contains(i.toLowerCase()) ||
              i.toLowerCase().contains(ingredient.toLowerCase()),
        )) {
          aMatches++;
        }
      }

      for (final ingredient in b.ingredients) {
        if (availableIngredients.any(
          (i) =>
              ingredient.toLowerCase().contains(i.toLowerCase()) ||
              i.toLowerCase().contains(ingredient.toLowerCase()),
        )) {
          bMatches++;
        }
      }

      // Calcular porcentaje de coincidencia
      final aMatchPercent = aMatches / a.ingredients.length;
      final bMatchPercent = bMatches / b.ingredients.length;

      // Ordenar por mayor porcentaje de coincidencia
      return bMatchPercent.compareTo(aMatchPercent);
    });
  }

  // Retornar las 5 mejores sugerencias
  return suggestions.take(5).toList();
});
