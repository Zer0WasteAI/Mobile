import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the modular widgets
import 'package:zer0_waste_ai/features/home/presentation/widgets/welcome_header.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/motivational_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/inventory_summary_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/recipe_suggestions.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/home_daily_planner_widget.dart';

/// The HomeScreen widget is the main entry point of the app.
/// It displays a welcome message, a motivational card, inventory summary,
/// recipe suggestions, impact summary, and other personalized content.
class HomeScreen extends ConsumerStatefulWidget {
  // Common spacing values
  static const double _horizontalPadding = 16.0;
  static const double _sectionSpacing = 16.0;

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when home screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when returning to home screen
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .refreshUserFromFirestore();
      log('🏠 Home: Datos de usuario refrescados automáticamente');
    } catch (e) {
      log('🏠 Home: Error al refrescar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get background color from theme
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor, // Use theme background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // Espacio superior
              // Welcome Header con padding horizontal
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: WelcomeHeader(),
              ),

              const SizedBox(height: 24), // Espacio después del header
              // Daily Planner Widget - Planificación de comidas del día (NUEVO)
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: HomeDailyPlannerWidget(),
              ),
              const SizedBox(height: HomeScreen._sectionSpacing),

              // Motivational Card
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: MotivationalCard(),
              ),
              const SizedBox(height: HomeScreen._sectionSpacing),

              // Inventory Summary Card
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: InventorySummaryCard(),
              ),
              const SizedBox(height: HomeScreen._sectionSpacing),

              // Quick Actions Widget - Acciones rápidas
              /*const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: QuickActionsWidget(),
              ),
              const SizedBox(height: HomeScreen._sectionSpacing),*/

              // Recipe Suggestions
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: RecipeSuggestions(),
              ),
              const SizedBox(height: HomeScreen._sectionSpacing),

              // Impact Summary Card
              /*const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeScreen._horizontalPadding,
                ),
                child: ImpactSummaryCard(),
              ),*/
              const SizedBox(height: 24), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
