import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

class AddMealDialog {
  static void show(
    BuildContext context,
    WidgetRef ref,
    DateTime day, {
    MealType? initialType,
    required Function(MealPlan meal, String dateKey) onMealAdded,
  }) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final formattedDate = DateFormat('EEEE d MMMM', 'es_ES').format(day);

    // Comida seleccionada actualmente para agregar
    MealPlan? selectedMeal;

    // Obtener todas las recetas, favoritos y recientes
    final allRecipes = ref.read(allRecipesProvider);
    final favorites = ref.read(favoriteRecipesProvider);
    final recents = ref.read(recentRecipesProvider);

    // Filtrar por tipo de comida (si se especificó)
    final filteredAll =
        initialType != null
            ? allRecipes.where((recipe) => recipe.type == initialType).toList()
            : allRecipes;

    final filteredFavorites =
        initialType != null
            ? favorites.where((recipe) => recipe.type == initialType).toList()
            : favorites;

    final filteredRecents =
        initialType != null
            ? recents.where((recipe) => recipe.type == initialType).toList()
            : recents;

    // Definir las pestañas
    const tabs = ['Todas', 'Favoritas', 'Recientes'];
    int selectedTabIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Determinar qué lista mostrar según la pestaña seleccionada
              List<MealPlan> currentList;
              switch (selectedTabIndex) {
                case 1:
                  currentList = filteredFavorites;
                  break;
                case 2:
                  currentList = filteredRecents;
                  break;
                case 0:
                default:
                  currentList = filteredAll;
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador visual para arrastrar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Título y fecha
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Añadir comida',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Text(
                            formattedDate.toUpperCase().substring(0, 1) +
                                formattedDate.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF00BFA5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filtro por tipo de comida
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: MealType.values.length,
                          itemBuilder: (context, index) {
                            final type = MealType.values[index];
                            final isSelected = initialType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(type.name),
                                selected: isSelected,
                                backgroundColor: Colors.grey.shade100,
                                selectedColor: type.color.withValues(
                                  alpha: 0.2,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    initialType = selected ? type : null;
                                  });
                                },
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color:
                                      isSelected
                                          ? type.color
                                          : Colors.grey.shade700,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Pestañas para alternar entre Todas, Favoritas, Recientes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(
                          tabs.length,
                          (index) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTabIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          selectedTabIndex == index
                                              ? const Color(0xFF00BFA5)
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tabs[index],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight:
                                        selectedTabIndex == index
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        selectedTabIndex == index
                                            ? const Color(0xFF00BFA5)
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de recetas según la pestaña seleccionada
                    Expanded(
                      child:
                          currentList.isEmpty
                              ? _buildEmptyRecipesState(context)
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: currentList.length,
                                itemBuilder: (context, index) {
                                  final recipe = currentList[index];
                                  final isSelected =
                                      selectedMeal?.id == recipe.id;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedMeal =
                                            isSelected ? null : recipe;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFF00BFA5,
                                                ).withValues(alpha: 0.05)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF00BFA5)
                                                  : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Imagen o icono
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child:
                                                  recipe.imageUrl.startsWith(
                                                        'assets/',
                                                      )
                                                      ? Image.asset(
                                                        recipe.imageUrl,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : Container(
                                                        color: recipe.type.color
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        child: Icon(
                                                          recipe.type.icon,
                                                          color:
                                                              recipe.type.color,
                                                          size: 40,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          // Información
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Etiqueta de tipo
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: recipe.type.color
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      recipe.type.name,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            recipe.type.color,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Nombre
                                                  Text(
                                                    recipe.name,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Detalles
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.schedule,
                                                        size: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${recipe.prepTimeMinutes} min',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Icon(
                                                        Icons
                                                            .local_fire_department,
                                                        size: 12,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${recipe.calories} cal',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Indicador de selección
                                          if (isSelected)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: const Color(0xFF00BFA5),
                                                size: 24,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),

                    // Botón para agregar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed:
                            selectedMeal == null
                                ? null
                                : () {
                                  Navigator.pop(context);

                                  // Actualizar fecha de último uso
                                  ref
                                      .read(allRecipesProvider.notifier)
                                      .updateLastUsed(selectedMeal!.id);

                                  // Llamar callback para agregar la comida
                                  onMealAdded(selectedMeal!, dateKey);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Agregar a mi plan'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  // Widget para mostrar un estado vacío cuando no hay recetas
  static Widget _buildEmptyRecipesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No se encontraron recetas',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otro filtro o añade recetas nuevas',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
