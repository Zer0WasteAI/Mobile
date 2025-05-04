import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/filter_models.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RecipeFilterBottomSheet extends HookWidget {
  final List<FilterCategory> filterCategories;
  final Map<String, Set<String>> initialSelectedFilters;
  final Function(Map<String, Set<String>>) onApply;

  const RecipeFilterBottomSheet({
    super.key,
    required this.filterCategories,
    required this.initialSelectedFilters,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    // Initialize selected filters state with the provided initial values
    final selectedFilters = useState<Map<String, Set<String>>>(
      Map<String, Set<String>>.from(initialSelectedFilters),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar with drag handle
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: secondaryTextColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(
              'Filtrar recetas',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainTextColor,
              ),
            ),
          ),

          // Filter categories
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    filterCategories.map((category) {
                      return _buildFilterCategory(
                        category: category,
                        selectedFilters: selectedFilters,
                        mainTextColor: mainTextColor,
                        secondaryTextColor: secondaryTextColor,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      );
                    }).toList(),
              ),
            ),
          ),

          // Apply/Cancel buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        side: BorderSide(color: secondaryTextColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Apply button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onApply(selectedFilters.value);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Aplicar',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory({
    required FilterCategory category,
    required ValueNotifier<Map<String, Set<String>>> selectedFilters,
    required Color mainTextColor,
    required Color secondaryTextColor,
    required Color primaryColor,
    required bool isDark,
  }) {
    // Check if there are any filters in this category that are selected
    final hasSelectedFilters =
        selectedFilters.value.containsKey(category.category) &&
        selectedFilters.value[category.category]!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with count of selected filters
          Row(
            children: [
              Text(
                category.category,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              if (hasSelectedFilters) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${selectedFilters.value[category.category]!.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Clear this category's filters
                    final newFilters = Map<String, Set<String>>.from(
                      selectedFilters.value,
                    );
                    newFilters.remove(category.category);
                    selectedFilters.value = newFilters;
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Limpiar',
                    style: GoogleFonts.inter(fontSize: 12, color: primaryColor),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Filters as chips in a wrapped layout
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                category.filters.map((filter) {
                  final isSelected =
                      selectedFilters.value.containsKey(category.category) &&
                      selectedFilters.value[category.category]!.contains(
                        filter.value,
                      );

                  return FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    checkmarkColor: primaryColor,
                    backgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    selectedColor: primaryColor.withOpacity(0.15),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected ? primaryColor : secondaryTextColor,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    onSelected: (selected) {
                      final newFilters = Map<String, Set<String>>.from(
                        selectedFilters.value,
                      );

                      if (selected) {
                        // Add the filter
                        if (!newFilters.containsKey(category.category)) {
                          newFilters[category.category] = {};
                        }
                        newFilters[category.category]!.add(filter.value);
                      } else {
                        // Remove the filter
                        if (newFilters.containsKey(category.category)) {
                          newFilters[category.category]!.remove(filter.value);
                          if (newFilters[category.category]!.isEmpty) {
                            newFilters.remove(category.category);
                          }
                        }
                      }

                      selectedFilters.value = newFilters;
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
