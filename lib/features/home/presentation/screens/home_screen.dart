import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the modular widgets
import 'package:zer0_waste_ai/features/home/presentation/widgets/welcome_header.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/motivational_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/inventory_summary_card.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/recipe_suggestions.dart';
import 'package:zer0_waste_ai/features/home/presentation/widgets/impact_summary_card.dart';

/// Home screen
class HomeScreen extends ConsumerWidget {
  /// Constructor
  const HomeScreen({super.key});

  // Define constants for padding and colors
  static const double _horizontalPadding = 16.0;
  static const double _sectionSpacing = 16.0;
  static const Color _backgroundColor = Color(0xFFFAF9F6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // Top spacing
                // 1. Welcome Header
                const WelcomeHeader(),
                const SizedBox(
                  height: _sectionSpacing * 1.5,
                ), // More space after header
                // 2. Motivational Card
                const MotivationalCard(),
                const SizedBox(height: _sectionSpacing),

                // 3. Inventory Summary Card
                const InventorySummaryCard(),
                const SizedBox(height: _sectionSpacing * 1.5),

                // 4. Recipe Suggestions
                const RecipeSuggestions(),
                const SizedBox(height: _sectionSpacing * 1.5),

                // 5. Impact Summary Card
                const ImpactSummaryCard(),
                const SizedBox(height: 24), // Bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
