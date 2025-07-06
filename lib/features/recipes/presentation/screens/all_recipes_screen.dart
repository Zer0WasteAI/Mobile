import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_backend_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/lottie_loading_widget.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/favorite_button.dart';

class AllRecipesScreen extends ConsumerStatefulWidget {
  const AllRecipesScreen({super.key});

  static const String routeName = 'all-recipes';
  static const String routePath = '/recipes/all';

  @override
  ConsumerState<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends ConsumerState<AllRecipesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  bool _isLoading = true;
  List<Recipe> _allRecipes = [];
  String? _error;
  final bool _showDefaultRecipes =
      false; // Toggle between all recipes and default recipes

  List<String> _categories = ['Todas']; // Will be populated from backend

  @override
  void initState() {
    super.initState();
    _loadAllRecipes();
  }

  Future<void> _loadAllRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipeBackend = ref.read(recipeBackendProvider);
      final Map<String, dynamic> response;

      if (_showDefaultRecipes) {
        // Load default/curated recipes
        final categoryFilter =
            _selectedCategory == 'Todas' ? null : _selectedCategory;
        response = await recipeBackend.getDefaultRecipes(
          category: categoryFilter,
        );
      } else {
        // Load all recipes (existing behavior)
        response = await recipeBackend.getAllRecipes();
      }

      final recipesData = response['recipes'] as List? ?? [];
      final recipes =
          recipesData.map((data) => _parseRecipeFromAPI(data)).toList();

      // Extract unique categories from recipes
      final Set<String> uniqueCategories = {'Todas'};
      for (final recipe in recipes) {
        uniqueCategories.addAll(recipe.categories);
      }

      setState(() {
        _allRecipes = recipes;
        _categories = uniqueCategories.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Recipe _parseRecipeFromAPI(Map<String, dynamic> data) {
    // Parse ingredients from the API format
    final ingredientsData = data['ingredients'] as List? ?? [];
    final ingredientNames =
        ingredientsData
            .map((ingredient) {
              if (ingredient is Map<String, dynamic>) {
                return ingredient['name']?.toString() ?? '';
              }
              return ingredient.toString();
            })
            .where((name) => name.isNotEmpty)
            .toList();

    return Recipe(
      id:
          data['uid']?.toString() ??
          data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['title'] ?? data['name'] ?? 'Receta',
      description: data['description'] ?? '',
      emoji: _getEmojiForRecipe(data['title'] ?? data['name'] ?? ''),
      ingredients: ingredientNames,
      requiredIngredientsCount: ingredientNames.length,
      availableIngredientsCount: ingredientNames.length,
      usesExpiringItems: false,
      cookingTime: data['prep_time'] ?? data['cook_time'] ?? 30,
      difficulty: data['difficulty'] ?? 'fácil',
      dietType: data['diet_type'] ?? 'Omnívora',
      categories: [data['category'] ?? 'General'],
    );
  }

  String _getEmojiForRecipe(String recipeName) {
    final name = recipeName.toLowerCase();
    if (name.contains('pasta') || name.contains('spaghetti')) return '🍝';
    if (name.contains('pizza')) return '🍕';
    if (name.contains('ensalada') || name.contains('salad')) return '🥗';
    if (name.contains('sopa') || name.contains('soup')) return '🍲';
    if (name.contains('arroz') || name.contains('rice')) return '🍚';
    if (name.contains('pollo') || name.contains('chicken')) return '🍗';
    if (name.contains('pescado') || name.contains('fish')) return '🐟';
    if (name.contains('verduras') || name.contains('vegetable')) return '🥕';
    if (name.contains('huevo') || name.contains('egg')) return '🍳';
    if (name.contains('taco')) return '🌮';
    if (name.contains('hamburguesa') || name.contains('burger')) return '🍔';
    if (name.contains('curry')) return '🍛';
    return '🍽️';
  }

  List<Recipe> get _filteredRecipes {
    var filtered = _allRecipes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (recipe) =>
                    recipe.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    recipe.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    recipe.ingredients.any(
                      (ingredient) => ingredient.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();
    }

    // Filter by category
    if (_selectedCategory != 'Todas') {
      filtered =
          filtered
              .where(
                (recipe) => recipe.categories.any(
                  (category) => category.toLowerCase().contains(
                    _selectedCategory.toLowerCase(),
                  ),
                ),
              )
              .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showDefaultRecipes ? 'Recetas por Defecto' : 'Todas las Recetas',
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              '${_allRecipes.length} recetas disponibles',
              style: GoogleFonts.inter(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadAllRecipes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar recetas...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  filled: true,
                  fillColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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

            const SizedBox(height: 8),

            // Category filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      selectedColor: Colors.green.shade600,
                      checkmarkColor: Colors.white,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: LoadingWidgets.recipeLoading)
                      : _error != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar recetas',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAllRecipes,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                      : _filteredRecipes.isEmpty
                      ? Center(
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
                              'No se encontraron recetas',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otros términos de búsqueda',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
                          return _buildRecipeCard(recipe);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.green.shade100,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: FavoriteButton(
                      recipe: recipe,
                      size: 20,
                      showBackground: false,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recipe content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.timer, '${recipe.cookingTime} min'),
                    _buildInfoChip(Icons.restaurant, recipe.difficulty),
                    if (recipe.categories.isNotEmpty)
                      _buildInfoChip(Icons.category, recipe.categories.first),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToRecipeDetail(recipe),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ver receta',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }


  void _navigateToRecipeDetail(Recipe recipe) {
    context.pushNamed('recipeDetail', extra: recipe);
  }
}
