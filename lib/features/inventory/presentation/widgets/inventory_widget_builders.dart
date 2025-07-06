import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';

import 'package:zer0_waste_ai/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'inventory_dialog_manager.dart';

/// Widget builders for inventory screen components
class InventoryWidgetBuilders {
  /// Build search bar widget
  static Widget buildSearchBar(
    TextEditingController searchController,
    FocusNode searchFocusNode,
    WidgetRef ref,
    VoidCallback onFilterTap,
  ) {
    final theme = Theme.of(ref.context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color searchBarIconColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar alimentos',
                prefixIcon: Icon(Icons.search, color: searchBarIconColor),
                filled: true,
                fillColor:
                    isDark
                        ? AppColors.darkSurface
                        : AppColors.lightFormBackground,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                hintStyle: GoogleFonts.inter(color: secondaryTextColor),
              ),
              style: GoogleFonts.inter(color: mainTextColor),
              focusNode: searchFocusNode,
            ),
          ),
          const SizedBox(width: 12.0),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightPrimary.withValues(alpha: 0.8),
                  AppColors.lightPrimary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.0),
                onTap: onFilterTap,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final filterCount = _getActiveFiltersCount(ref);
                      return Badge(
                        isLabelVisible: filterCount > 0,
                        label: Text(
                          filterCount.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build inventory summary section
  static Widget buildInventorySummary(
    bool isExpanded,
    VoidCallback onToggleExpansion,
    WidgetRef ref,
  ) {
    final theme = Theme.of(ref.context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color errorColor =
        isDark ? AppColors.darkError : AppColors.lightError;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final totalCount = ref.watch(totalItemCountProvider);

                  if (totalCount == 0) {
                    return const SizedBox(width: 0);
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: onToggleExpansion,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: textTheme.labelMedium?.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$totalCount',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' Ítems'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: secondaryTextColor,
                                size: 16.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        Consumer(
          builder: (context, ref, _) {
            final expiringSoonCount = ref.watch(expiringSoonCountProvider);
            final expiredCount = ref.watch(expiredCountProvider);
            final totalCount = ref.watch(totalItemCountProvider);
            if (!isExpanded || totalCount == 0) {
              return const SizedBox.shrink();
            }
            final Color warningTextColor =
                isDark ? AppColors.warningTextDark : AppColors.warningTextLight;

            return Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expiringSoonCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.labelMedium?.copyWith(
                            color: warningTextColor.withValues(alpha: 0.9),
                          ),
                          children: [
                            TextSpan(
                              text: '$expiringSoonCount',
                              style: textTheme.labelMedium?.copyWith(
                                color: warningTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' próximos a vencer'),
                          ],
                        ),
                      ),
                    ),
                  if (expiredCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.labelMedium?.copyWith(
                            color: errorColor.withValues(alpha: 0.9),
                          ),
                          children: [
                            TextSpan(
                              text: '$expiredCount',
                              style: textTheme.labelMedium?.copyWith(
                                color: errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' vencidos'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build generate recipe button
  static Widget buildGenerateRecipeButton(
    VoidCallback onPressed,
    WidgetRef ref,
  ) {
    final theme = Theme.of(ref.context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = AppColors.lightPrimary;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : AppColors.lightFormBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.restaurant_menu_outlined, size: 20),
        label: const Text('Generar receta'),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: cardBackgroundColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          minimumSize: const Size(double.infinity, 50),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
          shadowColor: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  /// Build tab bar for expiration status filtering
  static Widget buildTabBar(
    TabController tabController,
    Color scaffoldBackgroundColor,
  ) {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: tabController,
          isScrollable: false,
          labelColor: AppColors.lightPrimary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppColors.lightPrimary,
          indicatorWeight: 3.0,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs:
              ExpirationStatus.values.map((status) {
                return Tab(text: status.displayName);
              }).toList(),
        ),
        backgroundColor: scaffoldBackgroundColor,
      ),
      pinned: true,
    );
  }

  /// Build inventory item list
  static Widget buildInventoryList(
    List<DisplayBatchInfo> filteredItems,
    WidgetRef ref,
    ScrollController scrollController,
  ) {
    if (filteredItems.isEmpty) {
      return _buildEmptyState(ref);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final displayBatchInfo = filteredItems[index];
        final item = displayBatchInfo.displayBatch;
        final recentlyAddedIds = ref.watch(inventoryProvider).recentlyAddedIds;
        final isHighlighted = recentlyAddedIds.contains(item.id);

        return Slidable(
          key: ValueKey(item.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  InventoryDialogManager.showMarkConsumedDialog(
                    context,
                    item,
                    ref,
                  );
                },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.restaurant,
                label: 'Consumir',
              ),
              SlidableAction(
                onPressed: (context) {
                  InventoryDialogManager.showQuantityEditDialog(
                    context,
                    item,
                    ref,
                  );
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
              ),
              SlidableAction(
                onPressed: (context) {
                  InventoryDialogManager.showDeleteConfirmationDialog(
                    context,
                    item,
                    ref,
                  );
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
            ],
          ),
          child: InventoryItemCard(
            key: ValueKey('${item.id}_${item.quantity}'),
            item: item,
            allBatchesForIngredient: displayBatchInfo.allBatchesForIngredient,
            isHighlighted: isHighlighted,
          ),
        );
      }, childCount: filteredItems.length),
    );
  }

  /// Build empty state widget
  static Widget _buildEmptyState(WidgetRef ref) {
    final inventoryState = ref.watch(inventoryRealProvider);
    final theme = Theme.of(ref.context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = AppColors.lightPrimary;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              inventoryState.isLoading
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando inventario...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  )
                  : _buildFilterBasedEmptyMessage(inventoryState, ref),
        ),
      ),
    );
  }

  /// Build empty message based on active filters
  static Widget _buildFilterBasedEmptyMessage(
    InventoryState inventoryState,
    WidgetRef ref,
  ) {
    final theme = Theme.of(ref.context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    bool hasActiveFilters = false;
    String filterDescription = '';

    if (inventoryState.categoryFilter != ItemCategory.all) {
      hasActiveFilters = true;
      filterDescription +=
          'categoría: ${inventoryState.categoryFilter.displayName}';
    }

    if (inventoryState.storageFilter.isNotEmpty) {
      hasActiveFilters = true;
      if (filterDescription.isNotEmpty) filterDescription += ', ';
      filterDescription +=
          'ubicación: ${inventoryState.storageFilter.map((s) => s.toString()).join(', ')}';
    }

    if (inventoryState.searchQuery.isNotEmpty) {
      hasActiveFilters = true;
      if (filterDescription.isNotEmpty) filterDescription += ', ';
      filterDescription += 'búsqueda: "${inventoryState.searchQuery}"';
    }

    if (hasActiveFilters) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: secondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron alimentos',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: mainTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Con los filtros aplicados: $filterDescription',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: secondaryTextColor),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              final notifier = ref.read(inventoryRealProvider.notifier);
              notifier.setCategoryFilter(ItemCategory.all);
              notifier.setStorageFilter({});
              notifier.setSearchQuery('');
            },
            child: Text(
              'Limpiar filtros',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 80,
            color: secondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu inventario está vacío',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: mainTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando alimentos desde la pantalla de reconocimiento',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: secondaryTextColor),
          ),
        ],
      );
    }
  }

  // Helper methods

  /// Get active filters count
  static int _getActiveFiltersCount(WidgetRef ref) {
    final inventoryState = ref.watch(inventoryRealProvider);
    int count = 0;

    if (inventoryState.categoryFilter != ItemCategory.all) {
      count++;
    }

    if (inventoryState.storageFilter.isNotEmpty) {
      count++;
    }

    if (inventoryState.searchQuery.isNotEmpty) {
      count++;
    }

    if (!inventoryState.sortAscending) {
      count++;
    }

    return count;
  }
}

/// Sliver tab bar delegate for pinned tabs
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
