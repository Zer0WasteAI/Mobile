import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final RecipeMode mode;

  const RecipeScreen({
    super.key,
    this.mode = RecipeMode.explore,
  });

  static const String routeName = 'recipes';
  static const String routePath = '/recipes';

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  final List<String> _categories = ['Todas', 'Desayuno', 'Almuerzo', 'Cena', 'Postres', 'Bebidas'];
  
  @override
  Widget build(BuildContext context) {
    final aiRecipes = ref.watch(generatedRecipesProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Recetas',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.pushNamed('favorite-recipes'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh recipes
          ref.invalidate(generatedRecipesProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(child: _buildRecipesList(aiRecipes)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildRecipesList(List<Recipe> recipes) {
    final filteredRecipes = _filterRecipes(recipes);
    
    if (recipes.isEmpty) {
      return _buildEmptyState();
    }
    
    if (filteredRecipes.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = filteredRecipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToRecipeDetail(recipe),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.cookingTime} min',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.restaurant, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    recipe.difficulty,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Color(0xFF00BFA5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Hora de crear recetas increíbles!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Usa nuestra IA para generar recetas personalizadas\nbasadas en tus ingredientes y preferencias',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.pushNamed('AIRecipeGenerationScreen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: Text(
                      'Generar con IA',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showQuickActionsMenu,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00BFA5),
                side: const BorderSide(color: Color(0xFF00BFA5)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.explore, size: 18),
              label: Text(
                'Ver más opciones',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            _buildQuickTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tips para mejores recetas:',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTip('• Especifica el tipo de comida (desayuno, almuerzo, cena)'),
          _buildTip('• Menciona ingredientes que tienes disponibles'),
          _buildTip('• Indica si tienes restricciones alimentarias'),
          _buildTip('• Especifica el tiempo de preparación deseado'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    context.pushNamed('recipeDetail', extra: recipe);
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar recetas...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00BFA5)),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Category filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : const Color(0xFF00BFA5),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF00BFA5),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF00BFA5)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActionsMenu,
      backgroundColor: const Color(0xFF00BFA5),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_awesome),
      label: Text(
        'Generar',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Generar Nuevas Recetas',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionTile(
                    icon: Icons.auto_awesome,
                    title: 'Receta con IA',
                    subtitle: 'Crea una receta completamente nueva',
                    color: const Color(0xFF00BFA5),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('AIRecipeGenerationScreen');
                    },
                  ),
                  _buildQuickActionTile(
                    icon: Icons.inventory_2,
                    title: 'Con mis ingredientes',
                    subtitle: 'Usa lo que tienes en tu inventario',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('AIRecipeGenerationScreen', 
                        queryParameters: {'mode': 'inventory'});
                    },
                  ),
                  _buildQuickActionTile(
                    icon: Icons.shuffle,
                    title: 'Receta sorpresa',
                    subtitle: 'Deja que te sorprendamos',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('AIRecipeGenerationScreen', 
                        queryParameters: {'mode': 'random'});
                    },
                  ),
                  _buildQuickActionTile(
                    icon: Icons.favorite,
                    title: 'Según mis gustos',
                    subtitle: 'Basado en tus recetas favoritas',
                    color: Colors.pink,
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('AIRecipeGenerationScreen', 
                        queryParameters: {'mode': 'preferences'});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron recetas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda\no selecciona una categoría diferente',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'Todas';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Limpiar filtros',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    var filtered = recipes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               recipe.ingredients.any((ingredient) => 
                 ingredient.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'Todas') {
      filtered = filtered.where((recipe) {
        // This is a simple categorization - you might want to add a category field to Recipe model
        switch (_selectedCategory) {
          case 'Desayuno':
            return recipe.name.toLowerCase().contains('desayuno') ||
                   recipe.name.toLowerCase().contains('breakfast') ||
                   recipe.name.toLowerCase().contains('café') ||
                   recipe.name.toLowerCase().contains('tostada') ||
                   recipe.name.toLowerCase().contains('avena');
          case 'Almuerzo':
            return recipe.name.toLowerCase().contains('almuerzo') ||
                   recipe.name.toLowerCase().contains('lunch') ||
                   recipe.name.toLowerCase().contains('sopa') ||
                   recipe.name.toLowerCase().contains('ensalada');
          case 'Cena':
            return recipe.name.toLowerCase().contains('cena') ||
                   recipe.name.toLowerCase().contains('dinner') ||
                   recipe.name.toLowerCase().contains('pasta') ||
                   recipe.name.toLowerCase().contains('pollo');
          case 'Postres':
            return recipe.name.toLowerCase().contains('postre') ||
                   recipe.name.toLowerCase().contains('dessert') ||
                   recipe.name.toLowerCase().contains('torta') ||
                   recipe.name.toLowerCase().contains('dulce');
          case 'Bebidas':
            return recipe.name.toLowerCase().contains('bebida') ||
                   recipe.name.toLowerCase().contains('jugo') ||
                   recipe.name.toLowerCase().contains('smoothie') ||
                   recipe.name.toLowerCase().contains('batido');
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }
}