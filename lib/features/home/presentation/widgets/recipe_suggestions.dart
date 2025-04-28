import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider

class RecipeSuggestions extends ConsumerWidget {
  const RecipeSuggestions({super.key});

  // Define colors locally
  static const Color _mainTextColor = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeSuggestionsProvider);

    if (recipes.isEmpty) {
      return const SizedBox.shrink(); // Don't show section if no recipes
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0), // Space below title
          child: Text(
            'Recetas basadas en tu despensa 🍽️',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _mainTextColor,
            ),
          ),
        ),
        SizedBox(
          height: 220, // Adjust height as needed for cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Padding(
                // Add spacing between cards, except for the last one
                padding: EdgeInsets.only(
                  right: index == recipes.length - 1 ? 0 : 12.0,
                ),
                child: RecipeCard(recipe: recipe),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  // Define colors locally
  static const Color _primaryColor = Color(0xFF00B894);
  static const Color _accentColor = Color(0xFFF07548);
  static const Color _mainTextColor = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    // Determine badge color based on difficulty
    final Color badgeColor =
        recipe.difficulty == 'Fácil'
            ? _primaryColor.withOpacity(0.2)
            : _accentColor.withOpacity(0.2);
    final Color badgeTextColor =
        recipe.difficulty == 'Fácil' ? _primaryColor : _accentColor;

    return SizedBox(
      width: 160, // Fixed width for horizontal scroll items
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        clipBehavior: Clip.antiAlias, // Clip the image to the card shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            // TODO: Implement navigation to recipe details
            print("Navigate to Recipe: ${recipe.title}");
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Placeholder
              AspectRatio(
                aspectRatio: 16 / 10, // Adjust aspect ratio
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  // Optional: Add loading/error builders for network image
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                  },
                  errorBuilder: (context, error, stack) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _mainTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
