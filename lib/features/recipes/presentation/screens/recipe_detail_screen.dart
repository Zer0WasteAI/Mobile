import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart'
    as impact;
import 'package:zer0_waste_ai/features/recipes/presentation/widgets/recipe_cooking_mode.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'dart:developer';
import 'package:zer0_waste_ai/core/error/error_handler.dart';

import 'package:zer0_waste_ai/core/presentation/widgets/dialog_helper.dart';

import '../../../home/application/providers/home_providers.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({required this.recipe, super.key});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _isCookingMode = false;
  bool _isFavorite = false;
  bool _showAllSteps = false;
  bool _showIngredientCheck = false;
  Map<String, bool> _ingredientAvailability = {};

  @override
  void initState() {
    super.initState();
    // No llamar a ref.watch aquí
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar la disponibilidad de ingredientes aquí
    _checkIngredientAvailability();
  }

  // Verifica qué ingredientes están disponibles en el inventario
  void _checkIngredientAvailability() {
    final inventoryState = ref.read(inventoryRealProvider);
    final List<dynamic> recipeIngredients = widget.recipe['ingredients'] ?? [];

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
                onComplete: _completeRecipe,
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
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
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
      backgroundColor: color.withValues(alpha: 0.1),
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
        color: textColor.withValues(alpha: 0.8),
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
    final bool usesExpiringItems = widget.recipe['usesExpiringItems'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ingredientes',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            // Botón para verificar disponibilidad de ingredientes
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showIngredientCheck = !_showIngredientCheck;
                  if (_showIngredientCheck) {
                    _checkIngredientAvailability();
                  }
                });
              },
              icon: Icon(
                _showIngredientCheck ? Icons.visibility_off : Icons.visibility,
                size: 18,
              ),
              label: Text(
                _showIngredientCheck
                    ? 'Ocultar disponibilidad'
                    : 'Verificar disponibilidad',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Lista de ingredientes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (usesExpiringItems)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta receta ayuda a aprovechar ingredientes que están por vencer',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ...ingredients.map((ingredient) {
                final ingredientInfo = _parseIngredientSimple(ingredient);
                final ingredientKey = ingredientInfo['name'] ?? '';

                bool isAvailable =
                    _showIngredientCheck
                        ? (_ingredientAvailability[ingredientKey] ?? false)
                        : true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isAvailable && _showIngredientCheck
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Availability indicator
                      if (_showIngredientCheck)
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color:
                                isAvailable
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.red.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAvailable ? Icons.check_circle : Icons.cancel,
                            color: isAvailable ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ),

                      // Ingredient icon
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),

                      // Ingredient details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ingredientInfo['name'] ?? 'Ingrediente',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    _showIngredientCheck && !isAvailable
                                        ? Colors.grey
                                        : textColor,
                                decoration:
                                    _showIngredientCheck && !isAvailable
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            if ((ingredientInfo['quantity'] ?? '').isNotEmpty)
                              const SizedBox(height: 2),
                            if ((ingredientInfo['quantity'] ?? '').isNotEmpty)
                              Text(
                                '${ingredientInfo['quantity']} ${ingredientInfo['unit']}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color:
                                      _showIngredientCheck && !isAvailable
                                          ? Colors.grey.withValues(alpha: 0.7)
                                          : textColor.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
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
              color: secondaryColor.withValues(alpha: 0.1),
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
                color: textColor.withValues(alpha: 0.8),
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
        side: BorderSide(
          color: secondaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
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
                      color: textColor.withValues(alpha: 0.8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impacto Ambiental',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.eco, color: primaryColor, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Calcula cómo esta receta ayuda al planeta reduciendo tu huella de carbono y ahorrando recursos.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calcular y Guardar Impacto'),
                  onPressed: _completeRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    // ignore: unused_local_variable
    final bool usesExpiringItems = widget.recipe['usesExpiringItems'] ?? false;

    // Contar ingredientes disponibles
    int availableCount = 0;
    int totalIngredients = (widget.recipe['ingredients'] as List?)?.length ?? 0;

    if (_showIngredientCheck && totalIngredients > 0) {
      availableCount = _ingredientAvailability.values.where((v) => v).length;
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: Icon(
            _showIngredientCheck ? Icons.restaurant : Icons.play_arrow,
          ),
          label: Text(
            _showIngredientCheck
                ? 'Cocinar ($availableCount/$totalIngredients)'
                : 'Iniciar cocina',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (_showIngredientCheck && availableCount < totalIngredients) {
              _showMissingIngredientsDialog(context);
            } else {
              setState(() {
                _isCookingMode = true;
              });
            }
          },
        ),
      ),
    );
  }

  // Muestra un diálogo con los ingredientes que faltan
  void _showMissingIngredientsDialog(BuildContext context) {
    final List<dynamic> ingredients = widget.recipe['ingredients'] ?? [];
    final missingIngredients =
        ingredients.where((ingredient) {
          String ingredientName = ingredient.toString();
          return !(_ingredientAvailability[ingredientName] ?? false);
        }).toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Ingredientes faltantes',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parece que te faltan algunos ingredientes:',
                    style: GoogleFonts.inter(),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: missingIngredients.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.orange,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  missingIngredients[index].toString(),
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isCookingMode = true;
                  });
                },
                child: const Text('Cocinar de todos modos'),
              ),
            ],
          ),
    );
  }

  void _showContinueWithoutImpactDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Receta Personalizada'),
            content: const Text(
              'Esta receta no está disponible para el cálculo de impacto ambiental. Es posible que sea una receta personalizada que no está en nuestra base de datos.\n\n¿Te gustaría continuar y marcar la receta como completada sin calcular el impacto ambiental?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _completeRecipeWithoutImpact();
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
    );
  }

  void _completeRecipeWithoutImpact() async {
    try {
      // Only consume ingredients from inventory, skip impact calculation
      _consumeIngredientsFromInventory(ref);

      // Invalidate inventory provider to refresh UI
      ref.invalidate(inventoryRealProvider);

      // Show success feedback and pop
      if (mounted) {
        await DialogHelper.showAlert(
          context: context,
          title: '¡Receta Completada!',
          message:
              'Hemos actualizado tu inventario. El impacto ambiental no se pudo calcular para esta receta.',
          imageUrl: 'assets/icons/home/image_motivational.png',
        );
        context.pop(true); // Pop screen and signal success
      }
    } catch (e) {
      log('Failed to complete recipe without impact: $e');
      if (mounted) {
        String userFriendlyMessage = ErrorHandler.getDisplayMessage(e);
        DialogHelper.showAlert(
          context: context,
          title: 'Error',
          message: userFriendlyMessage,
          icon: Icons.error,
          iconColor: Colors.red,
        );
      }
    }
  }

  void _completeRecipe() async {
    final recipeName = widget.recipe['name'] ?? 'una receta';
    final recipeUid = widget.recipe['uid'];

    try {
      final impactService = ref.read(impact.impactCalculationServiceProvider);

      // 1. Create the impact calculation record
      // Try with UID first (more reliable), fallback to title if no UID
      if (recipeUid != null && recipeUid.toString().trim().isNotEmpty) {
        await impactService.calculateFromUid(recipeUid.toString());
      } else {
        await impactService.calculateFromTitle(recipeName);
      }

      // 2. Consume ingredients from inventory
      _consumeIngredientsFromInventory(ref);

      // 3. Invalidate providers to refresh UI
      ref.invalidate(impact.allImpactCalculationsProvider);
      ref.invalidate(impact.impactSummaryProvider);
      ref.invalidate(recipeSuggestionsProvider);
      ref.invalidate(inventoryRealProvider); // Ensure inventory UI updates

      // 4. Show success feedback and pop
      if (mounted) {
        await DialogHelper.showAlert(
          context: context,
          title: '¡Receta Completada!',
          message:
              'Hemos registrado el impacto ambiental y actualizado tu inventario.',
          imageUrl: 'assets/icons/home/image_motivational.png',
        );
        context.pop(true); // Pop screen and signal success
      }
    } catch (e) {
      log('Failed to complete recipe flow: $e');
      if (mounted) {
        // Check for specific impact calculation error first
        String errorString = e.toString();
        if (errorString.contains(
          'no está disponible para el cálculo de impacto ambiental',
        )) {
          // Show dialog with option to continue without impact calculation
          _showContinueWithoutImpactDialog();
          return;
        }

        // Use ErrorHandler for all other errors
        String userFriendlyMessage = ErrorHandler.getDisplayMessage(e);

        DialogHelper.showAlert(
          context: context,
          title: 'Error',
          message: userFriendlyMessage,
          icon: Icons.error,
          iconColor: Colors.red,
        );
      }
    }
  }

  void _consumeIngredientsFromInventory(WidgetRef ref) {
    final List<String> recipeIngredients =
        (widget.recipe['ingredients'] as List<dynamic>).cast<String>();
    final List<InventoryItem> currentInventory =
        ref.read(inventoryRealProvider).items;

    if (currentInventory.isEmpty) {
      log('Inventory is empty, nothing to consume.');
      return;
    }

    final inventoryNotifier = ref.read(inventoryRealProvider.notifier);
    final Set<String> consumedItemIds = {};

    for (var ingredientName in recipeIngredients) {
      final normalizedIngredientName = ingredientName.toLowerCase().trim();

      // Find all matching items in inventory, sorted by expiration date (soonest first)
      final matchingItems =
          currentInventory
              .where(
                (item) =>
                    item.name.toLowerCase().trim() ==
                        normalizedIngredientName &&
                    !consumedItemIds.contains(item.id),
              )
              .toList();

      if (matchingItems.isNotEmpty) {
        // Sort by expiration date, nulls last
        matchingItems.sort((a, b) {
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return a.expirationDate!.compareTo(b.expirationDate!);
        });

        // Get the item that will expire soonest
        final itemToConsume = matchingItems.first;

        log('Consuming item: ${itemToConsume.name} (ID: ${itemToConsume.id})');

        // Call the notifier to remove the item
        inventoryNotifier.removeItem(itemToConsume.id);
        consumedItemIds.add(itemToConsume.id);
      } else {
        log('Ingredient "$normalizedIngredientName" not found in inventory.');
      }
    }

    // Invalidate inventory provider to ensure UI reflects the removal
    ref.invalidate(inventoryRealProvider);
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
