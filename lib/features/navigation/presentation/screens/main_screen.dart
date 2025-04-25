import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/widgets/app_bottom_app_bar.dart';
import 'package:zer0_waste_ai/features/scan/presentation/widgets/scan_options_modal.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isScanOpen = ref.watch(isScanModalOpenProvider);

    // Get current route location
    final currentRouteLocation = GoRouterState.of(context).matchedLocation;
    // Determine if we are in the scan flow (modal open OR on add screen)
    final bool isScanFlowActive =
        isScanOpen || currentRouteLocation.startsWith('/scan/add/');

    // Use AppColors for FAB Background based on scan flow state
    final Color fabBackgroundColor =
        isScanFlowActive // Use the combined flag
            ? colorScheme.primary
            : (isDark
                ? AppColors.darkFabBackground
                : AppColors.lightFabBackground);

    // Use AppColors for FAB Icon (cannot be const if AppColors is not const)
    final Color fabIconColor = AppColors.fabIcon;

    return Scaffold(
      bottomNavigationBar: const AppBottomAppBar(),
      // Restore FloatingActionButton and its location
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: fabBackgroundColor,
        onPressed: () {
          // FAB now toggles the state that controls the modal in the Stack
          ref.read(isScanModalOpenProvider.notifier).update((state) => !state);
        },
        elevation: 2.0,
        child: Image.asset(
          'assets/icons/navbar/scan.png',
          color: fabIconColor,
          width: 28,
          height: 28,
        ),
      ),
      // Keep Stack in body for ModalBarrier and positioned ScanOptionsModal
      body: Stack(
        children: [
          // Main screen content
          child,

          // Dimming barrier
          if (isScanOpen)
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.3),
              dismissible: false,
            ),

          // Conditionally display the modal (positioned relative to bottom)
          if (isScanOpen)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ScanOptionsModal(
                  onClose:
                      () =>
                          ref.read(isScanModalOpenProvider.notifier).state =
                              false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
