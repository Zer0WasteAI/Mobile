import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart';

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

    return BottomAppBar(
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
          _buildNavItem(
            context,
            ref,
            FontAwesomeIcons.solidUser,
            'Perfil',
            '/profile',
            currentPath,
            navItemSelecedColor,
            navItemUnselectedColor,
            isScanFlowActive,
          ),
        ],
      ),
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
          ref.read(currentNavigationProvider.notifier).state = path;
          context.go(path);
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
}
