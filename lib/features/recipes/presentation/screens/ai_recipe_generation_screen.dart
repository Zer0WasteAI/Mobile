import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'
    as home;
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipe_detail_screen.dart';

class AIRecipeGenerationScreen extends ConsumerStatefulWidget {
  const AIRecipeGenerationScreen({super.key});

  @override
  ConsumerState<AIRecipeGenerationScreen> createState() =>
      _AIRecipeGenerationScreenState();
}

class _AIRecipeGenerationScreenState
    extends ConsumerState<AIRecipeGenerationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ingredientsController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _dietaryController = TextEditingController();
  final _timeController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Auto-generate recipes from inventory after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateFromInventory();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ingredientsController.dispose();
    _cuisineController.dispose();
    _dietaryController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Costo en EcoCoins para usar este servicio
  final int _ecoCoinsRequired = home.EcoCoinCosts.generateAIRecipe;

  // Método para verificar y gastar EcoCoins
  bool _checkAndSpendEcoCoins() {
    final ecoCoinsNotifier = ref.read(home.ecoCoinsProvider.notifier);
    final currentCoins = ref.read(home.ecoCoinsProvider);

    if (currentCoins < _ecoCoinsRequired) {
      // No hay suficientes monedas
      _showInsufficientCoinsDialog();
      return false;
    }

    // Hay suficientes monedas, cobrar
    ecoCoinsNotifier.spendCoins(_ecoCoinsRequired);
    return true;
  }

  // Generar recetas desde inventario
  Future<void> _generateFromInventory() async {
    if (!_checkAndSpendEcoCoins()) return;

    // Call the real backend API
    ref.read(aiRecipeProvider.notifier).generateRecipesFromInventory();
  }

  // Generar recetas personalizadas
  Future<void> _generateCustomRecipes() async {
    if (!_checkAndSpendEcoCoins()) return;

    final ingredients =
        _ingredientsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (ingredients.isEmpty) {
      _showSnackBar(
        'Por favor, ingresa al menos un ingrediente',
        isError: true,
      );
      return;
    }

    // Build preferences list
    final preferences = <String>[];
    if (_dietaryController.text.isNotEmpty) {
      preferences.add(_dietaryController.text.trim());
    }
    if (_cuisineController.text.isNotEmpty) {
      preferences.add(_cuisineController.text.trim());
    }

    // Call the real backend API
    ref
        .read(aiRecipeProvider.notifier)
        .generateCustomRecipes(
          ingredients: ingredients,
          preferences: preferences.isNotEmpty ? preferences : null,
          numRecipes: 3,
        );
  }

  // Diálogo para mostrar cuando no hay suficientes EcoCoins
  void _showInsufficientCoinsDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'EcoCoins insuficientes',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Necesitas $_ecoCoinsRequired EcoCoins para generar recetas con IA.',
                    style: GoogleFonts.inter(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿Cómo conseguir más EcoCoins?',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Completa objetivos en el Panel de Impacto\n'
                    '• Salva alimentos de ser desperdiciados\n'
                    '• Consigue insignias por tus acciones\n'
                    '• Sube de nivel salvando alimentos',
                    style: GoogleFonts.inter(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (mounted) {
                      context.push('/impact');
                    }
                  },
                  child: Text(
                    'Ver Panel de Impacto',
                    style: GoogleFonts.inter(),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar', style: GoogleFonts.inter()),
                ),
              ],
            ),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : Colors.black54;

    // Watch the AI recipe state
    final aiRecipeState = ref.watch(aiRecipeProvider);
    final currentEcoCoins = ref.watch(home.ecoCoinsProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Recetas Inteligentes',
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Mostrar EcoCoins actuales
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/home/eco_coin.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$currentEcoCoins',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          aiRecipeState.isGenerating
              ? _buildLoadingView(textColor, secondaryTextColor)
              : aiRecipeState.error != null
              ? _buildErrorView(
                aiRecipeState.error!,
                textColor,
                secondaryTextColor,
              )
              : aiRecipeState.recipes.isEmpty && aiRecipeState.hasGenerated
              ? _buildEmptyView(textColor, secondaryTextColor)
              : aiRecipeState.recipes.isNotEmpty
              ? _buildRecipesView(aiRecipeState.recipes)
              : _buildCustomGenerationView(textColor, secondaryTextColor),
    );
  }

  Widget _buildLoadingView(Color textColor, Color secondaryTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _animationController,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Generando recetas inteligentes...',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Nuestro algoritmo de IA está analizando tus ingredientes disponibles y preferencias para crear recetas personalizadas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Generando con $_ecoCoinsRequired EcoCoins',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.green.shade800,
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

  Widget _buildErrorView(
    String error,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al generar recetas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      () => ref.read(aiRecipeProvider.notifier).clearError(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _generateFromInventory(),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generar Nuevamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(Color textColor, Color secondaryTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 60,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No se pudieron generar recetas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Intenta agregar más ingredientes a tu inventario o verifica tu conexión a internet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _generateFromInventory(),
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de Nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesView(List<Recipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length + 1, // +1 for the custom generation option
      itemBuilder: (context, index) {
        if (index == recipes.length) {
          return _buildCustomGenerationCard();
        }
        final recipe = recipes[index];
        return _buildRecipeCard(context, recipe);
      },
    );
  }

  Widget _buildCustomGenerationView(Color textColor, Color secondaryTextColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generar Recetas Personalizadas',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomGenerationCard(),
        ],
      ),
    );
  }

  Widget _buildCustomGenerationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Crear Recetas Personalizadas',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes (separados por comas)',
                  hintText: 'ej: tomate, cebolla, pollo, arroz',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa al menos un ingrediente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cuisineController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Cocina (opcional)',
                        hintText: 'ej: italiana, mexicana, asiática',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dietaryController,
                      decoration: const InputDecoration(
                        labelText: 'Dieta (opcional)',
                        hintText: 'ej: vegetariana, vegana',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateCustomRecipes,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    'Generar Recetas ($_ecoCoinsRequired EcoCoins)',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Resto del código para visualizar recetas
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    // Código existente...
    // ...
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder con etiqueta generada por IA
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
                const Center(
                  child: Icon(Icons.restaurant, size: 60, color: Colors.green),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Generada por IA',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la receta
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
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.timer, '${recipe.cookingTime} min'),
                    _buildInfoChip(Icons.restaurant, recipe.dietType),
                    _buildInfoChip(
                      Icons.eco,
                      '${recipe.usesExpiringItems ? "Usa ingredientes" : "Sin ingredientes"} por vencer',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Botón para ver receta completa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la pantalla de detalle
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RecipeDetailScreen(
                                recipe: {
                                  'name': recipe.name,
                                  'description': recipe.description,
                                  'emoji': recipe.emoji,
                                  'ingredients': recipe.ingredients,
                                  'time': '${recipe.cookingTime} min',
                                  'difficulty': recipe.difficulty,
                                  'type': 'fondo', // Valor por defecto
                                  'tags': recipe.categories,
                                  'usesExpiringItems': recipe.usesExpiringItems,
                                  'dietType': recipe.dietType,
                                  'steps': [
                                    'Prepara todos los ingredientes antes de comenzar',
                                    'Sigue las instrucciones de la receta paso a paso',
                                    'Disfruta de tu comida recién preparada',
                                  ],
                                },
                              ),
                        ),
                      ).then((value) {
                        // Si el usuario ha cocinado la receta, mostrar feedback
                        if (value == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '¡Felicidades por cocinar esta receta! Has ganado EcoCoins por reducir el desperdicio.',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: Colors.green.shade600,
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Ver impacto',
                                textColor: Colors.white,
                                onPressed: () {
                                  context.push('/impact');
                                },
                              ),
                            ),
                          );

                          // Otorgar EcoCoins al usuario
                          ref.read(home.ecoCoinsProvider.notifier).addCoins(15);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ver receta completa',
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

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey.shade600).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? Colors.grey.shade600).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
