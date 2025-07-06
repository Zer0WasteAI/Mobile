// ignore_for_file: unused_element, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/favorite_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/lottie_loading_widget.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final RecipeMode mode;

  const RecipeScreen({required this.mode, super.key});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _screenTitle = 'Generar Recetas';

  // Variables para el tab de Mis Recetas
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      final newTitle =
          _tabController.index == 0 ? 'Generar Recetas' : 'Mis Recetas';
      if (_screenTitle != newTitle) {
        setState(() {
          _screenTitle = newTitle;
        });
      }
    });

    // Load favorite recipes on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoriteRecipesProvider.notifier).loadFavoritesFromBackend();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final Color scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    final favoritesState = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _screenTitle,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: mainTextColor,
              ),
            ),
            if (_tabController.index == 1)
              Text(
                '${favoritesState.favoriteCount} recetas guardadas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor),
        actions: [
          if (_tabController.index == 1 &&
              favoritesState.favoriteCount > 0) ...[
            IconButton(
              icon: Icon(Icons.refresh, color: mainTextColor),
              onPressed: () async {
                await ref.read(favoriteRecipesProvider.notifier).refresh();
              },
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [Tab(text: 'Generar'), Tab(text: 'Mis Recetas')],
        ),
      ),
      body: Column(
        children: [
          // Search bar solo para el tab de Mis Recetas
          if (_tabController.index == 1 && favoritesState.favoriteCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: GoogleFonts.inter(color: mainTextColor),
                decoration: InputDecoration(
                  hintText: 'Buscar en tus recetas...',
                  hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                  prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.darkSurface : Colors.grey.shade100,
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

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGenerateTab(
                  context,
                  ref,
                  isDark,
                  primaryColor,
                  mainTextColor,
                  secondaryTextColor,
                ),
                _buildMyRecipesTab(
                  context,
                  ref,
                  isDark,
                  primaryColor,
                  mainTextColor,
                  secondaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build method for Generate Tab - shows recipe generation options
  Widget _buildGenerateTab(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Welcome section
          Text(
            '¡Genera recetas increíbles!',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: mainTextColor,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Descubre nuevas recetas personalizadas según tus ingredientes y preferencias.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: secondaryTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // Generation options
          _buildGenerationOption(
            icon: Icons.kitchen,
            title: 'Generar con mi inventario',
            subtitle: 'Usa los ingredientes que tienes disponibles',
            description:
                'Genera recetas inteligentes basadas en los ingredientes de tu inventario',
            primaryColor: primaryColor,
            textColor: mainTextColor,
            secondaryTextColor: secondaryTextColor,
            cardColor: cardColor,
            isDark: isDark,
            onTap: () => _generateFromInventory(ref, context),
          ),
          const SizedBox(height: 20),

          _buildGenerationOption(
            icon: Icons.tune,
            title: 'Generar receta personalizada',
            subtitle: 'Elige ingredientes específicos y preferencias',
            description:
                'Personaliza completamente tu receta con ingredientes, tipo de cocina y restricciones dietéticas',
            primaryColor: primaryColor,
            textColor: mainTextColor,
            secondaryTextColor: secondaryTextColor,
            cardColor: cardColor,
            isDark: isDark,
            onTap: () => _generateCustomRecipe(),
          ),

          const SizedBox(height: 40),

          // Features section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'IA Inteligente',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: mainTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Nuestro sistema de IA analiza tus ingredientes y crea recetas deliciosas y nutritivas adaptadas a ti.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build method for My Recipes Tab - shows user's saved recipes
  Widget _buildMyRecipesTab(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
  ) {
    final favoritesState = ref.watch(favoriteRecipesProvider);
    final isGenerating = ref.watch(isGeneratingRecipesProvider);
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    // Get filtered and sorted recipes
    List<Recipe> displayedRecipes = _getFilteredAndSortedRecipes();

    // Loading state
    if (favoritesState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LottieLoadingWidget.food(
              width: 100,
              height: 100,
              showMessage: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando tus recetas...',
              style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Error state
    if (favoritesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar recetas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: mainTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              favoritesState.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(favoriteRecipesProvider.notifier).refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Intentar de nuevo',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state - no recipes saved
    if (favoritesState.favoriteCount == 0 && !isGenerating) {
      return _buildEmptyState(
        primaryColor,
        mainTextColor,
        secondaryTextColor,
        isDark,
      );
    }

    // Get cached AI recipes
    final aiRecipeState = ref.watch(aiRecipeProvider);
    
    // Recipes list with cached section
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(favoriteRecipesProvider.notifier).refresh();
      },
      color: primaryColor,
      child: CustomScrollView(
        slivers: [
          // Cached AI Recipes Section
          if (aiRecipeState.hasRecentRecipes)
            SliverToBoxAdapter(
              child: _buildCachedRecipesSection(
                context,
                ref,
                aiRecipeState,
                isDark,
                primaryColor,
                mainTextColor,
                secondaryTextColor,
                cardColor,
              ),
            ),
          
          // Saved Recipes Section
          if (displayedRecipes.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Mis Recetas Guardadas',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: mainTextColor,
                  ),
                ),
              ),
            ),
          
          // Saved Recipes List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recipe = displayedRecipes[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildRecipeCard(
                    recipe,
                    cardColor,
                    primaryColor,
                    mainTextColor,
                    secondaryTextColor,
                    isDark,
                  ),
                );
              },
              childCount: displayedRecipes.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCachedRecipesSection(
    BuildContext context,
    WidgetRef ref,
    AIRecipeState aiRecipeState,
    bool isDark,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with cache info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recetas Recientes (IA)',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: mainTextColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Force regenerate - clear cache
                  ref.read(aiRecipeProvider.notifier).clearState();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Limpiar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Cache status message
        if (aiRecipeState.cacheStatusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    aiRecipeState.cacheStatusMessage,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Horizontal scrollable recipes list
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: aiRecipeState.recipes.length,
            itemBuilder: (context, index) {
              final recipe = aiRecipeState.recipes[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: _buildCachedRecipeCard(
                  recipe,
                  cardColor,
                  primaryColor,
                  mainTextColor,
                  secondaryTextColor,
                  isDark,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCachedRecipeCard(
    Recipe recipe,
    Color cardColor,
    Color primaryColor,
    Color mainTextColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'recipe-detail',
            pathParameters: {'id': recipe.id},
            extra: recipe,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AI badge
              Row(
                children: [
                  Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'IA',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Recipe name
              Text(
                recipe.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description
              Text(
                recipe.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Footer with time and difficulty
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipe.formattedCookingTime,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe.difficulty,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildEmptyState(
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_menu, size: 64, color: primaryColor),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            '¡Comienza tu colección!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Aún no tienes recetas guardadas.\nGenera recetas personalizadas y guárdalas para acceder fácilmente a tus favoritas.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: secondaryTextColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Generation options
          _buildEmptyStateGenerationOption(
            icon: Icons.kitchen,
            title: 'Generar con mi inventario',
            subtitle: 'Usa los ingredientes que tienes disponibles',
            primaryColor: primaryColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            isDark: isDark,
            onTap: () {
              // Cambiar al tab de generar y ejecutar la acción
              _tabController.animateTo(0);
              Future.delayed(const Duration(milliseconds: 300), () {
                _generateFromInventory(ref, context);
              });
            },
          ),
          const SizedBox(height: 16),

          _buildEmptyStateGenerationOption(
            icon: Icons.tune,
            title: 'Generar receta personalizada',
            subtitle: 'Elige ingredientes específicos y preferencias',
            primaryColor: primaryColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            isDark: isDark,
            onTap: () {
              // Cambiar al tab de generar y ejecutar la acción
              _tabController.animateTo(0);
              Future.delayed(const Duration(milliseconds: 300), () {
                _generateCustomRecipe();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateGenerationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(
    Recipe recipe,
    Color cardColor,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _navigateToRecipeDetail(recipe);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Recipe emoji/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Recipe info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.schedule,
                            '${recipe.cookingTime}min',
                            primaryColor,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.signal_cellular_alt,
                            recipe.difficulty,
                            primaryColor,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showDeleteRecipeDialog(recipe);
                      },
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: secondaryTextColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
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
        color: primaryColor.withValues(alpha: 0.1),
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

  List<Recipe> _getFilteredAndSortedRecipes() {
    final favoriteRecipes = ref
        .read(favoriteRecipesProvider.notifier)
        .getSortedFavorites(ascending: true);

    if (_searchQuery.isEmpty) {
      return favoriteRecipes;
    }

    return ref
        .read(favoriteRecipesProvider.notifier)
        .searchFavorites(_searchQuery);
  }

  void _showDeleteRecipeDialog(Recipe recipe) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quitar de favoritos'),
            content: Text(
              '¿Estás seguro de que quieres quitar "${recipe.name}" de tus recetas favoritas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Use removeRecipeFromFavorites with the recipe ID
                  final success = await ref
                      .read(favoriteRecipesProvider.notifier)
                      .removeRecipeFromFavorites(recipe.id);

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${recipe.name} eliminada de favoritos',
                          ),
                          action: SnackBarAction(
                            label: 'Deshacer',
                            onPressed: () async {
                              await ref
                                  .read(favoriteRecipesProvider.notifier)
                                  .saveRecipeToFavorites(recipe);
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar ${recipe.name}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Quitar'),
              ),
            ],
          ),
    );
  }

  Widget _buildGenerationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generateFromInventory(WidgetRef ref, BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Generando recetas con tu inventario...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to AI generation screen to show results using root navigator
      if (mounted) {
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

  void _generateCustomRecipe() {
    // Navigate to custom recipe generation screen using root navigator
    GoRouter.of(context).go('/recipes/custom-generation');
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    context.pushNamed('recipeDetail', extra: recipe);
  }
}
