import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/storage_filter_bottom_sheet.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/expiration_filter_bottom_sheet.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFilterSectionVisible = false; // State to control filter visibility
  late TabController _tabController; // Declare TabController

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(inventoryProvider.notifier)
          .setSearchQuery(_searchController.text);
    });

    // Initialize TabController
    final initialFilterStatus =
        ref.read(inventoryProvider).expirationStatusFilter;
    final initialTabIndex = ExpirationStatus.values.indexOf(
      initialFilterStatus,
    );
    _tabController = TabController(
      length: ExpirationStatus.values.length,
      vsync: this,
      initialIndex:
          initialTabIndex >= 0 ? initialTabIndex : 0, // Handle potential issues
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final selectedStatus = ExpirationStatus.values[_tabController.index];
        ref
            .read(inventoryProvider.notifier)
            .setExpirationStatusFilter(selectedStatus);
      }
    });

    // Clear highlights when entering the screen initially unless triggered by navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We check if recentlyAddedIds is already populated (e.g., from navigation)
      // If it is, the highlight process is already scheduled.
      // If not, ensure it's empty (covers cases like returning via back button).
      if (ref.read(inventoryProvider).recentlyAddedIds.isEmpty) {
        ref.read(inventoryProvider.notifier).clearHighlightsImmediately();
      }
      // Optional: Scroll to first highlighted item - implementation needed if required
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  void _showStorageFilterBottomSheet() {
    final inventoryState = ref.read(inventoryProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take up more height
      backgroundColor: Colors.transparent,
      builder:
          (context) => StorageFilterBottomSheet(
            initialSelectedTypes: inventoryState.storageFilter,
            onApply: (selectedTypes) {
              ref
                  .read(inventoryProvider.notifier)
                  .setStorageFilter(selectedTypes);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final filteredItems = ref.watch(filteredSortedInventoryProvider);
    final recentlyAddedIds = inventoryState.recentlyAddedIds;
    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Define colors from spec
    const Color primaryColor = Color(0xFF00B894);
    const Color secondaryColor = Color(0xFFF07548);
    const Color mainTextColor = Color(0xFF3A3A3A);
    const Color secondaryTextColor = Color(0xFF70605A);
    const Color formBackgroundColor = Color(0xFFEDF2F4);
    const Color screenBackgroundColor = Color(0xFFFAF9F6); // General Background
    const Color chipSelectedColor = primaryColor;
    final Color chipUnselectedColor = Colors.grey.shade200;
    final Color chipSelectedTextColor = Colors.white;
    final Color chipUnselectedTextColor = secondaryTextColor;
    final Color cardBackgroundColor = Colors.white;
    final Color chipUnselectedBorderColor = Colors.grey.shade300;

    final labelStyle = GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: mainTextColor,
      fontSize: 14,
    );

    final chipTextStyle = GoogleFonts.inter(
      color: secondaryTextColor,
      fontSize: 13,
    );

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Inventario',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            // Use headlineLarge style if available, otherwise adjust size
            fontSize: textTheme.headlineSmall?.fontSize ?? 24,
            color: mainTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: mainTextColor,
        ), // For potential leading icon
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar with Shadow
                Container(
                  decoration: BoxDecoration(
                    color: cardBackgroundColor, // White background for shadow
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
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
                      prefixIcon: const Icon(
                        Icons.search,
                        color: secondaryTextColor,
                      ),
                      filled: true,
                      fillColor: Colors.transparent, // Handled by container
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
                  ),
                ),
                const SizedBox(height: 12.0),

                // Filter Toggle Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: Icon(
                      _isFilterSectionVisible
                          ? Icons.filter_list_off_outlined
                          : Icons.filter_list_outlined,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                    label: Text(
                      _isFilterSectionVisible
                          ? 'Ocultar Filtros'
                          : 'Mostrar Filtros',
                      style: GoogleFonts.inter(
                        color: secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isFilterSectionVisible = !_isFilterSectionVisible;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      // minimumSize: Size.zero, // Keep compact
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),

                // --- Animated Filter Section ---
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _isFilterSectionVisible,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Tipo Filter Block
                        Text('Tipo:', style: labelStyle),
                        const SizedBox(height: 10.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 8.0,
                            children: [
                              ChoiceChip(
                                avatar: Icon(
                                  ItemCategory.food.icon,
                                  size: 18,
                                  color:
                                      inventoryState.categoryFilter ==
                                              ItemCategory.food
                                          ? Colors.white
                                          : secondaryTextColor,
                                ),
                                label: Text(
                                  ItemCategory.food.displayName,
                                  style: chipTextStyle,
                                ),
                                selected:
                                    inventoryState.categoryFilter ==
                                    ItemCategory.food,
                                onSelected:
                                    (_) => inventoryNotifier.setCategoryFilter(
                                      ItemCategory.food,
                                    ),
                                selectedColor: primaryColor,
                                backgroundColor: Colors.white,
                                labelStyle: chipTextStyle.copyWith(
                                  color:
                                      inventoryState.categoryFilter ==
                                              ItemCategory.food
                                          ? Colors.white
                                          : secondaryTextColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                  side: BorderSide(
                                    color:
                                        inventoryState.categoryFilter ==
                                                ItemCategory.food
                                            ? primaryColor
                                            : chipUnselectedBorderColor,
                                    width: 1,
                                  ),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                pressElevation: 0,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                showCheckmark: false,
                              ),
                              ChoiceChip(
                                avatar: Icon(
                                  ItemCategory.ingredient.icon,
                                  size: 18,
                                  color:
                                      inventoryState.categoryFilter ==
                                              ItemCategory.ingredient
                                          ? Colors.white
                                          : secondaryTextColor,
                                ),
                                label: Text(
                                  ItemCategory.ingredient.displayName,
                                  style: chipTextStyle,
                                ),
                                selected:
                                    inventoryState.categoryFilter ==
                                    ItemCategory.ingredient,
                                onSelected:
                                    (_) => inventoryNotifier.setCategoryFilter(
                                      ItemCategory.ingredient,
                                    ),
                                selectedColor: primaryColor,
                                backgroundColor: Colors.white,
                                labelStyle: chipTextStyle.copyWith(
                                  color:
                                      inventoryState.categoryFilter ==
                                              ItemCategory.ingredient
                                          ? Colors.white
                                          : secondaryTextColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                  side: BorderSide(
                                    color:
                                        inventoryState.categoryFilter ==
                                                ItemCategory.ingredient
                                            ? primaryColor
                                            : chipUnselectedBorderColor,
                                    width: 1,
                                  ),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                pressElevation: 0,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                showCheckmark: false,
                              ),
                              ChoiceChip(
                                label: Text(
                                  ItemCategory.all.displayName,
                                  style: chipTextStyle,
                                ),
                                selected:
                                    inventoryState.categoryFilter ==
                                    ItemCategory.all,
                                onSelected:
                                    (_) => inventoryNotifier.setCategoryFilter(
                                      ItemCategory.all,
                                    ),
                                selectedColor: primaryColor,
                                backgroundColor: Colors.white,
                                labelStyle: chipTextStyle.copyWith(
                                  color:
                                      inventoryState.categoryFilter ==
                                              ItemCategory.all
                                          ? Colors.white
                                          : secondaryTextColor,
                                  fontWeight:
                                      inventoryState.categoryFilter ==
                                              ItemCategory.all
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                  side: BorderSide(
                                    color:
                                        inventoryState.categoryFilter ==
                                                ItemCategory.all
                                            ? primaryColor
                                            : chipUnselectedBorderColor,
                                    width: 1,
                                  ),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                pressElevation: 0,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                showCheckmark: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        // 2. Filtrar por Block
                        Text('Filtrar por:', style: labelStyle),
                        const SizedBox(height: 10.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            // Storage Filter Button (Existing InkWell)
                            InkWell(
                              onTap: _showStorageFilterBottomSheet,
                              borderRadius: BorderRadius.circular(24.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(
                                    color: chipUnselectedBorderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min, // Make button width fit content
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 18,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      inventoryState.storageFilter.isEmpty
                                          ? 'Almacenamiento'
                                          : 'Almacenamiento (${inventoryState.storageFilter.length})',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      size: 20,
                                      color: secondaryTextColor,
                                    ), // Changed chevron to dropdown arrow
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20.0),

                        // 3. Ordenar por Block
                        Text('Ordenar por:', style: labelStyle),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            // Sort Criteria Button (Container wrapping Dropdown)
                            Container(
                              padding: const EdgeInsets.only(right: 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: chipUnselectedBorderColor,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<InventorySortCriteria>(
                                  value: inventoryState.sortCriteria,
                                  icon: const SizedBox.shrink(),
                                  style: GoogleFonts.inter(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                  items:
                                      InventorySortCriteria.values.map((
                                        criteria,
                                      ) {
                                        return DropdownMenuItem(
                                          value: criteria,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 10.0,
                                            ),
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
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      inventoryNotifier.setSortCriteria(value);
                                    }
                                  },
                                  selectedItemBuilder: (BuildContext context) {
                                    return InventorySortCriteria.values.map((
                                      criteria,
                                    ) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 10.0,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              inventoryState.sortCriteria.icon,
                                              size: 18,
                                              color: secondaryTextColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              inventoryState
                                                  .sortCriteria
                                                  .displayName,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  },
                                  focusColor: Colors.transparent,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Sort Direction Button
                            IconButton(
                              icon: Icon(
                                inventoryState.sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 22,
                                color: secondaryTextColor,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip:
                                  inventoryState.sortAscending
                                      ? 'Ascendente'
                                      : 'Descendente',
                              onPressed: inventoryNotifier.toggleSortDirection,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                      ], // End children of inner Column
                    ), // End inner Column
                  ), // End Visibility
                ), // End AnimatedSize
                // --- Inventory Summary ---
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final totalCount = ref.watch(totalItemCountProvider);
                      final expiringSoonCount = ref.watch(
                        expiringSoonCountProvider,
                      );
                      final expiredCount = ref.watch(expiredCountProvider);
                      final bool isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      // Choose warning TEXT color based on theme
                      final Color warningTextColor =
                          isDark
                              ? AppColors.warningTextDark
                              : AppColors.warningTextLight;
                      // Use original warning color for less prominent parts if needed (e.g., opacity)
                      final Color baseWarningColor = AppColors.warning;

                      if (totalCount == 0) return const SizedBox.shrink();

                      // Use Column for vertical arrangement
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align text left
                        children: [
                          // 1. Expiring Soon Message
                          if (expiringSoonCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4.0,
                              ), // Add spacing below
                              child: RichText(
                                text: TextSpan(
                                  style: textTheme.labelMedium?.copyWith(
                                    color: warningTextColor.withOpacity(0.9),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$expiringSoonCount',
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: warningTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            textTheme.labelMedium?.fontSize ??
                                            12,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' productos próximos a vencer',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // 2. Expired Message
                          if (expiredCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4.0,
                              ), // Add spacing below
                              child: RichText(
                                text: TextSpan(
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.error.withOpacity(0.9),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '$expiredCount',
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            textTheme.labelMedium?.fontSize ??
                                            12,
                                      ),
                                    ),
                                    const TextSpan(text: ' productos vencidos'),
                                  ],
                                ),
                              ),
                            ),
                          // 3. Total Count Message
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4.0,
                            ), // Add spacing below
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.labelMedium?.copyWith(
                                  color: secondaryTextColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$totalCount',
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: mainTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          textTheme.labelMedium?.fontSize ?? 12,
                                    ),
                                  ),
                                  const TextSpan(text: ' ítems registrados'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // --- TabBar for Expiration Status ---
          Container(
            color:
                screenBackgroundColor, // Match background, or use a slight contrast
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ), // Optional padding
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: primaryColor,
              unselectedLabelColor: secondaryTextColor,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: primaryColor, width: 3.0),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          ),
          // Inventory List Section
          Expanded(
            child:
                inventoryState.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                    : filteredItems.isEmpty
                    ? Center(
                      child: Text(
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
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final bool isHighlighted = recentlyAddedIds.contains(
                          item.id,
                        );

                        return Dismissible(
                          key: ValueKey(item.id), // Unique key for Dismissible
                          direction:
                              DismissDirection
                                  .endToStart, // Swipe left to delete
                          onDismissed: (direction) {
                            inventoryNotifier.removeItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} eliminado'),
                                backgroundColor: AppColors.error,
                                action: SnackBarAction(
                                  label:
                                      'DESHACER', // Optional: Undo functionality
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // TODO: Implement undo logic if needed
                                    // inventoryNotifier.addItem(item); // Need original item data
                                  },
                                ),
                              ),
                            );
                          },
                          background: Container(
                            color: AppColors.error.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          child: InventoryItemCard(
                            item: item,
                            isHighlighted: isHighlighted,
                          ),
                        );
                      },
                    ),
          ),
          // Add Manually Button
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
            color: screenBackgroundColor, // Ensure button is above list
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Agregar manualmente'),
              onPressed: () {
                print('Navigate to manual add item screen');
                // TODO: context.push('/inventory/add');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0), // Pill shape
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16, // labelLarge
                  fontWeight: FontWeight.w600, // semibold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
