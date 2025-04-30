import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:zer0_waste_ai/features/home/presentation/screens/home_screen.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/providers/navigation_provider.dart';
import 'package:zer0_waste_ai/features/navigation/presentation/screens/main_screen.dart';
import 'package:zer0_waste_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipes_screen.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/add_scan_item_screen.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/scan_confirm_screen.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/scan_results_screen.dart';
import 'package:zer0_waste_ai/features/splash/presentation/screens/splash_screen.dart';
import 'dart:io';
import 'package:zer0_waste_ai/features/profile/presentation/screens/allergy_selector_screen.dart'; // Import the new screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/cooking_level_selector_screen.dart'; // Import Cooking Level screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/preferred_food_type_screen.dart'; // Import Food Type screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/special_diet_selector_screen.dart'; // Import Special Diet screen
import 'package:zer0_waste_ai/features/inventory/presentation/screens/add_inventory_item_screen.dart';

// Global key for the ShellRoute navigator
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();
// Global key for the root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.createRouter(ref);

  // Listen to route changes and update the navigation provider
  router.routerDelegate.addListener(() {
    // Use the root navigator key context to get the current location safely
    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      // Use GoRouter.of(context).location to get the current displayed route
      final routeMatchList = router.routerDelegate.currentConfiguration.matches;
      if (routeMatchList.isNotEmpty) {
        final currentLocation = routeMatchList.last.matchedLocation;

        // Only update if the location is one of the main tab routes
        if ([
          '/home',
          '/inventory',
          '/recipes',
          '/profile',
        ].contains(currentLocation)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check if the provider's state needs updating
            if (ref.read(currentNavigationProvider) != currentLocation) {
              ref.read(currentNavigationProvider.notifier).state =
                  currentLocation;
            }
          });
        }
      }
    }
  });

  return router;
});

/// App router configuration
class AppRouter {
  /// GoRouter instance factory
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        // Add the Allergy Selector Screen route here (top-level)
        GoRoute(
          path: AllergySelectorScreen.routePath,
          name: AllergySelectorScreen.routeName,
          builder: (context, state) => const AllergySelectorScreen(),
        ),
        // Add the Cooking Level Selector Screen route here (top-level)
        GoRoute(
          path: CookingLevelSelectorScreen.routePath,
          name: CookingLevelSelectorScreen.routeName,
          builder: (context, state) => const CookingLevelSelectorScreen(),
        ),
        // Add the Preferred Food Type Screen route here (top-level)
        GoRoute(
          path: PreferredFoodTypeScreen.routePath,
          name: PreferredFoodTypeScreen.routeName,
          builder: (context, state) => const PreferredFoodTypeScreen(),
        ),
        // Add the Special Diet Selector Screen route here (top-level)
        GoRoute(
          path: SpecialDietSelectorScreen.routePath,
          name: SpecialDietSelectorScreen.routeName,
          builder: (context, state) => const SpecialDietSelectorScreen(),
        ),
        // Add the ScanConfirmScreen route here (top-level)
        GoRoute(
          path: ScanConfirmScreen.routePath,
          name: ScanConfirmScreen.routeName,
          builder: (context, state) {
            // Expect a Map in the extra field
            final extraData = state.extra as Map<String, dynamic>?;
            final List<File>? images = extraData?['images'] as List<File>?;
            final ScanItemType? originType =
                extraData?['originType'] as ScanItemType?;

            // Validate the extracted data
            if (images == null || images.isEmpty || originType == null) {
              print(
                "Error: ScanConfirmScreen missing images or originType. Redirecting.",
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Fallback to ingredient scan add screen
                RouterExtension(
                  context,
                ).goNamed('addScanItem', params: {'itemType': 'ingredient'});
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Pass both required parameters
            return ScanConfirmScreen(
              initialImages: images,
              originType: originType, // Pass originType
            );
          },
        ),
        // Add the ScanResultsScreen route
        GoRoute(
          path: ScanResultsScreen.routePath,
          name: ScanResultsScreen.routeName,
          builder: (context, state) {
            // Extract data passed from ScanConfirmScreen (or analysis step)
            final Map<String, dynamic>? extraData =
                state.extra as Map<String, dynamic>?;
            // TODO: Replace List<String> with the actual result type from analysis
            // Expecting the raw JSON list now
            final List<Map<String, dynamic>> initialJsonData =
                extraData?['recognizedItemsJson']
                    as List<Map<String, dynamic>>? ??
                [];
            final ScanItemType itemType =
                extraData?['itemType'] as ScanItemType? ??
                ScanItemType.ingredient; // Default if missing

            // Handle case where no data is passed (e.g., direct navigation attempt)
            // Consider adding a check if initialJsonData is empty if that's an invalid state
            //   print("ScanResultsScreen missing data, redirecting...");
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //      context.go('/home'); // Redirect home or to scan start
            //   });
            //   return const Scaffold(body: Center(child: CircularProgressIndicator()));

            return ScanResultsScreen(
              initialJsonData: initialJsonData,
              itemType: itemType,
            );
          },
        ),
        // Add the route for AddInventoryItemScreen (top-level for simplicity now)
        GoRoute(
          path: AddInventoryItemScreen.routePath, // '/inventory/add'
          name: AddInventoryItemScreen.routeName, // 'addInventoryItem'
          builder: (context, state) => const AddInventoryItemScreen(),
        ),
        // Routes accessible via the Bottom Navigation Bar (using ShellRoute)
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            // Update provider when ShellRoute builds (handles initial load/deep link)
            // Use state.matchedLocation for ShellRoute context
            final currentLocation = state.matchedLocation;

            if ([
              '/home',
              '/inventory',
              '/recipes',
              '/profile',
            ].contains(currentLocation)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (ref.read(currentNavigationProvider) != currentLocation) {
                  ref.read(currentNavigationProvider.notifier).state =
                      currentLocation;
                }
              });
            }
            return MainScreen(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/inventory',
              name: 'inventory',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const InventoryScreen(),
            ),
            GoRoute(
              path: '/recipes',
              name: 'recipes',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const RecipesScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const ProfileScreen(),
            ),
            // Add new routes for scanning under the ShellRoute
            GoRoute(
              path: '/scan/add/:itemType', // Use path parameter for item type
              name: 'addScanItem',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) {
                // Extract itemType from path parameters
                final itemTypeString = state.pathParameters['itemType'];
                ScanItemType itemType;
                if (itemTypeString == 'ingredient') {
                  itemType = ScanItemType.ingredient;
                } else if (itemTypeString == 'food') {
                  itemType = ScanItemType.food;
                } else {
                  // Handle invalid or missing parameter, maybe default or error
                  // For now, default to ingredient or throw an error
                  // Or redirect to a safe place, e.g., home
                  print(
                    'Invalid itemType in route: $itemTypeString, defaulting to ingredient',
                  );
                  itemType =
                      ScanItemType.ingredient; // Or handle error appropriately
                }
                return AddScanItemScreen(itemType: itemType);
              },
            ),
          ],
        ),
      ],
      errorBuilder:
          (context, state) => Scaffold(
            body: Center(
              child: Text(
                'Page not found: ${state.error}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
    );
  }
}

/// Extension to easily access the router from BuildContext
extension RouterExtension on BuildContext {
  /// Navigate to a named route
  void goNamed(String name, {Map<String, String> params = const {}}) {
    GoRouter.of(this).goNamed(name, pathParameters: params);
  }

  /// Navigate to a path
  void go(String path) {
    GoRouter.of(this).go(path);
  }

  /// Replace the current route with a named route
  void replaceNamed(String name, {Map<String, String> params = const {}}) {
    GoRouter.of(this).replaceNamed(name, pathParameters: params);
  }

  /// Replace the current route with a path
  void replace(String path) {
    GoRouter.of(this).replace(path);
  }
}
