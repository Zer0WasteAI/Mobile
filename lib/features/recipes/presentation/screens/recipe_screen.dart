// ignore_for_file: unused_element, avoid_unnecessary_containers

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_providers.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/favorite_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/filter_models.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart'
    // ignore: library_prefixes
    as RecipeModel;
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_filter_bottom_sheet.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/favorite_button.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/create_recipe_screen.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/favorite_recipes_screen.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/unfocus_detector.dart';
// Importar el provider de recetas IA

// Mapa con datos de preparación e ingredientes para las recetas más comunes
final Map<String, Map<String, dynamic>> recipeDetailsMap = {
  'pasta_carbonara': {
    'description':
        'Un clásico italiano que combina pasta con una salsa cremosa a base de huevo, queso y panceta.',
    'ingredients': [
      {'name': 'Spaghetti', 'quantity': '400', 'unit': 'g'},
      {'name': 'Panceta', 'quantity': '200', 'unit': 'g'},
      {'name': 'Huevos', 'quantity': '3', 'unit': 'unidad(es)'},
      {'name': 'Queso parmesano', 'quantity': '100', 'unit': 'g'},
      {'name': 'Pimienta negra', 'quantity': '', 'unit': 'al gusto'},
      {'name': 'Sal', 'quantity': '', 'unit': 'al gusto'},
    ],
    'steps': [
      'Cocer la pasta en agua con sal según las instrucciones del paquete.',
      'Mientras tanto, cortar la panceta en dados y dorarlos en una sartén a fuego medio hasta que estén crujientes.',
      'En un bol, batir los huevos con el queso parmesano rallado y pimienta negra.',
      'Cuando la pasta esté lista, escurrirla y mezclarla inmediatamente con la panceta.',
      'Retirar la sartén del fuego y añadir rápidamente la mezcla de huevo, revolviendo constantemente para evitar que se cuaje.',
      'Servir inmediatamente con más queso parmesano rallado y pimienta negra al gusto.',
    ],
    'tags': ['italiana', 'cremosa'],
    'notes':
        'El secreto está en agregar la mezcla de huevo fuera del fuego para que no se cuaje y quede cremosa.',
  },
  'ensalada_cesar': {
    'description':
        'Una ensalada fresca y crujiente con aderezo César cremoso, crutones y queso parmesano.',
    'ingredients': [
      {'name': 'Lechuga romana', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Pan de molde', 'quantity': '3', 'unit': 'rebanadas'},
      {'name': 'Queso parmesano', 'quantity': '50', 'unit': 'g'},
      {'name': 'Aceite de oliva', 'quantity': '3', 'unit': 'cucharadas'},
      {'name': 'Ajo', 'quantity': '1', 'unit': 'diente'},
      {'name': 'Anchoas', 'quantity': '3', 'unit': 'filetes'},
      {'name': 'Yema de huevo', 'quantity': '1', 'unit': 'unidad'},
    ],
    'steps': [
      'Cortar el pan en cubos y dorarlos en una sartén con un poco de aceite para hacer los crutones.',
      'Lavar y cortar la lechuga romana en trozos grandes.',
      'Para el aderezo César, mezclar en un procesador la yema de huevo, ajo, anchoas, mostaza y jugo de limón.',
      'Añadir el aceite lentamente mientras mezclas para crear una emulsión.',
      'Colocar la lechuga en un bol grande, añadir el aderezo y mezclar bien.',
      'Agregar los crutones y el queso parmesano rallado encima.',
      'Servir inmediatamente para mantener la textura crujiente.',
    ],
    'tags': ['fresca', 'ensalada'],
    'notes':
        'Para una versión más ligera, puedes sustituir la yema de huevo por un poco de yogur natural.',
  },
  'tacos_pollo': {
    'description':
        'Tacos de pollo al estilo mexicano con salsa, guacamole y todos los acompañamientos tradicionales.',
    'ingredients': [
      {'name': 'Pechuga de pollo', 'quantity': '500', 'unit': 'g'},
      {'name': 'Tortillas de maíz', 'quantity': '8', 'unit': 'unidad(es)'},
      {'name': 'Cebolla', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Aguacate', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Limón', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Tomate', 'quantity': '2', 'unit': 'unidad(es)'},
      {'name': 'Cilantro', 'quantity': '1', 'unit': 'manojo'},
      {'name': 'Chile jalapeño', 'quantity': '1', 'unit': 'unidad'},
    ],
    'steps': [
      'Marinar el pollo con sal, pimienta, comino y jugo de limón durante 20 minutos.',
      'Preparar el guacamole machacando el aguacate con limón, sal, cebolla y cilantro picados.',
      'Cocinar el pollo en una sartén hasta que esté dorado y completamente cocido.',
      'Picar finamente el pollo cocido.',
      'Calentar las tortillas en una sartén caliente.',
      'Montar los tacos colocando el pollo sobre las tortillas calientes y añadiendo guacamole, tomate picado, cebolla y cilantro.',
      'Servir con rodajas de limón y salsa picante al gusto.',
    ],
    'tags': ['mexicana', 'picante'],
    'notes':
        'Puedes sustituir el pollo por proteínas vegetales para una versión vegetariana.',
  },
  'pizza_margarita': {
    'description':
        'La clásica pizza italiana con salsa de tomate, mozzarella fresca y albahaca.',
    'ingredients': [
      {'name': 'Masa de pizza', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Tomates', 'quantity': '4', 'unit': 'unidad(es)'},
      {'name': 'Mozzarella fresca', 'quantity': '200', 'unit': 'g'},
      {'name': 'Albahaca fresca', 'quantity': '1', 'unit': 'manojo'},
      {'name': 'Aceite de oliva', 'quantity': '2', 'unit': 'cucharadas'},
    ],
    'steps': [
      'Precalentar el horno a su máxima temperatura.',
      'Estirar la masa de pizza sobre una superficie enharinada hasta conseguir un círculo fino.',
      'Preparar la salsa de tomate cocinando los tomates pelados con sal, aceite y un poco de orégano.',
      'Cubrir la masa con una capa fina de salsa de tomate.',
      'Cortar la mozzarella en rodajas y distribuirla sobre la pizza.',
      'Hornear la pizza durante 8-10 minutos o hasta que los bordes estén dorados y el queso burbujeante.',
      'Agregar las hojas de albahaca fresca, un chorrito de aceite de oliva y servir inmediatamente.',
    ],
    'tags': ['italiana', 'al horno'],
    'notes':
        'Para una base más crujiente, puedes precalentar una piedra para pizza en el horno.',
  },
  'curry_lentejas': {
    'description':
        'Un curry vegano reconfortante a base de lentejas, rico en proteínas y especias aromáticas.',
    'ingredients': [
      {'name': 'Lentejas', 'quantity': '250', 'unit': 'g'},
      {'name': 'Cebolla', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Ajo', 'quantity': '3', 'unit': 'dientes'},
      {'name': 'Jengibre', 'quantity': '1', 'unit': 'trozo pequeño'},
      {'name': 'Curry en polvo', 'quantity': '2', 'unit': 'cucharadas'},
      {'name': 'Tomate', 'quantity': '2', 'unit': 'unidad(es)'},
      {'name': 'Leche de coco', 'quantity': '400', 'unit': 'ml'},
      {'name': 'Espinacas', 'quantity': '200', 'unit': 'g'},
      {'name': 'Cilantro fresco', 'quantity': '', 'unit': 'al gusto'},
      {'name': 'Arroz basmati', 'quantity': '200', 'unit': 'g'},
    ],
    'steps': [
      'Lavar las lentejas y cocerlas en agua con sal durante unos 20 minutos hasta que estén tiernas. Escurrir y reservar.',
      'En una olla grande, sofreír la cebolla, el ajo y el jengibre picados hasta que estén dorados.',
      'Añadir el curry en polvo y cocinar 1 minuto para activar los aromas.',
      'Agregar los tomates picados y cocinar hasta que se ablanden.',
      'Incorporar las lentejas cocidas y la leche de coco, cocinar a fuego lento durante 10 minutos.',
      'Añadir las espinacas y cocinar hasta que se marchiten.',
      'Mientras tanto, cocinar el arroz basmati según las instrucciones del paquete.',
      'Servir el curry sobre el arroz y decorar con cilantro fresco picado.',
    ],
    'tags': ['vegana', 'india', 'proteica'],
    'notes':
        'Para un toque de acidez, añade un chorrito de zumo de limón al final de la cocción.',
  },
  'hamburguesas_garbanzos': {
    'description':
        'Hamburguesas vegetarianas caseras a base de garbanzos, nutritivas y llenas de sabor.',
    'ingredients': [
      {'name': 'Garbanzos cocidos', 'quantity': '400', 'unit': 'g'},
      {'name': 'Cebolla', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Ajo', 'quantity': '2', 'unit': 'dientes'},
      {'name': 'Comino', 'quantity': '1', 'unit': 'cucharadita'},
      {'name': 'Cilantro', 'quantity': '1/4', 'unit': 'taza'},
      {'name': 'Pan rallado', 'quantity': '1/2', 'unit': 'taza'},
      {'name': 'Huevo', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Sal y pimienta', 'quantity': '', 'unit': 'al gusto'},
      {'name': 'Aceite de oliva', 'quantity': '2', 'unit': 'cucharadas'},
    ],
    'steps': [
      'Escurrir y enjuagar los garbanzos, secarlos bien con papel de cocina.',
      'En un procesador de alimentos, combinar los garbanzos, cebolla, ajo y cilantro hasta obtener una mezcla homogénea.',
      'Transferir a un bol y añadir el comino, pan rallado, huevo, sal y pimienta. Mezclar bien.',
      'Formar 4-6 hamburguesas con las manos, presionando para compactar la mezcla.',
      'Refrigerar las hamburguesas durante 30 minutos para que se afirmen.',
      'Calentar aceite en una sartén a fuego medio-alto y cocinar las hamburguesas 3-4 minutos por cada lado.',
      'Servir en panes de hamburguesa con tus condimentos favoritos como aguacate, tomate y lechuga.',
    ],
    'tags': ['vegetariana', 'proteica'],
    'notes':
        'Para una versión vegana, sustituye el huevo por 3 cucharadas de aquafaba (líquido de los garbanzos en conserva).',
  },
  'brownies': {
    'description':
        'Brownies de chocolate densos y húmedos con un exterior crujiente y un interior suave.',
    'ingredients': [
      {'name': 'Chocolate negro', 'quantity': '200', 'unit': 'g'},
      {'name': 'Mantequilla', 'quantity': '180', 'unit': 'g'},
      {'name': 'Azúcar', 'quantity': '250', 'unit': 'g'},
      {'name': 'Huevos', 'quantity': '3', 'unit': 'unidad(es)'},
      {'name': 'Harina', 'quantity': '120', 'unit': 'g'},
      {'name': 'Cacao en polvo', 'quantity': '30', 'unit': 'g'},
      {'name': 'Nueces (opcional)', 'quantity': '100', 'unit': 'g'},
      {'name': 'Sal', 'quantity': '1', 'unit': 'pizca'},
    ],
    'steps': [
      'Precalentar el horno a 180°C y forrar un molde cuadrado con papel de hornear.',
      'Derretir el chocolate y la mantequilla al baño maría o en el microondas, removiendo ocasionalmente.',
      'En un bol grande, batir los huevos con el azúcar hasta que estén espumosos.',
      'Añadir la mezcla de chocolate derretido y mezclar bien.',
      'Tamizar la harina, el cacao y la sal sobre la mezcla e incorporar suavemente.',
      'Si se usan, añadir las nueces troceadas y mezclar.',
      'Verter la masa en el molde preparado y hornear durante 25-30 minutos.',
      'Dejar enfriar completamente antes de cortar en cuadrados.',
    ],
    'tags': ['postre', 'chocolate'],
    'notes':
        'La clave de un buen brownie es no hornearlo demasiado tiempo para que mantenga su interior húmedo.',
  },
  'omelette': {
    'description':
        'Un omelette clásico y esponjoso, perfecto para el desayuno o una comida rápida.',
    'ingredients': [
      {'name': 'Huevos', 'quantity': '3', 'unit': 'unidad(es)'},
      {'name': 'Leche', 'quantity': '2', 'unit': 'cucharadas'},
      {'name': 'Sal', 'quantity': '', 'unit': 'al gusto'},
      {'name': 'Pimienta', 'quantity': '', 'unit': 'al gusto'},
      {'name': 'Mantequilla', 'quantity': '1', 'unit': 'cucharada'},
      {'name': 'Queso rallado (opcional)', 'quantity': '30', 'unit': 'g'},
      {
        'name': 'Hierbas frescas (opcional)',
        'quantity': '',
        'unit': 'al gusto',
      },
    ],
    'steps': [
      'Batir los huevos en un bol con la leche, sal y pimienta hasta que estén bien integrados.',
      'Calentar una sartén antiadherente a fuego medio y añadir la mantequilla.',
      'Cuando la mantequilla esté derretida, verter la mezcla de huevo en la sartén.',
      'A medida que el omelette se cuaja, levantar los bordes con una espátula y dejar que el huevo líquido fluya por debajo.',
      'Cuando esté casi cuajado pero aún ligeramente húmedo en la superficie, añadir el queso rallado si se desea.',
      'Doblar el omelette por la mitad con la ayuda de la espátula.',
      'Deslizar el omelette en un plato y decorar con hierbas frescas picadas.',
    ],
    'tags': ['desayuno', 'rápido', 'proteico'],
    'notes':
        'Puedes añadir tus ingredientes favoritos como champiñones, espinacas o jamón antes de doblar el omelette.',
  },
  'tostadas_aguacate': {
    'description':
        'Tostadas con aguacate machacado, un desayuno nutritivo y energético.',
    'ingredients': [
      {'name': 'Pan integral', 'quantity': '2', 'unit': 'rebanadas'},
      {'name': 'Aguacate maduro', 'quantity': '1', 'unit': 'unidad'},
      {'name': 'Limón', 'quantity': '1/2', 'unit': 'unidad'},
      {'name': 'Sal marina', 'quantity': '', 'unit': 'al gusto'},
      {'name': 'Pimienta negra', 'quantity': '', 'unit': 'al gusto'},
      {
        'name': 'Hojuelas de chile (opcional)',
        'quantity': '',
        'unit': 'al gusto',
      },
      {'name': 'Huevo (opcional)', 'quantity': '1', 'unit': 'unidad'},
    ],
    'steps': [
      'Tostar el pan hasta que esté crujiente.',
      'Mientras tanto, cortar el aguacate por la mitad, quitar el hueso y sacar la pulpa con una cuchara.',
      'En un bol pequeño, machacar el aguacate con un tenedor y añadir el jugo de limón, sal y pimienta al gusto.',
      'Untar generosamente el aguacate machacado sobre las tostadas.',
      'Opcionalmente, puedes añadir un huevo frito o pochado encima para aumentar el aporte proteico.',
      'Espolvorear con hojuelas de chile si deseas un toque picante.',
      'Servir inmediatamente para disfrutar de la textura crujiente del pan.',
    ],
    'tags': ['desayuno', 'vegano', 'rápido'],
    'notes':
        'Para evitar que el aguacate se oxide, añade siempre jugo de limón fresco y prepáralo justo antes de servir.',
  },
};

// Define a provider for recipe filters
final recipeFiltersProvider = FutureProvider<List<FilterCategory>>((ref) async {
  // In a real app, this might come from a repository or API
  // For now, let's load the JSON file containing filters
  final String filtersJson = '''
[
    {
      "category": "Tipo de receta",
      "filters": [
        { "label": "Entrada", "value": "entrada", "icon": "restaurant_menu" },
        { "label": "Plato principal", "value": "fondo", "icon": "dinner_dining" },
        { "label": "Postre", "value": "postre", "icon": "icecream" },
        { "label": "Bebida", "value": "bebida", "icon": "local_cafe" },
        { "label": "Snack / Bocadito", "value": "snack", "icon": "emoji_food_beverage" }
      ]
    },
    {
      "category": "Tiempo de preparación",
      "filters": [
        { "label": "< 15 min", "value": "short_time", "icon": "timer" },
        { "label": "15–30 min", "value": "medium_time", "icon": "schedule" },
        { "label": "> 30 min", "value": "long_time", "icon": "hourglass_bottom" }
      ]
    },
    {
      "category": "Dificultad",
      "filters": [
        { "label": "Fácil", "value": "facil", "icon": "light_mode" },
        { "label": "Intermedio", "value": "intermedio", "icon": "star_half" },
        { "label": "Difícil", "value": "dificil", "icon": "grade" }
      ]
    },
    {
      "category": "Tipo de dieta",
      "filters": [
        { "label": "Vegana", "value": "vegana", "icon": "eco" },
        { "label": "Vegetariana", "value": "vegetariana", "icon": "spa" },
        { "label": "Sin gluten", "value": "sin_gluten", "icon": "no_food" },
        { "label": "Sin lactosa", "value": "sin_lactosa", "icon": "free_breakfast" }
      ]
    },
    {
      "category": "Sostenibilidad",
      "filters": [
        { "label": "Aprovechar sobrantes", "value": "sobrantes", "icon": "recycling" },
        { "label": "Bajo impacto ambiental", "value": "bajo_impacto", "icon": "compost" }
      ]
    }
]
  ''';

  final List<dynamic> decodedJson = jsonDecode(filtersJson);

  return decodedJson
      .map((categoryJson) => FilterCategory.fromJson(categoryJson))
      .toList();
});

// Primero, añadir un provider para gestionar los favoritos
final favoritesProvider = StateProvider<Set<String>>((ref) => {});

// --- Provider Definitions (to be moved to recipe_providers.dart later) ---

// StateNotifier for Recipe Logic
// class RecipeController extends StateNotifier<RecipeState> {
//   final RecipeMode _mode;
//   // TODO: Inject dependencies like InventoryRepository, RecipeRepository
//
//   RecipeController(this._mode) : super(const RecipeState()) {
//     _loadRecipes(); // Load recipes on initialization based on mode
//   }
//
//   Future<void> _loadRecipes() async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       // Simulate network delay
//       await Future.delayed(const Duration(seconds: 2));
//
//       // TODO: Implement actual data fetching logic based on _mode
//       // - If _mode == RecipeMode.smartFromInventory:
//       //   - Get inventory items (prioritize near-expired)
//       //   - Call AI/Backend service with ingredients
//       //   - Populate `recipes` and `expiringIngredientsUsedCount`
//       // - If _mode == RecipeMode.explore:
//       //   - Fetch all recipes (or apply initial filters)
//       //   - Populate `recipes`
//
//       // Mock Data for now
//       final mockRecipes = [
//         Recipe(
//           id: '1', name: 'Pasta Aglio e Olio', description: 'Classic Italian pasta with garlic and oil.', emoji: '🍝',
//           ingredients: ['Spaghetti', 'Garlic', 'Olive Oil', 'Chili Flakes', 'Parsley'],
//           requiredIngredientsCount: 5, availableIngredientsCount: 3, usesExpiringItems: _mode == RecipeMode.smartFromInventory, // Example
//         ),
//         Recipe(
//           id: '2', name: 'Chicken Stir-Fry', description: 'Quick and easy chicken stir-fry with vegetables.', emoji: '🥘',
//           ingredients: ['Chicken Breast', 'Broccoli', 'Bell Pepper', 'Soy Sauce', 'Ginger', 'Garlic'],
//           requiredIngredientsCount: 6, availableIngredientsCount: 5, usesExpiringItems: false,
//         ),
//         Recipe(
//           id: '3', name: 'Lentil Soup', description: 'Hearty and healthy lentil soup.', emoji: '🥣',
//           ingredients: ['Lentils', 'Carrot', 'Celery', 'Onion', 'Vegetable Broth', 'Tomato Paste'],
//           requiredIngredientsCount: 6, availableIngredientsCount: 6, usesExpiringItems: _mode == RecipeMode.smartFromInventory, // Example
//         ),
//       ];
//
//       state = state.copyWith(
//         isLoading: false,
//         recipes: mockRecipes,
//         // Example: Set based on actual logic
//         expiringIngredientsUsedCount: _mode == RecipeMode.smartFromInventory ? 3 : null,
//       );
//
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: 'Failed to load recipes: ${e.toString()}');
//     }
//   }
//
//   void setSearchQuery(String query) {
//     // TODO: Implement search filtering (client-side or fetch again)
//     state = state.copyWith(searchQuery: query);
//   }
//
//   void toggleShowOnlyWithMyIngredients(bool value) {
//     // TODO: Implement filtering based on inventory
//     state = state.copyWith(showOnlyWithMyIngredients: value);
//   }
//
//   void applyFilters(/* Filter parameters */) {
//     // TODO: Implement filter application (client-side or fetch again)
//     // state = state.copyWith(selectedCategories: ..., etc.);
//   }
//
//   void retryLoad() {
//     _loadRecipes();
//   }
// }

// Provider definition using family to pass the mode
// final recipeControllerProviderFamily =
//     StateNotifierProvider.autoDispose.family<RecipeController, RecipeState, RecipeMode>(
//         (ref, mode) {
//   // TODO: Pass dependencies like repositories to the controller
//   // final inventoryRepository = ref.watch(inventoryRepositoryProvider);
//   // final recipeRepository = ref.watch(recipeRepositoryProvider);
//   return RecipeController(mode /*, inventoryRepository, recipeRepository */);
// });

// --- End Provider Definitions ---

// Convert to ConsumerStatefulWidget
class RecipeScreen extends ConsumerStatefulWidget {
  // Mode might be less relevant now, or only apply to the 'Explore' tab
  // Let's keep it for now for the explore tab logic
  final RecipeMode mode;

  const RecipeScreen({required this.mode, super.key});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

// Add SingleTickerProviderStateMixin for TabController vsync
class _RecipeScreenState extends ConsumerState<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFab = false; // State variable for FAB visibility
  String _screenTitle = 'Explorar Recetas'; // Default title for first tab

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs
    _tabController = TabController(length: 2, vsync: this);
    // Add listener to update FAB visibility and title
    _tabController.addListener(() {
      // Update FAB visibility
      if (_showFab != (_tabController.index == 1)) {
        setState(() {
          _showFab = _tabController.index == 1;
        });
      }

      // Update screen title based on selected tab
      final newTitle =
          _tabController.index == 0 ? 'Explorar Recetas' : 'Mis Recetas';
      if (_screenTitle != newTitle) {
        setState(() {
          _screenTitle = newTitle;
        });
      }
    });

    // Precargar los filtros cuando se inicia la pantalla
    Future.microtask(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Utilizar un enfoque diferente para precargar
          ProviderScope.containerOf(context).read(recipeFiltersProvider.future);
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We'll use the explore provider for the first tab
    final exploreRecipeState = ref.watch(
      recipeControllerProviderFamily(RecipeMode.explore),
    );
    final exploreRecipeNotifier = ref.read(
      recipeControllerProviderFamily(RecipeMode.explore).notifier,
    );

    // TODO: Add providers for "Mis Recetas" (e.g., myRecipesProvider)

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // --- Theme-aware Colors ---
    final Color scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color cardBackgroundColor =
        isDark
            ? AppColors.darkSurface
            : AppColors.lightFormBackground; // Use form background for search
    final Color errorColor = AppColors.error;
    final Color successBannerColor =
        isDark
            ? AppColors.darkPrimary.withValues(alpha: 0.2)
            : AppColors.lightPrimary.withValues(alpha: 0.15);
    final Color successBannerTextColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color searchBarIconColor = secondaryTextColor;
    final Color switchActiveColor = primaryColor;
    final Color onPrimaryColor = isDark ? Colors.black : Colors.white;
    final Color darkOnPrimaryColor = Colors.black;
    final Color unselectedLabelColor = secondaryTextColor; // For tabs
    final Color indicatorColor = primaryColor; // For tab indicator
    // -------------------------- //

    // Title might change based on tab, or be removed if tabs are clear enough
    // final String title = _tabController.index == 0 ? 'Explora recetas' : 'Mis Recetas';

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        // Add dynamic title based on current tab
        title: Text(
          _screenTitle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: textTheme.titleLarge?.fontSize ?? 20,
            color: mainTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor, // Match scaffold
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor), // Back button color
        actions: [
          // Botón para ver todas las recetas
          IconButton(
            icon: Icon(Icons.library_books, color: mainTextColor),
            onPressed: () {
              Navigator.pushNamed(context, '/recipes/all');
            },
            tooltip: 'Ver todas las recetas',
          ),
        ],
        // TabBar as the bottom part of the AppBar
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: indicatorColor,
          labelColor: mainTextColor, // Color of selected tab label
          unselectedLabelColor:
              unselectedLabelColor, // Color of unselected tab labels
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ), // Style for selected tab
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ), // Style for unselected tab
          tabs: const [Tab(text: 'Explorar'), Tab(text: 'Mis Recetas')],
        ),
      ),
      // Use TabBarView for the body content
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Tab 1: Explore Recipes ---
          ExploreTabWidget(
            recipeState: exploreRecipeState,
            recipeNotifier: exploreRecipeNotifier,
            isDark: isDark,
            scaffoldBackgroundColor: scaffoldBackgroundColor,
            primaryColor: primaryColor,
            mainTextColor: mainTextColor,
            secondaryTextColor: secondaryTextColor,
            cardBackgroundColor: cardBackgroundColor,
            errorColor: errorColor,
            successBannerColor: successBannerColor,
            successBannerTextColor: successBannerTextColor,
            searchBarIconColor: searchBarIconColor,
            switchActiveColor: switchActiveColor,
            onPrimaryColor: onPrimaryColor,
            darkOnPrimaryColor: darkOnPrimaryColor,
          ),

          // --- Tab 2: My Recipes ---
          _buildMyRecipesTab(
            context,
            ref,
            isDark, // Pass necessary theme info
            mainTextColor,
            secondaryTextColor,
          ),
        ],
      ),
      // Conditional Floating Action Button
      floatingActionButton:
          _showFab // Use the state variable
              ? FloatingActionButton(
                onPressed: () {
                  // Navigate to CreateRecipeScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateRecipeScreen(),
                    ),
                  );
                },
                backgroundColor: primaryColor,
                child: Icon(Icons.add, color: onPrimaryColor),
              )
              : null, // No FAB on explore tab
    );
  }

  // --- Build method for My Recipes Tab ---
  Widget _buildMyRecipesTab(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    // Create a TabController for the nested tabs
    return DefaultTabController(
      length: 3, // Three tabs: AI generated, Uploaded, Favorites
      child: Column(
        children: [
          // TabBar for recipe categories
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TabBar(
              labelColor: mainTextColor,
              unselectedLabelColor: secondaryTextColor,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: "AI Generadas"),
                Tab(text: "Subidas"),
                Tab(text: "Favoritas"),
              ],
            ),
          ),

          // TabBarView for the corresponding recipe lists
          Expanded(
            child: TabBarView(
              children: [
                // AI Generated Recipes
                _buildAIGeneratedRecipesView(
                  context,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                ),

                // Manually Uploaded Recipes
                _buildUploadedRecipesView(
                  context,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                ),

                // Favorite Recipes
                _buildFavoritesView(
                  context,
                  ref,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AI Generated Recipes View
  Widget _buildAIGeneratedRecipesView(
    BuildContext context,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    // TODO: Connect to actual AI generated recipes source
    // For now, show placeholder
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_toy, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'No tienes recetas generadas por IA',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: mainTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Explora la app y genera recetas inteligentes basadas en tus ingredientes disponibles.',
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Manually Uploaded Recipes View
  Widget _buildUploadedRecipesView(
    BuildContext context,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    // Colores para la tarjeta de receta
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;

    // Datos de la receta de pasta que el usuario quiere mostrar manualmente
    final Map<String, dynamic> pastaRecipe = {
      'id': 'manual_pasta_recipe',
      'name': 'Pasta con Salsa de Champiñones y Espinacas',
      'emoji': '🍝',
      'time': '25 min',
      'difficulty': 'Fácil',
      'type': 'fondo', // Plato principal
      'description':
          'Una deliciosa pasta cremosa con champiñones y espinacas, perfecta para una cena rápida y nutritiva.',
      'requiredIngredientsCount': 11,
      'availableIngredientsCount': 11,
      'ingredients': [
        {'name': 'Pasta', 'quantity': '250', 'unit': 'g'},
        {'name': 'Champiñones', 'quantity': '200', 'unit': 'g'},
        {'name': 'Espinaca', 'quantity': '150', 'unit': 'g'},
        {'name': 'Ajo', 'quantity': '3', 'unit': 'unidad(es)'},
        {'name': 'Cebolla', 'quantity': '1', 'unit': 'mediana'},
        {'name': 'Crema para cocinar', 'quantity': '200', 'unit': 'ml'},
        {'name': 'Queso parmesano rallado', 'quantity': '50', 'unit': 'g'},
        {'name': 'Aceite de oliva', 'quantity': '2', 'unit': 'cucharada(s)'},
        {'name': 'Sal', 'quantity': '', 'unit': 'al gusto'},
        {'name': 'Pimienta negra', 'quantity': '', 'unit': 'al gusto'},
        {'name': 'Orégano seco', 'quantity': '1', 'unit': 'cucharadita(s)'},
      ],
      'steps': [
        'Hervir agua en una olla grande, añadir sal y cocinar la pasta según las instrucciones del paquete.',
        'Mientras la pasta se cocina, picar finamente la cebolla y el ajo. Limpiar y cortar los champiñones en láminas.',
        'En una sartén grande, calentar el aceite de oliva a fuego medio y saltear la cebolla hasta que esté transparente.',
        'Añadir el ajo y cocinar por 30 segundos hasta que desprenda su aroma.',
        'Agregar los champiñones y cocinar por 5-6 minutos hasta que estén dorados.',
        'Incorporar las espinacas y cocinar hasta que se marchiten, aproximadamente 2 minutos.',
        'Verter la crema para cocinar, añadir el orégano y cocinar a fuego lento por 3-4 minutos.',
        'Salpimentar al gusto y añadir la mitad del queso parmesano, mezclando bien.',
        'Escurrir la pasta y mezclarla con la salsa en la sartén.',
        'Servir inmediatamente con el resto del queso parmesano espolvoreado por encima.',
      ],
      'tags': ['vegetariana', 'italiana', 'cremosa'],
      'sustainabilityOptions': ['bajo_impacto'],
      'notes':
          'Para una versión vegana, puedes sustituir la crema por crema vegetal y el queso parmesano por levadura nutricional.',
    };

    final Color difficultyColor =
        pastaRecipe['difficulty'] == 'Fácil'
            ? Colors.green
            : pastaRecipe['difficulty'] == 'Medio'
            ? Colors.orange
            : Colors.red;

    // Mostrar la tarjeta de la receta
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Mis Recetas Subidas',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainTextColor,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                // Navegar a la pantalla de detalle de receta
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => RecipeDetailScreen(recipe: pastaRecipe),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Recipe emoji
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Text(
                          pastaRecipe['emoji'],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),

                    // Recipe info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pastaRecipe['name'],
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: mainTextColor,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                pastaRecipe['time'],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: difficultyColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  pastaRecipe['difficulty'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: difficultyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            pastaRecipe['description'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: secondaryTextColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Mensaje para añadir más recetas
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRecipeScreen(),
                  ),
                );
              },
              icon: Icon(Icons.add_circle_outline, color: primaryColor),
              label: Text(
                'Añadir otra receta',
                style: GoogleFonts.inter(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para construir los chips de información
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Método para obtener etiquetas amigables
  String _getTagLabel(String tag) {
    final Map<String, String> tagLabels = {
      'vegetariana': 'Vegetariana',
      'vegana': 'Vegana',
      'sin_gluten': 'Sin Gluten',
      'sin_lactosa': 'Sin Lactosa',
      'italiana': 'Italiana',
      'mexicana': 'Mexicana',
      'española': 'Española',
      'asiática': 'Asiática',
      'sobrantes': 'Aprovecha sobrantes',
      'estacion': 'De temporada',
      'bajo_impacto': 'Bajo impacto ambiental',
    };

    return tagLabels[tag] ?? tag;
  }

  // Favorite Recipes View
  Widget _buildFavoritesView(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    final favoritesState = ref.watch(favoriteRecipesProvider);
    final favoriteRecipes = favoritesState.favoriteRecipes;

    // Loading state
    if (favoritesState.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF00BFA5)),
              ),
              const SizedBox(height: 20),
              Text(
                'Cargando recetas favoritas...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (favoritesState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
              const SizedBox(height: 20),
              Text(
                'Error al cargar favoritas',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                favoritesState.error!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(favoriteRecipesProvider.notifier).refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (favoriteRecipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Text(
                'No tienes recetas favoritas',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Explora recetas y guarda las que más te gusten tocando el corazón.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to explore recipes
                      // This would switch to the explore tab
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Explorar recetas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to dedicated favorites screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FavoriteRecipesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Ver todas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BFA5),
                      side: const BorderSide(color: Color(0xFF00BFA5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Show favorites with header
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count and view all button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Favoritas',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${favoriteRecipes.length} recetas guardadas',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sync indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              favoritesState.isBackendSynced
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          favoritesState.isBackendSynced
                              ? 'Sincronizado'
                              : 'Solo local',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color:
                                favoritesState.isBackendSynced
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FavoriteRecipesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver todas'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00BFA5),
                ),
              ),
            ],
          ),
        ),

        // Favorites grid (showing first 4-6 items)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.75,
              ),
              itemCount:
                  favoriteRecipes.length > 6 ? 6 : favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                return _buildFavoriteRecipeCard(
                  context,
                  recipe,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                  ref,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Método auxiliar para obtener todas las categorías de recetas
  List<Map<String, dynamic>> _getAllRecipeCategories() {
    // Retorna la lista de categorías completa con todas las recetas disponibles
    return [
      {
        'name': 'Destacados',
        'emoji': '✨',
        'recipes': [
          {
            'id': 'pasta_carbonara',
            'name': 'Pasta Carbonara',
            'emoji': '🍝',
            'time': '25 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'ensalada_cesar',
            'name': 'Ensalada César',
            'emoji': '🥗',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'tacos_pollo',
            'name': 'Tacos de Pollo',
            'emoji': '🌮',
            'time': '30 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'pizza_margarita',
            'name': 'Pizza Margarita',
            'emoji': '🍕',
            'time': '40 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'hamburguesa_casera',
            'name': 'Hamburguesa Casera',
            'emoji': '🍔',
            'time': '35 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 9,
            'availableIngredientsCount': 4,
          },
        ],
      },
      {
        'name': 'Rápidas y Fáciles',
        'emoji': '⏱️',
        'recipes': [
          {
            'id': 'omelette',
            'name': 'Omelette',
            'emoji': '🍳',
            'time': '10 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'tostadas_aguacate',
            'name': 'Tostadas de Aguacate',
            'emoji': '🥑',
            'time': '5 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 3,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'wrap_pollo',
            'name': 'Wrap de Pollo',
            'emoji': '🌯',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 2,
          },
          {
            'id': 'sandwich_atun',
            'name': 'Sándwich de Atún',
            'emoji': '🥪',
            'time': '8 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 0,
          },
          {
            'id': 'ensalada_frutas',
            'name': 'Ensalada de Frutas',
            'emoji': '🍎',
            'time': '12 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 3,
          },
        ],
      },
      {
        'name': 'Vegetarianas',
        'emoji': '🥬',
        'recipes': [
          {
            'id': 'curry_lentejas',
            'name': 'Curry de Lentejas',
            'emoji': '🍛',
            'time': '40 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 10,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'pasta_pesto',
            'name': 'Pasta al Pesto',
            'emoji': '🌿',
            'time': '20 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'bowl_buddha',
            'name': 'Bowl de Buddha',
            'emoji': '🥙',
            'time': '25 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 0,
          },
          {
            'id': 'risotto_hongos',
            'name': 'Risotto de Hongos',
            'emoji': '🍄',
            'time': '35 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'hamburguesas_garbanzos',
            'name': 'Hamburguesas de Garbanzos',
            'emoji': '🌱',
            'time': '30 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 9,
            'availableIngredientsCount': 5,
          },
        ],
      },
      {
        'name': 'Postres',
        'emoji': '🍰',
        'recipes': [
          {
            'id': 'brownies',
            'name': 'Brownies',
            'emoji': '🍫',
            'time': '45 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'cheesecake',
            'name': 'Cheesecake',
            'emoji': '🧀',
            'time': '60 min',
            'difficulty': 'Difícil',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 1,
          },
          {
            'id': 'galletas_chocolate',
            'name': 'Galletas de Chocolate',
            'emoji': '🍪',
            'time': '30 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'mousse_chocolate',
            'name': 'Mousse de Chocolate',
            'emoji': '🍮',
            'time': '20 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 2,
          },
          {
            'id': 'pastel_zanahoria',
            'name': 'Pastel de Zanahoria',
            'emoji': '🥕',
            'time': '65 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 10,
            'availableIngredientsCount': 0,
          },
        ],
      },
      {
        'name': 'Saludables',
        'emoji': '💪',
        'recipes': [
          {
            'id': 'bowl_acai',
            'name': 'Bowl de Açaí',
            'emoji': '🍇',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'ensalada_quinoa',
            'name': 'Ensalada de Quinoa',
            'emoji': '🌾',
            'time': '25 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 9,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'pollo_verduras',
            'name': 'Pollo al Horno con Verduras',
            'emoji': '🍗',
            'time': '45 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'batido_verde',
            'name': 'Batido Verde',
            'emoji': '🥤',
            'time': '5 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 2,
          },
          {
            'id': 'salmon_esparragos',
            'name': 'Salmón con Espárragos',
            'emoji': '🐟',
            'time': '30 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 3,
          },
        ],
      },
      {
        'name': 'Con Tus Ingredientes',
        'emoji': '🥘',
        'recipes': [
          {
            'id': 'pasta_aglio_olio',
            'name': 'Pasta Aglio e Olio',
            'emoji': '🍝',
            'time': '20 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'huevos_revueltos',
            'name': 'Huevos Revueltos',
            'emoji': '🍳',
            'time': '5 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 3,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'pan_ajo',
            'name': 'Pan de Ajo',
            'emoji': '🍞',
            'time': '10 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'arroz_frito',
            'name': 'Arroz Frito',
            'emoji': '🍚',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'tortilla_espanola',
            'name': 'Tortilla Española',
            'emoji': '🥔',
            'time': '25 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
        ],
      },
    ];
  }

  // Método para construir tarjetas de recetas favoritas
  Widget _buildFavoriteRecipeCard(
    BuildContext context,
    RecipeModel.Recipe recipe,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
    WidgetRef ref,
  ) {
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final Color difficultyColor =
        recipe.difficulty == 'Fácil'
            ? Colors.green
            : recipe.difficulty == 'Medio'
            ? Colors.orange
            : Colors.red;

    // Determinar el tipo de receta basado en el nombre o emoji
    String recipeType = 'fondo'; // Valor por defecto

    final String nameLC = recipe.name.toLowerCase();
    final String emoji = recipe.emoji;

    if (nameLC.contains('ensalada') ||
        nameLC.contains('sopa') ||
        nameLC.contains('crema') ||
        nameLC.contains('ceviche') ||
        emoji == '🥗' ||
        emoji == '🥣') {
      recipeType = 'entrada';
    } else if (nameLC.contains('pasta') ||
        nameLC.contains('arroz') ||
        nameLC.contains('hamburguesa') ||
        nameLC.contains('pollo') ||
        emoji == '🍝' ||
        emoji == '🍗' ||
        emoji == '🍖' ||
        emoji == '🍔' ||
        emoji == '🌮' ||
        emoji == '🥘') {
      recipeType = 'fondo';
    } else if (nameLC.contains('pastel') ||
        nameLC.contains('tarta') ||
        nameLC.contains('helado') ||
        nameLC.contains('brownie') ||
        nameLC.contains('galleta') ||
        emoji == '🍰' ||
        emoji == '🧁' ||
        emoji == '🍮' ||
        emoji == '🍦' ||
        emoji == '🍨' ||
        emoji == '🍪') {
      recipeType = 'postre';
    } else if (nameLC.contains('batido') ||
        nameLC.contains('café') ||
        nameLC.contains('jugo') ||
        nameLC.contains('bebida') ||
        emoji == '🥤' ||
        emoji == '☕' ||
        emoji == '🍹') {
      recipeType = 'bebida';
    } else if (nameLC.contains('snack') ||
        nameLC.contains('tostada') ||
        nameLC.contains('chips') ||
        emoji == '🥨' ||
        emoji == '🥯' ||
        emoji == '🥪') {
      recipeType = 'snack';
    }

    // Colores para el tag de tipo de receta
    final Map<String, Color> typeColors = {
      'entrada': Colors.blue,
      'fondo': Colors.deepPurple,
      'postre': Colors.pink,
      'bebida': Colors.teal,
      'snack': Colors.amber,
    };

    // Labels amigables para mostrar
    final Map<String, String> typeLabels = {
      'entrada': 'Entrada',
      'fondo': 'Plato principal',
      'postre': 'Postre',
      'bebida': 'Bebida',
      'snack': 'Snack',
    };

    final Color typeColor = typeColors[recipeType] ?? primaryColor;
    final String typeLabel = typeLabels[recipeType] ?? 'Plato principal';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          // Navigate to recipe detail (if available)
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => RecipeDetailScreen(recipe: recipe),
          //   ),
          // );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image/emoji container with favorite button
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),

                // Tag de tipo de receta
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      typeLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                      ),
                    ),
                  ),
                ),

                // Botón de favoritos usando nuestro widget
                Positioned(
                  top: 8,
                  right: 8,
                  child: CompactFavoriteButton(recipe: recipe),
                ),
              ],
            ),

            // Recipe info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe name
                    Text(
                      recipe.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Recipe stats
                    Row(
                      children: [
                        // Time
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recipe.formattedCookingTime,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Difficulty
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Ingredients availability
                    Row(
                      children: [
                        Icon(
                          recipe.availableIngredientsCount ==
                                  recipe.requiredIngredientsCount
                              ? Icons.check_circle
                              : Icons.info,
                          size: 12,
                          color:
                              recipe.availableIngredientsCount ==
                                      recipe.requiredIngredientsCount
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${recipe.availableIngredientsCount}/${recipe.requiredIngredientsCount} ingredientes',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color:
                                  recipe.availableIngredientsCount ==
                                          recipe.requiredIngredientsCount
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate ExploreTabWidget as HookConsumerWidget
class ExploreTabWidget extends HookConsumerWidget {
  final RecipeState recipeState;
  final RecipeController recipeNotifier;
  final bool isDark;
  final Color scaffoldBackgroundColor;
  final Color primaryColor;
  final Color mainTextColor;
  final Color secondaryTextColor;
  final Color cardBackgroundColor;
  final Color errorColor;
  final Color successBannerColor;
  final Color successBannerTextColor;
  final Color searchBarIconColor;
  final Color switchActiveColor;
  final Color onPrimaryColor;
  final Color darkOnPrimaryColor;

  const ExploreTabWidget({
    super.key,
    required this.recipeState,
    required this.recipeNotifier,
    required this.isDark,
    required this.scaffoldBackgroundColor,
    required this.primaryColor,
    required this.mainTextColor,
    required this.secondaryTextColor,
    required this.cardBackgroundColor,
    required this.errorColor,
    required this.successBannerColor,
    required this.successBannerTextColor,
    required this.searchBarIconColor,
    required this.switchActiveColor,
    required this.onPrimaryColor,
    required this.darkOnPrimaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final RecipeMode mode = RecipeMode.explore;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // State for currently selected category chip - using hooks
    final selectedCategoryState = useState('Todas');

    // State for active filters
    final activeFiltersState = useState<Map<String, Set<String>>>({});

    // Mock categories for carousel display
    final List<Map<String, dynamic>> recipeCategories = [
      {
        'name': 'Destacados',
        'emoji': '✨',
        'recipes': [
          {
            'id': 'pasta_carbonara',
            'name': 'Pasta Carbonara',
            'emoji': '🍝',
            'time': '25 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'ensalada_cesar',
            'name': 'Ensalada César',
            'emoji': '🥗',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'tacos_pollo',
            'name': 'Tacos de Pollo',
            'emoji': '🌮',
            'time': '30 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'pizza_margarita',
            'name': 'Pizza Margarita',
            'emoji': '🍕',
            'time': '40 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'hamburguesa_casera',
            'name': 'Hamburguesa Casera',
            'emoji': '🍔',
            'time': '35 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 9,
            'availableIngredientsCount': 4,
          },
        ],
      },
      {
        'name': 'Rápidas y Fáciles',
        'emoji': '⏱️',
        'recipes': [
          {
            'id': 'omelette',
            'name': 'Omelette',
            'emoji': '🍳',
            'time': '10 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'tostadas_aguacate',
            'name': 'Tostadas de Aguacate',
            'emoji': '🥑',
            'time': '5 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 3,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'wrap_pollo',
            'name': 'Wrap de Pollo',
            'emoji': '🌯',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 2,
          },
          {
            'id': 'sandwich_atun',
            'name': 'Sándwich de Atún',
            'emoji': '🥪',
            'time': '8 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 0,
          },
          {
            'id': 'ensalada_frutas',
            'name': 'Ensalada de Frutas',
            'emoji': '🍎',
            'time': '12 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 3,
          },
        ],
      },
      {
        'name': 'Vegetarianas',
        'emoji': '🥬',
        'recipes': [
          {
            'id': 'curry_lentejas',
            'name': 'Curry de Lentejas',
            'emoji': '🍛',
            'time': '40 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 10,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'pasta_pesto',
            'name': 'Pasta al Pesto',
            'emoji': '🌿',
            'time': '20 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'bowl_buddha',
            'name': 'Bowl de Buddha',
            'emoji': '🥙',
            'time': '25 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 0,
          },
          {
            'id': 'risotto_hongos',
            'name': 'Risotto de Hongos',
            'emoji': '🍄',
            'time': '35 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'hamburguesas_garbanzos',
            'name': 'Hamburguesas de Garbanzos',
            'emoji': '🌱',
            'time': '30 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 9,
            'availableIngredientsCount': 5,
          },
        ],
      },
      {
        'name': 'Postres',
        'emoji': '🍰',
        'recipes': [
          {
            'id': 'brownies',
            'name': 'Brownies',
            'emoji': '🍫',
            'time': '45 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'cheesecake',
            'name': 'Cheesecake',
            'emoji': '🧀',
            'time': '60 min',
            'difficulty': 'Difícil',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 1,
          },
          {
            'id': 'galletas_chocolate',
            'name': 'Galletas de Chocolate',
            'emoji': '🍪',
            'time': '30 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'mousse_chocolate',
            'name': 'Mousse de Chocolate',
            'emoji': '🍮',
            'time': '20 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 2,
          },
          {
            'id': 'pastel_zanahoria',
            'name': 'Pastel de Zanahoria',
            'emoji': '🥕',
            'time': '65 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 10,
            'availableIngredientsCount': 0,
          },
        ],
      },
      {
        'name': 'Saludables',
        'emoji': '💪',
        'recipes': [
          {
            'id': 'bowl_acai',
            'name': 'Bowl de Açaí',
            'emoji': '🍇',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 7,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'ensalada_quinoa',
            'name': 'Ensalada de Quinoa',
            'emoji': '🌾',
            'time': '25 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 9,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'pollo_verduras',
            'name': 'Pollo al Horno con Verduras',
            'emoji': '🍗',
            'time': '45 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 8,
            'availableIngredientsCount': 6,
          },
          {
            'id': 'batido_verde',
            'name': 'Batido Verde',
            'emoji': '🥤',
            'time': '5 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 2,
          },
          {
            'id': 'salmon_esparragos',
            'name': 'Salmón con Espárragos',
            'emoji': '🐟',
            'time': '30 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 6,
            'availableIngredientsCount': 3,
          },
        ],
      },
      {
        'name': 'Con Tus Ingredientes',
        'emoji': '🥘',
        'recipes': [
          {
            'id': 'pasta_aglio_olio',
            'name': 'Pasta Aglio e Olio',
            'emoji': '🍝',
            'time': '20 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'huevos_revueltos',
            'name': 'Huevos Revueltos',
            'emoji': '🍳',
            'time': '5 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 3,
            'availableIngredientsCount': 3,
          },
          {
            'id': 'pan_ajo',
            'name': 'Pan de Ajo',
            'emoji': '🍞',
            'time': '10 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
          {
            'id': 'arroz_frito',
            'name': 'Arroz Frito',
            'emoji': '🍚',
            'time': '15 min',
            'difficulty': 'Fácil',
            'requiredIngredientsCount': 5,
            'availableIngredientsCount': 5,
          },
          {
            'id': 'tortilla_espanola',
            'name': 'Tortilla Española',
            'emoji': '🥔',
            'time': '25 min',
            'difficulty': 'Medio',
            'requiredIngredientsCount': 4,
            'availableIngredientsCount': 4,
          },
        ],
      },
    ];

    // Filtered categories based on selection and filters
    List<Map<String, dynamic>> filteredCategories =
        selectedCategoryState.value == 'Todas'
            ? recipeCategories
            : recipeCategories
                .where(
                  (category) =>
                      category['name'] == selectedCategoryState.value ||
                      (selectedCategoryState.value == 'Rápidas' &&
                          category['name'] == 'Rápidas y Fáciles'),
                )
                .toList();

    // Apply active filters to recipes in each category
    if (activeFiltersState.value.isNotEmpty) {
      filteredCategories =
          filteredCategories.map((category) {
            // Create a copy of the category with filtered recipes
            final Map<String, dynamic> newCategory = Map<String, dynamic>.from(
              category,
            );

            List<dynamic> filteredRecipes = List.from(category['recipes']);

            // Apply time filters
            if (activeFiltersState.value.containsKey('Tiempo de preparación')) {
              final timeFilters =
                  activeFiltersState.value['Tiempo de preparación']!;
              if (timeFilters.isNotEmpty) {
                filteredRecipes =
                    filteredRecipes.where((recipe) {
                      final time = recipe['time'];
                      final minutes = int.tryParse(time.split(' ')[0]) ?? 0;

                      if (timeFilters.contains('short_time') && minutes < 15) {
                        return true;
                      }
                      if (timeFilters.contains('medium_time') &&
                          minutes >= 15 &&
                          minutes <= 30) {
                        return true;
                      }
                      if (timeFilters.contains('long_time') && minutes > 30) {
                        return true;
                      }
                      return false;
                    }).toList();
              }
            }

            // Apply difficulty filters
            if (activeFiltersState.value.containsKey('Dificultad')) {
              final difficultyFilters = activeFiltersState.value['Dificultad']!;
              if (difficultyFilters.isNotEmpty) {
                filteredRecipes =
                    filteredRecipes.where((recipe) {
                      final difficulty = recipe['difficulty'];
                      return (difficultyFilters.contains('facil') &&
                              difficulty == 'Fácil') ||
                          (difficultyFilters.contains('intermedio') &&
                              difficulty == 'Medio') ||
                          (difficultyFilters.contains('dificil') &&
                              difficulty == 'Difícil');
                    }).toList();
              }
            }

            // Apply recipe type filters
            if (activeFiltersState.value.containsKey('Tipo de receta')) {
              final typeFilters = activeFiltersState.value['Tipo de receta']!;
              if (typeFilters.isNotEmpty) {
                // En un caso real, estas recetas tendrían una propiedad 'type'
                // Aquí simulamos la aplicación de estos filtros usando el nombre de la categoría
                if (typeFilters.contains('postre') &&
                    category['name'] != 'Postres') {
                  filteredRecipes = [];
                } else if (typeFilters.contains('entrada') &&
                    ![
                      'Rápidas y Fáciles',
                      'Saludables',
                    ].contains(category['name'])) {
                  filteredRecipes = [];
                } else if (typeFilters.contains('bebida')) {
                  // Filtrar para mostrar solo recetas de bebidas - en una app real tendríamos una propiedad de tipo
                  filteredRecipes =
                      filteredRecipes.where((recipe) {
                        final name = recipe['name'].toString().toLowerCase();
                        final emoji = recipe['emoji'] ?? '';
                        return name.contains('batido') ||
                            name.contains('bebida') ||
                            name.contains('café') ||
                            emoji == '🥤' ||
                            emoji == '🧃' ||
                            emoji == '☕';
                      }).toList();
                } else if (typeFilters.contains('snack')) {
                  // Filtrar para mostrar solo snacks
                  filteredRecipes =
                      filteredRecipes.where((recipe) {
                        final name = recipe['name'].toString().toLowerCase();
                        return name.contains('snack') ||
                            name.contains('galletas') ||
                            name.contains('bocadito') ||
                            (category['name'] == 'Rápidas y Fáciles' &&
                                recipe['time'].toString().contains('< 15'));
                      }).toList();
                }
                // Implementar otros tipos según sea necesario
              }
            }

            // Apply diet type filters
            if (activeFiltersState.value.containsKey('Tipo de dieta')) {
              final dietFilters = activeFiltersState.value['Tipo de dieta']!;
              if (dietFilters.isNotEmpty) {
                // Para vegetarianas
                if (dietFilters.contains('vegetariana')) {
                  if (category['name'] != 'Vegetarianas') {
                    // Para esta demo, asumimos que solo la categoría "Vegetarianas" tiene recetas vegetarianas
                    filteredRecipes = [];
                  }
                }

                // Para veganas (simulado - en una app real cada receta tendría estas propiedades)
                if (dietFilters.contains('vegana')) {
                  // Para el ejemplo, asumimos que solo recetas con emoji 🌱 o en la categoría vegetarianas con ciertos nombres son veganas
                  filteredRecipes =
                      filteredRecipes.where((recipe) {
                        return recipe['emoji'] == '🌱' ||
                            (category['name'] == 'Vegetarianas' &&
                                (recipe['name'].toString().contains('Buddha') ||
                                    recipe['name'].toString().contains(
                                      'Garbanzos',
                                    )));
                      }).toList();
                }

                // Para sin gluten (simulado)
                if (dietFilters.contains('sin_gluten')) {
                  // Simular filtro de sin gluten - en una app real esto sería una propiedad en cada receta
                  filteredRecipes =
                      filteredRecipes.where((recipe) {
                        // Ejemplo simple: excluir recetas con palabras clave relacionadas con gluten
                        final name = recipe['name'].toString().toLowerCase();
                        return !name.contains('pasta') &&
                            !name.contains('pan') &&
                            !name.contains('pizza') &&
                            !name.contains('galletas');
                      }).toList();
                }
              }
            }

            // Apply sustainability filters
            if (activeFiltersState.value.containsKey('Sostenibilidad')) {
              final sustainabilityFilters =
                  activeFiltersState.value['Sostenibilidad']!;
              if (sustainabilityFilters.isNotEmpty) {
                // En una app real, estas serían propiedades de cada receta
                // Para esta demo, simplemente filtramos aleatoriamente
                if (sustainabilityFilters.contains('sobrantes')) {
                  // Filtrar al azar algunas recetas como ejemplo
                  filteredRecipes =
                      filteredRecipes.where((recipe) {
                        // Un criterio simple: recetas con 'id' de longitud par
                        return recipe['id'].toString().length % 2 == 0;
                      }).toList();
                }

                if (sustainabilityFilters.contains('bajo_impacto')) {
                  // Simular filtrado para bajo impacto
                  filteredRecipes =
                      filteredRecipes.where((recipe) {
                        // Ejemplos de recetas de "bajo impacto"
                        return !recipe['name']
                                .toString()
                                .toLowerCase()
                                .contains('carne') &&
                            !recipe['emoji'].toString().contains('🍖') &&
                            !recipe['emoji'].toString().contains('🥩');
                      }).toList();
                }
              }
            }

            newCategory['recipes'] = filteredRecipes;
            return newCategory;
          }).toList();

      // Remove empty categories
      filteredCategories =
          filteredCategories
              .where((category) => category['recipes'].isNotEmpty)
              .toList();
    }

    return RefreshIndicator(
      onRefresh: () async => recipeNotifier.retryLoad(),
      color: primaryColor,
      child: UnfocusDetector(
        child: CustomScrollView(
          slivers: [
            // --- Filters/Search/Switch (Explore Mode) ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : Colors.grey.withValues(alpha: 0.15),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: recipeNotifier.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Buscar recetas por nombre o ingredientes',
                          prefixIcon: Icon(
                            Icons.search,
                            color: searchBarIconColor,
                          ),
                          filled: true,
                          fillColor: cardBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: GoogleFonts.inter(
                            color: secondaryTextColor,
                          ),
                        ),
                        style: GoogleFonts.inter(color: mainTextColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First row: Filter button and ingredients switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start, // Alinear al inicio para que los botones se alineen correctamente
                          children: [
                            // Filter Button
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Botón de filtros
                                  TextButton.icon(
                                    icon: Icon(
                                      Icons.filter_list_rounded,
                                      color: primaryColor,
                                    ),
                                    label: Text(
                                      'Filtros${activeFiltersState.value.isNotEmpty ? ' (${_countActiveFilters(activeFiltersState.value)})' : ''}',
                                      style: GoogleFonts.inter(
                                        color: primaryColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      // Show Filter Bottom Sheet
                                      final filtersData = ref.read(
                                        recipeFiltersProvider,
                                      );

                                      // Primero verificamos si los datos ya están disponibles
                                      if (filtersData
                                          is AsyncData<List<FilterCategory>>) {
                                        // Si ya tenemos los datos, mostrar el modal directamente
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder:
                                              (
                                                context,
                                              ) => RecipeFilterBottomSheet(
                                                filterCategories:
                                                    filtersData.value,
                                                initialSelectedFilters:
                                                    activeFiltersState.value,
                                                onApply: (newFilters) {
                                                  // Update active filters state
                                                  activeFiltersState.value =
                                                      newFilters;
                                                },
                                              ),
                                        );
                                      } else {
                                        // Mostrar un indicador de carga breve
                                        final loadingSnackBar = SnackBar(
                                          content: Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: primaryColor,
                                                    ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text('Cargando filtros...'),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 1),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(loadingSnackBar);

                                        // Precarga los datos antes de mostrar el modal
                                        ref
                                            .read(recipeFiltersProvider.future)
                                            .then(
                                              (filterCategories) {
                                                // Una vez cargados, mostrar el modal
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder:
                                                      (
                                                        context,
                                                      ) => RecipeFilterBottomSheet(
                                                        filterCategories:
                                                            filterCategories,
                                                        initialSelectedFilters:
                                                            activeFiltersState
                                                                .value,
                                                        onApply: (newFilters) {
                                                          // Update active filters state
                                                          activeFiltersState
                                                                  .value =
                                                              newFilters;
                                                        },
                                                      ),
                                                );
                                              },
                                              onError: (error, stack) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'No se pudieron cargar los filtros: $error',
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ),

                                  // "Limpiar filtros" button debajo del botón de filtros
                                  if (activeFiltersState.value.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4.0,
                                        left: 4.0,
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          // Clear all filters
                                          activeFiltersState.value = {};
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Limpiar filtros',
                                          style: GoogleFonts.inter(
                                            color: errorColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // My Ingredients Switch - Alineado al top para coincidir con el botón de filtros
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Solo con mis ingredientes',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 4),
                                Transform.scale(
                                  scale: 0.85,
                                  child: Switch.adaptive(
                                    value:
                                        recipeState.showOnlyWithMyIngredients,
                                    onChanged:
                                        recipeNotifier
                                            .toggleShowOnlyWithMyIngredients,
                                    activeColor: switchActiveColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Display active filters as chips
                    // Eliminamos esta sección para que no se muestren los chips individuales
                    // y solo aparezca el número de filtros en el botón "Filtros"
                    /*
                  if (activeFiltersState.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _buildActiveFilterChips(
                          activeFiltersState.value,
                          (category, value) {
                            final newFilters = Map<String, Set<String>>.from(
                              activeFiltersState.value,
                            );
                            newFilters[category]!.remove(value);
                            if (newFilters[category]!.isEmpty) {
                              newFilters.remove(category);
                            }
                            activeFiltersState.value = newFilters;
                          },
                          context,
                        ),
                      ),
                    ),
                  */
                  ],
                ),
              ),
            ),

            // --- Featured Categories Chips ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        'Todas',
                        '🍴',
                        selectedCategoryState.value == 'Todas',
                        primaryColor,
                        isDark,
                        () => selectedCategoryState.value = 'Todas',
                      ),
                      _buildCategoryChip(
                        'Destacados',
                        '✨',
                        selectedCategoryState.value == 'Destacados',
                        primaryColor,
                        isDark,
                        () => selectedCategoryState.value = 'Destacados',
                      ),
                      _buildCategoryChip(
                        'Rápidas',
                        '⏱️',
                        selectedCategoryState.value == 'Rápidas',
                        primaryColor,
                        isDark,
                        () => selectedCategoryState.value = 'Rápidas',
                      ),
                      _buildCategoryChip(
                        'Vegetarianas',
                        '🥬',
                        selectedCategoryState.value == 'Vegetarianas',
                        primaryColor,
                        isDark,
                        () => selectedCategoryState.value = 'Vegetarianas',
                      ),
                      _buildCategoryChip(
                        'Postres',
                        '🍰',
                        selectedCategoryState.value == 'Postres',
                        primaryColor,
                        isDark,
                        () => selectedCategoryState.value = 'Postres',
                      ),
                      _buildCategoryChip(
                        'Saludables',
                        '💪',
                        selectedCategoryState.value == 'Saludables',
                        primaryColor,
                        isDark,
                        () => selectedCategoryState.value = 'Saludables',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading indicator (if needed)
            if (recipeState.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // --- "No hay recetas" message when filtered recipes are empty ---
            if (!recipeState.isLoading &&
                recipeState.errorMessage == null &&
                filteredCategories.isEmpty &&
                activeFiltersState.value.isNotEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 64,
                            color: secondaryTextColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No hay recetas que coincidan con tus filtros',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: mainTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Prueba ajustando o eliminando algunos filtros para ver más recetas.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Limpiar filtros'),
                            onPressed: () {
                              // Limpiar todos los filtros
                              activeFiltersState.value = {};
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: onPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // --- Recipe Categories with Carousels ---
            if (!recipeState.isLoading &&
                recipeState.errorMessage == null &&
                filteredCategories.isNotEmpty)
              SliverList.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return _buildRecipeCategorySection(
                    category['name'],
                    category['emoji'],
                    category['recipes'],
                    screenWidth,
                    isDark,
                    primaryColor,
                    mainTextColor,
                    secondaryTextColor,
                    cardBackgroundColor,
                    context,
                  );
                },
              ),

            // Show error if needed
            if (!recipeState.isLoading && recipeState.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: errorColor,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '¡Ups! Algo salió mal',
                            style: textTheme.titleMedium?.copyWith(
                              color: mainTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            recipeState.errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            onPressed: recipeNotifier.retryLoad,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor:
                                  isDark ? darkOnPrimaryColor : onPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to count total active filters
  int _countActiveFilters(Map<String, Set<String>> filters) {
    int count = 0;
    filters.forEach((_, values) {
      count += values.length;
    });
    return count;
  }

  // Helper method to build chips for active filters
  List<Widget> _buildActiveFilterChips(
    Map<String, Set<String>> activeFilters,
    Function(String, String) onRemove,
    BuildContext context,
  ) {
    final List<Widget> chips = [];
    final filterLabels = {
      'short_time': '< 15 min',
      'medium_time': '15-30 min',
      'long_time': '> 30 min',
      'facil': 'Fácil',
      'intermedio': 'Intermedio',
      'dificil': 'Difícil',
      'vegana': 'Vegana',
      'vegetariana': 'Vegetariana',
      'sin_gluten': 'Sin gluten',
      'sin_lactosa': 'Sin lactosa',
      'entrada': 'Entrada',
      'fondo': 'Plato principal',
      'postre': 'Postre',
      'bebida': 'Bebida',
      'snack': 'Snack',
      'sobrantes': 'Aprovechar sobrantes',
      'bajo_impacto': 'Bajo impacto ambiental',
    };

    activeFilters.forEach((category, values) {
      for (final value in values) {
        chips.add(
          Chip(
            label: Text(
              filterLabels[value] ?? value,
              style: GoogleFonts.inter(fontSize: 12),
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onRemove(category, value),
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
          ),
        );
      }
    });

    return chips;
  }

  // Helper method to build category selection chips
  Widget _buildCategoryChip(
    String label,
    String emoji,
    bool isSelected,
    Color primaryColor,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onTap();
          }
        },
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        checkmarkColor: primaryColor,
        avatar: Text(emoji, style: const TextStyle(fontSize: 16)),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color:
                isSelected
                    ? primaryColor
                    : isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // Helper method to build recipe category section with carousel
  Widget _buildRecipeCategorySection(
    String categoryName,
    String categoryEmoji,
    List<dynamic> recipes,
    double screenWidth,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
    Color cardBackgroundColor,
    BuildContext context,
  ) {
    // Filtrar recetas si "Solo con mis ingredientes" está activado
    final bool showOnlyWithIngredients = recipeState.showOnlyWithMyIngredients;

    // Filtramos las recetas
    final filteredRecipes =
        showOnlyWithIngredients
            ? recipes
                .where(
                  (recipe) => (recipe['availableIngredientsCount'] ?? 0) > 0,
                )
                .toList()
            : recipes;

    // Si no hay recetas después de filtrar, no mostrar la categoría
    if (filteredRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
          child: Row(
            children: [
              Text(categoryEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to category detail screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => CategoryDetailScreen(
                            categoryName: categoryName,
                            categoryEmoji: categoryEmoji,
                            recipes: recipes,
                            showOnlyWithIngredients: showOnlyWithIngredients,
                          ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ver más',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Recipes carousel
        SizedBox(
          height:
              showOnlyWithIngredients
                  ? 210
                  : 190, // Aumentar la altura cuando se muestra info de ingredientes
          child: Consumer(
            builder: (context, ref, _) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = filteredRecipes[index];

                  // Determinar el tipo de receta basado en el nombre o categoría
                  String? recipeType;

                  // Determinar tipo basado en categoría
                  if (categoryName == 'Postres') {
                    recipeType = 'postre';
                  } else if (categoryName == 'Vegetarianas') {
                    // Solo establece el tipo de dieta, no el tipo de receta
                  } else if (categoryName == 'Saludables') {
                    // Solo establece característica, no tipo
                  } else if (categoryName == 'Rápidas y Fáciles') {
                    // La mayoría suelen ser entradas o snacks, pero verificar primero
                  }

                  // Determinar tipo basado en el contenido del nombre o emoji
                  final String nameLC = recipe['name'].toString().toLowerCase();
                  final String emoji = recipe['emoji'].toString();

                  if (recipeType == null) {
                    if (nameLC.contains('ensalada') ||
                        nameLC.contains('salad')) {
                      recipeType = 'entrada';
                    } else if (nameLC.contains('pasta') ||
                        nameLC.contains('arroz') ||
                        nameLC.contains('hamburguesa') ||
                        nameLC.contains('pollo') ||
                        nameLC.contains('carne') ||
                        nameLC.contains('pescado') ||
                        nameLC.contains('filete') ||
                        nameLC.contains('guiso') ||
                        nameLC.contains('chuleta') ||
                        nameLC.contains('pechuga') ||
                        emoji == '🍝' ||
                        emoji == '🍗' ||
                        emoji == '🍖' ||
                        emoji == '🍔' ||
                        emoji == '🌮' ||
                        emoji == '🥘') {
                      recipeType = 'fondo';
                    } else if (nameLC.contains('pastel') ||
                        nameLC.contains('tarta') ||
                        nameLC.contains('helado') ||
                        nameLC.contains('brownie') ||
                        nameLC.contains('galleta') ||
                        nameLC.contains('pudín') ||
                        emoji == '🍰' ||
                        emoji == '🧁' ||
                        emoji == '🍮' ||
                        emoji == '🍦' ||
                        emoji == '🍨' ||
                        emoji == '🍪') {
                      recipeType = 'postre';
                    } else if (nameLC.contains('batido') ||
                        nameLC.contains('café') ||
                        nameLC.contains('té') ||
                        nameLC.contains('jugo') ||
                        nameLC.contains('bebida') ||
                        nameLC.contains('limonada') ||
                        emoji == '🥤' ||
                        emoji == '🧃' ||
                        emoji == '☕' ||
                        emoji == '🍹' ||
                        emoji == '🍵') {
                      recipeType = 'bebida';
                    } else if (nameLC.contains('snack') ||
                        nameLC.contains('bocadito') ||
                        nameLC.contains('tostada') ||
                        nameLC.contains('chips') ||
                        emoji == '🥨' ||
                        emoji == '🥯' ||
                        emoji == '🥪') {
                      recipeType = 'snack';
                    }
                  }

                  // Si no se ha identificado un tipo, asignar uno por defecto basado en el tiempo de preparación
                  if (recipeType == null) {
                    final int minutes =
                        int.tryParse(recipe['time'].toString().split(' ')[0]) ??
                        0;

                    if (minutes <= 15) {
                      // Recetas muy rápidas suelen ser snacks o bebidas
                      recipeType = 'snack';
                    } else if (minutes >= 45) {
                      // Recetas que toman más tiempo suelen ser platos principales
                      recipeType = 'fondo';
                    } else {
                      // Valor por defecto para cualquier receta no identificada
                      recipeType =
                          'fondo'; // Asumimos plato principal por defecto
                    }
                  }

                  return _buildRecipeCard(
                    recipe['name'],
                    recipe['emoji'],
                    recipe['time'],
                    recipe['difficulty'],
                    screenWidth,
                    isDark,
                    primaryColor,
                    mainTextColor,
                    secondaryTextColor,
                    cardBackgroundColor,
                    availableIngredients: recipe['availableIngredientsCount'],
                    requiredIngredients: recipe['requiredIngredientsCount'],
                    showIngredientInfo: showOnlyWithIngredients,
                    recipeId: recipe['id'], // Usar el ID que ya está definido
                    recipeType: recipeType, // Añadir el tipo de receta
                    ref: ref,
                    context: context,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper method to build a recipe card for the carousel
  Widget _buildRecipeCard(
    String recipeName,
    String recipeEmoji,
    String cookingTime,
    String difficulty,
    double screenWidth,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
    Color cardBackgroundColor, {
    int? availableIngredients,
    int? requiredIngredients,
    bool showIngredientInfo = false,
    String? recipeId, // Añadir ID para identificar recetas
    String?
    recipeType, // Tipo de receta: entrada, plato principal, postre, etc.
    required WidgetRef ref,
    required BuildContext context,
  }) {
    final Color difficultyColor =
        difficulty == 'Fácil'
            ? Colors.green
            : difficulty == 'Medio'
            ? Colors.orange
            : Colors.red;

    final missingIngredients =
        requiredIngredients != null && availableIngredients != null
            ? requiredIngredients - availableIngredients
            : null;

    // Calcular la altura dinámica dependiendo de si mostramos info de ingredientes
    final double cardHeight =
        showIngredientInfo && missingIngredients != null ? 210 : 190;

    // Verificar si esta receta está en favoritos
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = recipeId != null && favorites.contains(recipeId);

    // Colores para el tag de tipo de receta
    final Map<String, Color> typeColors = {
      'entrada': Colors.blue,
      'fondo': Colors.deepPurple,
      'postre': Colors.pink,
      'bebida': Colors.teal,
      'snack': Colors.amber,
    };

    // Labels amigables para mostrar
    final Map<String, String> typeLabels = {
      'entrada': 'Entrada',
      'fondo': 'Plato principal',
      'postre': 'Postre',
      'bebida': 'Bebida',
      'snack': 'Snack',
    };

    // Obtener color y label para el tipo de receta
    final String recipeTypeValue =
        recipeType ?? 'fondo'; // Valor por defecto si es null
    final Color typeColor = typeColors[recipeTypeValue] ?? primaryColor;
    final String typeLabel = typeLabels[recipeTypeValue] ?? 'Plato principal';

    return GestureDetector(
      onTap: () {
        // Navigate to recipe detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => RecipeDetailScreen(
                  recipe: {
                    'name': recipeName,
                    'emoji': recipeEmoji,
                    'time': cookingTime,
                    'difficulty': difficulty,
                    'type': recipeTypeValue,
                    'id': recipeId,
                    // Obtener los detalles de la receta del mapa si existen
                    'description':
                        recipeDetailsMap[recipeId]?['description'] ??
                        'Una deliciosa receta casera.',
                    'steps':
                        recipeDetailsMap[recipeId]?['steps'] ??
                        [
                          'Preparar los ingredientes',
                          'Seguir las instrucciones de la receta',
                          'Cocinar a la temperatura adecuada',
                          'Servir y disfrutar',
                        ],
                    'ingredients':
                        recipeDetailsMap[recipeId]?['ingredients'] ??
                        [
                          {
                            'name': 'Ingredientes varios',
                            'quantity': '',
                            'unit': 'según necesidad',
                          },
                        ],
                    'notes':
                        recipeDetailsMap[recipeId]?['notes'] ??
                        'Personaliza esta receta a tu gusto.',
                    'tags': recipeDetailsMap[recipeId]?['tags'] ?? [],
                    'availableIngredientsCount': availableIngredients,
                    'requiredIngredientsCount': requiredIngredients,
                    'isFavorite': isFavorite,
                  },
                ),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.42, // Width based on screen size
        height: cardHeight, // Altura ajustada dinámicamente
        margin: const EdgeInsets.only(right: 14, bottom: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image/emoji container with favorite button
            Stack(
              children: [
                Container(
                  height:
                      90, // Reducir ligeramente la altura del contenedor de emoji
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      recipeEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),

                // Tag de tipo de receta
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      typeLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                      ),
                    ),
                  ),
                ),

                // Botón de favoritos
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      if (recipeId != null) {
                        final notifier = ref.read(favoritesProvider.notifier);
                        if (isFavorite) {
                          // Quitar de favoritos
                          notifier.state = {...favorites}..remove(recipeId);
                          log('Receta eliminada de favoritos: $recipeId');
                        } else {
                          // Añadir a favoritos
                          notifier.state = {...favorites, recipeId};
                          log('Receta añadida a favoritos: $recipeId');
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black38 : Colors.white38,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Recipe info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe name
                    Text(
                      recipeName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mainTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Recipe details (time and difficulty)
                    Row(
                      children: [
                        // Time indicator
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cookingTime,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        const Spacer(),

                        // Difficulty indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            difficulty,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Show ingredient information if requested
                    if (showIngredientInfo && missingIngredients != null) ...[
                      const Spacer(), // Empuja el indicador de ingredientes hacia abajo
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          missingIngredients > 0
                              ? 'Faltan $missingIngredients ingredientes'
                              : 'Tienes todos los ingredientes',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color:
                                missingIngredients > 0
                                    ? Colors.orange.shade700
                                    : Colors.green,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple category detail screen to show when "Ver más" is tapped
class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final String categoryEmoji;
  final List<dynamic> recipes;
  final bool showOnlyWithIngredients;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.categoryEmoji,
    required this.recipes,
    required this.showOnlyWithIngredients,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBackgroundColor = isDark ? AppColors.darkSurface : Colors.white;

    // Filtrar recetas si es necesario
    final filteredRecipes =
        showOnlyWithIngredients
            ? recipes
                .where(
                  (recipe) => (recipe['availableIngredientsCount'] ?? 0) > 0,
                )
                .toList()
            : recipes;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(categoryEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: theme.textTheme.titleLarge?.fontSize ?? 20,
                color: mainTextColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor),
      ),
      body:
          filteredRecipes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_food,
                      size: 64,
                      color: secondaryTextColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay recetas disponibles',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: mainTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se encontraron recetas con tus ingredientes disponibles',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = filteredRecipes[index];
                  final difficultyColor =
                      recipe['difficulty'] == 'Fácil'
                          ? Colors.green
                          : recipe['difficulty'] == 'Medio'
                          ? Colors.orange
                          : Colors.red;

                  // Calcular ingredientes faltantes
                  final missingIngredients =
                      recipe.containsKey('requiredIngredientsCount') &&
                              recipe.containsKey('availableIngredientsCount')
                          ? (recipe['requiredIngredientsCount'] ?? 0) -
                              (recipe['availableIngredientsCount'] ?? 0)
                          : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () {
                        // Navigate to recipe detail in the future
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => RecipeDetailScreen(
                                  recipe: {
                                    'name': recipe['name'],
                                    'emoji': recipe['emoji'],
                                    'time': recipe['time'],
                                    'difficulty': recipe['difficulty'],
                                    'type': recipe['type'],
                                    'id': recipe['id'],
                                    'steps': [], // Pasos vacíos por ahora
                                    'ingredients':
                                        [], // Ingredientes vacíos por ahora
                                    'availableIngredientsCount':
                                        recipe['availableIngredientsCount'],
                                    'requiredIngredientsCount':
                                        recipe['requiredIngredientsCount'],
                                    'isFavorite': recipe['isFavorite'],
                                  },
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Recipe emoji
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Text(
                                  recipe['emoji'],
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),

                            // Recipe info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['name'],
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: mainTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        recipe['time'],
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: difficultyColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Text(
                                          recipe['difficulty'],
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: difficultyColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Mostrar info de ingredientes si corresponde
                                  if (showOnlyWithIngredients &&
                                      missingIngredients != null) ...[
                                    const SizedBox(height: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Text(
                                        missingIngredients > 0
                                            ? 'Faltan $missingIngredients ingredientes'
                                            : 'Tienes todos los ingredientes',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              missingIngredients > 0
                                                  ? Colors.orange.shade700
                                                  : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Arrow icon
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: secondaryTextColor.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
