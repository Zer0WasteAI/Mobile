import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/lottie_loading_widget.dart';

class CustomRecipeGenerationScreen extends ConsumerStatefulWidget {
  const CustomRecipeGenerationScreen({super.key});

  static const String routeName = 'custom-recipe-generation';
  static const String routePath = '/recipes/custom-generation';

  @override
  ConsumerState<CustomRecipeGenerationScreen> createState() =>
      _CustomRecipeGenerationScreenState();
}

class _CustomRecipeGenerationScreenState
    extends ConsumerState<CustomRecipeGenerationScreen> {
  final List<String> _selectedIngredients = [];
  final List<String> _selectedPreferences = [];
  final List<String> _selectedCategories = [];
  int _numRecipes = 2;

  final TextEditingController _ingredientController = TextEditingController();

  // Predefined options
  final List<String> _commonIngredients = [
    'Pollo',
    'Pasta',
    'Arroz',
    'Tomates',
    'Cebolla',
    'Ajo',
    'Queso',
    'Huevos',
    'Leche',
    'Pan',
    'Aceite de oliva',
    'Sal',
    'Pimienta',
    'Papas',
    'Zanahorias',
    'Brócoli',
    'Espinacas',
    'Pescado',
    'Carne',
    'Limón',
    'Cilantro',
    'Champiñones',
  ];

  final List<Map<String, dynamic>> _dietaryPreferences = [
    {
      'name': 'Vegetariano',
      'icon': '🥗',
      'description': 'Sin carne ni pescado',
    },
    {'name': 'Vegano', 'icon': '🌱', 'description': 'Sin productos animales'},
    {
      'name': 'Sin gluten',
      'icon': '🌾',
      'description': 'Libre de trigo y gluten',
    },
    {'name': 'Bajo en sodio', 'icon': '🧂', 'description': 'Menos sal'},
    {
      'name': 'Bajo en grasa',
      'icon': '💪',
      'description': 'Opciones saludables',
    },
    {
      'name': 'Keto',
      'icon': '🥑',
      'description': 'Alto en grasas, bajo en carbos',
    },
    {
      'name': 'Sin lácteos',
      'icon': '🥛',
      'description': 'Sin leche ni derivados',
    },
    {
      'name': 'Alto en proteína',
      'icon': '🏋️',
      'description': 'Rica en proteínas',
    },
  ];

  final List<Map<String, dynamic>> _recipeCategories = [
    {
      'name': 'Italiana',
      'icon': '🇮🇹',
      'description': 'Pasta, pizza, risotto',
    },
    {
      'name': 'Mexicana',
      'icon': '🇲🇽',
      'description': 'Tacos, enchiladas, salsas',
    },
    {'name': 'Asiática', 'icon': '🥢', 'description': 'Stir-fry, sushi, curry'},
    {
      'name': 'Mediterránea',
      'icon': '🫒',
      'description': 'Aceite de oliva, hierbas',
    },
    {'name': 'Americana', 'icon': '🇺🇸', 'description': 'BBQ, hamburguesas'},
    {
      'name': 'Francesa',
      'icon': '🇫🇷',
      'description': 'Salsas, técnicas clásicas',
    },
    {'name': 'India', 'icon': '🇮🇳', 'description': 'Especias, curry, naan'},
    {
      'name': 'Tailandesa',
      'icon': '🇹🇭',
      'description': 'Picante, coco, hierbas',
    },
  ];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final isGenerating = ref.watch(isGeneratingRecipesProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Crear Recetas Personalizadas',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // Header con descripción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personaliza tu receta eligiendo ingredientes y preferencias. ¡La IA creará algo delicioso!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIngredientsSection(
                    primaryColor,
                    textColor,
                    secondaryTextColor,
                    isDark,
                  ),
                  const SizedBox(height: 32),
                  _buildPreferencesSection(
                    primaryColor,
                    textColor,
                    secondaryTextColor,
                    isDark,
                  ),
                  const SizedBox(height: 32),
                  _buildCategoriesSection(
                    primaryColor,
                    textColor,
                    secondaryTextColor,
                    isDark,
                  ),
                  const SizedBox(height: 32),
                  _buildNumRecipesSection(
                    primaryColor,
                    textColor,
                    secondaryTextColor,
                    isDark,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildGenerateButton(primaryColor, isGenerating),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIngredientsSection(
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Ingredientes principales',
          subtitle: 'Elige los ingredientes que quieres usar (mínimo 1)',
          icon: Icons.restaurant,
          primaryColor: primaryColor,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          isRequired: true,
        ),

        // Add custom ingredient
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  style: GoogleFonts.inter(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Ej: Salmón, quinoa, aguacate...',
                    hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                    prefixIcon: Icon(
                      Icons.add_circle_outline,
                      color: primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: _addCustomIngredient,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed:
                      () => _addCustomIngredient(_ingredientController.text),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Common ingredients chips
        Text(
          '🔥 Ingredientes populares:',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _commonIngredients.map((ingredient) {
                final isSelected = _selectedIngredients.contains(ingredient);
                return FilterChip(
                  label: Text(
                    ingredient,
                    style: GoogleFonts.inter(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedIngredients.add(ingredient);
                      } else {
                        _selectedIngredients.remove(ingredient);
                      }
                    });
                  },
                  selectedColor: primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: primaryColor,
                  backgroundColor:
                      isDark ? AppColors.darkSurface : Colors.white,
                  side: BorderSide(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
        ),

        // Selected ingredients
        if (_selectedIngredients.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Ingredientes seleccionados (${_selectedIngredients.length})',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _selectedIngredients.map((ingredient) {
                        return Chip(
                          label: Text(
                            ingredient,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedIngredients.remove(ingredient);
                            });
                          },
                          backgroundColor: Colors.white,
                          deleteIconColor: primaryColor,
                          side: BorderSide(color: primaryColor, width: 1),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreferencesSection(
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Dieta y restricciones',
          subtitle:
              'Selecciona si tienes alguna preferencia dietética especial',
          icon: Icons.health_and_safety,
          primaryColor: primaryColor,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _dietaryPreferences.length,
          itemBuilder: (context, index) {
            final preference = _dietaryPreferences[index];
            final isSelected = _selectedPreferences.contains(
              preference['name'],
            );
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPreferences.remove(preference['name']);
                  } else {
                    _selectedPreferences.add(preference['name']);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor.withValues(alpha: 0.1)
                          : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      preference['icon'],
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            preference['name'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            preference['description'],
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: primaryColor, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Estilo de cocina',
          subtitle: 'Elige el tipo de cocina que más te guste',
          icon: Icons.public,
          primaryColor: primaryColor,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _recipeCategories.length,
          itemBuilder: (context, index) {
            final category = _recipeCategories[index];
            final isSelected = _selectedCategories.contains(category['name']);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(category['name']);
                  } else {
                    _selectedCategories.add(category['name']);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor.withValues(alpha: 0.1)
                          : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category['name'],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            category['description'],
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: primaryColor, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNumRecipesSection(
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Cantidad de recetas',
          subtitle: 'Desliza para elegir cuántas recetas quieres generar',
          icon: Icons.numbers,
          primaryColor: primaryColor,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '$_numRecipes receta${_numRecipes > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                  thumbColor: primaryColor,
                  overlayColor: primaryColor.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: _numRecipes.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _numRecipes = value.round();
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1',
                    style: GoogleFonts.inter(color: secondaryTextColor),
                  ),
                  Text(
                    '2',
                    style: GoogleFonts.inter(color: secondaryTextColor),
                  ),
                  Text(
                    '3',
                    style: GoogleFonts.inter(color: secondaryTextColor),
                  ),
                  Text(
                    '4',
                    style: GoogleFonts.inter(color: secondaryTextColor),
                  ),
                  Text(
                    '5',
                    style: GoogleFonts.inter(color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(Color primaryColor, bool isGenerating) {
    final canGenerate = _selectedIngredients.isNotEmpty && !isGenerating;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canGenerate ? _generateRecipes : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canGenerate ? primaryColor : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: canGenerate ? 2 : 0,
          ),
          child:
              isGenerating
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LottieLoadingWidget.small(width: 24, height: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Generando recetas con IA...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        canGenerate
                            ? 'Generar $_numRecipes receta${_numRecipes > 1 ? 's' : ''}'
                            : 'Selecciona al menos un ingrediente',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  void _addCustomIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty &&
        !_selectedIngredients.contains(ingredient.trim())) {
      setState(() {
        _selectedIngredients.add(ingredient.trim());
        _ingredientController.clear();
      });
    }
  }

  void _generateRecipes() async {
    if (_selectedIngredients.isEmpty) return;

    try {
      await ref
          .read(aiRecipeProvider.notifier)
          .generateCustomRecipes(
            ingredients: _selectedIngredients,
            preferences:
                _selectedPreferences.isNotEmpty ? _selectedPreferences : null,
            recipeCategories:
                _selectedCategories.isNotEmpty ? _selectedCategories : null,
            numRecipes: _numRecipes,
          );

      if (mounted) {
        // Navigate to AI generation screen to show results
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
}
