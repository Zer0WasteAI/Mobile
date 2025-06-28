import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

/// Maneja analytics, estadísticas y listas de compras del planner
class PlannerAnalyticsManager {
  
  /// Mostrar lista de compras
  static void showShoppingList(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.read(mealPlansProvider);
    final shoppingList = _generateShoppingList(mealPlans);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShoppingListHeader(),
              const SizedBox(height: 20),
              
              Flexible(
                child: shoppingList.isEmpty
                    ? _buildEmptyShoppingList()
                    : _buildShoppingListContent(shoppingList),
              ),
              
              const SizedBox(height: 20),
              _buildShoppingListActions(context, shoppingList),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Mostrar estadísticas de planificación
  static void showStats(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.read(mealPlansProvider);
    final stats = _calculateStats(mealPlans);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatsHeader(),
              const SizedBox(height: 24),
              
              ...stats.entries.map((entry) => _buildStatItem(entry.key, entry.value)),
              
              const SizedBox(height: 24),
              _buildEcoTip(),
              
              const SizedBox(height: 24),
              _buildStatsActions(context),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Mostrar historial de planificación
  static void showPlanningHistory(BuildContext context, WidgetRef ref) {
    final planningHistory = ref.read(planningHistoryProvider);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHistoryHeader(),
              const SizedBox(height: 20),
              
              Flexible(
                child: planningHistory.isEmpty
                    ? _buildEmptyHistory()
                    : _buildHistoryContent(planningHistory),
              ),
              
              const SizedBox(height: 20),
              _buildHistoryActions(context),
            ],
          ),
        ),
      ),
    );
  }
  
  // ==================== SHOPPING LIST BUILDERS ====================
  
  static Widget _buildShoppingListHeader() {
    return Row(
      children: [
        Icon(Icons.shopping_cart, color: AppColors.lightPrimary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Lista de Compras',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightPrimary,
          ),
        ),
      ],
    );
  }
  
  static Widget _buildEmptyShoppingList() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay ingredientes para comprar',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Planifica algunas comidas para generar tu lista',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  static Widget _buildShoppingListContent(Map<String, List<String>> shoppingList) {
    return ListView(
      children: shoppingList.entries
          .map((entry) => _buildShoppingCategory(entry.key, entry.value))
          .toList(),
    );
  }
  
  static Widget _buildShoppingCategory(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.lightPrimary,
          ),
        ),
        children: items
            .map((item) => ListTile(
                  dense: true,
                  leading: Icon(Icons.circle, size: 8, color: Colors.grey[400]),
                  title: Text(
                    item,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ))
            .toList(),
      ),
    );
  }
  
  static Widget _buildShoppingListActions(BuildContext context, Map<String, List<String>> shoppingList) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
        ),
        if (shoppingList.isNotEmpty)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _shareShoppingList(shoppingList),
              icon: const Icon(Icons.share, size: 18),
              label: Text(
                'Compartir',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // ==================== STATS BUILDERS ====================
  
  static Widget _buildStatsHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, color: AppColors.lightPrimary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Estadísticas',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightPrimary,
          ),
        ),
      ],
    );
  }
  
  static Widget _buildStatItem(String label, int value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.toString(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildEcoTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: Colors.green[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu planificación ayuda a reducir el desperdicio de alimentos',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildStatsActions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cerrar',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  // ==================== HISTORY BUILDERS ====================
  
  static Widget _buildHistoryHeader() {
    return Row(
      children: [
        Icon(Icons.history, color: AppColors.lightPrimary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Historial',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightPrimary,
          ),
        ),
      ],
    );
  }
  
  static Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay historial aún',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu historial de planificación aparecerá aquí',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  static Widget _buildHistoryContent(List<String> history) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final weekKey = history[index];
        return ListTile(
          leading: Icon(
            Icons.calendar_view_week,
            color: AppColors.lightPrimary,
          ),
          title: Text(
            'Semana planificada',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            weekKey,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        );
      },
    );
  }
  
  static Widget _buildHistoryActions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cerrar',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Generar lista de compras desde los planes de comida
  static Map<String, List<String>> _generateShoppingList(Map<String, List<MealPlan>> mealPlans) {
    final Map<String, Set<String>> shoppingList = {};
    
    for (final dayMeals in mealPlans.values) {
      for (final meal in dayMeals) {
        final category = _getCategoryForMeal(meal);
        shoppingList.putIfAbsent(category, () => <String>{});
        shoppingList[category]!.addAll(meal.ingredients);
      }
    }
    
    // Convertir sets a listas
    return shoppingList.map((key, value) => MapEntry(key, value.toList()));
  }
  
  /// Calcular estadísticas desde los planes de comida
  static Map<String, int> _calculateStats(Map<String, List<MealPlan>> mealPlans) {
    int totalMeals = 0;
    final Set<String> uniqueIngredients = {};
    final Map<MealType, int> mealsByType = {};
    
    for (final dayMeals in mealPlans.values) {
      totalMeals += dayMeals.length;
      
      for (final meal in dayMeals) {
        uniqueIngredients.addAll(meal.ingredients);
        mealsByType[meal.type] = (mealsByType[meal.type] ?? 0) + 1;
      }
    }
    
    return {
      'Comidas Planificadas': totalMeals,
      'Ingredientes Únicos': uniqueIngredients.length,
      'Desayunos': mealsByType[MealType.breakfast] ?? 0,
      'Almuerzos': mealsByType[MealType.lunch] ?? 0,
      'Cenas': mealsByType[MealType.dinner] ?? 0,
      'Snacks': mealsByType[MealType.snack] ?? 0,
      'Días Planificados': mealPlans.length,
    };
  }
  
  /// Categorizar ingredientes por tipo
  static String _getCategoryForMeal(MealPlan meal) {
    // Análisis simple de categorización
    final ingredients = meal.ingredients.map((i) => i.toLowerCase()).join(' ');
    
    if (ingredients.contains('carne') || 
        ingredients.contains('pollo') || 
        ingredients.contains('pescado') ||
        ingredients.contains('pavo') ||
        ingredients.contains('cerdo')) {
      return 'Proteínas';
    } else if (ingredients.contains('verdura') || 
               ingredients.contains('vegetal') ||
               ingredients.contains('lechuga') ||
               ingredients.contains('tomate') ||
               ingredients.contains('cebolla') ||
               ingredients.contains('zanahoria')) {
      return 'Verduras';
    } else if (ingredients.contains('fruta') ||
               ingredients.contains('manzana') ||
               ingredients.contains('plátano') ||
               ingredients.contains('naranja')) {
      return 'Frutas';
    } else if (ingredients.contains('leche') ||
               ingredients.contains('queso') ||
               ingredients.contains('yogur') ||
               ingredients.contains('mantequilla')) {
      return 'Lácteos';
    } else if (ingredients.contains('pan') ||
               ingredients.contains('arroz') ||
               ingredients.contains('pasta') ||
               ingredients.contains('harina') ||
               ingredients.contains('avena')) {
      return 'Carbohidratos';
    } else {
      return 'Otros';
    }
  }
  
  /// Compartir lista de compras
  static void _shareShoppingList(Map<String, List<String>> shoppingList) {
    final buffer = StringBuffer('Lista de Compras:\\n\\n');
    
    for (final entry in shoppingList.entries) {
      buffer.writeln('${entry.key}:');
      for (final item in entry.value) {
        buffer.writeln('• $item');
      }
      buffer.writeln();
    }
    
    // Aquí implementarías la lógica de compartir
    // Por ejemplo, usando share_plus package
    // Share.share(buffer.toString());
  }
}