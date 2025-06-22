import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/widgets/more_options_modal.dart';

class AppBottomAppBar extends ConsumerWidget {
  const AppBottomAppBar({super.key});

  // Define the asset path for the scan icon
  static const String scanIconPath = 'assets/icons/navbar/scan.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPath = ref.watch(currentNavigationProvider);
    final isScanModalOpen = ref.watch(isScanModalOpenProvider);
    final isMoreMenuOpen = ref.watch(isMoreMenuOpenProvider);

    // Get current route location to check for scan flow routes
    final currentRouteLocation = GoRouterState.of(context).matchedLocation;
    // Determine if we are in the scan flow (modal open OR on add screen)
    final bool isScanFlowActive =
        isScanModalOpen || currentRouteLocation.startsWith('/scan/add/');

    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color defaultBottomNavBg =
        isDark
            ? AppColors.darkBottomNavBackground
            : AppColors.lightBottomNavBackground;
    final Color defaultUnselectedColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    // Colors for items should NOT depend on isScanOpen
    final Color currentBackgroundColor =
        defaultBottomNavBg; // Background is fixed
    final Color navItemSelecedColor =
        primaryColor; // Selected is always primary
    final Color navItemUnselectedColor =
        defaultUnselectedColor; // Unselected is always default

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom App Bar
        BottomAppBar(
          color: currentBackgroundColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                context,
                ref,
                FontAwesomeIcons.house,
                'Inicio',
                '/home',
                currentPath,
                navItemSelecedColor,
                navItemUnselectedColor,
                isScanFlowActive,
              ),
              _buildNavItem(
                context,
                ref,
                'assets/icons/navbar/inventory.png',
                'Inventario',
                '/inventory',
                currentPath,
                navItemSelecedColor,
                navItemUnselectedColor,
                isScanFlowActive,
              ),
              _buildScanItem(
                context,
                ref,
                'assets/icons/navbar/scan.png',
                'Escanear',
                isScanFlowActive,
                navItemSelecedColor,
                navItemUnselectedColor,
              ),
              _buildNavItem(
                context,
                ref,
                'assets/icons/navbar/recipes.png',
                'Recetas',
                '/recipes',
                currentPath,
                navItemSelecedColor,
                navItemUnselectedColor,
                isScanFlowActive,
              ),
              _buildMoreNavItem(
                context,
                ref,
                FontAwesomeIcons.ellipsis,
                'Más',
                isMoreMenuOpen,
                navItemSelecedColor,
                navItemUnselectedColor,
              ),
            ],
          ),
        ),

        // "Más" Options Modal
        if (isMoreMenuOpen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MoreOptionsModal(
              onClose:
                  () => ref.read(isMoreMenuOpenProvider.notifier).state = false,
            ),
          ),
      ],
    );
  }

  Widget _buildScanItem(
    BuildContext context,
    WidgetRef ref,
    Object icon,
    String label,
    bool isScanFlowActive,
    Color selectedColor,
    Color defaultUnselectedColor,
  ) {
    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.bodySmall ?? const TextStyle(fontSize: 10);
    const double iconSize = 24;
    final iconWidget = Icon(
      Icons.circle,
      color: Colors.transparent,
      size: iconSize,
    );
    final labelColor =
        isScanFlowActive ? selectedColor : defaultUnselectedColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              iconWidget,
              Text(
                label,
                style: textStyle.copyWith(
                  color: labelColor,
                  fontWeight:
                      isScanFlowActive ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    Object icon,
    String label,
    String path,
    String currentPath,
    Color selectedColor,
    Color unselectedColor,
    bool isScanFlowActive,
  ) {
    final bool isSelected = !isScanFlowActive && currentPath == path;
    final Color color = isSelected ? selectedColor : unselectedColor;
    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.bodySmall ?? const TextStyle(fontSize: 10);
    const double iconSize = 24;

    Widget iconWidget;

    if (icon is IconData) {
      iconWidget = Icon(icon, color: color, size: iconSize);
    } else if (icon is String) {
      iconWidget = Image.asset(
        icon,
        color: color,
        width: iconSize,
        height: iconSize,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error_outline, color: color, size: iconSize);
        },
      );
    } else {
      iconWidget = Icon(Icons.help_outline, color: color, size: iconSize);
    }

    final labelColor = color;

    return Expanded(
      child: InkWell(
        onTap: () {
          print('🏠 Navigation button tapped: $label -> $path');
          print('📍 Current path: $currentPath');
          print('🔄 Scan flow active: $isScanFlowActive');

          // Always navigate to ensure we get out of any scan flow
          ref.read(currentNavigationProvider.notifier).state = path;
          context.go(path);

          // Close any open modals
          if (ref.read(isScanModalOpenProvider)) {
            ref.read(isScanModalOpenProvider.notifier).state = false;
          }
          if (ref.read(isMoreMenuOpenProvider)) {
            ref.read(isMoreMenuOpenProvider.notifier).state = false;
          }

          print('✅ Navigation completed to: $path');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              iconWidget,
              Text(
                label,
                style: textStyle.copyWith(
                  color: labelColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreNavItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    bool isMoreMenuOpen,
    Color selectedColor,
    Color defaultUnselectedColor,
  ) {
    final Color color = isMoreMenuOpen ? selectedColor : defaultUnselectedColor;
    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.bodySmall ?? const TextStyle(fontSize: 10);
    const double iconSize = 24;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(isMoreMenuOpenProvider.notifier).state = !isMoreMenuOpen;
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: iconSize),
              Text(
                label,
                style: textStyle.copyWith(
                  color: color,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
