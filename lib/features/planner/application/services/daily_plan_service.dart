import 'package:intl/intl.dart';
import '../../domain/models/meal_plan_models.dart';

class DailyPlanService {
  // For development, using mock data. TODO: Connect to real API
  
  /// Generate automatic daily meal plan using AI
  Future<MealPlanModel> generateAutomaticPlan({
    required DateTime date,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    int? targetCalories,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Generate balanced meals for the day
    final meals = _generateBalancedMeals(
      targetCalories: targetCalories ?? 2000,
      dietaryPreferences: dietaryPreferences ?? [],
      allergies: allergies ?? [],
    );
    
    final totalCalories = meals.totalCalories;
    
    return MealPlanModel(
      uid: 'auto_${DateTime.now().millisecondsSinceEpoch}',
      date: DateFormat('yyyy-MM-dd').format(date),
      meals: meals,
      totalCalories: totalCalories,
      createdAt: DateTime.now(),
    );
  }
  
  /// Create manual meal plan template
  MealPlanModel createEmptyManualPlan(DateTime date) {
    return MealPlanModel(
      uid: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      date: DateFormat('yyyy-MM-dd').format(date),
      meals: const DailyMeals(),
      totalCalories: 0,
      createdAt: DateTime.now(),
    );
  }
  
  /// Generate balanced meals for automatic plan
  DailyMeals _generateBalancedMeals({
    required int targetCalories,
    required List<String> dietaryPreferences,
    required List<String> allergies,
  }) {
    // Distribute calories: 30% breakfast, 40% lunch, 30% dinner
    final breakfastCalories = (targetCalories * 0.30).round();
    final lunchCalories = (targetCalories * 0.40).round();
    final dinnerCalories = (targetCalories * 0.30).round();
    
    return DailyMeals(
      breakfast: _generateMeal(
        type: MealType.breakfast,
        targetCalories: breakfastCalories,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
      ),
      lunch: _generateMeal(
        type: MealType.lunch,
        targetCalories: lunchCalories,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
      ),
      dinner: _generateMeal(
        type: MealType.dinner,
        targetCalories: dinnerCalories,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
      ),
    );
  }
  
  /// Generate individual meal based on criteria
  Meal _generateMeal({
    required MealType type,
    required int targetCalories,
    required List<String> dietaryPreferences,
    required List<String> allergies,
  }) {
    final recipes = _getMealRecipes(type);
    
    // Find recipe that best matches criteria
    Meal selectedMeal = recipes.first;
    int bestScore = 0;
    
    for (final recipe in recipes) {
      int score = 0;
      
      // Prefer recipes closer to target calories
      final caloriesDiff = (recipe.calories - targetCalories).abs();
      if (caloriesDiff < 100) {
        score += 3;
      } else if (caloriesDiff < 200) {
        score += 2;
      } else {
        score += 1;
      }
      
      // Consider dietary preferences
      for (final pref in dietaryPreferences) {
        if (_recipeMatchesPreference(recipe, pref)) {
          score += 2;
        }
      }
      
      // Avoid allergens
      bool hasAllergen = false;
      for (final allergen in allergies) {
        if (_recipeContainsAllergen(recipe, allergen)) {
          hasAllergen = true;
          break;
        }
      }
      
      if (!hasAllergen && score > bestScore) {
        bestScore = score;
        selectedMeal = recipe;
      }
    }
    
    return selectedMeal;
  }
  
  /// Get recipe options for meal type
  List<Meal> _getMealRecipes(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return [
          Meal(
            recipeTitle: 'Avena con Frutas y Miel',
            ingredientsNeeded: [
              const MealIngredient(name: 'Avena', quantity: 50, unit: 'gramos'),
              const MealIngredient(name: 'Leche', quantity: 200, unit: 'ml'),
              const MealIngredient(name: 'Plátano', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Fresas', quantity: 100, unit: 'gramos'),
              const MealIngredient(name: 'Miel', quantity: 1, unit: 'cucharada'),
            ],
            prepTime: 10,
            calories: 380,
          ),
          Meal(
            recipeTitle: 'Tostadas de Aguacate',
            ingredientsNeeded: [
              const MealIngredient(name: 'Pan integral', quantity: 2, unit: 'rebanadas'),
              const MealIngredient(name: 'Aguacate', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Tomate', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Limón', quantity: 1, unit: 'mitad'),
            ],
            prepTime: 8,
            calories: 320,
          ),
          Meal(
            recipeTitle: 'Huevos Revueltos con Vegetales',
            ingredientsNeeded: [
              const MealIngredient(name: 'Huevos', quantity: 2, unit: 'unidades'),
              const MealIngredient(name: 'Espinacas', quantity: 50, unit: 'gramos'),
              const MealIngredient(name: 'Pimiento', quantity: 1, unit: 'mitad'),
              const MealIngredient(name: 'Queso', quantity: 30, unit: 'gramos'),
            ],
            prepTime: 12,
            calories: 280,
          ),
          Meal(
            recipeTitle: 'Smoothie Verde Energizante',
            ingredientsNeeded: [
              const MealIngredient(name: 'Espinacas', quantity: 100, unit: 'gramos'),
              const MealIngredient(name: 'Manzana verde', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Plátano', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Agua de coco', quantity: 250, unit: 'ml'),
            ],
            prepTime: 5,
            calories: 200,
          ),
        ];
      case MealType.lunch:
        return [
          Meal(
            recipeTitle: 'Ensalada César con Pollo',
            ingredientsNeeded: [
              const MealIngredient(name: 'Pechuga de pollo', quantity: 150, unit: 'gramos'),
              const MealIngredient(name: 'Lechuga romana', quantity: 200, unit: 'gramos'),
              const MealIngredient(name: 'Queso parmesano', quantity: 30, unit: 'gramos'),
              const MealIngredient(name: 'Crutones', quantity: 20, unit: 'gramos'),
            ],
            prepTime: 20,
            calories: 450,
          ),
          Meal(
            recipeTitle: 'Pasta con Vegetales',
            ingredientsNeeded: [
              const MealIngredient(name: 'Pasta integral', quantity: 100, unit: 'gramos'),
              const MealIngredient(name: 'Brócoli', quantity: 150, unit: 'gramos'),
              const MealIngredient(name: 'Zanahoria', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Aceite de oliva', quantity: 1, unit: 'cucharada'),
            ],
            prepTime: 25,
            calories: 420,
          ),
          Meal(
            recipeTitle: 'Sopa de Lentejas',
            ingredientsNeeded: [
              const MealIngredient(name: 'Lentejas', quantity: 100, unit: 'gramos'),
              const MealIngredient(name: 'Zanahoria', quantity: 2, unit: 'unidades'),
              const MealIngredient(name: 'Cebolla', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Caldo de verduras', quantity: 500, unit: 'ml'),
            ],
            prepTime: 35,
            calories: 380,
          ),
          Meal(
            recipeTitle: 'Bowl de Quinoa',
            ingredientsNeeded: [
              const MealIngredient(name: 'Quinoa', quantity: 80, unit: 'gramos'),
              const MealIngredient(name: 'Garbanzos', quantity: 100, unit: 'gramos'),
              const MealIngredient(name: 'Aguacate', quantity: 1, unit: 'mitad'),
              const MealIngredient(name: 'Tomate cherry', quantity: 100, unit: 'gramos'),
            ],
            prepTime: 18,
            calories: 480,
          ),
        ];
      case MealType.dinner:
        return [
          Meal(
            recipeTitle: 'Salmón Grillado con Vegetales',
            ingredientsNeeded: [
              const MealIngredient(name: 'Salmón', quantity: 120, unit: 'gramos'),
              const MealIngredient(name: 'Espárragos', quantity: 150, unit: 'gramos'),
              const MealIngredient(name: 'Brócoli', quantity: 100, unit: 'gramos'),
              const MealIngredient(name: 'Limón', quantity: 1, unit: 'mitad'),
            ],
            prepTime: 20,
            calories: 350,
          ),
          Meal(
            recipeTitle: 'Ensalada de Vegetales Asados',
            ingredientsNeeded: [
              const MealIngredient(name: 'Calabacín', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Berenjena', quantity: 1, unit: 'mitad'),
              const MealIngredient(name: 'Pimiento rojo', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Queso feta', quantity: 50, unit: 'gramos'),
            ],
            prepTime: 30,
            calories: 280,
          ),
          Meal(
            recipeTitle: 'Pollo al Horno con Hierbas',
            ingredientsNeeded: [
              const MealIngredient(name: 'Pechuga de pollo', quantity: 150, unit: 'gramos'),
              const MealIngredient(name: 'Batata', quantity: 1, unit: 'unidad'),
              const MealIngredient(name: 'Romero', quantity: 2, unit: 'ramitas'),
              const MealIngredient(name: 'Aceite de oliva', quantity: 1, unit: 'cucharada'),
            ],
            prepTime: 35,
            calories: 400,
          ),
          Meal(
            recipeTitle: 'Crema de Calabaza',
            ingredientsNeeded: [
              const MealIngredient(name: 'Calabaza', quantity: 300, unit: 'gramos'),
              const MealIngredient(name: 'Cebolla', quantity: 1, unit: 'mitad'),
              const MealIngredient(name: 'Caldo de verduras', quantity: 400, unit: 'ml'),
              const MealIngredient(name: 'Crema de leche', quantity: 50, unit: 'ml'),
            ],
            prepTime: 25,
            calories: 220,
          ),
        ];
      case MealType.snack:
        return [
          Meal(
            recipeTitle: 'Mix de Frutos Secos',
            ingredientsNeeded: [
              const MealIngredient(name: 'Almendras', quantity: 20, unit: 'gramos'),
              const MealIngredient(name: 'Nueces', quantity: 15, unit: 'gramos'),
              const MealIngredient(name: 'Pasas', quantity: 10, unit: 'gramos'),
            ],
            prepTime: 2,
            calories: 180,
          ),
        ];
    }
  }
  
  /// Check if recipe matches dietary preference
  bool _recipeMatchesPreference(Meal recipe, String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetariano':
        return !_containsMeat(recipe);
      case 'vegano':
        return !_containsMeat(recipe) && !_containsDairy(recipe);
      case 'sin gluten':
        return !_containsGluten(recipe);
      case 'bajo en carbohidratos':
        return recipe.calories < 300;
      default:
        return false;
    }
  }
  
  /// Check if recipe contains allergen
  bool _recipeContainsAllergen(Meal recipe, String allergen) {
    switch (allergen.toLowerCase()) {
      case 'lácteos':
        return _containsDairy(recipe);
      case 'huevos':
        return _containsEggs(recipe);
      case 'frutos secos':
        return _containsNuts(recipe);
      case 'gluten':
        return _containsGluten(recipe);
      default:
        return false;
    }
  }
  
  bool _containsMeat(Meal recipe) {
    final meatKeywords = ['pollo', 'carne', 'pescado', 'salmón', 'atún', 'pavo'];
    return recipe.ingredientsNeeded.any((ingredient) =>
        meatKeywords.any((keyword) => ingredient.name.toLowerCase().contains(keyword)));
  }
  
  bool _containsDairy(Meal recipe) {
    final dairyKeywords = ['leche', 'queso', 'yogurt', 'mantequilla', 'crema'];
    return recipe.ingredientsNeeded.any((ingredient) =>
        dairyKeywords.any((keyword) => ingredient.name.toLowerCase().contains(keyword)));
  }
  
  bool _containsEggs(Meal recipe) {
    return recipe.ingredientsNeeded.any((ingredient) =>
        ingredient.name.toLowerCase().contains('huevo'));
  }
  
  bool _containsNuts(Meal recipe) {
    final nutKeywords = ['almendra', 'nuez', 'maní', 'avellana', 'pistacho'];
    return recipe.ingredientsNeeded.any((ingredient) =>
        nutKeywords.any((keyword) => ingredient.name.toLowerCase().contains(keyword)));
  }
  
  bool _containsGluten(Meal recipe) {
    final glutenKeywords = ['pan', 'pasta', 'harina', 'trigo', 'avena'];
    return recipe.ingredientsNeeded.any((ingredient) =>
        glutenKeywords.any((keyword) => ingredient.name.toLowerCase().contains(keyword)));
  }
}