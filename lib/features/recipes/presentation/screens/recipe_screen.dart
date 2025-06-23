// ignore_for_file: unused_element, avoid_unnecessary_containers

import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_providers.dart';
import 'package:zer0_waste_ai/features/recipes/application/states/recipe_state.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/filter_models.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart'
    as recipe_model;
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_filter_bottom_sheet.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/favorite_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/create_recipe_screen.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/favorite_recipes_screen.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/unfocus_detector.dart';

// Define a provider for recipe filters using JSON file
final recipeFiltersProvider = FutureProvider<List<FilterCategory>>((ref) async {
  try {
    // Load filters from the JSON file in constants
    final String filtersJson = await rootBundle.loadString(
      'lib/core/constants/filters_recipes.json',
    );
    final List<dynamic> decodedJson = jsonDecode(filtersJson);

    return decodedJson
        .map((categoryJson) => FilterCategory.fromJson(categoryJson))
        .toList();
  } catch (e) {
    // Fallback to basic filters if file loading fails
    log('Error loading filters from JSON: $e');
    return [
      FilterCategory(
        category: 'Tipo de receta',
        filters: [
          Filter(
            label: 'Plato principal',
            value: 'fondo',
            icon: Icons.dinner_dining,
          ),
          Filter(label: 'Postre', value: 'postre', icon: Icons.icecream),
        ],
      ),
    ];
  }
});

// Provider for managing favorites
final favoritesProvider = StateProvider<Set<String>>((ref) => {});

// Provider for managing applied filters
final appliedFiltersProvider = StateProvider<Map<String, Set<String>>>((ref) => {});

class RecipeScreen extends ConsumerStatefulWidget {
  final RecipeMode mode;

  const RecipeScreen({required this.mode, super.key});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFab = false;
  String _screenTitle = 'Explorar Recetas';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_showFab != (_tabController.index == 1)) {
        setState(() {
          _showFab = _tabController.index == 1;
        });
      }

      final newTitle =
          _tabController.index == 0 ? 'Explorar Recetas' : 'Mis Recetas';
      if (_screenTitle != newTitle) {
        setState(() {
          _screenTitle = newTitle;
        });
      }
    });

    // Preload filters
    Future.microtask(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(recipeFiltersProvider.future);
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exploreRecipeState = ref.watch(
      recipeControllerProviderFamily(RecipeMode.explore),
    );
    final exploreRecipeNotifier = ref.read(
      recipeControllerProviderFamily(RecipeMode.explore).notifier,
    );

    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final Color scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color onPrimaryColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _screenTitle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: mainTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [Tab(text: 'Explorar'), Tab(text: 'Mis Recetas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExploreTab(
            context,
            ref,
            exploreRecipeState,
            exploreRecipeNotifier,
            isDark,
            primaryColor,
            mainTextColor,
            secondaryTextColor,
          ),
          _buildMyRecipesTab(
            context,
            ref,
            isDark,
            mainTextColor,
            secondaryTextColor,
          ),
        ],
      ),
      floatingActionButton:
          _showFab
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateRecipeScreen(),
                    ),
                  );
                },
                backgroundColor: primaryColor,
                child: Icon(Icons.add, color: onPrimaryColor),
              )
              : null,
    );
  }

  // Build method for Explore Tab - uses backend data only
  Widget _buildExploreTab(
    BuildContext context,
    WidgetRef ref,
    RecipeState recipeState,
    RecipeController recipeNotifier,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    // Show loading state
    if (recipeState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Cargando recetas...',
              style: GoogleFonts.inter(color: secondaryTextColor),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (recipeState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar recetas',
              style: GoogleFonts.inter(color: mainTextColor, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              recipeState.errorMessage!,
              style: GoogleFonts.inter(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: recipeNotifier.retryLoad,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // Show recipes from backend
    return RefreshIndicator(
      onRefresh: () async => recipeNotifier.retryLoad(),
      color: primaryColor,
      child: UnfocusDetector(
        child: CustomScrollView(
          slivers: [
            // Search and filters section
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      onChanged: (query) {
                        // Handle search query change
                        // This would need to be implemented in the controller
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar recetas...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: secondaryTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter button
                    Row(
                      children: [
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final appliedFilters = ref.watch(appliedFiltersProvider);
                              final filterCount = appliedFilters.values.fold<int>(
                                0, (sum, filterSet) => sum + filterSet.length,
                              );
                              
                              return ElevatedButton.icon(
                                onPressed: () => _showFilterBottomSheet(context, ref),
                                icon: Stack(
                                  children: [
                                    Icon(Icons.filter_list),
                                    if (filterCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 14,
                                            minHeight: 14,
                                          ),
                                          child: Text(
                                            '$filterCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                label: Text(filterCount > 0 ? 'Filtros ($filterCount)' : 'Filtros'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: filterCount > 0 ? primaryColor.withValues(alpha: 0.8) : primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recipes list
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = recipeState.recipes[index];
                return _buildRecipeCard(
                  recipe,
                  isDark,
                  primaryColor,
                  mainTextColor,
                  secondaryTextColor,
                );
              }, childCount: recipeState.recipes.length),
            ),
          ],
        ),
      ),
    );
  }

  // Build method for My Recipes Tab
  Widget _buildMyRecipesTab(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
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
          Expanded(
            child: TabBarView(
              children: [
                // AI Generated recipes tab
                _buildAIRecipesTab(
                  ref,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                ),
                // Uploaded recipes tab
                _buildUploadedRecipesTab(
                  ref,
                  isDark,
                  mainTextColor,
                  secondaryTextColor,
                ),
                // Favorite recipes tab
                const FavoriteRecipesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecipesTab(
    WidgetRef ref,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    // Implementation for AI generated recipes
    return Center(
      child: Text(
        'Recetas generadas por IA\n(Próximamente)',
        style: GoogleFonts.inter(color: secondaryTextColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUploadedRecipesTab(
    WidgetRef ref,
    bool isDark,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    // Implementation for uploaded recipes
    return Center(
      child: Text(
        'Recetas subidas\n(Próximamente)',
        style: GoogleFonts.inter(color: secondaryTextColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRecipeCard(
    Recipe recipe,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: Text(recipe.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          recipe.name,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: mainTextColor,
          ),
        ),
        subtitle: Text(
          recipe.description,
          style: GoogleFonts.inter(color: secondaryTextColor),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: FavoriteButton(
          recipe: recipe_model.Recipe(
            id: recipe.id,
            name: recipe.name,
            description: recipe.description,
            emoji: recipe.emoji,
            ingredients: recipe.ingredients,
            requiredIngredientsCount: recipe.requiredIngredientsCount ?? 0,
            availableIngredientsCount: recipe.availableIngredientsCount ?? 0,
            usesExpiringItems: recipe.usesExpiringItems,
            cookingTime: 30,
            difficulty: 'Fácil',
            dietType: 'Omnívora',
            categories: ['General'],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => RecipeDetailScreen(
                    recipe: {
                      'uid': recipe.id,
                      'name': recipe.name,
                      'description': recipe.description,
                      'emoji': recipe.emoji,
                      'ingredients': recipe.ingredients,
                    },
                  ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) async {
    try {
      // Load filter categories from the provider
      final filterCategories = await ref.read(recipeFiltersProvider.future);
      
      // Get current applied filters
      final currentFilters = ref.read(appliedFiltersProvider);
      
      if (!context.mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RecipeFilterBottomSheet(
          filterCategories: filterCategories,
          initialSelectedFilters: currentFilters,
          onApply: (filters) {
            // Apply filters to the recipe list
            ref.read(appliedFiltersProvider.notifier).state = filters;
            
            // Apply filters to the recipe controller
            final recipeNotifier = ref.read(
              recipeControllerProviderFamily(RecipeMode.explore).notifier,
            );
            recipeNotifier.applyFilters(filters);
          },
        ),
      );
    } catch (e) {
      // Show error dialog or fallback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando filtros: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
