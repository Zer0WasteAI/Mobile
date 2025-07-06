import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/core/widgets/error_handler.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/widgets/app_bottom_app_bar.dart';
import 'package:zer0_waste_ai/features/scan/presentation/widgets/scan_options_modal.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/widgets/more_options_modal.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isScanOpen = ref.watch(isScanModalOpenProvider);
    final isMoreMenuOpen = ref.watch(isMoreMenuOpenProvider);

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

    // Listen for navigation events to close modals
    ref.listen<String>(currentNavigationProvider, (previous, current) {
      // Close modals when navigating
      if (previous != current) {
        if (ref.read(isScanModalOpenProvider.notifier).state) {
          ref.read(isScanModalOpenProvider.notifier).state = false;
        }
        if (ref.read(isMoreMenuOpenProvider.notifier).state) {
          ref.read(isMoreMenuOpenProvider.notifier).state = false;
        }
      }
    });

    return Scaffold(
      bottomNavigationBar:
          isMoreMenuOpen
              ? null // Ocultar bottomNavigationBar cuando el menú está abierto
              : const AppBottomAppBar(),
      // Restore FloatingActionButton and its location
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          isMoreMenuOpen
              ? null // No mostrar el FAB cuando el menú "Más" está abierto
              : FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: fabBackgroundColor,
                onPressed: () {
                  // Close More menu if open
                  if (isMoreMenuOpen) {
                    ref.read(isMoreMenuOpenProvider.notifier).state = false;
                  }
                  // Toggle scan modal
                  ref
                      .read(isScanModalOpenProvider.notifier)
                      .update((state) => !state);
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
          // Main screen content with AnimatedSwitcher for smooth transitions
          // Wrapped with AuthErrorHandler
          AuthErrorHandler(
            child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: child,
            ),
          ),

          // Dimming barrier for scan modal
          if (isScanOpen)
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.3),
              dismissible: false,
            ),

          // Conditionally display the scan modal
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

          // Dimming barrier for more menu
          if (isMoreMenuOpen)
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.3),
              dismissible: true,
              onDismiss:
                  () => ref.read(isMoreMenuOpenProvider.notifier).state = false,
            ),

          // Conditionally display the more menu
          if (isMoreMenuOpen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MoreOptionsModal(
                onClose:
                    () =>
                        ref.read(isMoreMenuOpenProvider.notifier).state = false,
              ),
            ),
        ],
      ),
    );
  }
}
