import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/screens/custom_loading_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:zer0_waste_ai/features/auth/presentation/screens/email_verification_screen.dart'; // Import EmailVerificationScreen
import 'package:zer0_waste_ai/features/auth/presentation/screens/auth_transition_screen.dart'; // Import AuthTransitionScreen
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
import 'package:zer0_waste_ai/features/impact/presentation/screens/impact_screen.dart'; // Import ImpactScreen
import 'package:zer0_waste_ai/features/planner/presentation/screens/planner_screen.dart'; // Import PlannerScreen
import 'package:zer0_waste_ai/features/recipes/presentation/screens/recipe_detail_screen.dart'; // Import RecipeDetailScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/profile_cooking_level_selector_screen.dart'; // Import profile cooking level screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/profile_preferred_food_type_screen.dart'; // Import profile food type screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/profile_allergy_selector_screen.dart'; // Import profile allergy screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/profile_special_diet_selector_screen.dart'; // Import profile special diet screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/notifications_screen.dart'; // Import notifications screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/language_screen.dart'; // Import language screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/units_screen.dart'; // Import units screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/faqs_screen.dart'; // Import FAQs screen
import 'package:zer0_waste_ai/features/profile/presentation/screens/privacy_policy_screen.dart'; // Import PrivacyPolicyScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/terms_and_conditions_screen.dart'; // Import TermsAndConditionsScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/about_app_screen.dart'; // Import AboutAppScreen
import 'package:zer0_waste_ai/features/profile/presentation/screens/support_screen.dart'; // Import SupportScreen
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart'; // Importar el servicio de preferencias
import 'package:zer0_waste_ai/features/splash/presentation/providers/splash_provider.dart'; // Import splashControllerProvider
import 'package:zer0_waste_ai/features/profile/presentation/screens/edit_profile_screen.dart'; // Import EditProfileScreen

// Global key for the ShellRoute navigator
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();
// Global key for the root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Define route names (add one for smart recipes)
const String splashRouteName = 'splash';
const String routerEntryName = 'router_entry';
const String onboardingRouteName = 'onboarding';
const String loginRouteName = 'login';
const String registerRouteName = 'register';
const String forgotPasswordRouteName = 'forgot-password';
const String emailVerificationRouteName =
    EmailVerificationScreen.routeName; // Add email verification route name
const String authTransitionRouteName =
    AuthTransitionScreen.routeName; // Add auth transition route name
const String loadingRouteName = 'loading'; // Add loading route name
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
const String scanResultsRouteName = ScanResultsScreen.routeName;
const String allergySelectorRouteName = AllergySelectorScreen.routeName;
const String cookingLevelSelectorRouteName =
    CookingLevelSelectorScreen.routeName;
const String preferredFoodTypeRouteName = PreferredFoodTypeScreen.routeName;
const String specialDietSelectorRouteName = SpecialDietSelectorScreen.routeName;
const String aiRecipeGenerationRouteName = 'AIRecipeGenerationScreen';

// Profile-specific selector route names
const String profileCookingLevelSelectorRouteName =
    ProfileCookingLevelSelectorScreen.routeName;
const String profilePreferredFoodTypeRouteName =
    ProfilePreferredFoodTypeScreen.routeName;
const String profileAllergySelectorRouteName =
    ProfileAllergySelectorScreen.routeName;
const String profileSpecialDietSelectorRouteName =
    ProfileSpecialDietSelectorScreen.routeName;
const String notificationsRouteName = NotificationsScreen.routeName;
const String languageRouteName = LanguageScreen.routeName;
const String unitsRouteName = UnitsScreen.routeName;
const String faqsRouteName = FAQsScreen.routeName;
const String privacyPolicyRouteName = PrivacyPolicyScreen.routeName;
const String termsAndConditionsRouteName = TermsAndConditionsScreen.routeName;
const String aboutAppRouteName = AboutAppScreen.routeName;
const String supportRouteName = SupportScreen.routeName;
const String editProfileRouteName = EditProfileScreen.routeName;

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

/// App router configuration
class AppRouter {
  /// GoRouter instance factory
  static GoRouter createRouter(Ref ref) {
    // Create the HeroController
    final heroController = HeroController();
    final authState = ref.watch(authStateProvider);

    // Watch the user preferences state to avoid async calls during redirects
    final userPreferences = ref.watch(userPreferencesProvider);

    // Definir transición personalizada para hacer navegación más fluida
    CustomTransitionPage<void> buildPageWithDefaultTransition<T>({
      required BuildContext context,
      required GoRouterState state,
      required Widget child,
    }) {
      return CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade transition para una experiencia más suave
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(
          milliseconds: 150,
        ), // Transición rápida para evitar pantallas negras
      );
    }

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      // Add the observer here
      observers: [heroController],
      redirect: (context, state) {
        // Use synchronous state data from the provider instead of async calls
        final isLoggedIn = authState.value != null;
        final isLoading = userPreferences.isLoading;
        final hasCompletedPreferences = userPreferences.hasCompletedPreferences;

        // DEBUG INFO
        print('================== ROUTER REDIRECT INFO ==================');
        print(
          'Route: ${state.matchedLocation}, isLoggedIn: $isLoggedIn, isLoading: $isLoading, hasCompletedPreferences: $hasCompletedPreferences',
        );

        // Get initialPreferencesCompleted directly from Firestore
        final firestorePreferencesCompleted =
            isLoggedIn && authState.value != null
                ? authState.value!.initialPreferencesCompleted
                : false;

        if (isLoggedIn && authState.value != null) {
          final firebaseValue = authState.value!.initialPreferencesCompleted;
          final inMemoryValue = userPreferences.hasCompletedPreferences;
          print('User: ${authState.value!.id}');
          print('Firestore initialPreferencesCompleted: $firebaseValue');
          print('In-memory hasCompletedPreferences: $inMemoryValue');

          if (firebaseValue != inMemoryValue) {
            print(
              '⚠️ ALERTA: Inconsistencia entre valores de Firestore ($firebaseValue) y memoria ($inMemoryValue)',
            );
            // Actualizar el estado en memoria si está desincronizado con Firestore
            if (firebaseValue && !inMemoryValue && !isLoading) {
              print(
                'Sincronizando estado en memoria con valor de Firestore...',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(userPreferencesProvider.notifier)
                    .markPreferencesAsCompleted();
              });
            }
          }
        }
        print('========================================================');

        // === EVITAR LOOPS DE REDIRECCIÓN ===
        // Si estamos en el splash, permitir mostrar el splash por un tiempo adecuado
        if (state.matchedLocation == '/splash') {
          print('En splash, permitiendo mostrar animación...');
          return null;
        }

        // Si viene de la ruta /router-entry (después del splash), redireccionar según estado
        if (state.matchedLocation == '/router-entry') {
          // Verificar si ya vio el onboarding
          final splashController = ref.read(splashControllerProvider);
          if (!splashController.onboardingSeen) {
            print('Router: Primera vez abriendo la app, mostrando onboarding');
            return '/onboarding';
          }

          // Si no está autenticado, ir a login
          if (!isLoggedIn) {
            print('Router: Usuario no autenticado, redirigiendo a login');
            return '/login';
          }

          // Si está cargando preferencias, mostrar pantalla de carga
          if (isLoading) {
            print('Router: Preferencias cargando, mostrando pantalla de carga');
            return '/loading';
          }

          // SIEMPRE priorizar el valor de Firestore sobre cualquier otro
          if (firestorePreferencesCompleted) {
            print(
              'Router: Usuario completó preferencias según Firestore, redirigiendo a home',
            );
            return '/home';
          } else {
            print(
              'Router: Usuario sin preferencias completadas según Firestore, redirigiendo a selector de alergias',
            );
            return AllergySelectorScreen.routePath;
          }
        }

        // PASO 1: Si estamos en alguna ruta de la app principal y tenemos confirmado que el
        // usuario ha completado preferencias en Firestore, permitir la navegación
        if (isLoggedIn &&
            !isLoading &&
            firestorePreferencesCompleted &&
            ![
              '/login',
              '/register',
              '/signup',
              '/forgot-password',
              '/onboarding',
            ].contains(state.matchedLocation)) {
          print(
            'Usuario autenticado con preferencias confirmadas en Firestore, permitiendo navegación a: ${state.matchedLocation}',
          );
          return null;
        }

        // Rutas que no requieren autenticación
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToSignup = state.matchedLocation == '/signup';
        final isGoingToSignup2 = state.matchedLocation == '/register';
        final isGoingToForgotPassword =
            state.matchedLocation == '/forgot-password';
        final isGoingToOnboarding = state.matchedLocation == '/onboarding';
        final isGoingToSplash =
            state.matchedLocation == '/' || state.matchedLocation == '/splash';
        final isGoingToEmailVerification =
            state.matchedLocation == EmailVerificationScreen.routePath;
        final isGoingToAuthTransition =
            state.matchedLocation == AuthTransitionScreen.routePath;

        // Rutas relacionadas con el flujo de preferencias de usuario
        final isGoingToUserPreferences =
            state.matchedLocation == AllergySelectorScreen.routePath ||
            state.matchedLocation == CookingLevelSelectorScreen.routePath ||
            state.matchedLocation == PreferredFoodTypeScreen.routePath ||
            state.matchedLocation == SpecialDietSelectorScreen.routePath;

        print(
          'isGoingToUserPreferences=$isGoingToUserPreferences, path=${state.matchedLocation}',
        );

        // Determinar si necesita completar preferencias basado en el estado del provider en lugar de llamada asincrónica
        final needsToCompletePreferences =
            isLoggedIn && !hasCompletedPreferences && !isLoading;
        print('needsToCompletePreferences=$needsToCompletePreferences (sync)');

        // Si va a la pantalla de home después de completar las dietas especiales,
        // y el marcador de preferencias está en true, permitir la navegación y no redireccionar
        if (isLoggedIn &&
            state.matchedLocation == '/home' &&
            (hasCompletedPreferences || firestorePreferencesCompleted)) {
          print(
            'Usuario autenticado con preferencias completadas, permitiendo ir al home',
          );
          return null;
        }

        // CASO ESPECIAL: Si está autenticado, necesita completar preferencias
        // y NO está yendo a una pantalla de preferencias, FORZAR redirección al selector de alergias
        if (isLoggedIn &&
            needsToCompletePreferences &&
            !firestorePreferencesCompleted && // Verificar directamente con Firestore para evitar bucles
            !isGoingToUserPreferences &&
            !isGoingToSplash && // Excepción para splash (manejo especial)
            !isGoingToAuthTransition // Permitir la pantalla de transición
            ) {
          print('FORZANDO NAVEGACIÓN AL SELECTOR DE ALERGIAS');
          return AllergySelectorScreen.routePath;
        }

        // 2. Permitir el acceso al splash solo cuando la app se inicia por primera vez (es la ruta inicial)
        if (isGoingToSplash) {
          return null; // Permitir mostrar siempre el splash, la navegación será gestionada por este
        }

        // 3. Si el usuario no está autenticado y no está yendo a una pantalla permitida sin autenticación,
        //    redirigir al login
        if (!isLoggedIn &&
            !isGoingToLogin &&
            !isGoingToSignup &&
            !isGoingToSignup2 &&
            !isGoingToForgotPassword &&
            !isGoingToOnboarding &&
            !isGoingToEmailVerification &&
            !isGoingToAuthTransition &&
            !isGoingToSplash) {
          print('Usuario no autenticado, redirigiendo al login');
          return '/login';
        }

        // 4. Si está autenticado y está intentando ir a pantallas de inicio de sesión o registro,
        //    pero no está en el flujo de preferencias de usuario, redirigir a la pantalla principal
        if (isLoggedIn &&
            (isGoingToLogin ||
                isGoingToSignup ||
                isGoingToSignup2 ||
                isGoingToForgotPassword ||
                isGoingToOnboarding) &&
            !isGoingToUserPreferences &&
            !isGoingToAuthTransition) {
          if (isLoading) {
            print(
              'Usuario autenticado, preferencias cargando, mostrando pantalla de transición',
            );
            return AuthTransitionScreen.routePath;
          }

          // Si necesita completar preferencias, enviarlo al selector de alergias en lugar de home
          if (needsToCompletePreferences && !firestorePreferencesCompleted) {
            print(
              'Usuario autenticado sin preferencias, redirigiendo al selector de alergias',
            );
            return AllergySelectorScreen.routePath;
          }

          print('Usuario autenticado con preferencias, redirigiendo al home');
          return '/home';
        }

        // No redirigir si no se cumple ninguna de las condiciones anteriores
        print(
          'No se aplica ninguna regla de redirección, manteniendo ruta: ${state.matchedLocation}',
        );
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: splashRouteName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/loading',
          name: loadingRouteName,
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CustomLoadingScreen(
                  message: 'Cargando...',
                  subMessage: 'Personalizando tu experiencia',
                ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
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
        // Add the Email Verification Screen route
        GoRoute(
          path: EmailVerificationScreen.routePath,
          name: emailVerificationRouteName,
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        // Add the Auth Transition Screen route
        GoRoute(
          path: AuthTransitionScreen.routePath,
          name: authTransitionRouteName,
          pageBuilder:
              (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const AuthTransitionScreen(),
              ),
        ),
        // Add the Allergy Selector Screen route here (top-level)
        GoRoute(
          path: AllergySelectorScreen.routePath,
          name: allergySelectorRouteName,
          pageBuilder:
              (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const AllergySelectorScreen(),
              ),
        ),
        // Add the Cooking Level Selector Screen route here (top-level)
        GoRoute(
          path: CookingLevelSelectorScreen.routePath,
          name: cookingLevelSelectorRouteName,
          pageBuilder:
              (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const CookingLevelSelectorScreen(),
              ),
        ),
        // Add the Preferred Food Type Screen route here (top-level)
        GoRoute(
          path: PreferredFoodTypeScreen.routePath,
          name: preferredFoodTypeRouteName,
          pageBuilder:
              (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const PreferredFoodTypeScreen(),
              ),
        ),
        // Add the Special Diet Selector Screen route here (top-level)
        GoRoute(
          path: SpecialDietSelectorScreen.routePath,
          name: specialDietSelectorRouteName,
          pageBuilder:
              (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: const SpecialDietSelectorScreen(),
              ),
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
              pageBuilder:
                  (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const HomeScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOut,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
            ),
            GoRoute(
              path: '/inventory',
              name: inventoryRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder:
                  (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const InventoryScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOut,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
            ),
            GoRoute(
              path: '/recipes',
              name: recipesRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              // This route (from bottom nav) always goes to explore mode
              pageBuilder:
                  (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: RecipeScreen(mode: RecipeMode.explore),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOut,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
            ),
            GoRoute(
              path: '/profile',
              name: profileRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder:
                  (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: const ProfileScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOut,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
            ),
            // Add new routes for scanning under the ShellRoute
            GoRoute(
              path: '/scan/add/:itemType', // Use path parameter for item type
              name: addScanItemRouteName,
              parentNavigatorKey: _shellNavigatorKey,
              pageBuilder: (context, state) {
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
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: AddScanItemScreen(itemType: itemType),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeInOut,
                      ).animate(animation),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
              },
            ),
          ],
        ),
        // Add the profile-specific preference screens routes
        GoRoute(
          path: ProfileCookingLevelSelectorScreen.routePath,
          name: profileCookingLevelSelectorRouteName,
          builder:
              (context, state) => const ProfileCookingLevelSelectorScreen(),
        ),
        GoRoute(
          path: ProfilePreferredFoodTypeScreen.routePath,
          name: profilePreferredFoodTypeRouteName,
          builder: (context, state) => const ProfilePreferredFoodTypeScreen(),
        ),
        GoRoute(
          path: ProfileAllergySelectorScreen.routePath,
          name: profileAllergySelectorRouteName,
          builder: (context, state) => const ProfileAllergySelectorScreen(),
        ),
        GoRoute(
          path: ProfileSpecialDietSelectorScreen.routePath,
          name: profileSpecialDietSelectorRouteName,
          builder: (context, state) => const ProfileSpecialDietSelectorScreen(),
        ),
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
        // Add the Edit Profile screen route
        GoRoute(
          path: EditProfileScreen.routePath,
          name: editProfileRouteName,
          builder: (context, state) => const EditProfileScreen(),
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
