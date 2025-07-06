import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/favorite_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/lottie_loading_widget.dart';

class MyRecipesScreen extends ConsumerStatefulWidget {
  const MyRecipesScreen({super.key});

  static const String routeName = 'my-recipes';
  static const String routePath = '/recipes/my-recipes';

  @override
  ConsumerState<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends ConsumerState<MyRecipesScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  SortCriteria _sortBy = SortCriteria.name;
  bool _ascending = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Load favorite recipes on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoriteRecipesProvider.notifier).loadFavoritesFromBackend();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final favoritesState = ref.watch(favoriteRecipesProvider);
    final isGenerating = ref.watch(isGeneratingRecipesProvider);

    // Theme colors
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    // Get filtered and sorted recipes
    List<Recipe> displayedRecipes = _getFilteredAndSortedRecipes();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Recetas',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textColor,
              ),
            ),
            Text(
              '${favoritesState.favoriteCount} recetas guardadas',
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          if (favoritesState.favoriteCount > 0) ...[
            // Sort menu
            PopupMenuButton<SortCriteria>(
              icon: Icon(Icons.sort, color: textColor),
              onSelected: (SortCriteria criteria) {
                setState(() {
                  if (_sortBy == criteria) {
                    _ascending = !_ascending;
                  } else {
                    _sortBy = criteria;
                    _ascending = true;
                  }
                });
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: SortCriteria.name,
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_by_alpha,
                            size: 20,
                            color:
                                _sortBy == SortCriteria.name
                                    ? primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          const Text('Por nombre'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: SortCriteria.cookingTime,
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color:
                                _sortBy == SortCriteria.cookingTime
                                    ? primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          const Text('Por tiempo'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: SortCriteria.difficulty,
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 20,
                            color:
                                _sortBy == SortCriteria.difficulty
                                    ? primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          const Text('Por dificultad'),
                        ],
                      ),
                    ),
                  ],
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: textColor),
              onPressed: () async {
                await ref.read(favoriteRecipesProvider.notifier).refresh();
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (favoritesState.favoriteCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Buscar en tus recetas...',
                  hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                  prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.darkSurface : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

          // Content
          Expanded(
            child: _buildContent(
              favoritesState,
              displayedRecipes,
              isGenerating,
              cardColor,
              primaryColor,
              textColor,
              secondaryTextColor,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    FavoriteRecipesState favoritesState,
    List<Recipe> displayedRecipes,
    bool isGenerating,
    Color cardColor,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    // Loading state
    if (favoritesState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LottieLoadingWidget.food(
              width: 100,
              height: 100,
              showMessage: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando tus recetas...',
              style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Error state
    if (favoritesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar recetas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              favoritesState.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(favoriteRecipesProvider.notifier).refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Intentar de nuevo',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state - no recipes saved
    if (favoritesState.favoriteCount == 0 && !isGenerating) {
      return _buildEmptyState(
        primaryColor,
        textColor,
        secondaryTextColor,
        isDark,
      );
    }

    // Recipes list
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(favoriteRecipesProvider.notifier).refresh();
      },
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = displayedRecipes[index];
          return _buildRecipeCard(
            recipe,
            cardColor,
            primaryColor,
            textColor,
            secondaryTextColor,
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_menu, size: 64, color: primaryColor),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            '¡Comienza tu colección!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Aún no tienes recetas guardadas.\nGenera recetas personalizadas y guárdalas para acceder fácilmente a tus favoritas.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: secondaryTextColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Generation options
          _buildGenerationOption(
            icon: Icons.kitchen,
            title: 'Generar con mi inventario',
            subtitle: 'Usa los ingredientes que tienes disponibles',
            primaryColor: primaryColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            isDark: isDark,
            onTap: () => _generateFromInventory(),
          ),
          const SizedBox(height: 16),

          _buildGenerationOption(
            icon: Icons.tune,
            title: 'Generar receta personalizada',
            subtitle: 'Elige ingredientes específicos y preferencias',
            primaryColor: primaryColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            isDark: isDark,
            onTap: () => _generateCustomRecipe(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(
    Recipe recipe,
    Color cardColor,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _navigateToRecipeDetail(recipe);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Recipe emoji/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Recipe info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.schedule,
                            '${recipe.cookingTime}min',
                            primaryColor,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.signal_cellular_alt,
                            recipe.difficulty,
                            primaryColor,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showDeleteRecipeDialog(recipe);
                      },
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: secondaryTextColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Recipe> _getFilteredAndSortedRecipes() {
    final favoriteRecipes = ref
        .read(favoriteRecipesProvider.notifier)
        .getSortedFavorites(sortBy: _sortBy, ascending: _ascending);

    if (_searchQuery.isEmpty) {
      return favoriteRecipes;
    }

    return ref
        .read(favoriteRecipesProvider.notifier)
        .searchFavorites(_searchQuery);
  }

  void _generateFromInventory() async {
    try {
      // Show loading indicator in navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Generando recetas con tu inventario...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await ref.read(aiRecipeProvider.notifier).generateRecipesFromInventory();

      // Navigate to AI generation screen to show results
      if (mounted) {
        GoRouter.of(context).go('/recipes/ai-generation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar recetas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _generateCustomRecipe() {
    // Navigate to custom recipe generation screen
    GoRouter.of(context).go('/recipes/custom-generation');
  }

  void _showDeleteRecipeDialog(Recipe recipe) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quitar de favoritos'),
            content: Text(
              '¿Estás seguro de que quieres quitar "${recipe.name}" de tus recetas favoritas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Use removeRecipeFromFavorites with the recipe ID
                  final success = await ref
                      .read(favoriteRecipesProvider.notifier)
                      .removeRecipeFromFavorites(recipe.id);

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${recipe.name} eliminada de favoritos',
                          ),
                          action: SnackBarAction(
                            label: 'Deshacer',
                            onPressed: () async {
                              await ref
                                  .read(favoriteRecipesProvider.notifier)
                                  .saveRecipeToFavorites(recipe);
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar ${recipe.name}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Quitar'),
              ),
            ],
          ),
    );
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    context.pushNamed('recipeDetail', extra: recipe);
  }
}
