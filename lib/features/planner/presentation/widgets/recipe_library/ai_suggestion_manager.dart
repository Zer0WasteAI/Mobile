import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';
import 'recipe_card_builder.dart';

/// Manager for AI recipe suggestions and related functionality
class AiSuggestionManager {
  /// Build AI suggestions widget
  static Widget buildAiSuggestions(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSuggestionsHeader(),
          
          const SizedBox(height: 16),
          
          // Suggestions based on inventory
          _buildInventoryBasedSuggestions(ref),
          
          const SizedBox(height: 24),
          
          // Trending recipes
          _buildTrendingRecipes(ref),
          
          const SizedBox(height: 24),
          
          // Quick suggestions
          _buildQuickSuggestions(ref),
        ],
      ),
    );
  }

  /// Build suggestions header
  static Widget _buildSuggestionsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF00BFA5),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sugerencias IA',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Recetas personalizadas basadas en tus preferencias y disponibilidad',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build inventory-based suggestions
  static Widget _buildInventoryBasedSuggestions(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.kitchen,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Basado en tu inventario',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Check if user has inventory items
        Consumer(
          builder: (context, ref, child) {
            // This would normally check the inventory provider
            final hasInventory = true; // Placeholder
            
            if (!hasInventory) {
              return _buildNoInventoryCard(ref);
            }
            
            return _buildInventorySuggestionsList(ref);
          },
        ),
      ],
    );
  }

  /// Build trending recipes section
  static Widget _buildTrendingRecipes(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Tendencias',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Placeholder count
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildTrendingRecipeCard(index, ref),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build quick suggestions section
  static Widget _buildQuickSuggestions(WidgetRef ref) {
    final quickSuggestions = [
      {
        'title': 'Recetas rápidas',
        'subtitle': 'Menos de 15 minutos',
        'icon': Icons.flash_on,
        'color': Colors.orange,
      },
      {
        'title': 'Saludables',
        'subtitle': 'Bajo en calorías',
        'icon': Icons.favorite,
        'color': Colors.red,
      },
      {
        'title': 'Vegetarianas',
        'subtitle': 'Sin carne',
        'icon': Icons.eco,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugerencias rápidas',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Column(
          children: quickSuggestions.map((suggestion) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildQuickSuggestionCard(suggestion, ref),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build no inventory card
  static Widget _buildNoInventoryCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No tienes ingredientes registrados',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega ingredientes a tu inventario para recibir sugerencias personalizadas',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to inventory
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ir al Inventario',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build inventory suggestions list
  static Widget _buildInventorySuggestionsList(WidgetRef ref) {
    // This would normally get suggestions based on user's inventory
    final suggestions = _getMockInventorySuggestions();
    
    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              // Recipe type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: suggestion['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  suggestion['icon'] as IconData,
                  color: suggestion['color'] as Color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      suggestion['ingredients'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Generate button
              GestureDetector(
                onTap: () {
                  // Generate recipe based on suggestion
                  _generateRecipeFromSuggestion(suggestion, ref);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Generar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build trending recipe card
  static Widget _buildTrendingRecipeCard(int index, WidgetRef ref) {
    // Mock trending recipes
    final trendingRecipes = _getMockTrendingRecipes();
    final recipe = trendingRecipes[index % trendingRecipes.length];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: recipe['color'].withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                recipe['icon'] as IconData,
                size: 40,
                color: recipe['color'] as Color,
              ),
            ),
          ),
          
          // Recipe info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 12,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe['popularity']}% popular',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick suggestion card
  static Widget _buildQuickSuggestionCard(
    Map<String, dynamic> suggestion, 
    WidgetRef ref
  ) {
    return GestureDetector(
      onTap: () {
        // Apply quick filter
        _applyQuickFilter(suggestion, ref);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (suggestion['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                suggestion['icon'] as IconData,
                color: suggestion['color'] as Color,
                size: 18,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['title'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    suggestion['subtitle'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Mock data methods (these would be replaced with real data sources)

  static List<Map<String, dynamic>> _getMockInventorySuggestions() {
    return [
      {
        'title': 'Pasta con tomate',
        'ingredients': 'Tienes: pasta, tomate, albahaca',
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
      {
        'title': 'Ensalada verde',
        'ingredients': 'Tienes: lechuga, pepino, zanahoria',
        'icon': Icons.eco,
        'color': Colors.green,
      },
      {
        'title': 'Tortilla española',
        'ingredients': 'Tienes: huevos, patatas, cebolla',
        'icon': Icons.breakfast_dining,
        'color': Colors.orange,
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockTrendingRecipes() {
    return [
      {
        'name': 'Bowl de Buddha',
        'popularity': 85,
        'icon': Icons.rice_bowl,
        'color': Colors.green,
      },
      {
        'name': 'Tacos de pollo',
        'popularity': 92,
        'icon': Icons.lunch_dining,
        'color': Colors.orange,
      },
      {
        'name': 'Smoothie bowl',
        'popularity': 78,
        'icon': Icons.local_drink,
        'color': Colors.purple,
      },
      {
        'name': 'Pizza casera',
        'popularity': 95,
        'icon': Icons.local_pizza,
        'color': Colors.red,
      },
      {
        'name': 'Sushi bowl',
        'popularity': 88,
        'icon': Icons.set_meal,
        'color': Colors.blue,
      },
    ];
  }

  // Action methods

  static void _generateRecipeFromSuggestion(
    Map<String, dynamic> suggestion, 
    WidgetRef ref
  ) {
    // This would trigger AI recipe generation based on the suggestion
    // For now, just show a placeholder
  }

  static void _applyQuickFilter(
    Map<String, dynamic> suggestion, 
    WidgetRef ref
  ) {
    // This would apply the quick filter to the recipe list
    final title = suggestion['title'] as String;
    
    // Apply different filters based on the suggestion type
    switch (title) {
      case 'Recetas rápidas':
        // Apply cooking time filter for quick recipes
        break;
      case 'Saludables':
        // Apply healthy/low-calorie filter
        break;
      case 'Vegetarianas':
        // Apply vegetarian filter
        break;
    }
  }
}