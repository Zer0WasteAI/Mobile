import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/create_recipe_screen.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/widgets/safe_navigation_buttons.dart';

// Import extracted components
import '../widgets/recipe_library/recipe_card_builder.dart';
import '../widgets/recipe_library/recipe_dialog_manager.dart';
import '../widgets/recipe_library/recipe_filter_manager.dart';
import '../widgets/recipe_library/ai_suggestion_manager.dart';

/// Refactored Recipe Library Screen with extracted components
/// 
/// This screen now delegates complex logic to specialized managers:
/// - RecipeCardBuilder: Handles recipe cards and grids
/// - RecipeDialogManager: Manages all dialogs
/// - RecipeFilterManager: Handles filtering and search
/// - AiSuggestionManager: Manages AI suggestions
class RecipeLibraryScreen extends ConsumerStatefulWidget {
  final bool selectionMode;
  final MealType? initialMealType;
  final Function(MealPlan)? onRecipeSelected;

  const RecipeLibraryScreen({
    super.key,
    this.selectionMode = false,
    this.initialMealType,
    this.onRecipeSelected,
  });

  @override
  ConsumerState<RecipeLibraryScreen> createState() =>
      _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends ConsumerState<RecipeLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);

    // Apply initial meal type filter if present
    if (widget.initialMealType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyInitialMealTypeFilter();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(recipeFiltersProvider.notifier).state = ref
        .read(recipeFiltersProvider)
        .copyWith(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          clearSearch: _searchController.text.isEmpty,
        );
  }

  void _applyInitialMealTypeFilter() {
    final currentFilters = ref.read(recipeFiltersProvider);
    ref.read(recipeFiltersProvider.notifier).state = 
        currentFilters.copyWith(mealType: widget.initialMealType);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final primaryColor = const Color(0xFF00BFA5);

    final recipes = ref.watch(filteredRecipesProvider);
    final favorites = ref.watch(favoriteRecipesProvider);
    final recents = ref.watch(recentRecipesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(textColor),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title (only if not in selection mode)
          if (!widget.selectionMode) _buildScreenTitle(textColor),

          // Search bar
          RecipeFilterManager.buildSearchBar(
            _searchController,
            ref,
            onFilterTap: _toggleFilterPanel,
          ),

          const SizedBox(height: 8),

          // Filter panel
          if (_showFilterPanel) 
            RecipeFilterManager.buildFilterPanel(ref),

          // Active filters display
          RecipeFilterManager.buildActiveFilters(ref),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All recipes
                RecipeCardBuilder.buildRecipeGrid(
                  recipes,
                  ref,
                  selectionMode: widget.selectionMode,
                  onRecipeSelected: widget.onRecipeSelected,
                ),

                // Favorites
                RecipeCardBuilder.buildRecipeGrid(
                  favorites,
                  ref,
                  selectionMode: widget.selectionMode,
                  onRecipeSelected: widget.onRecipeSelected,
                ),

                // Recent recipes
                RecipeCardBuilder.buildRecipeGrid(
                  recents,
                  ref,
                  selectionMode: widget.selectionMode,
                  onRecipeSelected: widget.onRecipeSelected,
                ),

                // AI suggestions
                AiSuggestionManager.buildAiSuggestions(ref),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(primaryColor),
    );
  }

  /// Build app bar
  AppBar _buildAppBar(Color textColor) {
    return AppBar(
      leading: SafeBackButton(iconColor: textColor),
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: widget.selectionMode
          ? Text(
              'Seleccionar receta',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )
          : null,
      actions: [
        // Filter toggle button
        IconButton(
          icon: Icon(Icons.tune, color: textColor),
          onPressed: _toggleFilterPanel,
          tooltip: 'Filtros',
        ),
        
        // Create recipe button (only in normal mode)
        if (!widget.selectionMode)
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: textColor),
            onPressed: _navigateToCreateRecipe,
            tooltip: 'Crear receta',
          ),
      ],
    );
  }

  /// Build screen title
  Widget _buildScreenTitle(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        'Biblioteca de Recetas',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF00BFA5),
        indicatorWeight: 3,
        labelColor: const Color(0xFF00BFA5),
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Favoritas'),
          Tab(text: 'Recientes'),
          Tab(text: 'Sugeridas IA'),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(Color primaryColor) {
    return FloatingActionButton(
      onPressed: () {
        if (widget.selectionMode) {
          Navigator.pop(context);
        } else {
          RecipeDialogManager.showAiSuggestionDialog(context, ref);
        }
      },
      backgroundColor: primaryColor,
      tooltip: widget.selectionMode ? 'Volver' : 'Generar con IA',
      child: Icon(
        widget.selectionMode ? Icons.arrow_back : Icons.auto_awesome,
      ),
    );
  }

  // Event handlers

  void _toggleFilterPanel() {
    setState(() {
      _showFilterPanel = !_showFilterPanel;
    });
  }

  void _navigateToCreateRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRecipeScreen(),
      ),
    );
  }
}