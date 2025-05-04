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
import 'package:zer0_waste_ai/features/inventory/presentation/widgets/inventory_filter_bottom_sheet.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/screens/add_inventory_item_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zer0_waste_ai/core/utils/date_extensions.dart'; // Import for date formatting extension

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSummaryExpanded = false; // State to control summary visibility
  late TabController _tabController; // Declare TabController

  // Define route name for AddInventoryItemScreen
  static const String addInventoryItemRouteName = 'addInventoryItem';

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

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final filteredItems = ref.watch(filteredSortedInventoryProvider);
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
        inventoryNotifier.setExpirationStatusFilter(selectedStatus);
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor),
      ),
      body: CustomScrollView(
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
                                  ? Colors.black.withOpacity(0.25)
                                  : Colors.grey.withOpacity(0.15),
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
                        hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                      ),
                      style: GoogleFonts.inter(color: mainTextColor),
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
                                Theme.of(context).brightness == Brightness.dark;
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
                                      _isSummaryExpanded = !_isSummaryExpanded;
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
                            'Filtros',
                            style: GoogleFonts.inter(color: primaryColor),
                          ),
                          onPressed: () {
                            final currentFilters = ref.read(inventoryProvider);
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
                                      final notifier = ref.read(
                                        inventoryProvider.notifier,
                                      );
                                      notifier.setCategoryFilter(category);
                                      notifier.setStorageFilter(storageTypes);
                                      notifier.setSortCriteria(sortCriteria);
                                      notifier.setSortDirection(sortAscending);
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
                      if (!_isSummaryExpanded || totalCount == 0)
                        return const SizedBox.shrink();
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
                                      color: warningTextColor.withOpacity(0.9),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '$expiringSoonCount',
                                        style: textTheme.labelMedium?.copyWith(
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
                                      color: errorColor.withOpacity(0.9),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.restaurant_menu_outlined,
                        size: 20,
                      ),
                      label: const Text('Generar receta'),
                      onPressed: () {
                        print('Navigate to recipe generation');
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
                        shadowColor: Colors.grey.withOpacity(0.2),
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
                  child: Text(
                    inventoryState.searchQuery.isNotEmpty ||
                            inventoryState.categoryFilter != ItemCategory.all ||
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

                  final bool isHighlighted = recentlyAddedIds.contains(item.id);
                  final bool isIngredient =
                      item.category == ItemCategory.ingredient;
                  final bool isFood = item.category == ItemCategory.food;

                  return Slidable(
                    key: ValueKey(item.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed:
                              (context) => _showDeleteConfirmationDialog(
                                context,
                                item,
                                inventoryNotifier,
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
                            pathParameters: {'itemId': item.id},
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
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.pushNamed(addInventoryItemRouteName),
        backgroundColor: fabBackgroundColor,
        tooltip: 'Añadir Ítem',
        child: Icon(Icons.add, color: fabIconColor),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    InventoryItem item,
    InventoryNotifier notifier,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de eliminar "${item.name}"?'),
                const SizedBox(height: 8),
                const Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Eliminar'),
              onPressed: () {
                notifier.removeItem(item.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${item.name}" eliminado'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
  final TextEditingController quantityController = TextEditingController(
    text: _formatQuantityForEditing(
      item.quantity,
      item.unitType,
    ), // Use formatter for initial text
  );
  final inventoryNotifier = ref.read(inventoryProvider.notifier);
  final formKey = GlobalKey<FormState>(); // For validation

  // Theme-aware colors
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final Color primaryColor =
      isDark ? AppColors.darkPrimary : const Color(0xFF00B894);
  final Color backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
  final Color textColor =
      isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
  final Color secondaryTextColor =
      isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);
  final Color inputFillColor =
      isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5);

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      // Use a local stateful builder to update +/- buttons reflected in text field immediately
      // This avoids needing to listen to the main provider just for the dialog
      String currentTextValue = quantityController.text;
      return StatefulBuilder(
        builder: (stfContext, stfSetState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            elevation: 8,
            backgroundColor: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with emoji and title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          item.image.isNotEmpty ? item.image : '🍲',
                          style: const TextStyle(fontSize: 42),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Editar Cantidad',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),

                  // Quantity Form
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Ingresa la nueva cantidad',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: secondaryTextColor,
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
                              color: primaryColor.withOpacity(0.2),
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
                                        double.tryParse(
                                          quantityController.text,
                                        ) ??
                                        item.quantity;
                                    final step = inventoryNotifier
                                        .getQuantityStep(item.unitType);
                                    final min = inventoryNotifier
                                        .getMinimumQuantity(item.unitType);
                                    final newVal =
                                        ((currentVal * 10 - step * 10).round() /
                                                10.0)
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
                                      color: primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),

                              // Vertical divider
                              Container(
                                height: 30,
                                width: 1,
                                color: primaryColor.withOpacity(0.2),
                              ),

                              // Text field
                              Expanded(
                                child: TextFormField(
                                  controller: quantityController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  autofocus: true,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                    suffix: Text(
                                      item.unitType,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: secondaryTextColor,
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
                                    final double? enteredQuantity =
                                        double.tryParse(value);
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
                                color: primaryColor.withOpacity(0.2),
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
                                        double.tryParse(
                                          quantityController.text,
                                        ) ??
                                        item.quantity;
                                    final step = inventoryNotifier
                                        .getQuantityStep(item.unitType);
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
                                      color: primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Error message container
                        Container(
                          height: 20,
                          margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: FormField<String>(
                            validator: (_) {
                              if (formKey.currentState?.validate() == false) {
                                // This doesn't actually validate, just makes space for the real validator
                                return 'Error';
                              }
                              return null;
                            },
                            builder: (state) {
                              return state.hasError
                                  ? Text(
                                    state.errorText!,
                                    style: GoogleFonts.inter(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons with gradient primary button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel button
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

                        // Save button
                        InkWell(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              final double? newQuantity = double.tryParse(
                                quantityController.text,
                              );
                              if (newQuantity != null) {
                                inventoryNotifier.setQuantity(
                                  item.id,
                                  newQuantity,
                                );
                                Navigator.of(dialogContext).pop();
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.9),
                                  primaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Guardar',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                        color: primaryColor.withOpacity(0.3),
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
                                inventoryNotifier.setUserSelectedBatch(
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
                                        ? primaryColor.withOpacity(0.1)
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
                                            color: primaryColor.withOpacity(
                                              0.1,
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
                                              : statusColor.withOpacity(0.6),
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
