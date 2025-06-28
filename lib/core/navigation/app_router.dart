import 'dart:developer';

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
import 'package:zer0_waste_ai/features/recognition/presentation/screens/simplified_recognition_screen.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/screens/simplified_food_recognition_screen.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/screens/recognition_type_selector_screen.dart';
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
import 'package:zer0_waste_ai/features/recipes/presentation/screens/all_recipes_screen.dart'; // Import AllRecipesScreen
import 'package:zer0_waste_ai/features/impact/presentation/screens/impact_screen.dart'; // Import ImpactScreen
import 'package:zer0_waste_ai/features/planner/presentation/screens/planner_screen.dart'; // Import PlannerScreen
import 'package:zer0_waste_ai/features/planner/presentation/screens/meal_planning_screen.dart'; // Import MealPlanningScreen
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipe_detail_screen.dart'; // Import RecipeDetailScreen
// Profile-specific selector screens removed - now using unified screens with context parameter
import 'package:zer0_waste_ai/features/profile/presentation/screens/notifications_screen.dart'; // Import notifications screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/language_screen.dart'; // Import language screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/units_screen.dart'; // Import units screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/faqs_screen.dart'; // Import FAQs screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/privacy_policy_screen.dart'; // Import PrivacyPolicyScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/terms_and_conditions_screen.dart'; // Import TermsAndConditionsScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/about_app_screen.dart'; // Import AboutAppScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/support_screen.dart'; // Import SupportScreen
import 'package:zer0_waste_ai/features/recipes/presentation/screens/my_recipes_screen.dart'; // Import MyRecipesScreen
import 'package:zer0_waste_ai/features/recipes/presentation/screens/custom_recipe_generation_screen.dart'; // Import CustomRecipeGenerationScreen
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';

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
const String impactRouteName = 'impact'; // For impact panel
const String plannerRouteName = 'planner'; // For weekly planner
const String addInventoryItemRouteName = AddInventoryItemScreen.routeName;
const String ingredientDetailRouteName = 'ingredientDetail';
const String foodDetailRouteName = 'foodDetail';
const String addScanItemRouteName = 'addScanItem';
const String scanConfirmRouteName = ScanConfirmScreen.routeName;
const String scanResultsRouteName = 'scan_results';
const String allergySelectorRouteName = AllergySelectorScreen.routeName;
const String cookingLevelSelectorRouteName =
    CookingLevelSelectorScreen.routeName;
const String preferredFoodTypeRouteName = PreferredFoodTypeScreen.routeName;
const String specialDietSelectorRouteName = SpecialDietSelectorScreen.routeName;
const String aiRecipeGenerationRouteName = 'AIRecipeGenerationScreen';
const String allRecipesRouteName = AllRecipesScreen.routeName;

// Profile-specific selector route names removed - now using unified screens
const String notificationsRouteName = NotificationsScreen.routeName;
const String languageRouteName = LanguageScreen.routeName;
const String unitsRouteName = UnitsScreen.routeName;
const String faqsRouteName = FAQsScreen.routeName;
const String privacyPolicyRouteName = PrivacyPolicyScreen.routeName;
const String termsAndConditionsRouteName = TermsAndConditionsScreen.routeName;
const String aboutAppRouteName = AboutAppScreen.routeName;
const String supportRouteName = SupportScreen.routeName;

/// App router configuration
class AppRouter {
  /// GoRouter instance factory
  static GoRouter createRouter(Ref ref) {
    // Create the HeroController
    final heroController = HeroController();

    // Watch auth state for redirect logic
    final authState = ref.watch(authStateProvider);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      // Add the observer here
      observers: [heroController],
      redirect: (context, state) {
        final isLoggedIn = authState.value != null;
        final user = authState.value;

        // Get user profile state to check preferences completion
        final userProfileState = ref.watch(userProfileProvider);
        final hasCompletedPreferences =
            userProfileState.user?.initialPreferencesCompleted ?? false;

        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToForgotPassword =
            state.matchedLocation == '/forgot-password';
        final isGoingToOnboarding = state.matchedLocation == '/onboarding';
        final isGoingToSplash = state.matchedLocation == '/splash';
        final isGoingToAuthFlow =
            state.matchedLocation.startsWith('/allergy-selector') ||
            state.matchedLocation.startsWith('/cooking-level-selector') ||
            state.matchedLocation.startsWith('/preferred-food-type') ||
            state.matchedLocation.startsWith('/special-diet-selector');

        log(
          '🔄 Router redirect - isLoggedIn: $isLoggedIn, hasCompletedPreferences: $hasCompletedPreferences, location: ${state.matchedLocation}',
        );

        // If not logged in and not going to auth/onboarding screens, redirect to login
        if (!isLoggedIn &&
            !isGoingToLogin &&
            !isGoingToRegister &&
            !isGoingToForgotPassword &&
            !isGoingToOnboarding &&
            !isGoingToSplash &&
            !isGoingToAuthFlow) {
          log('🔄 Redirecting to login - user not authenticated');
          return '/login';
        }

        // If logged in, check preferences completion
        if (isLoggedIn && user != null) {
          // If user has completed preferences but trying to go to auth/onboarding screens, redirect to home
          if (hasCompletedPreferences &&
              (isGoingToLogin ||
                  isGoingToRegister ||
                  isGoingToForgotPassword ||
                  isGoingToOnboarding ||
                  isGoingToSplash ||
                  isGoingToAuthFlow)) {
            log('🔄 Redirecting to home - user has completed preferences');
            return '/home';
          }

          // If user has NOT completed preferences and trying to go to protected screens, redirect to onboarding
          if (!hasCompletedPreferences &&
              !isGoingToAuthFlow &&
              !isGoingToSplash &&
              state.matchedLocation != '/allergy-selector') {
            log(
              '🔄 Redirecting to onboarding - user needs to complete preferences',
            );
            return '/allergy-selector';
          }
        }

        return null; // No redirect needed
      },
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
          builder: (context, state) {
            // Check if coming from profile via query parameter
            final fromProfile = state.uri.queryParameters['from'] == 'profile';
            return AllergySelectorScreen(fromProfile: fromProfile);
          },
        ),
        // Add the Cooking Level Selector Screen route here (top-level)
        GoRoute(
          path: CookingLevelSelectorScreen.routePath,
          name: cookingLevelSelectorRouteName,
          builder: (context, state) {
            // Check if coming from profile via query parameter
            final fromProfile = state.uri.queryParameters['from'] == 'profile';
            return CookingLevelSelectorScreen(fromProfile: fromProfile);
          },
        ),
        // Add the Preferred Food Type Screen route here (top-level)
        GoRoute(
          path: PreferredFoodTypeScreen.routePath,
          name: preferredFoodTypeRouteName,
          builder: (context, state) {
            // Check if coming from profile via query parameter
            final fromProfile = state.uri.queryParameters['from'] == 'profile';
            return PreferredFoodTypeScreen(fromProfile: fromProfile);
          },
        ),
        // Add the Special Diet Selector Screen route here (top-level)
        GoRoute(
          path: SpecialDietSelectorScreen.routePath,
          name: specialDietSelectorRouteName,
          builder: (context, state) {
            // Check if coming from profile via query parameter
            final fromProfile = state.uri.queryParameters['from'] == 'profile';
            return SpecialDietSelectorScreen(fromProfile: fromProfile);
          },
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
              log(
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
          path: '/scan/results',
          name: scanResultsRouteName,
          builder: (context, state) {
            // Extract data passed from ScanConfirmScreen (or analysis step)
            final Map<String, dynamic>? extraData =
                state.extra as Map<String, dynamic>?;

            // Extract the recognized items JSON data from the analysis
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
        // ✨ NEW: Simplified Recognition Screen (for testing)
        GoRoute(
          path: SimplifiedRecognitionScreen.routeName,
          name: 'simplifiedRecognition',
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const SimplifiedRecognitionScreen(),
        ),
        // ✨ NEW: Simplified Food Recognition Screen
        GoRoute(
          path: '/simplified-food-recognition',
          name: 'simplifiedFoodRecognition',
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const SimplifiedFoodRecognitionScreen(),
        ),
        // ✨ NEW: Recognition Type Selector Screen
        GoRoute(
          path: RecognitionTypeSelectorScreen.routePath,
          name: RecognitionTypeSelectorScreen.routeName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const RecognitionTypeSelectorScreen(),
        ),
        // Add the route for AddInventoryItemScreen (top-level for simplicity now)
        GoRoute(
          path: AddInventoryItemScreen.routePath, // '/inventory/add'
          name: addInventoryItemRouteName,
          builder: (context, state) {
            // Handle pre-filled data from scan results
            final prefilledItems = state.extra as List<Map<String, dynamic>>?;
            return AddInventoryItemScreen(prefilledItems: prefilledItems);
          },
        ),
        // Route for Ingredient Detail Screen
        GoRoute(
          path:
              '/inventory/ingredient/:ingredientName', // Define path with parameter
          name: ingredientDetailRouteName,
          builder: (context, state) {
            final ingredientName = state.pathParameters['ingredientName'];
            if (ingredientName == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).go('/inventory');
              });
              return const Scaffold(
                body: Center(child: Text('Ingredient name missing')),
              );
            }
            return IngredientDetailScreen(ingredientName: ingredientName);
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
            // Parse the itemId to extract foodName and addedAt
            // Expected format: "foodName_addedAt" (from FoodDetail.uniqueId)
            final parts = itemId.split('_');
            if (parts.length < 2) {
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Invalid food ID format')),
              );
            }
            final foodName = parts[0];
            final addedAt = parts
                .sublist(1)
                .join('_'); // In case addedAt contains underscores
            return FoodDetailScreen(foodName: foodName, addedAt: addedAt);
          },
        ),
        // Route for AI Recipe Generation Screen
        GoRoute(
          path: '/recipes/ai-generation',
          name: aiRecipeGenerationRouteName,
          builder: (context, state) => const AIRecipeGenerationScreen(),
        ),
        // Route for All Recipes Screen
        GoRoute(
          path: AllRecipesScreen.routePath,
          name: allRecipesRouteName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const AllRecipesScreen(),
        ),
        // Route for Recipe Detail Screen
        GoRoute(
          path: '/recipes/detail',
          name: 'recipeDetail',
          builder: (context, state) {
            // Esperar los datos de la receta como parameter extra
            final recipe = state.extra as Map<String, dynamic>?;
            if (recipe == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).go('/home');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return RecipeDetailScreen(recipe: recipe);
          },
        ),
        // Route for My Recipes Screen
        GoRoute(
          path: MyRecipesScreen.routePath,
          name: MyRecipesScreen.routeName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const MyRecipesScreen(),
        ),
        // Route for Custom Recipe Generation Screen
        GoRoute(
          path: CustomRecipeGenerationScreen.routePath,
          name: CustomRecipeGenerationScreen.routeName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const CustomRecipeGenerationScreen(),
        ),
        // Route for Impact Panel
        GoRoute(
          path: '/impact',
          name: impactRouteName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const ImpactScreen(),
        ),
        // Route for Weekly Planner
        GoRoute(
          path: '/planner',
          name: plannerRouteName,
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const PlannerScreen(),
        ),
        // Route for Meal Planning
        GoRoute(
          path: '/meal-planning',
          name: 'mealPlanning',
          parentNavigatorKey: _rootNavigatorKey, // Use root navigator
          builder: (context, state) => const MealPlanningScreen(),
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
                  log(
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
        // Profile-specific preference screens routes removed - now using unified screens with context parameter
        // Add the notifications screen route
        GoRoute(
          path: NotificationsScreen.routePath,
          name: notificationsRouteName,
          builder: (context, state) => const NotificationsScreen(),
        ),
        // Add the language screen route
        GoRoute(
          path: LanguageScreen.routePath,
          name: languageRouteName,
          builder: (context, state) => const LanguageScreen(),
        ),
        // Add the units screen route
        GoRoute(
          path: UnitsScreen.routePath,
          name: unitsRouteName,
          builder: (context, state) => const UnitsScreen(),
        ),
        // Add the FAQs screen route
        GoRoute(
          path: FAQsScreen.routePath,
          name: faqsRouteName,
          builder: (context, state) => const FAQsScreen(),
        ),
        // Add the Privacy Policy screen route
        GoRoute(
          path: PrivacyPolicyScreen.routePath,
          name: privacyPolicyRouteName,
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        // Add the Terms and Conditions screen route
        GoRoute(
          path: TermsAndConditionsScreen.routePath,
          name: termsAndConditionsRouteName,
          builder: (context, state) => const TermsAndConditionsScreen(),
        ),
        // Add the About App screen route
        GoRoute(
          path: AboutAppScreen.routePath,
          name: aboutAppRouteName,
          builder: (context, state) => const AboutAppScreen(),
        ),
        // Add the Support screen route
        GoRoute(
          path: SupportScreen.routePath,
          name: supportRouteName,
          builder: (context, state) => const SupportScreen(),
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
