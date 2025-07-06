import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_screen_providers.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/dialogs/add_meal_dialog.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/dialogs/move_meal_dialog.dart';
import 'package:zer0_waste_ai/features/planner/presentation/widgets/dialogs/custom_reminder_dialog.dart';
import 'package:zer0_waste_ai/features/planner/presentation/screens/recipe_library_screen.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

/// Maneja todos los dialogs y modales del planner
class PlannerDialogManager {
  
  /// Mostrar selector de mes
  static void showMonthPicker(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.read(currentWeekProvider);
    final currentMonth = DateTime(currentWeek.year, currentWeek.month);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Mes'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = DateTime(currentMonth.year, index + 1);
                final monthName = _getMonthName(index + 1);
                final isSelected = month.month == currentMonth.month;
                
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    final newWeek = DateTime(month.year, month.month, 1);
                    final mondayOfWeek = newWeek.subtract(
                      Duration(days: newWeek.weekday - 1),
                    );
                    ref.read(currentWeekProvider.notifier).state = mondayOfWeek;
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lightPrimary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        monthName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  /// Mostrar dialog para agregar comida
  static void showAddMealDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
    MealType mealType,
  ) {
    AddMealDialog.show(
      context,
      ref,
      selectedDay,
      initialType: mealType,
      onMealAdded: (meal, dateKey) {
        // Lógica para agregar la comida
        final mealPlansNotifier = ref.read(mealPlansProvider.notifier);
        mealPlansNotifier.addMeal(dateKey, meal);
      },
    );
  }

  /// Mostrar lista de compras
  static void showShoppingList(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.read(mealPlansProvider);
    final shoppingList = _generateShoppingList(mealPlans);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.lightPrimary),
              const SizedBox(width: 8),
              const Text('Lista de Compras'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: shoppingList.isEmpty
                ? const Center(
                    child: Text('No hay ingredientes para comprar'),
                  )
                : ListView(
                    children: shoppingList.entries.map((entry) {
                      return _buildShoppingCategory(entry.key, entry.value);
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Compartir lista de compras
                _shareShoppingList(shoppingList);
              },
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Mostrar estadísticas de planificación
  static void showStats(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.read(mealPlansProvider);
    final stats = _calculateStats(mealPlans);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: AppColors.lightPrimary),
              const SizedBox(width: 8),
              const Text('Estadísticas'),
            ],
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                _buildStatItem('Comidas Planificadas', '${stats['totalMeals']}'),
                _buildStatItem('Recetas Favoritas', '${stats['favoriteRecipes']}'),
                _buildStatItem('Ingredientes Únicos', '${stats['uniqueIngredients']}'),
                _buildStatItem('Promedio por Día', '${stats['averagePerDay']}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: AppColors.lightPrimary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tu planificación ayuda a reducir el desperdicio de alimentos',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  /// Mostrar dialog de sugerencias de IA
  static void showAiSuggestionDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
    MealType mealType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.lightPrimary),
            const SizedBox(width: 8),
            const Text('Sugerencias de IA'),
          ],
        ),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando sugerencias personalizadas...'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar dialog para mover comida
  static void showMoveMealDialog(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
  ) {
    final currentDate = DateTime.now();
    final currentDateKey = DateFormat('yyyy-MM-dd').format(currentDate);
    
    showDialog(
      context: context,
      builder: (context) => MoveMealDialog(
        meal: meal,
        currentDate: currentDate,
        currentDateKey: currentDateKey,
        onMoveMeal: (fromDate, toDate, movedMeal) {
          // Lógica para mover la comida
          final mealPlansNotifier = ref.read(mealPlansProvider.notifier);
          mealPlansNotifier.moveMeal(fromDate, toDate, movedMeal);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Mostrar dialog de recordatorio
  static void showReminderDialog(
    BuildContext context,
    WidgetRef ref,
    MealPlan meal,
  ) {
    showDialog(
      context: context,
      builder: (context) => CustomReminderDialog(
        initialText: 'Recordatorio para ${meal.name}',
        onAdd: (reminderText) {
          // Lógica para configurar recordatorio
          // En una implementación real, aquí guardarías el recordatorio
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Abrir biblioteca de recetas para selección
  static void openRecipeLibraryForSelection(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
    MealType mealType,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeLibraryScreen(
          selectionMode: true,
          onRecipeSelected: (recipe) {
            // Lógica para agregar receta seleccionada
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// Métodos auxiliares privados
  
  static String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  static Map<String, List<String>> _generateShoppingList(Map<String, List<MealPlan>> mealPlans) {
    Map<String, List<String>> shoppingList = {};
    
    for (final dayMeals in mealPlans.values) {
      for (final meal in dayMeals) {
        final category = _getCategoryForMeal(meal);
        shoppingList.putIfAbsent(category, () => []);
        
        if (meal.ingredients.isNotEmpty) {
          for (final ingredient in meal.ingredients) {
            if (!shoppingList[category]!.contains(ingredient)) {
              shoppingList[category]!.add(ingredient);
            }
          }
        }
      }
    }
    
    return shoppingList;
  }

  static String _getCategoryForMeal(MealPlan meal) {
    // Lógica simple para categorizar ingredientes
    if (meal.ingredients.any((ing) => ing.toLowerCase().contains('carne') || 
                                     ing.toLowerCase().contains('pollo') || 
                                     ing.toLowerCase().contains('pescado'))) {
      return 'Proteínas';
    } else if (meal.ingredients.any((ing) => ing.toLowerCase().contains('verdura') || 
                                           ing.toLowerCase().contains('vegetal'))) {
      return 'Verduras';
    } else if (meal.ingredients.any((ing) => ing.toLowerCase().contains('fruta'))) {
      return 'Frutas';
    } else {
      return 'Otros';
    }
  }

  static void _shareShoppingList(Map<String, List<String>> shoppingList) {
    final text = StringBuffer('Lista de Compras:\n\n');
    for (final entry in shoppingList.entries) {
      text.write('${entry.key}:\n');
      for (final item in entry.value) {
        text.write('• $item\n');
      }
      text.write('\n');
    }
    
    // Aquí implementarías la lógica de compartir
    // Por ejemplo, usando share_plus package
    // Share.share(text.toString());
  }

  static Map<String, int> _calculateStats(Map<String, List<MealPlan>> mealPlans) {
    int totalMeals = 0;
    Set<String> uniqueIngredients = {};
    
    for (final dayMeals in mealPlans.values) {
      totalMeals += dayMeals.length;
      
      for (final meal in dayMeals) {
        uniqueIngredients.addAll(meal.ingredients);
      }
    }
    
    return {
      'totalMeals': totalMeals,
      'favoriteRecipes': 0, // Placeholder
      'uniqueIngredients': uniqueIngredients.length,
      'averagePerDay': mealPlans.isNotEmpty ? (totalMeals / mealPlans.length).round() : 0,
    };
  }

  static Widget _buildShoppingCategory(String title, List<String> items) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: items.map((item) => ListTile(
        leading: const Icon(Icons.shopping_basket, size: 16),
        title: Text(item),
        dense: true,
      )).toList(),
    );
  }

  static Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}