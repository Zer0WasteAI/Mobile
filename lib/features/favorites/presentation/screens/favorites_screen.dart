import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_recipe_providers.dart';
import '../../domain/models/favorite_recipe_model.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Recetas Favoritas',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          final filteredFavorites = _filterFavorites(favorites);
          return Column(
            children: [
              _buildFilterChips(colorScheme, textTheme, favorites),
              Expanded(
                child: filteredFavorites.isEmpty
                    ? (favorites.isEmpty 
                        ? _buildEmptyState(colorScheme, textTheme)
                        : _buildNoResultsState(colorScheme, textTheme))
                    : _buildFavoritesList(filteredFavorites, colorScheme, textTheme, ref),
              ),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState(colorScheme, textTheme, error.toString()),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin Favoritos Aún',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega recetas a tus favoritos tocando el ícono de corazón en cualquier receta',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back or to recipe discovery screen
                // Navigator.pop(context);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explorar Recetas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, TextTheme textTheme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar favoritos',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(
    List<FavoriteRecipe> favorites,
    ColorScheme colorScheme,
    TextTheme textTheme,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${favorites.length} ${favorites.length == 1 ? 'receta favorita' : 'recetas favoritas'}',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return _buildFavoriteCard(favorite, colorScheme, textTheme, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    FavoriteRecipe favorite,
    ColorScheme colorScheme,
    TextTheme textTheme,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetails(favorite),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
                child: favorite.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          favorite.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(colorScheme);
                          },
                        ),
                      )
                    : _buildPlaceholderImage(colorScheme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            favorite.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (favorite.mealType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getMealTypeColor(favorite.mealType!).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMealTypeIcon(favorite.mealType!),
                                  size: 12,
                                  color: _getMealTypeColor(favorite.mealType!),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  favorite.mealType!,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: _getMealTypeColor(favorite.mealType!),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      favorite.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMetric(
                          Icons.schedule,
                          '${favorite.prepTime + favorite.cookTime} min',
                          colorScheme,
                          textTheme,
                        ),
                        const SizedBox(width: 16),
                        _buildMetric(
                          Icons.people,
                          '${favorite.servings}',
                          colorScheme,
                          textTheme,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _removeFavorite(favorite, ref),
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 32,
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildMetric(
    IconData icon,
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showRecipeDetails(FavoriteRecipe favorite) {
    // Aquí puedes implementar la navegación a la pantalla de detalles de la receta
    // o mostrar un modal con más información
  }

  void _removeFavorite(FavoriteRecipe favorite, WidgetRef ref) {
    final favoriteAction = ref.read(favoriteActionProvider.notifier);
    favoriteAction.toggleFavorite(
      favorite.id,
      favorite.title,
      favorite.description,
      favorite.ingredients.map((ing) => ing.name).toList(),
      favorite.instructions,
      favorite.prepTime,
      favorite.cookTime,
      favorite.servings,
      favorite.difficulty,
      imagePath: favorite.imagePath,
      mealType: favorite.mealType,
    );
  }

  List<FavoriteRecipe> _filterFavorites(List<FavoriteRecipe> favorites) {
    if (_selectedFilter == 'Todos') {
      return favorites;
    }
    return favorites.where((favorite) => favorite.mealType == _selectedFilter).toList();
  }

  Widget _buildFilterChips(ColorScheme colorScheme, TextTheme textTheme, List<FavoriteRecipe> favorites) {
    final mealTypes = ['Todos'];
    
    // Obtener tipos únicos de las recetas favoritas
    final uniqueTypes = favorites
        .where((f) => f.mealType != null)
        .map((f) => f.mealType!)
        .toSet()
        .toList();
    mealTypes.addAll(uniqueTypes);

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: mealTypes.map((type) {
            final isSelected = _selectedFilter == type;
            final count = type == 'Todos' 
                ? favorites.length 
                : favorites.where((f) => f.mealType == type).length;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('$type ($count)'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = type;
                  });
                },
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoResultsState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay recetas de $_selectedFilter',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro filtro o agrega más recetas favoritas',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Colors.orange;
      case 'almuerzo':
        return Colors.green;
      case 'cena':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Icons.breakfast_dining;
      case 'almuerzo':
        return Icons.lunch_dining;
      case 'cena':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}