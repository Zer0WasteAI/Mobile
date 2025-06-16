import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/favorite_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

class FavoriteRecipesScreen extends ConsumerStatefulWidget {
  const FavoriteRecipesScreen({super.key});

  static const String routeName = 'favorite-recipes';
  static const String routePath = '/recipes/favorites';

  @override
  ConsumerState<FavoriteRecipesScreen> createState() =>
      _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends ConsumerState<FavoriteRecipesScreen> {
  String _searchQuery = '';
  SortCriteria _sortBy = SortCriteria.name;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final favoritesState = ref.watch(favoriteRecipesProvider);
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    // Get filtered and sorted recipes
    List<Recipe> displayedRecipes = _getFilteredAndSortedRecipes();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recetas Favoritas',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              '${favoritesState.favoriteCount} recetas guardadas',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        actions: [
          // Sync indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  favoritesState.isBackendSynced
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              favoritesState.isBackendSynced
                  ? Icons.cloud_done
                  : Icons.cloud_off,
              size: 16,
              color: Colors.white,
            ),
          ),
          // Sort menu
          PopupMenuButton<SortCriteria>(
            icon: const Icon(Icons.sort),
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
                                  ? const Color(0xFF00BFA5)
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text('Por nombre'),
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
                                  ? const Color(0xFF00BFA5)
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text('Por tiempo'),
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
                                  ? const Color(0xFF00BFA5)
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text('Por dificultad'),
                      ],
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await favoritesNotifier.refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar en tus recetas favoritas...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
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

          // Loading state
          if (favoritesState.isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF00BFA5)),
                    ),
                    SizedBox(height: 16),
                    Text('Cargando recetas favoritas...'),
                  ],
                ),
              ),
            )
          // Error state
          else if (favoritesState.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar favoritas',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      favoritesState.error!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await favoritesNotifier.refresh();
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
            )
          // Empty state
          else if (displayedRecipes.isEmpty && _searchQuery.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes recetas favoritas',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora recetas y guarda las que más te gusten',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/recipes');
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Explorar recetas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Search empty state
          else if (displayedRecipes.isEmpty && _searchQuery.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin resultados',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se encontraron recetas con "$_searchQuery"',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          // Recipes list
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = displayedRecipes[index];
                  return _buildRecipeCard(recipe);
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Recipe> _getFilteredAndSortedRecipes() {
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    // First filter by search query
    List<Recipe> filtered = favoritesNotifier.searchFavorites(_searchQuery);

    // Then sort
    return favoritesNotifier
        .getSortedFavorites(sortBy: _sortBy, ascending: _ascending)
        .where((recipe) => filtered.contains(recipe))
        .toList();
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final isRecipeSaving = ref.watch(isRecipeSavingProvider(recipe.id));
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    return Dismissible(
      key: Key(recipe.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              'Eliminar',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      'Eliminar receta',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      '¿Estás seguro de que quieres eliminar "${recipe.name}" de tus favoritas?',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(color: Colors.grey.shade600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Eliminar',
                          style: GoogleFonts.inter(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        final success = await favoritesNotifier.removeRecipeFromFavorites(
          recipe.id,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${recipe.name} eliminada de favoritas'),
              action: SnackBarAction(
                label: 'Deshacer',
                textColor: Colors.white,
                onPressed: () async {
                  await favoritesNotifier.saveRecipeToFavorites(recipe);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to recipe detail
            context.push('/recipes/detail/${recipe.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with emoji and favorite button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe emoji
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Recipe info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Favorite button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:
                            isRecipeSaving
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.red.shade400,
                                    ),
                                  ),
                                )
                                : Icon(
                                  Icons.favorite,
                                  color: Colors.red.shade400,
                                ),
                        onPressed:
                            isRecipeSaving
                                ? null
                                : () async {
                                  final success = await favoritesNotifier
                                      .removeRecipeFromFavorites(recipe.id);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${recipe.name} eliminada de favoritas',
                                        ),
                                        action: SnackBarAction(
                                          label: 'Deshacer',
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            await favoritesNotifier
                                                .saveRecipeToFavorites(recipe);
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Recipe stats
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.schedule,
                      label: recipe.formattedCookingTime,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.signal_cellular_alt,
                      label: recipe.difficulty,
                      color: _getDifficultyColor(recipe.difficulty),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.restaurant,
                      label: recipe.dietType,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Ingredients available indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        recipe.availableIngredientsCount ==
                                recipe.requiredIngredientsCount
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          recipe.availableIngredientsCount ==
                                  recipe.requiredIngredientsCount
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        recipe.availableIngredientsCount ==
                                recipe.requiredIngredientsCount
                            ? Icons.check_circle
                            : Icons.info,
                        size: 16,
                        color:
                            recipe.availableIngredientsCount ==
                                    recipe.requiredIngredientsCount
                                ? Colors.green.shade600
                                : Colors.orange.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.availableIngredientsCount}/${recipe.requiredIngredientsCount} ingredientes disponibles',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              recipe.availableIngredientsCount ==
                                      recipe.requiredIngredientsCount
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.green;
      case 'Medio':
        return Colors.orange;
      case 'Difícil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
