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
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipe_screen.dart';
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
import 'package:zer0_waste_ai/features/inventory/presentation/screens/ingredient_detail_screen.dart'; // Import the new screen
import 'package:zer0_waste_ai/features/inventory/presentation/screens/food_detail_screen.dart'; // Import FoodDetailScreen
import 'package:zer0_waste_ai/features/recipes/domain/enums/recipe_mode.dart'; // Import RecipeMode
import 'package:zer0_waste_ai/features/recipes/presentation/screens/ai_recipe_generation_screen.dart'; // Import AIRecipeGenerationScreen

// Global key for the ShellRoute navigator
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();
// Global key for the root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Define route names (add one for smart recipes)
const String splashRouteName = 'splash';
const String onboardingRouteName = 'onboarding';
const String loginRouteName = 'login';
const String registerRouteName = 'register';
const String forgotPasswordRouteName = 'forgot-password';
const String homeRouteName = 'home';
const String inventoryRouteName = 'inventory';
const String recipesRouteName = 'recipes'; // For explore mode via bottom nav
const String smartRecipesRouteName = 'smart-recipes'; // For generation flow
const String profileRouteName = 'profile';
const String addInventoryItemRouteName = AddInventoryItemScreen.routeName;
const String ingredientDetailRouteName = 'ingredientDetail';
const String foodDetailRouteName = 'foodDetail';
const String addScanItemRouteName = 'addScanItem';
const String scanConfirmRouteName = ScanConfirmScreen.routeName;
const String scanResultsRouteName = ScanResultsScreen.routeName;
const String allergySelectorRouteName = AllergySelectorScreen.routeName;
const String cookingLevelSelectorRouteName =
    CookingLevelSelectorScreen.routeName;
const String preferredFoodTypeRouteName = PreferredFoodTypeScreen.routeName;
const String specialDietSelectorRouteName = SpecialDietSelectorScreen.routeName;
const String aiRecipeGenerationRouteName = 'AIRecipeGenerationScreen';

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
    // Create the HeroController
    final heroController = HeroController();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      // Add the observer here
      observers: [heroController],
      routes: [
        GoRoute(
          path: '/splash',
          name: splashRouteName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: onboardingRouteName,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: loginRouteName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: registerRouteName,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: forgotPasswordRouteName,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        // Add the Allergy Selector Screen route here (top-level)
        GoRoute(
          path: AllergySelectorScreen.routePath,
          name: allergySelectorRouteName,
          builder: (context, state) => const AllergySelectorScreen(),
        ),
        // Add the Cooking Level Selector Screen route here (top-level)
        GoRoute(
          path: CookingLevelSelectorScreen.routePath,
          name: cookingLevelSelectorRouteName,
          builder: (context, state) => const CookingLevelSelectorScreen(),
        ),
        // Add the Preferred Food Type Screen route here (top-level)
        GoRoute(
          path: PreferredFoodTypeScreen.routePath,
          name: preferredFoodTypeRouteName,
          builder: (context, state) => const PreferredFoodTypeScreen(),
        ),
        // Add the Special Diet Selector Screen route here (top-level)
        GoRoute(
          path: SpecialDietSelectorScreen.routePath,
          name: specialDietSelectorRouteName,
          builder: (context, state) => const SpecialDietSelectorScreen(),
        ),
        // Add the ScanConfirmScreen route here (top-level)
        GoRoute(
          path: ScanConfirmScreen.routePath,
          name: scanConfirmRouteName,
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
          name: scanResultsRouteName,
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

            return ScanResultsScreen(
              initialJsonData: initialJsonData,
              itemType: itemType,
            );
          },
        ),
        // Add the route for AddInventoryItemScreen (top-level for simplicity now)
        GoRoute(
          path: AddInventoryItemScreen.routePath, // '/inventory/add'
          name: addInventoryItemRouteName,
          builder: (context, state) => const AddInventoryItemScreen(),
        ),
        // Route for Ingredient Detail Screen
        GoRoute(
          path: '/inventory/ingredient/:itemId', // Define path with parameter
          name: ingredientDetailRouteName,
          builder: (context, state) {
            final itemId = state.pathParameters['itemId'];
            if (itemId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).go('/inventory');
              });
              return const Scaffold(
                body: Center(child: Text('Item ID missing')),
              );
            }
            return IngredientDetailScreen(itemId: itemId);
          },
        ),
        // Route for Food Detail Screen
        GoRoute(
          path: '/inventory/food/:itemId', // Define path with parameter
          name: foodDetailRouteName,
          builder: (context, state) {
            final itemId = state.pathParameters['itemId'];
            if (itemId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).go('/inventory');
              });
              return const Scaffold(
                body: Center(child: Text('Item ID missing')),
              );
            }
            return FoodDetailScreen(itemId: itemId);
          },
        ),
        // Route for AI Recipe Generation Screen
        GoRoute(
          path: '/recipes/ai-generation',
          name: aiRecipeGenerationRouteName,
          builder: (context, state) => const AIRecipeGenerationScreen(),
        ),
        // --- Route for Smart Recipe Generation (No Bottom Bar) ---
        GoRoute(
          path: '/smart-recipes',
          name: smartRecipesRouteName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          pageBuilder: (context, state) {
            // Expect smart mode, default is handled by the screen if needed but shouldn't happen here
            final mode =
                state.extra is RecipeMode &&
                        state.extra == RecipeMode.smartFromInventory
                    ? RecipeMode.smartFromInventory
                    : RecipeMode
                        .smartFromInventory; // Assume smart if launched via this route

            return CustomTransitionPage(
              key: state.pageKey,
              child: RecipeScreen(mode: mode),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          },
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
              name: homeRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/inventory',
              name: inventoryRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const InventoryScreen(),
            ),
            GoRoute(
              path: '/recipes',
              name: recipesRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              // This route (from bottom nav) always goes to explore mode
              builder:
                  (context, state) => RecipeScreen(
                    mode: RecipeMode.explore,
                  ), // Use correct screen and mode
            ),
            GoRoute(
              path: '/profile',
              name: profileRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              builder: (context, state) => const ProfileScreen(),
            ),
            // Add new routes for scanning under the ShellRoute
            GoRoute(
              path: '/scan/add/:itemType', // Use path parameter for item type
              name: addScanItemRouteName,
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
