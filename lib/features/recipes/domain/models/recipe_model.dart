class Recipe {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final List<String> ingredients;
  final int requiredIngredientsCount;
  final int availableIngredientsCount;
  final bool usesExpiringItems;
  final int cookingTime; // in minutes
  final String difficulty; // 'Fácil', 'Medio', 'Difícil'
  final String dietType; // 'Omnívora', 'Vegetariana', 'Vegana', etc.
  final List<String> categories; // e.g. ['Destacados', 'Rápidas y Fáciles']

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.ingredients,
    required this.requiredIngredientsCount,
    required this.availableIngredientsCount,
    required this.usesExpiringItems,
    required this.cookingTime,
    required this.difficulty,
    required this.dietType,
    required this.categories,
  });

  // Format cooking time as a human-readable string
  String get formattedCookingTime {
    return '$cookingTime min';
  }

  // Check if this recipe matches filter criteria
  bool matchesFilters(Map<String, Set<String>> filters) {
    if (filters.isEmpty) return true;

    // Check each filter category
    for (final category in filters.keys) {
      final values = filters[category]!;

      switch (category) {
        case 'Tiempo de preparación':
          final bool matchesTime = values.any((value) {
            if (value == 'short_time') return cookingTime < 15;
            if (value == 'medium_time')
              return cookingTime >= 15 && cookingTime <= 30;
            if (value == 'long_time') return cookingTime > 30;
            return false;
          });
          if (!matchesTime) return false;
          break;

        case 'Dificultad':
          final bool matchesDifficulty = values.any((value) {
            if (value == 'facil') return difficulty == 'Fácil';
            if (value == 'intermedio') return difficulty == 'Medio';
            if (value == 'dificil') return difficulty == 'Difícil';
            return false;
          });
          if (!matchesDifficulty) return false;
          break;

        case 'Tipo de dieta':
          final bool matchesDiet = values.any((value) {
            if (value == 'vegetariana') return dietType == 'Vegetariana';
            if (value == 'vegana') return dietType == 'Vegana';
            if (value == 'omnivora') return dietType == 'Omnívora';
            // Other diet types...
            return false;
          });
          if (!matchesDiet) return false;
          break;

        // Add other filter categories as needed
      }
    }

    return true;
  }

  // Check if recipe matches search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowercaseQuery = query.toLowerCase();

    // Check name
    if (name.toLowerCase().contains(lowercaseQuery)) return true;

    // Check description
    if (description.toLowerCase().contains(lowercaseQuery)) return true;

    // Check ingredients
    for (final ingredient in ingredients) {
      if (ingredient.toLowerCase().contains(lowercaseQuery)) return true;
    }

    return false;
  }
}
