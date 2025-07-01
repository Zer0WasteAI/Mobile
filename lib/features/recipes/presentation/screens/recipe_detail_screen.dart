import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_history_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/favorite_button.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  Map<String, bool> _ingredientAvailability = {};

  @override
  void initState() {
    super.initState();
    // Track recipe view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeHistoryProvider.notifier).trackRecipeView(widget.recipe);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIngredientAvailability();
  }

  // Verifica qué ingredientes están disponibles en el inventario
  void _checkIngredientAvailability() {
    final inventoryState = ref.read(inventoryRealProvider);
    final List<String> recipeIngredients = widget.recipe.ingredients;

    final availableIngredients = <String>{};

    for (var ingredient in recipeIngredients) {
      final ingredientInfo = _parseIngredientSimple(ingredient);
      String ingredientName = (ingredientInfo['name'] ?? '').toLowerCase();
      // Verificar si algún item del inventario contiene este ingrediente
      bool isAvailable = inventoryState.items.any(
        (item) =>
            item.name.toLowerCase().contains(ingredientName) ||
            ingredientName.contains(item.name.toLowerCase()),
      );
      if (isAvailable) {
        availableIngredients.add(ingredientInfo['name'] ?? '');
      }
    }

    setState(() {
      _ingredientAvailability = {
        for (var ingredient in availableIngredients) ingredient: true,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    // Recipe history state
    final isInProgress = ref.watch(
      isRecipeInProgressProvider(widget.recipe.id),
    );
    final recipeHistory = ref
        .read(recipeHistoryProvider.notifier)
        .getRecipeHistory(widget.recipe);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          widget.recipe.name,
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [FavoriteButton(recipe: widget.recipe)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe header
            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji and basic info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.recipe.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipe.name,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.timer,
                                  '${widget.recipe.cookingTime} min',
                                  primaryColor,
                                  isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.restaurant,
                                  widget.recipe.difficulty,
                                  primaryColor,
                                  isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    widget.recipe.description,
                    style: GoogleFonts.inter(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recipe history stats
            if (recipeHistory != null && recipeHistory.timesCooked > 0)
              Container(
                padding: const EdgeInsets.all(16),
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.restaurant,
                          'Cocinada ${recipeHistory.timesCooked} veces',
                          primaryColor,
                          isDark,
                        ),
                        if (recipeHistory.averageRating != null) ...[
                          const SizedBox(width: 8),
                          _buildStatChip(
                            Icons.star,
                            '${recipeHistory.averageRating!.toStringAsFixed(1)} ★',
                            primaryColor,
                            isDark,
                          ),
                        ],
                      ],
                    ),
                    if (recipeHistory.lastCooked != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Última vez: ${_formatDate(recipeHistory.lastCooked!)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Ingredients
            Container(
              padding: const EdgeInsets.all(16),
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredientes',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = widget.recipe.ingredients[index];
                      final isAvailable =
                          _ingredientAvailability[ingredient] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              isAvailable
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 20,
                              color: isAvailable ? primaryColor : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ingredient,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _handleCookingAction(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isInProgress ? 'Terminar de Cocinar' : 'Empezar a Cocinar',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
        color: primaryColor.withAlpha(25),
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

  Widget _buildStatChip(
    IconData icon,
    String label,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleCookingAction(BuildContext context) {
    final isInProgress = ref.read(isRecipeInProgressProvider(widget.recipe.id));
    final historyNotifier = ref.read(recipeHistoryProvider.notifier);

    if (isInProgress) {
      // Show rating dialog when completing
      showDialog(
        context: context,
        builder: (context) => _buildCompletionDialog(context),
      );
    } else {
      // Start cooking
      historyNotifier.startCooking(widget.recipe);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Empezaste a cocinar esta receta!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCompletionDialog(BuildContext context) {
    double rating = 5.0;
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('¿Qué tal quedó la receta?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rating slider
          Row(
            children: [
              const Text('1'),
              Expanded(
                child: Slider(
                  value: rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    rating = value;
                  },
                ),
              ),
              const Text('5'),
            ],
          ),
          const SizedBox(height: 16),
          // Notes field
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Notas (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Complete cooking with rating and notes
            ref
                .read(recipeHistoryProvider.notifier)
                .completeCooking(
                  widget.recipe,
                  rating: rating,
                  notes: controller.text.isNotEmpty ? controller.text : null,
                );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Receta completada!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // Función simple para parsear ingredientes
  Map<String, String> _parseIngredientSimple(dynamic ingredient) {
    if (ingredient is String) {
      // Si es un string que parece JSON, extraer el nombre
      if (ingredient.contains('name:')) {
        final nameMatch = RegExp(r'name:\s*([^,}]+)').firstMatch(ingredient);
        final quantityMatch = RegExp(
          r'quantity:\s*([^,}]+)',
        ).firstMatch(ingredient);
        final unitMatch = RegExp(r'unit:\s*([^,}]+)').firstMatch(ingredient);

        String name = nameMatch?.group(1)?.trim() ?? ingredient;
        String quantity = quantityMatch?.group(1)?.trim() ?? '';
        String unit = unitMatch?.group(1)?.trim() ?? '';

        // Limpiar comillas y espacios
        name = name.replaceAll(RegExp(r'["\s]+'), ' ').trim();
        quantity = quantity.replaceAll(RegExp(r'["\s]+'), ' ').trim();
        unit = unit.replaceAll(RegExp(r'["\s]+'), ' ').trim();

        return {'name': name, 'quantity': quantity, 'unit': unit};
      } else {
        return {'name': ingredient, 'quantity': '', 'unit': ''};
      }
    } else if (ingredient is Map) {
      return {
        'name': ingredient['name']?.toString() ?? 'Ingrediente',
        'quantity': ingredient['quantity']?.toString() ?? '',
        'unit': ingredient['unit']?.toString() ?? '',
      };
    } else {
      return {'name': ingredient.toString(), 'quantity': '', 'unit': ''};
    }
  }
}
