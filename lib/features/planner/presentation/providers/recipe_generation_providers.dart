import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal_plan_models.dart';

// Recipe generation state
class RecipeGenerationState {
  final List<GeneratedRecipe> recipes;
  final bool isLoading;
  final String? error;
  final String? imageTaskId;

  const RecipeGenerationState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
    this.imageTaskId,
  });

  RecipeGenerationState copyWith({
    List<GeneratedRecipe>? recipes,
    bool? isLoading,
    String? error,
    String? imageTaskId,
  }) {
    return RecipeGenerationState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      imageTaskId: imageTaskId ?? this.imageTaskId,
    );
  }
}

// Recipe generation notifier
class RecipeGenerationNotifier extends StateNotifier<RecipeGenerationState> {
  RecipeGenerationNotifier() : super(const RecipeGenerationState());

  Future<void> generateCustomRecipes({
    required MealType mealType,
    int numRecipes = 5,
    List<String>? preferences,
    List<String>? categories,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Generate mock recipes for development
      final recipes = _getMockRecipes(mealType);
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        recipes: recipes,
        imageTaskId: 'mock-task-id',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearRecipes() {
    state = const RecipeGenerationState();
  }

  // Mock data generation
  List<GeneratedRecipe> _getMockRecipes(MealType mealType) {
    final now = DateTime.now();
    
    switch (mealType) {
      case MealType.breakfast:
        return [
          GeneratedRecipe(
            title: 'Tostadas con Aguacate',
            description: 'Desayuno nutritivo y delicioso con aguacate fresco',
            ingredients: [
              const RecipeIngredient(name: 'Pan integral', quantity: 2, unit: 'rebanadas'),
              const RecipeIngredient(name: 'Aguacate', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Tomate cherry', quantity: 5, unit: 'unidades'),
            ],
            instructions: [
              'Tostar el pan hasta que esté dorado',
              'Machacar el aguacate con un tenedor',
              'Untar el aguacate sobre el pan',
              'Decorar con tomates cherry cortados',
            ],
            prepTime: 10,
            cookTime: 5,
            servings: 1,
            difficulty: 'Fácil',
            calories: 320,
            dietaryInfo: ['Vegetariano', 'Sin lácteos'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Smoothie Verde Energizante',
            description: 'Batido lleno de vitaminas para empezar el día',
            ingredients: [
              const RecipeIngredient(name: 'Espinacas', quantity: 1, unit: 'taza'),
              const RecipeIngredient(name: 'Plátano', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Manzana verde', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Agua', quantity: 200, unit: 'ml'),
            ],
            instructions: [
              'Lavar bien las espinacas',
              'Pelar el plátano y cortar en trozos',
              'Cortar la manzana en trozos',
              'Licuar todos los ingredientes hasta obtener consistencia suave',
            ],
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            difficulty: 'Fácil',
            calories: 180,
            dietaryInfo: ['Vegano', 'Sin gluten'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Avena con Frutas',
            description: 'Desayuno completo con avena y frutas frescas',
            ingredients: [
              const RecipeIngredient(name: 'Avena', quantity: 0.5, unit: 'taza'),
              const RecipeIngredient(name: 'Leche', quantity: 1, unit: 'taza'),
              const RecipeIngredient(name: 'Fresas', quantity: 5, unit: 'unidades'),
              const RecipeIngredient(name: 'Miel', quantity: 1, unit: 'cucharada'),
            ],
            instructions: [
              'Cocinar la avena con la leche a fuego medio',
              'Revolver hasta espesar',
              'Cortar las fresas en trozos',
              'Servir la avena y decorar con fresas y miel',
            ],
            prepTime: 5,
            cookTime: 10,
            servings: 1,
            difficulty: 'Fácil',
            calories: 250,
            dietaryInfo: ['Vegetariano'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Huevos Revueltos con Hierbas',
            description: 'Huevos cremosos con hierbas aromáticas',
            ingredients: [
              const RecipeIngredient(name: 'Huevos', quantity: 2, unit: 'unidades'),
              const RecipeIngredient(name: 'Mantequilla', quantity: 1, unit: 'cucharada'),
              const RecipeIngredient(name: 'Cebollín', quantity: 2, unit: 'cucharadas'),
              const RecipeIngredient(name: 'Sal y pimienta', quantity: 1, unit: 'pizca'),
            ],
            instructions: [
              'Batir los huevos en un bowl',
              'Derretir mantequilla en sartén a fuego bajo',
              'Agregar huevos y revolver constantemente',
              'Retirar del fuego y agregar cebollín, sal y pimienta',
            ],
            prepTime: 5,
            cookTime: 8,
            servings: 1,
            difficulty: 'Fácil',
            calories: 220,
            dietaryInfo: ['Vegetariano', 'Bajo en carbohidratos'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Yogurt Parfait con Granola',
            description: 'Layers de yogurt, granola y frutas',
            ingredients: [
              const RecipeIngredient(name: 'Yogurt griego', quantity: 200, unit: 'gramos'),
              const RecipeIngredient(name: 'Granola', quantity: 3, unit: 'cucharadas'),
              const RecipeIngredient(name: 'Arándanos', quantity: 0.5, unit: 'taza'),
              const RecipeIngredient(name: 'Miel', quantity: 1, unit: 'cucharadita'),
            ],
            instructions: [
              'En un vaso, poner una capa de yogurt',
              'Agregar granola sobre el yogurt',
              'Añadir arándanos',
              'Repetir las capas y finalizar con miel',
            ],
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            difficulty: 'Muy fácil',
            calories: 280,
            dietaryInfo: ['Vegetariano', 'Probióticos'],
            generatedAt: now,
          ),
        ];
      case MealType.lunch:
        return [
          GeneratedRecipe(
            title: 'Pasta con Tomate y Albahaca',
            description: 'Clásica pasta italiana con ingredientes frescos',
            ingredients: [
              const RecipeIngredient(name: 'Pasta', quantity: 200, unit: 'gramos'),
              const RecipeIngredient(name: 'Tomate', quantity: 3, unit: 'unidades'),
              const RecipeIngredient(name: 'Albahaca fresca', quantity: 10, unit: 'hojas'),
              const RecipeIngredient(name: 'Aceite de oliva', quantity: 2, unit: 'cucharadas'),
            ],
            instructions: [
              'Hervir agua con sal para la pasta',
              'Cortar los tomates en cubos',
              'Sofreír tomates con aceite de oliva',
              'Cocinar pasta al dente',
              'Mezclar pasta con salsa y albahaca',
            ],
            prepTime: 15,
            cookTime: 20,
            servings: 2,
            difficulty: 'Intermedio',
            calories: 450,
            dietaryInfo: ['Vegetariano'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Ensalada César con Pollo',
            description: 'Ensalada clásica con pollo grillado',
            ingredients: [
              const RecipeIngredient(name: 'Pechuga de pollo', quantity: 200, unit: 'gramos'),
              const RecipeIngredient(name: 'Lechuga romana', quantity: 1, unit: 'cabeza'),
              const RecipeIngredient(name: 'Crutones', quantity: 0.5, unit: 'taza'),
              const RecipeIngredient(name: 'Queso parmesano', quantity: 50, unit: 'gramos'),
            ],
            instructions: [
              'Grillado el pollo hasta cocinarlo completamente',
              'Lavar y cortar la lechuga',
              'Preparar aderezo césar',
              'Mezclar todos los ingredientes',
            ],
            prepTime: 15,
            cookTime: 15,
            servings: 2,
            difficulty: 'Intermedio',
            calories: 380,
            dietaryInfo: ['Alto en proteína'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Sopa de Lentejas',
            description: 'Sopa nutritiva y reconfortante',
            ingredients: [
              const RecipeIngredient(name: 'Lentejas', quantity: 1, unit: 'taza'),
              const RecipeIngredient(name: 'Zanahoria', quantity: 2, unit: 'unidades'),
              const RecipeIngredient(name: 'Cebolla', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Caldo de verduras', quantity: 4, unit: 'tazas'),
            ],
            instructions: [
              'Sofrito la cebolla hasta transparente',
              'Agregar zanahoria picada',
              'Añadir lentejas y caldo',
              'Cocinar 30 minutos hasta tiernas',
            ],
            prepTime: 10,
            cookTime: 35,
            servings: 3,
            difficulty: 'Fácil',
            calories: 280,
            dietaryInfo: ['Vegano', 'Alto en fibra'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Sandwich de Atún',
            description: 'Sandwich nutritivo y rápido',
            ingredients: [
              const RecipeIngredient(name: 'Pan integral', quantity: 4, unit: 'rebanadas'),
              const RecipeIngredient(name: 'Atún en agua', quantity: 1, unit: 'lata'),
              const RecipeIngredient(name: 'Mayonesa', quantity: 2, unit: 'cucharadas'),
              const RecipeIngredient(name: 'Lechuga', quantity: 4, unit: 'hojas'),
            ],
            instructions: [
              'Escurrir el atún',
              'Mezclar atún con mayonesa',
              'Armar sandwich con lechuga',
              'Tostar ligeramente si se desea',
            ],
            prepTime: 10,
            cookTime: 0,
            servings: 2,
            difficulty: 'Muy fácil',
            calories: 320,
            dietaryInfo: ['Alto en proteína'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Risotto de Champiñones',
            description: 'Risotto cremoso con champiñones frescos',
            ingredients: [
              const RecipeIngredient(name: 'Arroz arborio', quantity: 1, unit: 'taza'),
              const RecipeIngredient(name: 'Champiñones', quantity: 200, unit: 'gramos'),
              const RecipeIngredient(name: 'Caldo de pollo', quantity: 4, unit: 'tazas'),
              const RecipeIngredient(name: 'Queso parmesano', quantity: 50, unit: 'gramos'),
            ],
            instructions: [
              'Saltear champiñones hasta dorar',
              'Tostar arroz con cebolla',
              'Agregar caldo de a poco, revolviendo',
              'Finalizar con queso y champiñones',
            ],
            prepTime: 10,
            cookTime: 25,
            servings: 2,
            difficulty: 'Intermedio',
            calories: 400,
            dietaryInfo: ['Vegetariano'],
            generatedAt: now,
          ),
        ];
      case MealType.dinner:
        return [
          GeneratedRecipe(
            title: 'Ensalada Verde Completa',
            description: 'Cena ligera y nutritiva con vegetales frescos',
            ingredients: [
              const RecipeIngredient(name: 'Lechuga', quantity: 1, unit: 'cabeza'),
              const RecipeIngredient(name: 'Pepino', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Zanahoria', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Aceite de oliva', quantity: 2, unit: 'cucharadas'),
            ],
            instructions: [
              'Lavar y cortar la lechuga',
              'Cortar pepino en rodajas',
              'Rallar la zanahoria',
              'Mezclar con aceite de oliva',
            ],
            prepTime: 10,
            cookTime: 0,
            servings: 1,
            difficulty: 'Fácil',
            calories: 150,
            dietaryInfo: ['Vegano', 'Sin gluten'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Salmón Grillado con Vegetales',
            description: 'Cena saludable con omega-3',
            ingredients: [
              const RecipeIngredient(name: 'Filete de salmón', quantity: 200, unit: 'gramos'),
              const RecipeIngredient(name: 'Brócoli', quantity: 1, unit: 'taza'),
              const RecipeIngredient(name: 'Espárragos', quantity: 100, unit: 'gramos'),
              const RecipeIngredient(name: 'Limón', quantity: 1, unit: 'unidad'),
            ],
            instructions: [
              'Sazonar el salmón con sal y pimienta',
              'Grillado por 4 minutos cada lado',
              'Cocer vegetales al vapor',
              'Servir con jugo de limón',
            ],
            prepTime: 10,
            cookTime: 15,
            servings: 1,
            difficulty: 'Intermedio',
            calories: 350,
            dietaryInfo: ['Rico en omega-3', 'Sin gluten'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Crema de Calabaza',
            description: 'Sopa cremosa y reconfortante',
            ingredients: [
              const RecipeIngredient(name: 'Calabaza', quantity: 500, unit: 'gramos'),
              const RecipeIngredient(name: 'Cebolla', quantity: 1, unit: 'unidad'),
              const RecipeIngredient(name: 'Caldo de verduras', quantity: 3, unit: 'tazas'),
              const RecipeIngredient(name: 'Crema de leche', quantity: 0.5, unit: 'taza'),
            ],
            instructions: [
              'Cortar calabaza en cubos',
              'Sofrito cebolla hasta transparente',
              'Cocinar calabaza con caldo 20 min',
              'Licuar y agregar crema',
            ],
            prepTime: 15,
            cookTime: 25,
            servings: 3,
            difficulty: 'Fácil',
            calories: 180,
            dietaryInfo: ['Vegetariano', 'Rico en vitamina A'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Pollo al Horno con Hierbas',
            description: 'Pollo jugoso con sabor mediterráneo',
            ingredients: [
              const RecipeIngredient(name: 'Pechuga de pollo', quantity: 300, unit: 'gramos'),
              const RecipeIngredient(name: 'Romero', quantity: 2, unit: 'ramitas'),
              const RecipeIngredient(name: 'Tomillo', quantity: 1, unit: 'cucharadita'),
              const RecipeIngredient(name: 'Aceite de oliva', quantity: 2, unit: 'cucharadas'),
            ],
            instructions: [
              'Marinar pollo con hierbas y aceite',
              'Precalentar horno a 180°C',
              'Hornear por 25 minutos',
              'Dejar reposar antes de servir',
            ],
            prepTime: 15,
            cookTime: 25,
            servings: 2,
            difficulty: 'Fácil',
            calories: 280,
            dietaryInfo: ['Alto en proteína', 'Sin gluten'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Tortilla de Verduras',
            description: 'Tortilla ligera con vegetales frescos',
            ingredients: [
              const RecipeIngredient(name: 'Huevos', quantity: 4, unit: 'unidades'),
              const RecipeIngredient(name: 'Espinacas', quantity: 1, unit: 'taza'),
              const RecipeIngredient(name: 'Pimiento rojo', quantity: 0.5, unit: 'unidad'),
              const RecipeIngredient(name: 'Queso rallado', quantity: 50, unit: 'gramos'),
            ],
            instructions: [
              'Saltear verduras hasta tiernas',
              'Batir huevos con sal y pimienta',
              'Mezclar huevos con verduras',
              'Cocinar en sartén hasta cuajar',
            ],
            prepTime: 10,
            cookTime: 12,
            servings: 2,
            difficulty: 'Fácil',
            calories: 220,
            dietaryInfo: ['Vegetariano', 'Bajo en carbohidratos'],
            generatedAt: now,
          ),
        ];
      case MealType.snack:
        return [
          GeneratedRecipe(
            title: 'Mix de Frutos Secos',
            description: 'Snack energético y saludable',
            ingredients: [
              const RecipeIngredient(name: 'Almendras', quantity: 30, unit: 'gramos'),
              const RecipeIngredient(name: 'Nueces', quantity: 20, unit: 'gramos'),
              const RecipeIngredient(name: 'Pasas', quantity: 15, unit: 'gramos'),
            ],
            instructions: [
              'Mezclar todos los frutos secos',
              'Guardar en recipiente hermético',
            ],
            prepTime: 2,
            cookTime: 0,
            servings: 1,
            difficulty: 'Fácil',
            calories: 280,
            dietaryInfo: ['Vegano', 'Sin gluten'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Batido de Proteína',
            description: 'Snack post-entrenamiento',
            ingredients: [
              const RecipeIngredient(name: 'Proteína en polvo', quantity: 1, unit: 'scoop'),
              const RecipeIngredient(name: 'Leche de almendras', quantity: 250, unit: 'ml'),
              const RecipeIngredient(name: 'Plátano', quantity: 0.5, unit: 'unidad'),
              const RecipeIngredient(name: 'Canela', quantity: 1, unit: 'pizca'),
            ],
            instructions: [
              'Mezclar todos los ingredientes',
              'Licuar hasta obtener consistencia suave',
              'Servir inmediatamente',
            ],
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            difficulty: 'Muy fácil',
            calories: 200,
            dietaryInfo: ['Alto en proteína', 'Sin lácteos'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Tostadas de Hummus',
            description: 'Snack mediterráneo y nutritivo',
            ingredients: [
              const RecipeIngredient(name: 'Pan pita', quantity: 2, unit: 'unidades'),
              const RecipeIngredient(name: 'Hummus', quantity: 4, unit: 'cucharadas'),
              const RecipeIngredient(name: 'Pepino', quantity: 0.5, unit: 'unidad'),
              const RecipeIngredient(name: 'Tomate cherry', quantity: 4, unit: 'unidades'),
            ],
            instructions: [
              'Tostar ligeramente el pan pita',
              'Untar con hummus',
              'Cortar pepino y tomates',
              'Decorar las tostadas',
            ],
            prepTime: 5,
            cookTime: 2,
            servings: 1,
            difficulty: 'Fácil',
            calories: 180,
            dietaryInfo: ['Vegano', 'Rico en fibra'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Yogurt con Bayas',
            description: 'Snack cremoso y antioxidante',
            ingredients: [
              const RecipeIngredient(name: 'Yogurt natural', quantity: 150, unit: 'gramos'),
              const RecipeIngredient(name: 'Arándanos', quantity: 0.5, unit: 'taza'),
              const RecipeIngredient(name: 'Fresas', quantity: 3, unit: 'unidades'),
              const RecipeIngredient(name: 'Miel', quantity: 1, unit: 'cucharadita'),
            ],
            instructions: [
              'Lavar las bayas',
              'Cortar fresas en trozos',
              'Mezclar yogurt con miel',
              'Decorar con frutas',
            ],
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            difficulty: 'Muy fácil',
            calories: 160,
            dietaryInfo: ['Vegetariano', 'Rico en probióticos'],
            generatedAt: now,
          ),
          GeneratedRecipe(
            title: 'Crackers con Queso',
            description: 'Snack clásico y satisfactorio',
            ingredients: [
              const RecipeIngredient(name: 'Crackers integrales', quantity: 6, unit: 'unidades'),
              const RecipeIngredient(name: 'Queso fresco', quantity: 60, unit: 'gramos'),
              const RecipeIngredient(name: 'Tomate cherry', quantity: 3, unit: 'unidades'),
              const RecipeIngredient(name: 'Albahaca', quantity: 6, unit: 'hojas'),
            ],
            instructions: [
              'Cortar queso en porciones',
              'Cortar tomates por la mitad',
              'Armar crackers con queso',
              'Decorar con tomate y albahaca',
            ],
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            difficulty: 'Muy fácil',
            calories: 190,
            dietaryInfo: ['Vegetariano'],
            generatedAt: now,
          ),
        ];
    }
  }
}

// Generated recipe model
class GeneratedRecipe {
  final String title;
  final String description;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final int? calories;
  final List<String> dietaryInfo;
  final String? imagePath;
  final String imageStatus;
  final DateTime generatedAt;

  const GeneratedRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.calories,
    this.dietaryInfo = const [],
    this.imagePath,
    this.imageStatus = 'generating',
    required this.generatedAt,
  });

  factory GeneratedRecipe.fromJson(Map<String, dynamic> json) {
    return GeneratedRecipe(
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((ingredient) => RecipeIngredient.fromJson(ingredient as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((instruction) => instruction as String)
          .toList(),
      prepTime: json['prep_time'] as int,
      cookTime: json['cook_time'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      calories: json['calories'] as int?,
      dietaryInfo: (json['dietary_info'] as List<dynamic>?)
          ?.map((info) => info as String)
          .toList() ?? [],
      imagePath: json['image_path'] as String?,
      imageStatus: json['image_status'] as String? ?? 'generating',
      generatedAt: DateTime.parse(json['generated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  GeneratedRecipe copyWith({
    String? title,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<String>? instructions,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    int? calories,
    List<String>? dietaryInfo,
    String? imagePath,
    String? imageStatus,
    DateTime? generatedAt,
  }) {
    return GeneratedRecipe(
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      calories: calories ?? this.calories,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      imagePath: imagePath ?? this.imagePath,
      imageStatus: imageStatus ?? this.imageStatus,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

// Recipe ingredient model
class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  @override
  String toString() => '$quantity $unit de $name';
}

// Recipe generation result
class RecipeGenerationResult {
  final List<GeneratedRecipe> recipes;
  final String? imageTaskId;

  const RecipeGenerationResult({
    required this.recipes,
    this.imageTaskId,
  });
}

// Providers
final recipeGenerationProvider = StateNotifierProvider<RecipeGenerationNotifier, RecipeGenerationState>((ref) {
  return RecipeGenerationNotifier();
});