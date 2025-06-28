import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'package:zer0_waste_ai/features/planner/presentation/providers/planner_providers.dart';

/// Manager for recipe filtering and search functionality
class RecipeFilterManager {
  /// Build search bar widget
  static Widget buildSearchBar(
    TextEditingController searchController,
    WidgetRef ref, {
    VoidCallback? onFilterTap,
  }) {
    final textColor =
        Theme.of(ref.context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar recetas...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.inter(color: textColor),
              ),
            ),
          ),

          // Filter button
          if (onFilterTap != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build filter panel
  static Widget buildFilterPanel(WidgetRef ref) {
    final filters = ref.watch(recipeFiltersProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _clearAllFilters(ref),
                child: Text(
                  'Limpiar todo',
                  style: GoogleFonts.inter(color: const Color(0xFF00BFA5)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meal type filter
          _buildMealTypeFilter(filters, ref),

          const SizedBox(height: 16),

          // Dietary preferences filter
          _buildDietaryFilter(filters, ref),

          const SizedBox(height: 16),

          // Difficulty filter
          _buildDifficultyFilter(filters, ref),

          const SizedBox(height: 16),

          // Cooking time filter
          _buildCookingTimeFilter(filters, ref),
        ],
      ),
    );
  }

  /// Build meal type filter section
  static Widget _buildMealTypeFilter(dynamic filters, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de comida',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              MealType.values.map((type) {
                final isSelected = filters.mealType == type;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 16,
                        color: isSelected ? Colors.white : type.color,
                      ),
                      const SizedBox(width: 4),
                      Text(type.name),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    _updateMealTypeFilter(ref, selected ? type : null);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: type.color,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build dietary preferences filter section
  static Widget _buildDietaryFilter(dynamic filters, WidgetRef ref) {
    final dietaryOptions = [
      'Vegetariano',
      'Vegano',
      'Sin gluten',
      'Sin lácteos',
      'Sin azúcar',
      'Alto en proteínas',
      'Bajo en calorías',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferencias dietéticas',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              dietaryOptions.map((option) {
                final isSelected =
                    filters.dietaryRestrictions?.contains(option) ?? false;
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    _updateDietaryFilter(ref, option, selected);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                  labelStyle: GoogleFonts.inter(
                    color:
                        isSelected
                            ? const Color(0xFF00BFA5)
                            : Colors.grey.shade800,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build difficulty filter section
  static Widget _buildDifficultyFilter(dynamic filters, WidgetRef ref) {
    final difficultyOptions = ['Fácil', 'Medio', 'Difícil'];
    final difficultyColors = [Colors.green, Colors.orange, Colors.red];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dificultad',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              difficultyOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final difficulty = entry.value;
                final color = difficultyColors[index];
                final isSelected = filters.difficulty == difficulty;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(difficulty),
                    selected: isSelected,
                    onSelected: (selected) {
                      _updateDifficultyFilter(
                        ref,
                        selected ? difficulty : null,
                      );
                    },
                    backgroundColor: Colors.white,
                    selectedColor: color.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: isSelected ? color : Colors.grey.shade800,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build cooking time filter section
  static Widget _buildCookingTimeFilter(dynamic filters, WidgetRef ref) {
    final timeRanges = [
      {'label': '< 15 min', 'max': 15},
      {'label': '15-30 min', 'min': 15, 'max': 30},
      {'label': '30-60 min', 'min': 30, 'max': 60},
      {'label': '> 60 min', 'min': 60},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiempo de cocción',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              timeRanges.map((range) {
                final isSelected = _isTimeRangeSelected(filters, range);
                return FilterChip(
                  label: Text(range['label'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    _updateCookingTimeFilter(ref, selected ? range : null);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                  labelStyle: GoogleFonts.inter(
                    color:
                        isSelected
                            ? const Color(0xFF00BFA5)
                            : Colors.grey.shade800,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Build active filters display
  static Widget buildActiveFilters(WidgetRef ref) {
    final filters = ref.watch(recipeFiltersProvider);
    final activeFilters = _getActiveFiltersList(filters);

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtros activos:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _clearAllFilters(ref),
                child: Text(
                  'Limpiar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF00BFA5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                activeFilters.map((filter) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF00BFA5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeSpecificFilter(ref, filter),
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: const Color(0xFF00BFA5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // Private helper methods

  static void _updateMealTypeFilter(WidgetRef ref, MealType? type) {
    final currentFilters = ref.read(recipeFiltersProvider);
    ref.read(recipeFiltersProvider.notifier).state = currentFilters.copyWith(
      mealType: type,
    );
  }

  static void _updateDietaryFilter(
    WidgetRef ref,
    String option,
    bool selected,
  ) {
    final currentFilters = ref.read(recipeFiltersProvider);
    final currentRestrictions = List<String>.from(currentFilters.dietaryTags);

    if (selected) {
      currentRestrictions.add(option);
    } else {
      currentRestrictions.remove(option);
    }

    ref.read(recipeFiltersProvider.notifier).state = currentFilters.copyWith(
      dietaryTags: currentRestrictions,
    );
  }

  static void _updateDifficultyFilter(WidgetRef ref, String? difficulty) {
    // Difficulty filter is not supported in current RecipeFilters model
    // This method is kept for compatibility but does nothing
  }

  static void _updateCookingTimeFilter(
    WidgetRef ref,
    Map<String, dynamic>? range,
  ) {
    final currentFilters = ref.read(recipeFiltersProvider);
    ref.read(recipeFiltersProvider.notifier).state = currentFilters.copyWith(
      maxPrepTimeMinutes: range?['max'],
      clearPrepTime: range == null,
    );
  }

  static void _clearAllFilters(WidgetRef ref) {
    // Reset all filters to default state
    ref.read(recipeFiltersProvider.notifier).state = ref
        .read(recipeFiltersProvider)
        .copyWith(
          dietaryTags: const [],
          clearMealType: true,
          clearPrepTime: true,
          clearCalories: true,
          clearSearch: true,
        );
  }

  static bool _isTimeRangeSelected(
    dynamic filters,
    Map<String, dynamic> range,
  ) {
    final maxTime = filters.maxPrepTimeMinutes;
    final rangeMax = range['max'] as int?;

    return maxTime == rangeMax;
  }

  static List<String> _getActiveFiltersList(dynamic filters) {
    final activeFilters = <String>[];

    if (filters.mealType != null) {
      activeFilters.add(filters.mealType.name);
    }

    if (filters.dietaryTags.isNotEmpty) {
      activeFilters.addAll(filters.dietaryTags);
    }

    if (filters.maxPrepTimeMinutes != null) {
      activeFilters.add('Tiempo: < ${filters.maxPrepTimeMinutes} min');
    }

    if (filters.maxCalories != null) {
      activeFilters.add('Calorías: < ${filters.maxCalories}');
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      activeFilters.add('Búsqueda: ${filters.searchQuery}');
    }

    return activeFilters;
  }

  static void _removeSpecificFilter(WidgetRef ref, String filter) {
    // Check which type of filter to remove
    if (MealType.values.any((type) => type.name == filter)) {
      _updateMealTypeFilter(ref, null);
    } else if (filter.startsWith('Tiempo:')) {
      _updateCookingTimeFilter(ref, null);
    } else if (['Fácil', 'Medio', 'Difícil'].contains(filter)) {
      _updateDifficultyFilter(ref, null);
    } else {
      // It's a dietary restriction
      _updateDietaryFilter(ref, filter, false);
    }
  }
}
