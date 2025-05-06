import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_cooking_mode.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_rating_dialog.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({required this.recipe, Key? key}) : super(key: key);

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _isCookingMode = false;
  bool _isFavorite = false;
  bool _showAllSteps = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors
    final backgroundColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6);
    final textColor = isDark ? Colors.white : const Color(0xFF3A3A3A);
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondaryColor = isDark ? Colors.teal.shade300 : Colors.teal.shade600;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body:
          _isCookingMode
              ? RecipeCookingMode(
                recipe: widget.recipe,
                onExit: () => setState(() => _isCookingMode = false),
                onComplete: _showRatingDialog,
              )
              : _buildRecipeDetails(
                context,
                isDark,
                textColor,
                primaryColor,
                secondaryColor,
                cardColor,
              ),
      bottomNavigationBar:
          _isCookingMode
              ? null
              : _buildBottomButtons(context, isDark, primaryColor),
    );
  }

  Widget _buildRecipeDetails(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color primaryColor,
    Color secondaryColor,
    Color cardColor,
  ) {
    return CustomScrollView(
      slivers: [
        // Header image with back button and favorite
        _buildHeaderImage(isDark, textColor),

        // Recipe content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and info chips
                _buildTitleSection(textColor, primaryColor, secondaryColor),

                const SizedBox(height: 16),

                // Description
                _buildDescriptionSection(textColor),

                const SizedBox(height: 24),

                // Ingredients section
                _buildIngredientsSection(textColor, primaryColor, cardColor),

                const SizedBox(height: 32),

                // Preparation steps
                _buildPreparationSection(
                  textColor,
                  primaryColor,
                  secondaryColor,
                ),

                const SizedBox(height: 32),

                // Suggestion
                _buildSuggestionSection(textColor, secondaryColor, cardColor),

                const SizedBox(height: 24),

                // Environmental impact
                _buildEnvironmentalImpactSection(
                  textColor,
                  primaryColor,
                  cardColor,
                ),

                // Extra padding at bottom
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(bool isDark, Color textColor) {
    final String imageUrl =
        widget.recipe['imageUrl'] ??
        'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=896&q=80';
    final String emoji = widget.recipe['emoji'] ?? '🍛';

    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isFavorite
                      ? 'Añadido a favoritos'
                      : 'Eliminado de favoritos',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background:
            _hasValidImageUrl(imageUrl)
                ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 100),
                        ),
                      ),
                )
                : Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 100)),
                ),
      ),
    );
  }

  bool _hasValidImageUrl(String url) {
    return url.startsWith('http') &&
        (url.contains('.jpg') ||
            url.contains('.png') ||
            url.contains('.jpeg') ||
            url.contains('.webp'));
  }

  Widget _buildTitleSection(
    Color textColor,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final String name = widget.recipe['name'] ?? 'Curry de garbanzos';
    final String difficulty = widget.recipe['difficulty'] ?? 'Fácil';
    final String type = _getRecipeTypeLabel(widget.recipe['type'] ?? 'fondo');
    final String time = widget.recipe['time'] ?? '30 min';
    final List<dynamic> tags = widget.recipe['tags'] ?? ['vegana'];

    // Determine colors based on difficulty
    final Map<String, Color> difficultyColors = {
      'Fácil': Colors.green,
      'Medio': Colors.orange,
      'Difícil': Colors.red,
    };

    final Color difficultyColor = difficultyColors[difficulty] ?? Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        // Info chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildInfoChip(
              label: difficulty,
              color: difficultyColor,
              icon: Icons.signal_cellular_alt,
            ),
            _buildInfoChip(
              label: type,
              color: secondaryColor,
              icon: Icons.restaurant_menu,
            ),
            _buildInfoChip(label: time, color: primaryColor, icon: Icons.timer),
            if (tags.isNotEmpty)
              ...tags.map(
                (tag) => _buildInfoChip(
                  label: _getTagLabel(tag),
                  color: Colors.purpleAccent,
                  icon: Icons.eco,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      backgroundColor: color.withOpacity(0.1),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildDescriptionSection(Color textColor) {
    final String description =
        widget.recipe['description'] ??
        'Un curry de garbanzos vegano, lleno de sabor y perfecto para una comida rápida y sostenible.';

    return Text(
      description,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: textColor.withOpacity(0.8),
        height: 1.5,
      ),
    );
  }

  Widget _buildIngredientsSection(
    Color textColor,
    Color primaryColor,
    Color cardColor,
  ) {
    final List<dynamic> ingredients = widget.recipe['ingredients'] ?? [];
    final missingCount =
        ingredients
            .where((ingredient) => _isMissingIngredient(ingredient))
            .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingredientes',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (missingCount > 0)
              OutlinedButton.icon(
                icon: const Icon(Icons.shopping_basket),
                label: Text('¿Qué me falta? ($missingCount)'),
                onPressed: _showMissingIngredientsDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  ingredients.map<Widget>((ingredient) {
                    final name = ingredient['name'] ?? '';
                    final quantity = ingredient['quantity'] ?? '';
                    final unit = ingredient['unit'] ?? '';
                    final isMissing = _isMissingIngredient(ingredient);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  isMissing
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isMissing ? Icons.close : Icons.check,
                              color: isMissing ? Colors.red : Colors.green,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (quantity.isNotEmpty || unit.isNotEmpty)
                            Text(
                              '$quantity ${unit.isNotEmpty ? unit : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationSection(
    Color textColor,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final List<dynamic> steps = widget.recipe['steps'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasos de preparación',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Iniciar preparación'),
          onPressed: () {
            setState(() {
              _isCookingMode = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_showAllSteps)
          ...steps.asMap().entries.map(
            (entry) => _buildStepPreview(
              entry.key,
              entry.value,
              textColor,
              secondaryColor,
            ),
          )
        else ...[
          for (int i = 0; i < steps.length && i < 2; i++)
            _buildStepPreview(i, steps[i], textColor, secondaryColor),
        ],

        if (steps.length > 2)
          Center(
            child: TextButton.icon(
              icon: Icon(
                _showAllSteps
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              label: Text(
                _showAllSteps
                    ? 'Mostrar menos'
                    : 'Ver ${steps.length - 2} pasos más',
              ),
              onPressed: () {
                setState(() {
                  _showAllSteps = !_showAllSteps;
                });
              },
              style: TextButton.styleFrom(foregroundColor: secondaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildStepPreview(
    int index,
    String step,
    Color textColor,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection(
    Color textColor,
    Color secondaryColor,
    Color cardColor,
  ) {
    final String note =
        widget.recipe['notes'] ??
        'Si te falta espinaca, puedes usar kale como alternativa.';

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: secondaryColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: secondaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugerencia',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactSection(
    Color textColor,
    Color primaryColor,
    Color cardColor,
  ) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.eco, color: Colors.green.shade600, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Impacto ambiental positivo',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ahorras 0.8 kg CO₂ y 150 L de agua usando tus ingredientes.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Guardar receta'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receta guardada'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
                side: BorderSide(
                  color: isDark ? Colors.white30 : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Planificar'),
              onPressed: _showPlanningOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMissingIngredientsDialog() {
    final List<dynamic> ingredients = widget.recipe['ingredients'] ?? [];
    final List<dynamic> missingIngredients =
        ingredients
            .where((ingredient) => _isMissingIngredient(ingredient))
            .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Ingredientes que te faltan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...missingIngredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_basket_outlined,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${ingredient['name']} (${ingredient['quantity']} ${ingredient['unit']})',
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Añadir a la lista de compras'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingredientes añadidos a la lista de compras',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  void _showPlanningOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  '¿Cuándo quieres cocinar esta receta?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPlanningOption(context, 'Hoy', Icons.today),
                _buildPlanningOption(context, 'Mañana', Icons.event),
                _buildPlanningOption(
                  context,
                  'Este fin de semana',
                  Icons.weekend,
                ),
                _buildPlanningOption(
                  context,
                  'Elegir otra fecha',
                  Icons.calendar_month,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildPlanningOption(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receta programada para $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder:
          (context) => RecipeRatingDialog(
            recipeName: widget.recipe['name'] ?? 'Curry de garbanzos',
            onSubmit: (rating, comment) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Has calificado esta receta con $rating estrellas',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
            },
          ),
    );
  }

  bool _isMissingIngredient(dynamic ingredient) {
    // En un caso real, esto verificaría contra un repositorio de inventario
    // Para este ejemplo, haremos que algunos ingredientes estén "faltantes"
    final name = ingredient['name']?.toString().toLowerCase() ?? '';
    return name.contains('espinaca') ||
        name.contains('espinacas') ||
        name.contains('queso') ||
        name.contains('organo') ||
        name.contains('orégano');
  }

  String _getRecipeTypeLabel(String type) {
    final Map<String, String> typeLabels = {
      'entrada': 'Entrada',
      'fondo': 'Plato principal',
      'postre': 'Postre',
      'bebida': 'Bebida',
      'snack': 'Snack',
    };
    return typeLabels[type] ?? 'Plato principal';
  }

  String _getTagLabel(String tag) {
    final Map<String, String> tagLabels = {
      'vegetariana': 'Vegetariana',
      'vegana': 'Vegana',
      'sin_gluten': 'Sin Gluten',
      'sin_lactosa': 'Sin Lactosa',
      'italiana': 'Italiana',
      'cremosa': 'Cremosa',
      'mexicana': 'Mexicana',
      'española': 'Española',
      'asiática': 'Asiática',
      'sobrantes': 'Aprovecha sobrantes',
      'estacion': 'De temporada',
      'bajo_impacto': 'Bajo impacto',
    };

    return tagLabels[tag] ?? tag;
  }
}
