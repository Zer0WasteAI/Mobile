import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_providers.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/filter_models.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_filter_bottom_sheet.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';

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
            ? AppColors.darkPrimary.withOpacity(0.2)
            : AppColors.lightPrimary.withOpacity(0.15);
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
                  // TODO: Navigate to CreateRecipeFormScreen
                  print('Navigate to Create Recipe Screen');
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
    // TODO: Connect to user uploaded recipes source
    // For now, show placeholder
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'No has subido recetas todavía',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: mainTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea y sube tus propias recetas tocando el botón "+" abajo.',
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Favorite Recipes View
  Widget _buildFavoritesView(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    final favorites = ref.watch(favoritesProvider);
    final bool isEmpty = favorites.isEmpty;

    print('Favoritos actuales: $favorites');

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
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
                'Guarda tus recetas favoritas tocando el corazón en las recetas que te gusten.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      // Encontrar todas las recetas favoritas en todas las categorías
      final List<Map<String, dynamic>> favoriteRecipes = [];

      // Obtener todas las categorías mediante el método auxiliar
      final allCategories = _getAllRecipeCategories();

      // Recorrer todas las categorías y recetas para encontrar favoritos
      for (final category in allCategories) {
        for (final recipe in category['recipes']) {
          final recipeId = recipe['id'];
          if (favorites.contains(recipeId)) {
            // Añadir la receta a la lista de favoritos
            favoriteRecipes.add({...recipe, 'category': category['name']});
            print('Receta favorita encontrada: $recipeId - ${recipe['name']}');
          }
        }
      }

      print(
        'Total de recetas favoritas encontradas: ${favoriteRecipes.length}',
      );

      // Mostrar las recetas favoritas
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = favoriteRecipes[index];
                return _buildFavoriteRecipeCard(
                  context,
                  recipe,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                  ref,
                );
              }, childCount: favoriteRecipes.length),
            ),
          ),
        ],
      );
    }
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
    Map<String, dynamic> recipe,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
    WidgetRef ref,
  ) {
    final String categoryName = recipe['category'] ?? '';
    final favorites = ref.watch(favoritesProvider);
    final recipeId = recipe['id'] ?? recipe['name'];
    final isFavorite = favorites.contains(recipeId);
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final Color difficultyColor =
        recipe['difficulty'] == 'Fácil'
            ? Colors.green
            : recipe['difficulty'] == 'Medio'
            ? Colors.orange
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    recipe['emoji'],
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              // Botón de favoritos
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    // Quitar de favoritos
                    final notifier = ref.read(favoritesProvider.notifier);
                    notifier.state = {...favorites}..remove(recipeId);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white38,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Recipe info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe name
                Text(
                  recipe['name'],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: mainTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Category
                Text(
                  categoryName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Time and difficulty
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe['time'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        recipe['difficulty'],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

              if (timeFilters.contains('short_time')) {
                filteredRecipes =
                    filteredRecipes.where((recipe) {
                      final time = recipe['time'];
                      return time.contains('< 15') ||
                          (int.tryParse(time.split(' ')[0]) ?? 100) < 15;
                    }).toList();
              } else if (timeFilters.contains('medium_time')) {
                filteredRecipes =
                    filteredRecipes.where((recipe) {
                      final time = recipe['time'];
                      final minutes = int.tryParse(time.split(' ')[0]) ?? 0;
                      return minutes >= 15 && minutes <= 30;
                    }).toList();
              } else if (timeFilters.contains('long_time')) {
                filteredRecipes =
                    filteredRecipes.where((recipe) {
                      final time = recipe['time'];
                      final minutes = int.tryParse(time.split(' ')[0]) ?? 0;
                      return minutes > 30;
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
                      if (difficultyFilters.contains('facil') &&
                          difficulty == 'Fácil')
                        return true;
                      if (difficultyFilters.contains('intermedio') &&
                          difficulty == 'Medio')
                        return true;
                      if (difficultyFilters.contains('dificil') &&
                          difficulty == 'Difícil')
                        return true;
                      return false;
                    }).toList();
              }
            }

            // Apply diet type filters (example implementation)
            if (activeFiltersState.value.containsKey('Tipo de dieta')) {
              final dietFilters = activeFiltersState.value['Tipo de dieta']!;

              if (dietFilters.contains('vegetariana')) {
                // Filter vegetarian recipes - for demo, let's say all recipes in 'Vegetarianas' category are vegetarian
                if (category['name'] != 'Vegetarianas' &&
                    dietFilters.contains('vegetariana')) {
                  filteredRecipes = [];
                }
              }

              if (dietFilters.contains('vegana')) {
                // For demo purposes - filter by emoji (🌱 for vegan)
                filteredRecipes =
                    filteredRecipes
                        .where(
                          (recipe) =>
                              recipe['emoji'] == '🌱' ||
                              category['name'] == 'Vegetarianas',
                        )
                        .toList();
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
                                  ? Colors.black.withOpacity(0.25)
                                  : Colors.grey.withOpacity(0.15),
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
                        hintStyle: GoogleFonts.inter(color: secondaryTextColor),
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
                        children: [
                          // Filter Button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                icon: Icon(
                                  Icons.filter_list_rounded,
                                  color: primaryColor,
                                ),
                                label: Text(
                                  'Filtros${activeFiltersState.value.isNotEmpty ? ' (${_countActiveFilters(activeFiltersState.value)})' : ''}',
                                  style: GoogleFonts.inter(color: primaryColor),
                                ),
                                onPressed: () {
                                  // Show Filter Bottom Sheet
                                  final filtersData = ref.read(
                                    recipeFiltersProvider,
                                  );

                                  filtersData.when(
                                    data: (filterCategories) {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder:
                                            (
                                              context,
                                            ) => RecipeFilterBottomSheet(
                                              filterCategories:
                                                  filterCategories,
                                              initialSelectedFilters:
                                                  activeFiltersState.value,
                                              onApply: (newFilters) {
                                                // Update active filters state
                                                activeFiltersState.value =
                                                    newFilters;
                                              },
                                            ),
                                      );
                                    },
                                    error: (error, stack) {
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
                                    loading: () {
                                      // Show loading indicator in the bottom sheet instead
                                      showModalBottomSheet(
                                        context: context,
                                        builder:
                                            (context) => const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(24.0),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),

                              // "Limpiar filtros" button below the filter button
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

                          // My Ingredients Switch
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
                                  value: recipeState.showOnlyWithMyIngredients,
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

          // --- Recipe Categories with Carousels ---
          if (!recipeState.isLoading && recipeState.errorMessage == null)
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: errorColor, size: 48),
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
                    ],
                  ),
                ),
              ),
            ),
        ],
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
        selectedColor: primaryColor.withOpacity(0.2),
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
                    ref: ref,
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
    required WidgetRef ref,
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

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to recipe detail
        print('Tapped on recipe: $recipeName');
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
              color: Colors.black.withOpacity(0.06),
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
                    color: primaryColor.withOpacity(0.1),
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
                          print('Receta eliminada de favoritos: $recipeId');
                        } else {
                          // Añadir a favoritos
                          notifier.state = {...favorites, recipeId};
                          print('Receta añadida a favoritos: $recipeId');
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
                            color: difficultyColor.withOpacity(0.1),
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
                          color: primaryColor.withOpacity(0.1),
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
                      color: secondaryTextColor.withOpacity(0.5),
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () {
                        // Navigate to recipe detail in the future
                        print('Tapped on recipe: ${recipe['name']}');
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
                                color: primaryColor.withOpacity(0.1),
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
                                          color: difficultyColor.withOpacity(
                                            0.1,
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
                                        color: primaryColor.withOpacity(0.1),
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
                              color: secondaryTextColor.withOpacity(0.7),
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
