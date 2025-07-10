import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/meal_planning_providers.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan_models.dart';

/// Widget compacto que muestra el plan de comidas del día actual
/// Usa exactamente los mismos providers que el planner unificado
class HomeDailyPlannerWidget extends ConsumerStatefulWidget {
  const HomeDailyPlannerWidget({super.key});

  @override
  ConsumerState<HomeDailyPlannerWidget> createState() => _HomeDailyPlannerWidgetState();
}

class _HomeDailyPlannerWidgetState extends ConsumerState<HomeDailyPlannerWidget> {
  bool _isExpanded = false;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    // Force refresh on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTodayPlan();
    });
  }

  void _initializeLocale() async {
    if (!_localeInitialized) {
      await initializeDateFormatting('es_ES', null);
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when coming back to home
    _refreshTodayPlan();
  }

  void _refreshTodayPlan() {
    final today = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(today);
    
    print('[HOME_UNIFIED_PLANNER] Force refreshing plan for: $dateKey');
    
    // Use the same refresh strategy as unified planner
    ref.invalidate(mealPlanByDateProvider(dateKey));
    ref.invalidate(allMealPlansProvider);
    
    print('[HOME_UNIFIED_PLANNER] Providers refreshed');
  }

  @override
  Widget build(BuildContext context) {
    // Wait for locale initialization
    if (!_localeInitialized) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 16),
              Text('Inicializando...'),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;

    final today = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(today);

    // Use the EXACT SAME provider as unified planner
    final mealPlanAsync = ref.watch(mealPlanByDateProvider(dateKey));

    return RefreshIndicator(
      onRefresh: () async {
        print('[HOME_UNIFIED_PLANNER] Manual refresh triggered');
        _refreshTodayPlan();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: mealPlanAsync.when(
          data: (todayMealPlan) => _buildContent(
            context,
            today,
            todayMealPlan,
            isDark,
            primaryColor,
            textColor,
            secondaryTextColor,
            cardColor,
          ),
          loading: () => _buildLoadingCard(cardColor),
          error: (error, _) => _buildErrorCard(cardColor, textColor, error),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DateTime today,
    MealPlanModel? todayMealPlan,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    // Get meals using the same logic as unified planner
    final todayMeals = todayMealPlan?.meals.allMeals ?? [];
    
    // Debug: Same format as unified planner
    print('[HOME_UNIFIED_PLANNER] ===== PLAN DE HOY (UNIFIED) =====');
    print('[HOME_UNIFIED_PLANNER] Date: ${DateFormat('yyyy-MM-dd').format(today)}');
    print('[HOME_UNIFIED_PLANNER] Plan UID: ${todayMealPlan?.uid}');
    print('[HOME_UNIFIED_PLANNER] Meals count: ${todayMeals.length}');
    if (todayMealPlan != null) {
      print('[HOME_UNIFIED_PLANNER] Plan date: ${todayMealPlan.date}');
      print('[HOME_UNIFIED_PLANNER] Total calories: ${todayMealPlan.totalCalories}');
      print('[HOME_UNIFIED_PLANNER] Breakfast: ${todayMealPlan.meals.breakfast?.recipeTitle}');
      print('[HOME_UNIFIED_PLANNER] Lunch: ${todayMealPlan.meals.lunch?.recipeTitle}');
      print('[HOME_UNIFIED_PLANNER] Dinner: ${todayMealPlan.meals.dinner?.recipeTitle}');
    } else {
      print('[HOME_UNIFIED_PLANNER] NO MEAL PLAN FOUND FOR TODAY');
    }
    print('[HOME_UNIFIED_PLANNER] ================================');

    // Organize meals by type
    final mealsByType = <String, List<Meal>>{};
    for (final meal in todayMeals) {
      final mealType = _getMealTypeFromMeal(meal);
      mealsByType[mealType] = [...(mealsByType[mealType] ?? []), meal];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: () {
              if (todayMeals.isEmpty) {
                // Go to unified planner
                ref.read(selectedDateProvider.notifier).state = today;
                context.pushNamed('unifiedPlanning');
              } else {
                // Expand/collapse
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Plan de hoy',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (todayMeals.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${todayMeals.length} ${todayMeals.length == 1 ? 'comida' : 'comidas'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            // Refresh button
                            GestureDetector(
                              onTap: _refreshTodayPlan,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          todayMeals.isEmpty
                              ? 'Sin plan para hoy'
                              : _buildMealSummary(mealsByType),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Action button or expand icon
                  if (todayMeals.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          ref.read(selectedDateProvider.notifier).state = today;
                          await context.pushNamed('unifiedPlanning');
                          // Refresh when returning
                          if (mounted) {
                            _refreshTodayPlan();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Planificar',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMealTypeIcons(context, mealsByType),
                        const SizedBox(width: 8),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded && todayMeals.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  const Divider(height: 1),
                  ...mealsByType.entries.map(
                    (entry) => _buildMealTypeSection(
                      context,
                      entry.key,
                      entry.value,
                      isDark,
                      textColor,
                      secondaryTextColor,
                    ),
                  ),
                  // Button to go to unified planner
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              ref.read(selectedDateProvider.notifier).state = today;
                              await context.pushNamed('unifiedPlanning');
                              // Refresh when returning
                              if (mounted) {
                                _refreshTodayPlan();
                              }
                            },
                            icon: Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Abrir Mi Planificador',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods (same as original but streamlined)
  String _getMealTypeFromMeal(Meal meal) {
    final title = meal.recipeTitle.toLowerCase();
    if (title.contains('desayuno') || title.contains('breakfast')) {
      return 'Desayuno';
    } else if (title.contains('almuerzo') || title.contains('lunch')) {
      return 'Almuerzo';
    } else if (title.contains('cena') || title.contains('dinner')) {
      return 'Cena';
    } else {
      return 'Comida';
    }
  }

  String _buildMealSummary(Map<String, List<Meal>> mealsByType) {
    final parts = <String>[];
    mealsByType.forEach((type, meals) {
      parts.add('${meals.length} ${type.toLowerCase()}${meals.length > 1 ? 's' : ''}');
    });
    return parts.join(', ');
  }

  Widget _buildMealTypeIcons(BuildContext context, Map<String, List<Meal>> mealsByType) {
    final icons = <Widget>[];
    final displayTypes = mealsByType.keys.take(3).toList();

    for (final type in displayTypes) {
      final color = _getMealTypeColor(type);
      final icon = _getMealTypeIcon(type);

      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 14,
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      );
    }

    if (mealsByType.length > 3) {
      icons.add(
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '+${mealsByType.length - 3}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: icons);
  }

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'desayuno':
        return AppColors.breakfastColor;
      case 'almuerzo':
        return AppColors.lunchColor;
      case 'cena':
        return AppColors.dinnerColor;
      default:
        return AppColors.genericMealColor;
    }
  }

  IconData _getMealTypeIcon(String type) {
    switch (type.toLowerCase()) {
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

  Widget _buildMealTypeSection(
    BuildContext context,
    String type,
    List<Meal> meals,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final color = _getMealTypeColor(type);
    final icon = _getMealTypeIcon(type);

    return Container(
      color: isDark ? Colors.grey.shade900.withValues(alpha: 0.5) : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 12,
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (meals.length > 1)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${meals.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...meals.map((meal) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cleanRecipeTitle(meal.recipeTitle),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${meal.prepTime} min',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _cleanRecipeTitle(String title) {
    return title.replaceAll(RegExp(r'\s*\(\d+\)(\s*\(\d+\))*\s*$'), '');
  }

  Widget _buildLoadingCard(Color cardColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('Cargando plan del día...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(Color cardColor, Color textColor, Object error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error al cargar el plan',
                    style: GoogleFonts.inter(color: textColor),
                  ),
                  Text(
                    error.toString(),
                    style: GoogleFonts.inter(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _refreshTodayPlan,
              child: Icon(Icons.refresh, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}