import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';

class AIRecipeGenerationScreen extends ConsumerStatefulWidget {
  const AIRecipeGenerationScreen({super.key});

  @override
  ConsumerState<AIRecipeGenerationScreen> createState() =>
      _AIRecipeGenerationScreenState();
}

class _AIRecipeGenerationScreenState
    extends ConsumerState<AIRecipeGenerationScreen>
    with SingleTickerProviderStateMixin {
  bool _isGenerating = true;
  List<Recipe> _generatedRecipes = [];
  late AnimationController _animationController;
  final CarouselController _carouselController = CarouselController();
  int _currentRecipeIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate AI thinking and generating recipes after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _generateRecipes();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateRecipes() {
    // Get soon-to-expire ingredients from inventory
    final inventoryState = ref.read(inventoryProvider);
    final allItems = inventoryState.items;

    // Filter for valid ingredients that are expiring soon but not expired
    final soonToExpireItems =
        allItems.where((item) {
          final status = ExpirationStatusExtension.fromDate(
            item.expirationDate,
          );
          return status == ExpirationStatus.expiringSoon;
        }).toList();

    // Dummy recipes generation based on soon-to-expire ingredients
    // In a real app, this would call an API or use a local AI model
    final generatedRecipes = _createDummyRecipes(soonToExpireItems);

    setState(() {
      _isGenerating = false;
      _generatedRecipes = generatedRecipes;
    });
  }

  List<Recipe> _createDummyRecipes(List<InventoryItem> soonToExpireItems) {
    // This is a placeholder for actual AI recipe generation
    // In a real app, you would use these ingredients to generate recipes via API

    // For demo purposes, create dummy recipes that use the expiring ingredients
    final List<Recipe> recipes = [];

    // Get ingredient names to display in recipe
    final ingredientNames = soonToExpireItems.map((e) => e.name).toList();

    // Create 3 sample recipes
    recipes.add(
      Recipe(
        id: "recipe1",
        name: "Ensalada Fresca",
        description:
            "Una ensalada fresca y nutritiva utilizando tus ingredientes que están por vencer",
        emoji: "🥗",
        ingredients: ingredientNames,
        requiredIngredientsCount: ingredientNames.length,
        availableIngredientsCount: ingredientNames.length,
        usesExpiringItems: true,
        cookingTime: 15,
        difficulty: "Fácil",
        dietType: "Omnívora",
        categories: ["saludable", "rápido", "sin cocción"],
      ),
    );

    recipes.add(
      Recipe(
        id: "recipe2",
        name: "Salteado Rápido",
        description:
            "Un delicioso plato salteado con tus ingredientes a punto de vencer",
        emoji: "🍲",
        ingredients: ingredientNames,
        requiredIngredientsCount: ingredientNames.length,
        availableIngredientsCount: ingredientNames.length,
        usesExpiringItems: true,
        cookingTime: 25,
        difficulty: "Medio",
        dietType: "Omnívora",
        categories: ["caliente", "rápido", "versátil"],
      ),
    );

    recipes.add(
      Recipe(
        id: "recipe3",
        name: "Sopa Reconfortante",
        description:
            "Una sopa nutritiva que aprovecha tus ingredientes antes de que venzan",
        emoji: "🍜",
        ingredients: ingredientNames,
        requiredIngredientsCount: ingredientNames.length,
        availableIngredientsCount: ingredientNames.length,
        usesExpiringItems: true,
        cookingTime: 45,
        difficulty: "Fácil",
        dietType: "Vegetariana",
        categories: ["caliente", "reconfortante", "nutritivo"],
      ),
    );

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : Colors.black87;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Recetas con IA',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body:
          _isGenerating
              ? _buildLoadingView(isDark, textColor)
              : _buildRecipesView(
                isDark,
                cardColor,
                textColor,
                secondaryTextColor,
              ),
    );
  }

  Widget _buildLoadingView(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using Lottie animation for AI thinking effect
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animations/ai_thinking.json',
              controller: _animationController,
              onLoaded: (composition) {
                _animationController
                  ..duration = composition.duration
                  ..repeat();
              },
              errorBuilder: (context, error, stackTrace) {
                // Fallback animation if the Lottie animation fails
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        color:
                            isDark
                                ? AppColors.darkPrimary
                                : const Color(0xFF00B894),
                        strokeWidth: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('🧠', style: TextStyle(fontSize: 40)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Generando recetas con tus ingredientes...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Estamos priorizando los ingredientes próximos a vencer',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkSecondaryText : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesView(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    if (_generatedRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food, size: 64, color: secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              'No pudimos generar recetas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'No encontramos ingredientes próximos a vencer para usar en recetas.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.darkPrimary : const Color(0xFF00B894),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Volver al inventario',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            '¡Sugerencias listas!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Text(
            'Hemos generado recetas utilizando tus ingredientes próximos a vencer',
            style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // Carousel of recipe cards
        Expanded(
          child: CarouselSlider.builder(
            itemCount: _generatedRecipes.length,
            itemBuilder: (context, index, _) {
              final recipe = _generatedRecipes[index];
              return _buildRecipeCard(
                recipe,
                cardColor,
                textColor,
                secondaryTextColor,
                isDark,
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.6,
              enlargeCenterPage: true,
              enableInfiniteScroll: _generatedRecipes.length > 1,
              onPageChanged: (index, _) {
                setState(() {
                  _currentRecipeIndex = index;
                });
              },
            ),
          ),
        ),

        // Recipe navigation indicators
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _generatedRecipes.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentRecipeIndex == entry.key
                              ? (isDark
                                  ? AppColors.darkPrimary
                                  : const Color(0xFF00B894))
                              : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }).toList(),
          ),
        ),

        // Bottom actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt, size: 20),
                label: const Text('Guardar recetas'),
                onPressed: () {
                  // Mostrar indicador de carga
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Guardando recetas...'),
                        ],
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  // Simular guardado y mostrar confirmación
                  Future.delayed(const Duration(seconds: 1), () {
                    // Guardar recetas en el provider
                    ref
                        .read(aiRecipesProvider.notifier)
                        .addGeneratedRecipes(_generatedRecipes);

                    // Mostrar confirmación
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Recetas guardadas en tu colección!'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Navegar a la sección de recetas
                      Future.delayed(const Duration(seconds: 1), () {
                        if (context.mounted) {
                          context.go('/recipes');
                        }
                      });
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkPrimary : const Color(0xFF00B894),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Regenerar'),
                onPressed: () {
                  setState(() {
                    _isGenerating = true;
                  });
                  Timer(const Duration(seconds: 2), () {
                    _generateRecipes();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? AppColors.darkPrimary : const Color(0xFF00B894),
                  side: BorderSide(
                    color:
                        isDark
                            ? AppColors.darkPrimary
                            : const Color(0xFF00B894),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(
    Recipe recipe,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe image/emoji
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Center(
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Recipe difficulty and time badges
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.kitchen,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.difficulty,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.cookingTime} min',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Recipe title
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      recipe.name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Recipe details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ingredientes a usar',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            recipe.ingredients.length > 5
                                ? 5
                                : recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color:
                                      isDark
                                          ? AppColors.darkPrimary
                                          : const Color(0xFF00B894),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    recipe.ingredients[index],
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (recipe.ingredients.length > 5)
                      Text(
                        '...y ${recipe.ingredients.length - 5} más',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: secondaryTextColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
