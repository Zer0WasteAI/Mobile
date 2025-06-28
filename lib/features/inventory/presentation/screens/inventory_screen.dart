// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/inventory_filter_bottom_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zer0_waste_ai/core/utils/date_extensions.dart'; // Import for date formatting extension
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/mark_consumed_dialog.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/ai_recipes_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  // Define route name for AddInventoryItemScreen
  static const String addInventoryItemRouteName = 'addInventoryItem';

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSummaryExpanded = false; // State to control summary visibility
  Set<String> _previousRecentlyAddedIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      // Sync search query to both providers
      ref
          .read(inventoryProvider.notifier)
          .setSearchQuery(_searchController.text);
      ref
          .read(inventoryRealProvider.notifier)
          .setSearchQuery(_searchController.text);
    });

    // Initialize TabController
    final initialFilterStatus =
        ref.read(inventoryRealProvider).expirationStatusFilter;
    final initialTabIndex = ExpirationStatus.values.indexOf(
      initialFilterStatus,
    );
    _tabController = TabController(
      length: ExpirationStatus.values.length,
      vsync: this,
      initialIndex:
          initialTabIndex >= 0 ? initialTabIndex : 0, // Handle potential issues
    );

    // 🚀 OPTIMIZED: Smart inventory loading with cache
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInventorySmartly();

      // Verificar si hay elementos destacados al iniciar la pantalla
      final recentlyAddedIds = ref.read(inventoryProvider).recentlyAddedIds;
      log('initState: IDs destacados encontrados: ${recentlyAddedIds.length}');

      if (recentlyAddedIds.isEmpty) {
        // Si no hay elementos destacados, limpiar cualquier resaltado pendiente
        ref.read(inventoryProvider.notifier).clearHighlightsImmediately();
      } else {
        // Si hay elementos destacados, guardarlos y hacer scroll al último elemento
        _previousRecentlyAddedIds = Set<String>.from(recentlyAddedIds);
        log('initState: Haciendo scroll al último elemento de la lista');

        // ✅ UPDATED: Immediate scroll without artificial delay
        scrollToLastItem();
      }
    });
  }

  /// 🧠 Smart inventory loading logic
  /// Only loads from backend when necessary
  Future<void> _loadInventorySmartly() async {
    // 🚀 Use the new smart loading method from the provider
    await ref.read(inventoryRealProvider.notifier).loadInventoryIfNeeded();

    // Sync with UI provider
    final realItems = ref.read(inventoryRealProvider).items;
    ref.read(inventoryProvider.notifier).clearAllItems();
    if (realItems.isNotEmpty) {
      ref.read(inventoryProvider.notifier).addItems(realItems);
    }

    log('📋 Smart loading completed: ${realItems.length} items synced to UI');
  }

  /// 🔄 Force refresh inventory from backend (user-triggered)
  Future<void> _forceRefreshInventory() async {
    try {
      // Show loading feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Actualizando inventario...'),
              ],
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Force complete inventory reload
      await ref
          .read(inventoryRealProvider.notifier)
          .loadCompleteInventoryFromBackend();

      // Sync with UI provider
      final realItems = ref.read(inventoryRealProvider).items;
      ref.read(inventoryProvider.notifier).clearAllItems();
      if (realItems.isNotEmpty) {
        ref.read(inventoryProvider.notifier).addItems(realItems);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Inventario actualizado (${realItems.length} items)',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      log('❌ Failed to force refresh inventory: $e');
      // Fallback to regular inventory
      try {
        await ref.read(inventoryRealProvider.notifier).refreshInventory();

        final realItems = ref.read(inventoryRealProvider).items;
        ref.read(inventoryProvider.notifier).clearAllItems();
        if (realItems.isNotEmpty) {
          ref.read(inventoryProvider.notifier).addItems(realItems);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Inventario actualizado - modo básico (${realItems.length} items)',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (fallbackError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${fallbackError.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant InventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Obtener los IDs actuales de elementos destacados
    final currentRecentlyAddedIds =
        ref.read(inventoryProvider).recentlyAddedIds;
    log(
      'didUpdateWidget: Elementos destacados detectados: ${currentRecentlyAddedIds.length}',
    );
    log(
      'didUpdateWidget: Elementos previos: ${_previousRecentlyAddedIds.length}',
    );

    // Si hay elementos destacados nuevos...
    if (currentRecentlyAddedIds.isNotEmpty) {
      // Detectar elementos nuevos (IDs que están en currentRecentlyAddedIds pero no en _previousRecentlyAddedIds)
      final newIds =
          currentRecentlyAddedIds
              .where((id) => !_previousRecentlyAddedIds.contains(id))
              .toList();

      log('didUpdateWidget: Nuevos elementos destacados: ${newIds.length}');

      // Si hay nuevos elementos destacados
      if (newIds.isNotEmpty) {
        // Hacer scroll al último elemento de la lista en lugar de al elemento destacado
        log('didUpdateWidget: Haciendo scroll al último elemento de la lista');

        // ✅ UPDATED: Immediate scroll without artificial delay
        if (mounted) {
          scrollToLastItem();
        }
      } else if (_previousRecentlyAddedIds.isEmpty &&
          currentRecentlyAddedIds.isNotEmpty) {
        // Si no hay nuevos elementos específicos pero pasamos de ninguno a algunos
        log('didUpdateWidget: Haciendo scroll al último elemento de la lista');

        // ✅ UPDATED: Immediate scroll without artificial delay
        if (mounted) {
          scrollToLastItem();
        }
      }
    }

    // Actualizar los IDs anteriores para la próxima comparación
    _previousRecentlyAddedIds = Set<String>.from(currentRecentlyAddedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryRealProvider);
    final filteredItems = ref.watch(filteredSortedInventoryRealProvider);
    final recentlyAddedIds = inventoryState.recentlyAddedIds;
    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // --- Theme-aware Colors --- //
    final Color scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : const Color(0xFF00B894);
    final Color onPrimaryColor = isDark ? Colors.black : Colors.white;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color chipSelectedColor = primaryColor;
    final Color chipUnselectedColor =
        isDark ? AppColors.darkSurface : Colors.grey.shade200;
    final Color chipSelectedTextColor = onPrimaryColor;
    final Color chipUnselectedTextColor = secondaryTextColor;
    final Color chipUnselectedBorderColor =
        isDark ? AppColors.darkOutline : Colors.grey.shade300;
    final Color warningColor =
        isDark ? AppColors.warningTextDark : AppColors.warningTextLight;
    final Color errorColor = AppColors.error;
    final Color searchBarIconColor = secondaryTextColor;
    final Color dropdownBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color fabBackgroundColor = primaryColor;
    final Color fabIconColor = Colors.white;
    // ------------------------- //

    final labelStyle = GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: mainTextColor,
      fontSize: 14,
    );

    final chipTextStyle = GoogleFonts.inter(
      color: secondaryTextColor,
      fontSize: 13,
    );

    // Create the TabBar widget separately for the delegate
    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: primaryColor,
      unselectedLabelColor: secondaryTextColor,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor, width: 3.0)),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      tabs:
          ExpirationStatus.values.map((status) {
            return Tab(text: status.displayName);
          }).toList(),
      onTap: (index) {
        final selectedStatus = ExpirationStatus.values[index];
        // Sync expiration filter to both providers
        ref
            .read(inventoryProvider.notifier)
            .setExpirationStatusFilter(selectedStatus);
        ref
            .read(inventoryRealProvider.notifier)
            .setExpirationStatusFilter(selectedStatus);
      },
    );

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Inventario',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: textTheme.headlineSmall?.fontSize ?? 24,
            color: mainTextColor,
          ),
        ),
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          // 🚀 OPTIMIZED: Smart refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: () async {
              // Force refresh from backend (user explicitly requested)
              await _forceRefreshInventory();
            },
            tooltip: 'Actualizar inventario',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Quitar el foco del search bar cuando se toca en cualquier parte fuera de él
          _searchFocusNode.unfocus();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightFormBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : Colors.grey.withValues(alpha: 0.15),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar alimentos',
                          prefixIcon: Icon(
                            Icons.search,
                            color: searchBarIconColor,
                          ),
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
                          hintStyle: GoogleFonts.inter(
                            color: secondaryTextColor,
                          ),
                        ),
                        style: GoogleFonts.inter(color: mainTextColor),
                        focusNode: _searchFocusNode,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final totalCount = ref.watch(
                                totalItemCountProvider,
                              );
                              final expiringSoonCount = ref.watch(
                                expiringSoonCountProvider,
                              );
                              final expiredCount = ref.watch(
                                expiredCountProvider,
                              );
                              final bool isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              final Color warningTextColor =
                                  isDark
                                      ? AppColors.warningTextDark
                                      : AppColors.warningTextLight;

                              if (totalCount == 0) {
                                return const SizedBox(width: 0);
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isSummaryExpanded =
                                            !_isSummaryExpanded;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: secondaryTextColor,
                                                  ),
                                              children: [
                                                TextSpan(
                                                  text: '$totalCount',
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                        color: mainTextColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const TextSpan(text: ' Ítems'),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Icon(
                                            _isSummaryExpanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            size: 18,
                                            color: secondaryTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const Spacer(),
                          TextButton.icon(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: primaryColor,
                            ),
                            label: Text(
                              _getActiveFiltersCount(ref) > 0
                                  ? 'Filtros (${_getActiveFiltersCount(ref)})'
                                  : 'Filtros',
                              style: GoogleFonts.inter(color: primaryColor),
                            ),
                            onPressed: () {
                              final currentFilters = ref.read(
                                inventoryRealProvider,
                              );
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => InventoryFilterBottomSheet(
                                      initialCategoryFilter:
                                          currentFilters.categoryFilter,
                                      initialStorageFilter:
                                          currentFilters.storageFilter,
                                      initialSortCriteria:
                                          currentFilters.sortCriteria,
                                      initialSortAscending:
                                          currentFilters.sortAscending,
                                      onApply: ({
                                        required ItemCategory category,
                                        required Set<StorageType> storageTypes,
                                        required InventorySortCriteria
                                        sortCriteria,
                                        required bool sortAscending,
                                      }) {
                                        // Apply filters to both providers to keep them in sync
                                        final uiNotifier = ref.read(
                                          inventoryProvider.notifier,
                                        );
                                        final realNotifier = ref.read(
                                          inventoryRealProvider.notifier,
                                        );

                                        // Apply to UI provider (for filter counting)
                                        uiNotifier.setCategoryFilter(category);
                                        uiNotifier.setStorageFilter(
                                          storageTypes,
                                        );
                                        uiNotifier.setSortCriteria(
                                          sortCriteria,
                                        );
                                        uiNotifier.setSortDirection(
                                          sortAscending,
                                        );

                                        // Apply to real provider (for actual filtering)
                                        try {
                                          realNotifier.setCategoryFilter(
                                            category,
                                          );
                                          realNotifier.setStorageFilter(
                                            storageTypes,
                                          );
                                          realNotifier.setSortCriteria(
                                            sortCriteria,
                                          );
                                          realNotifier.setSortDirection(
                                            sortAscending,
                                          );
                                        } catch (e) {
                                          // Methods might not exist in real provider, that's ok
                                          log(
                                            'Some filter methods not available in real provider: $e',
                                          );
                                        }
                                      },
                                    ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Consumer(
                      builder: (context, ref, _) {
                        final expiringSoonCount = ref.watch(
                          expiringSoonCountProvider,
                        );
                        final expiredCount = ref.watch(expiredCountProvider);
                        final totalCount = ref.watch(totalItemCountProvider);
                        if (!_isSummaryExpanded || totalCount == 0) {
                          return const SizedBox.shrink();
                        }
                        final Color warningTextColor =
                            isDark
                                ? AppColors.warningTextDark
                                : AppColors.warningTextLight;

                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 4.0,
                            bottom: 8.0,
                            left: 4.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (expiringSoonCount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: textTheme.labelMedium?.copyWith(
                                        color: warningTextColor.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '$expiringSoonCount',
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                color: warningTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const TextSpan(
                                          text: ' próximos a vencer',
                                        ),
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
                                        color: errorColor.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '$expiredCount',
                                          style: textTheme.labelMedium
                                              ?.copyWith(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.restaurant_menu_outlined,
                          size: 20,
                        ),
                        label: const Text('Generar receta'),
                        onPressed: () {
                          // Clear AI recipe state to force regeneration
                          ref.read(aiRecipeProvider.notifier).clearState();
                          context.pushNamed('AIRecipeGenerationScreen');
                        },
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
                    ),
                  ],
                ),
              ),
            ),

            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                tabBar,
                backgroundColor: scaffoldBackgroundColor,
              ),
              pinned: true,
            ),

            if (inventoryState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child:
                        inventoryState.isLoading
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cargando inventario...',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: secondaryTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              inventoryState.searchQuery.isNotEmpty ||
                                      inventoryState.categoryFilter !=
                                          ItemCategory.all ||
                                      inventoryState.storageFilter.isNotEmpty
                                  ? 'No hay ítems que coincidan con los filtros.'
                                  : 'Tu inventario está vacío.\n¡Agrega algunos ítems!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: secondaryTextColor,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 88.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final batchInfo = filteredItems[index];
                    final item = batchInfo.displayBatch;
                    final allBatches = batchInfo.allBatchesForIngredient;

                    final bool isHighlighted = recentlyAddedIds.contains(
                      item.id,
                    );
                    final bool isIngredient =
                        item.category == ItemCategory.ingredient;
                    final bool isFood = item.category == ItemCategory.food;

                    // Check if item is expired to determine if we should show the delete action
                    final bool isExpired = _isItemExpired(item);

                    return Slidable(
                      key: ValueKey(item.id),
                      // Start action: Mark as consumed
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed:
                                (context) =>
                                    _showMarkConsumedDialog(context, item),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.restaurant,
                            label: 'Consumido',
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ],
                      ),
                      // End action: Delete (only if not expired)
                      endActionPane:
                          isExpired
                              ? null
                              : ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    onPressed:
                                        (context) =>
                                            _showDeleteConfirmationDialog(
                                              context,
                                              item,
                                              ref,
                                            ),
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_outline,
                                    label: 'Eliminar',
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ],
                              ),
                      child: GestureDetector(
                        onTap: () {
                          if (isIngredient) {
                            context.pushNamed(
                              'ingredientDetail',
                              pathParameters: {'ingredientName': item.name},
                            );
                          } else if (isFood) {
                            context.pushNamed(
                              'foodDetail',
                              pathParameters: {'itemId': item.id},
                            );
                          }
                        },
                        child: InventoryItemCard(
                          item: item,
                          allBatchesForIngredient: allBatches,
                          isHighlighted: isHighlighted,
                        ),
                      ),
                    );
                  }, childCount: filteredItems.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed:
            () => context.pushNamed(InventoryScreen.addInventoryItemRouteName),
        backgroundColor: fabBackgroundColor,
        tooltip: 'Añadir Ítem',
        child: Icon(Icons.add, color: fabIconColor),
      ),
    );
  }

  // Helper to check if item is expired
  bool _isItemExpired(InventoryItem item) {
    if (item.expirationDate == null) return false;
    final status = ExpirationStatusExtension.fromDate(item.expirationDate);
    return status == ExpirationStatus.expired;
  }

  // Helper to show mark consumed dialog
  void _showMarkConsumedDialog(BuildContext context, InventoryItem item) {
    showMarkConsumedDialog(context, item);
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) async {
    // Log para debug
    log(
      '🗑️ DEBUG: Showing delete dialog for item: ${item.name} (ID: ${item.id})',
    );

    // Capture references BEFORE showing dialog to avoid context issues
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Eliminar ${item.name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Estás seguro de que quieres eliminar este elemento del inventario?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta acción no se puede deshacer',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    log('🗑️ DEBUG: User cancelled deletion');
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    log('🗑️ DEBUG: User confirmed deletion');
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    log('🗑️ DEBUG: Dialog result: $confirmed');

    if (confirmed) {
      log('🗑️ DEBUG: Confirmed is true, proceeding with deletion...');
      log('🗑️ DEBUG: Starting deletion process for item: ${item.id}');

      // Show enhanced loading dialog using captured navigator
      navigator.push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black54,
          barrierDismissible: false,
          pageBuilder:
              (context, _, _) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Eliminando ${item.name}...',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
        ),
      );

      try {
        log('🗑️ DEBUG: Calling removeItem for ID: ${item.id}');
        log(
          '🗑️ DEBUG: Provider state before removal: ${ref.read(inventoryRealProvider).items.length} items',
        );

        // Use the correct provider with backend synchronization
        await ref.read(inventoryRealProvider.notifier).removeItem(item.id);

        log('🗑️ DEBUG: removeItem call completed successfully');
        log(
          '🗑️ DEBUG: Provider state after removal: ${ref.read(inventoryRealProvider).items.length} items',
        );
        log('🗑️ DEBUG: Item successfully removed from backend');

        // Hide loading dialog
        navigator.pop();

        // Show success message using captured scaffold messenger
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.name} eliminado del inventario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        log('🗑️ ERROR: Failed to delete item: $e');

        // Hide loading dialog
        navigator.pop();

        // Show error message using captured scaffold messenger
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al eliminar: ${e.toString()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  // Función para contar los filtros activos
  int _getActiveFiltersCount(WidgetRef ref) {
    final inventoryState = ref.read(inventoryRealProvider);
    int count = 0;

    // Categoría (si no es 'Todos')
    if (inventoryState.categoryFilter != ItemCategory.all) {
      count++;
    }

    // Almacenamiento (cuenta cada tipo seleccionado)
    if (inventoryState.storageFilter.isNotEmpty) {
      count += inventoryState.storageFilter.length;
    }

    // Búsqueda (si hay texto de búsqueda)
    if (inventoryState.searchQuery.isNotEmpty) {
      count++;
    }

    // Criterio de ordenación (si no es el predeterminado 'name')
    if (inventoryState.sortCriteria != InventorySortCriteria.name) {
      count++;
    }

    // Dirección de ordenación (si no es el predeterminado 'ascendente')
    if (!inventoryState.sortAscending) {
      count++;
    }

    return count;
  }

  // Función para hacer scroll al último elemento de la lista
  void scrollToLastItem() {
    // ✅ UPDATED: Reduced delay for better performance
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      // Obtener los elementos filtrados
      final filteredItems = ref.read(filteredSortedInventoryRealProvider);

      if (filteredItems.isEmpty) {
        log('La lista está vacía, no se puede hacer scroll');
        return;
      }

      log(
        'Intentando hacer scroll al final de ${filteredItems.length} elementos',
      );

      try {
        // MÉTODO 1: Intentar usar maxScrollExtent para ir al final de la lista
        // Este es el método más confiable para hacer scroll al final de la lista
        if (_scrollController.hasClients) {
          log(
            'Usando maxScrollExtent para scroll: ${_scrollController.position.maxScrollExtent}',
          );

          // ✅ UPDATED: Immediate scroll without additional delay
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
          return;
        }
      } catch (e) {
        log('Error usando maxScrollExtent: $e');
      }

      // MÉTODO 2: Cálculo basado en índices (respaldo)
      try {
        // Como respaldo, intentar calcular la posición del último elemento
        int lastIndex = filteredItems.length - 1;

        // Valores mayores para asegurar que se hace scroll suficiente
        final double searchBarHeight = 200.0;
        final double tabBarHeight = 70.0;
        final double itemHeight = 90.0;

        final double scrollPosition =
            searchBarHeight + tabBarHeight + (lastIndex * itemHeight) + 100;

        log('Usando cálculo de posición: $scrollPosition');

        // Hacer scroll a la posición calculada
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
        );
      } catch (e) {
        log('Error en cálculo de posición: $e');

        // MÉTODO 3: Último intento usando un valor arbitrario grande
        try {
          log('Intento final con valor fijo grande');
          _scrollController.animateTo(
            10000.0, // Valor grande para intentar llegar al final
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
        } catch (e) {
          log('Error en intento final: $e');
        }
      }
    });
  }

  // Función original para hacer scroll a un ítem específico por ID
  void scrollToHighlightedItem(String itemId) {
    // Aumentar el tiempo de espera para asegurar que la lista se ha construido completamente
    // y los elementos filtrados están disponibles
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      // Obtener los elementos filtrados más actualizados
      final filteredItems = ref.read(filteredSortedInventoryRealProvider);

      log('Intentando hacer scroll al ítem: $itemId');
      log('Total de ítems en la lista: ${filteredItems.length}');

      // Buscar el índice del ítem destacado
      int highlightedIndex = -1;
      for (int i = 0; i < filteredItems.length; i++) {
        if (filteredItems[i].displayBatch.id == itemId) {
          highlightedIndex = i;
          log('Ítem encontrado en el índice: $i');
          break;
        }
      }

      if (highlightedIndex >= 0) {
        // Calcular la posición con valores más precisos ajustados a la UI actual
        final double searchBarHeight =
            180.0; // Aumentar para asegurar visibilidad
        final double tabBarHeight = 60.0; // Aumentar para mayor margen
        final double itemHeight = 85.0; // Ajustar según tamaño real del ítem

        // Añadir un pequeño offset para asegurar que el ítem sea visible
        final double scrollPosition =
            searchBarHeight +
            tabBarHeight +
            (highlightedIndex * itemHeight) -
            40;

        log('Haciendo scroll a la posición: $scrollPosition');

        // Intentar hacer scroll con una duración más larga para mayor suavidad
        try {
          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuint,
          );
        } catch (e) {
          log('Error haciendo scroll: $e');
          // Intento alternativo con posición fija si falla el cálculo
          if (highlightedIndex > 0) {
            _scrollController.animateTo(
              highlightedIndex * 100.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutQuint,
            );
          }
        }
      } else {
        log('Ítem con ID: $itemId no encontrado en la lista filtrada');
        // Si no se encuentra el ítem específico, hacer scroll al último elemento
        scrollToLastItem();
      }
    });
  }
}

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

// --- Top-level function for Quantity Edit Dialog --- //
Future<void> showQuantityEditDialog(
  BuildContext context,
  InventoryItem item,
  WidgetRef ref,
) async {
  // Use a consistent key based on item ID instead of creating a new GlobalKey each time
  final formKey = GlobalKey<FormState>(debugLabel: 'editQuantity_${item.id}');
  final inventoryNotifier = ref.read(inventoryRealProvider.notifier);

  // Format initial quantity for display based on unit type
  final TextEditingController quantityController = TextEditingController(
    text: _formatQuantityForEditing(item.quantity, item.unitType),
  );

  // Get theme colors
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final inputFillColor =
      isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5);

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      // Use a local stateful builder to update +/- buttons reflected in text field immediately
      String currentTextValue = quantityController.text;
      return StatefulBuilder(
        builder: (stfContext, stfSetState) {
          return AppDialog(
            emoji: item.image.isNotEmpty ? item.image : '🍲',
            title: 'Editar Cantidad',
            subtitle: item.name,
            content: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ingresa la nueva cantidad',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Custom quantity input field
                  Container(
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Decrement button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              bottomLeft: Radius.circular(16.0),
                            ),
                            onTap: () {
                              final currentVal =
                                  double.tryParse(quantityController.text) ??
                                  item.quantity;
                              final step = inventoryNotifier.getQuantityStep(
                                item.unitType,
                              );
                              final min = inventoryNotifier.getMinimumQuantity(
                                item.unitType,
                              );
                              final newVal =
                                  ((currentVal * 10 - step * 10).round() / 10.0)
                                      .clamp(min, double.infinity);
                              stfSetState(() {
                                quantityController
                                    .text = _formatQuantityForEditing(
                                  newVal,
                                  item.unitType,
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14.0),
                              child: Icon(
                                Icons.remove_circle,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),

                        // Vertical divider
                        Container(
                          height: 30,
                          width: 1,
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),

                        // Text field
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              suffix: Text(
                                item.unitType,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa una cantidad';
                              }
                              final double? enteredQuantity = double.tryParse(
                                value,
                              );
                              if (enteredQuantity == null) {
                                return 'Número inválido';
                              }
                              final minQuantity = inventoryNotifier
                                  .getMinimumQuantity(item.unitType);
                              if (enteredQuantity < minQuantity) {
                                return 'Mínimo: ${_formatQuantityForEditing(minQuantity, item.unitType)} ${item.unitType}';
                              }
                              return null; // Valid
                            },
                          ),
                        ),

                        // Vertical divider
                        Container(
                          height: 30,
                          width: 1,
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),

                        // Increment button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            onTap: () {
                              final currentVal =
                                  double.tryParse(quantityController.text) ??
                                  item.quantity;
                              final step = inventoryNotifier.getQuantityStep(
                                item.unitType,
                              );
                              final newVal =
                                  ((currentVal * 10 + step * 10).round() /
                                      10.0);
                              stfSetState(() {
                                quantityController
                                    .text = _formatQuantityForEditing(
                                  newVal,
                                  item.unitType,
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14.0),
                              child: Icon(
                                Icons.add_circle,
                                color: colorScheme.primary,
                                size: 28,
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
            primaryAction: AppDialog.createPrimaryButton(
              context: context,
              text: 'Guardar',
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final double newQuantity = double.parse(
                    quantityController.text,
                  );

                  // Use the new quick quantity update endpoint for better performance
                  try {
                    await ref
                        .read(inventoryRealProvider.notifier)
                        .updateItemQuantityQuick(item.id, newQuantity);

                    // No need for manual sync since we're using inventoryRealProvider directly

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cantidad actualizada: ${_formatQuantityForEditing(newQuantity, item.unitType)} ${item.unitType}',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }

                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            secondaryAction: AppDialog.createSecondaryButton(
              context: context,
              text: 'Cancelar',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          );
        },
      );
    },
  );
}

// --- Top-level function for Batch Selector Dialog --- //
Future<void> showBatchSelectorDialog(
  BuildContext context,
  InventoryItem currentDisplayBatch,
  List<InventoryItem> allBatches,
  WidgetRef ref,
) async {
  final inventoryNotifier = ref.read(inventoryProvider.notifier);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final primaryColor = isDark ? AppColors.darkPrimary : const Color(0xFF00B894);
  final backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
  final textColor = isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
  final secondaryTextColor =
      isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);

  // Sort batches for display in the dialog (e.g., by expiration date)
  final sortedBatches = List<InventoryItem>.from(allBatches)..sort((a, b) {
    if (a.expirationDate == null && b.expirationDate == null) return 0;
    if (a.expirationDate == null) return 1;
    if (b.expirationDate == null) return -1;
    return a.expirationDate!.compareTo(b.expirationDate!);
  });

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: 8,
        backgroundColor: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Column(
                  children: [
                    Text(
                      currentDisplayBatch.name,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Selecciona el lote que deseas mostrar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // Batch list
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children:
                        sortedBatches.map((batch) {
                          final isCurrentlySelected =
                              batch.id == currentDisplayBatch.id;
                          final status = ExpirationStatusExtension.fromDate(
                            batch.expirationDate,
                          );

                          // Define colors and icons based on expiration status
                          final Color statusColor =
                              status == ExpirationStatus.expired
                                  ? AppColors.error
                                  : status == ExpirationStatus.expiringSoon
                                  ? Colors.orange.shade700
                                  : Colors.green.shade600;

                          final IconData statusIcon =
                              status == ExpirationStatus.expired
                                  ? Icons.error_outline
                                  : status == ExpirationStatus.expiringSoon
                                  ? Icons.warning_amber_outlined
                                  : Icons.check_circle_outline;

                          final String storageText =
                              batch.storageType.displayName;
                          final IconData storageIcon = batch.storageType.icon;

                          return InkWell(
                            onTap: () {
                              if (!isCurrentlySelected) {
                                // Update both providers to keep them in sync
                                ref
                                    .read(inventoryProvider.notifier)
                                    .setUserSelectedBatch(
                                      currentDisplayBatch.name,
                                      batch.id,
                                    );
                                ref
                                    .read(inventoryRealProvider.notifier)
                                    .setUserSelectedBatch(
                                      currentDisplayBatch.name,
                                      batch.id,
                                    );
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color:
                                    isCurrentlySelected
                                        ? primaryColor.withValues(alpha: 0.1)
                                        : isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isCurrentlySelected
                                          ? primaryColor
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow:
                                    isCurrentlySelected
                                        ? [
                                          BoxShadow(
                                            color: primaryColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Row(
                                children: [
                                  // Left side indicator
                                  Container(
                                    width: 4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          isCurrentlySelected
                                              ? primaryColor
                                              : statusColor.withValues(
                                                alpha: 0.6,
                                              ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Main content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Top row with quantity and selection indicator
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Cantidad: ${_formatQuantityForEditing(batch.quantity, batch.unitType)} ${batch.unitType}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            if (isCurrentlySelected)
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Expiration info - Separate row for expiration
                                        Row(
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: 16,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                batch.expirationDate
                                                        ?.formatExpirationStatus() ??
                                                    "Sin fecha",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: statusColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        // Storage type info - Separate row for storage
                                        Row(
                                          children: [
                                            Icon(
                                              storageIcon,
                                              size: 16,
                                              color: secondaryTextColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                storageText,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: secondaryTextColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper to format quantity consistently for display and editing
String _formatQuantityForEditing(double quantity, String unitType) {
  if (unitType.toLowerCase() == 'unidades') {
    return quantity.toInt().toString(); // Show units as integer
  } else {
    // For kg, g, lt, ml, show one decimal place if not whole
    if (quantity == quantity.truncateToDouble()) {
      return quantity.toInt().toString(); // 5.0 becomes "5"
    } else {
      return quantity.toStringAsFixed(1); // 5.1 becomes "5.1"
    }
  }
}
