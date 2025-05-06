import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart'; // Import for InventorySortCriteria

class InventoryFilterBottomSheet extends ConsumerStatefulWidget {
  // Pass initial state from the main screen provider
  final ItemCategory initialCategoryFilter;
  final Set<StorageType> initialStorageFilter;
  final InventorySortCriteria initialSortCriteria;
  final bool initialSortAscending;

  // Callback to apply filters back to the main screen provider
  final Function({
    required ItemCategory category,
    required Set<StorageType> storageTypes,
    required InventorySortCriteria sortCriteria,
    required bool sortAscending,
  })
  onApply;

  const InventoryFilterBottomSheet({
    super.key,
    required this.initialCategoryFilter,
    required this.initialStorageFilter,
    required this.initialSortCriteria,
    required this.initialSortAscending,
    required this.onApply,
  });

  @override
  ConsumerState<InventoryFilterBottomSheet> createState() =>
      _InventoryFilterBottomSheetState();
}

class _InventoryFilterBottomSheetState
    extends ConsumerState<InventoryFilterBottomSheet> {
  // Local state for the bottom sheet
  late ItemCategory _selectedCategory;
  late Set<StorageType> _selectedStorageTypes;
  late InventorySortCriteria _selectedSortCriteria;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    // Initialize local state from widget parameters
    _selectedCategory = widget.initialCategoryFilter;
    _selectedStorageTypes = Set<StorageType>.from(widget.initialStorageFilter);
    _selectedSortCriteria = widget.initialSortCriteria;
    _sortAscending = widget.initialSortAscending;
  }

  void _toggleStorageType(StorageType type) {
    setState(() {
      if (_selectedStorageTypes.contains(type)) {
        _selectedStorageTypes.remove(type);
      } else {
        _selectedStorageTypes.add(type);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = ItemCategory.all;
      _selectedStorageTypes.clear();
      _selectedSortCriteria = InventorySortCriteria.name; // Default sort
      _sortAscending = true; // Default direction
    });
  }

  // Calcula el número de filtros activos
  int _getActiveFiltersCount() {
    int count = 0;

    // Categoría (si no es 'Todos')
    if (_selectedCategory != ItemCategory.all) {
      count++;
    }

    // Almacenamiento (cuenta cada tipo seleccionado)
    if (_selectedStorageTypes.isNotEmpty) {
      count += _selectedStorageTypes.length;
    }

    // Criterio de ordenación (si no es el predeterminado 'name')
    if (_selectedSortCriteria != InventorySortCriteria.name) {
      count++;
    }

    // Dirección de ordenación (si no es el predeterminado 'ascendente')
    if (!_sortAscending) {
      count++;
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color chipSelectedColor = primaryColor;
    final Color chipUnselectedColor =
        isDark ? AppColors.darkFormBackground : Colors.grey.shade200;
    final Color chipSelectedTextColor = isDark ? Colors.black : Colors.white;
    final Color chipUnselectedTextColor = secondaryTextColor;
    final Color chipUnselectedBorderColor =
        isDark ? AppColors.darkOutline.withOpacity(0.5) : Colors.grey.shade300;
    final Color dropdownBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color buttonTextColor = isDark ? Colors.black : Colors.white;

    final labelStyle = GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: mainTextColor,
      fontSize: 15,
    );
    final chipTextStyle = GoogleFonts.inter(fontSize: 13);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros Inventario',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  ),
                ),
                Row(
                  children: [
                    if (_getActiveFiltersCount() > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getActiveFiltersCount()}',
                          style: GoogleFonts.inter(
                            color: buttonTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(
                        'Limpiar todo',
                        style: GoogleFonts.inter(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: secondaryTextColor),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Cerrar',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Filters List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              children: [
                // 1. Tipo Filter Block
                Text('Tipo:', style: labelStyle),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      ItemCategory.values.map((category) {
                        final bool isSelected = _selectedCategory == category;
                        return FilterChip(
                          avatar:
                              category.icon != null
                                  ? Icon(
                                    category.icon,
                                    size: 18,
                                    color:
                                        isSelected
                                            ? chipSelectedTextColor
                                            : chipUnselectedTextColor,
                                  )
                                  : null,
                          label: Text(
                            category.displayName,
                            style: chipTextStyle,
                          ),
                          selected: isSelected,
                          onSelected:
                              (_) =>
                                  setState(() => _selectedCategory = category),
                          selectedColor: chipSelectedColor,
                          backgroundColor: chipUnselectedColor,
                          labelStyle: chipTextStyle.copyWith(
                            color:
                                isSelected
                                    ? chipSelectedTextColor
                                    : chipUnselectedTextColor,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? chipSelectedColor
                                      : chipUnselectedBorderColor,
                              width: 1,
                            ),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          pressElevation: 0,
                          elevation: 0,
                          showCheckmark: false,
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20.0),

                // 2. Almacenamiento Filter Block
                Text('Almacenamiento:', style: labelStyle),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      StorageType.values.map((type) {
                        final bool isSelected = _selectedStorageTypes.contains(
                          type,
                        );
                        return FilterChip(
                          avatar: Icon(
                            type.icon,
                            size: 18,
                            color:
                                isSelected
                                    ? chipSelectedTextColor
                                    : chipUnselectedTextColor,
                          ),
                          label: Text(type.displayName, style: chipTextStyle),
                          selected: isSelected,
                          onSelected: (_) => _toggleStorageType(type),
                          selectedColor: chipSelectedColor,
                          backgroundColor: chipUnselectedColor,
                          labelStyle: chipTextStyle.copyWith(
                            color:
                                isSelected
                                    ? chipSelectedTextColor
                                    : chipUnselectedTextColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? chipSelectedColor
                                      : chipUnselectedBorderColor,
                              width: 1,
                            ),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          pressElevation: 0,
                          elevation: 0,
                          showCheckmark: false,
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20.0),

                // 3. Ordenar por Block
                Text('Ordenar por:', style: labelStyle),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    // Sort Criteria Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ), // Added padding
                      decoration: BoxDecoration(
                        color: chipUnselectedColor,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: chipUnselectedBorderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<InventorySortCriteria>(
                          value: _selectedSortCriteria,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                          style: GoogleFonts.inter(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                          items:
                              InventorySortCriteria.values.map((criteria) {
                                return DropdownMenuItem(
                                  value: criteria,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        criteria.icon,
                                        size: 18,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(criteria.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSortCriteria = value);
                            }
                          },
                          focusColor: Colors.transparent,
                          dropdownColor: dropdownBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort Direction Button
                    IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 22,
                        color: secondaryTextColor,
                      ),
                      tooltip: _sortAscending ? 'Ascendente' : 'Descendente',
                      onPressed:
                          () =>
                              setState(() => _sortAscending = !_sortAscending),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),

          // Apply Button
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: buttonTextColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                widget.onApply(
                  category: _selectedCategory,
                  storageTypes: _selectedStorageTypes,
                  sortCriteria: _selectedSortCriteria,
                  sortAscending: _sortAscending,
                ); // Pass the selected filters back
                Navigator.pop(context); // Close the bottom sheet
              },
              child: Text(
                _getActiveFiltersCount() > 0
                    ? 'Aplicar (${_getActiveFiltersCount()} filtros)'
                    : 'Aplicar filtros',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
