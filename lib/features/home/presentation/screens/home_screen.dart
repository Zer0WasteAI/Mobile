import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the modular widgets
import 'package:zer0_waste_ai/features/home/presentation/widgets/welcome_header.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/motivational_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/inventory_summary_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/recipe_suggestions.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/impact_summary_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/daily_planner_widget.dart';

/// The HomeScreen widget is the main entry point of the app.
/// It displays a welcome message, a motivational card, inventory summary,
/// recipe suggestions, impact summary, and other personalized content.
class HomeScreen extends ConsumerWidget {
  // Common spacing values
  static const double _horizontalPadding = 16.0;
  static const double _sectionSpacing = 16.0;

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: WelcomeHeader(),
              ),

              const SizedBox(height: 24), // Espacio después del header
              // Daily Planner Widget - Planificación de comidas del día (NUEVO)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: DailyPlannerWidget(),
              ),
              const SizedBox(height: _sectionSpacing),

              // Motivational Card
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: MotivationalCard(),
              ),
              const SizedBox(height: _sectionSpacing),

              // Inventory Summary Card
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: InventorySummaryCard(),
              ),
              const SizedBox(height: _sectionSpacing),

              // Recipe Suggestions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: RecipeSuggestions(),
              ),
              const SizedBox(height: _sectionSpacing),

              // Impact Summary Card
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: ImpactSummaryCard(),
              ),
              const SizedBox(height: 24), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
