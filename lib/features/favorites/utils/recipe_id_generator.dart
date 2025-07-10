/// Utility class for generating consistent recipe IDs across the app
/// This ensures that the same recipe gets the same ID regardless of where it comes from
class RecipeIdGenerator {
  /// Generate a consistent ID for a recipe based on its title
  /// This is the primary method for creating recipe IDs for favorites
  static String fromTitle(String title) {
    // Clean and normalize the title
    final cleanTitle = _cleanTitle(title);
    
    // Generate a consistent hash using Dart's built-in hashCode
    final hashCode = cleanTitle.hashCode.abs();
    
    // Return a shorter, consistent ID
    return 'recipe_$hashCode';
  }

  /// Generate ID from recipe data (fallback method)
  /// Use this when you have more recipe information available
  static String fromRecipeData({
    required String title,
    String? description,
    List<String>? ingredients,
  }) {
    final cleanTitle = _cleanTitle(title);
    
    // Create a more comprehensive signature if more data is available
    String signature = cleanTitle;
    
    if (description != null && description.isNotEmpty) {
      signature += '_${description.toLowerCase().trim()}';
    }
    
    if (ingredients != null && ingredients.isNotEmpty) {
      // Add first few ingredients to make ID more unique
      signature += '_${ingredients.take(3).join('_').toLowerCase()}';
    }
    
    final hashCode = signature.hashCode.abs();
    return 'recipe_$hashCode';
  }

  /// Check if two recipe titles should have the same ID
  static bool areEquivalent(String title1, String title2) {
    return _cleanTitle(title1) == _cleanTitle(title2);
  }

  /// Clean and normalize a recipe title for ID generation
  static String _cleanTitle(String title) {
    return title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s*\(\d+\)$'), '') // Remove (1), (2) suffixes
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .replaceAll(RegExp(r'_+'), '_'); // Replace multiple underscores with single
  }

  /// Extract clean title for display (without affecting ID generation)
  static String getDisplayTitle(String title) {
    return title
        .trim()
        .replaceAll(RegExp(r'\s*\(\d+\)$'), ''); // Remove (1), (2) suffixes only
  }
}