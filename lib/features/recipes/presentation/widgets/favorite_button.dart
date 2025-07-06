import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/favorite_recipes_provider.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';

/// INFO: Reusable favorite button widget
/// USAGE: Add to any recipe UI to enable favoriting functionality
/// ADVICE: Automatically syncs with backend and shows loading states
class FavoriteButton extends ConsumerWidget {
  final Recipe recipe;
  final double? size;
  final Color? favoriteColor;
  final Color? unfavoriteColor;
  final bool showBackground;
  final VoidCallback? onToggle;

  const FavoriteButton({
    super.key,
    required this.recipe,
    this.size = 24,
    this.favoriteColor,
    this.unfavoriteColor,
    this.showBackground = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isRecipeFavoritedProvider(recipe.id));
    final isLoading = ref.watch(isRecipeSavingProvider(recipe.id));
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    final effectiveFavoriteColor = favoriteColor ?? Colors.red.shade400;
    final effectiveUnfavoriteColor = unfavoriteColor ?? Colors.grey.shade400;

    Widget iconWidget;

    if (isLoading) {
      iconWidget = SizedBox(
        width: size! * 0.8,
        height: size! * 0.8,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(effectiveFavoriteColor),
        ),
      );
    } else {
      iconWidget = Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: isFavorited ? effectiveFavoriteColor : effectiveUnfavoriteColor,
        size: size,
      );
    }

    final button = IconButton(
      icon: iconWidget,
      onPressed:
          isLoading
              ? null
              : () async {
                // Call optional callback first
                onToggle?.call();

                // Toggle favorite status
                final success = await favoritesNotifier.toggleFavorite(recipe);

                // Show feedback to user
                if (context.mounted) {
                  final message =
                      isFavorited
                          ? '${recipe.name} eliminada de favoritas'
                          : '${recipe.name} guardada en favoritas';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 2),
                      action:
                          success
                              ? SnackBarAction(
                                label: 'Deshacer',
                                textColor: Colors.white,
                                onPressed: () async {
                                  await favoritesNotifier.toggleFavorite(
                                    recipe,
                                  );
                                },
                              )
                              : null,
                    ),
                  );
                }
              },
      tooltip: isFavorited ? 'Quitar de favoritas' : 'Agregar a favoritas',
    );

    if (!showBackground) {
      return button;
    }

    return Container(
      decoration: BoxDecoration(
        color:
            isFavorited
                ? effectiveFavoriteColor.withValues(alpha: 0.1)
                : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: button,
    );
  }
}

/// INFO: Floating favorite button for recipe detail screens
/// USAGE: Use as a FloatingActionButton replacement
class FloatingFavoriteButton extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback? onToggle;

  const FloatingFavoriteButton({
    super.key,
    required this.recipe,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isRecipeFavoritedProvider(recipe.id));
    final isLoading = ref.watch(isRecipeSavingProvider(recipe.id));
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    return FloatingActionButton(
      onPressed:
          isLoading
              ? null
              : () async {
                onToggle?.call();

                final success = await favoritesNotifier.toggleFavorite(recipe);

                if (context.mounted) {
                  final message =
                      isFavorited
                          ? '${recipe.name} eliminada de favoritas'
                          : '${recipe.name} guardada en favoritas';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 2),
                      action:
                          success
                              ? SnackBarAction(
                                label: 'Deshacer',
                                textColor: Colors.white,
                                onPressed: () async {
                                  await favoritesNotifier.toggleFavorite(
                                    recipe,
                                  );
                                },
                              )
                              : null,
                    ),
                  );
                }
              },
      backgroundColor: isFavorited ? Colors.red.shade400 : Colors.grey.shade300,
      foregroundColor: Colors.white,
      child:
          isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
              : Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                size: 28,
              ),
    );
  }
}

/// INFO: Compact favorite button for cards and lists
/// USAGE: Use in recipe cards, search results, etc.
class CompactFavoriteButton extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback? onToggle;

  const CompactFavoriteButton({super.key, required this.recipe, this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isRecipeFavoritedProvider(recipe.id));
    final isLoading = ref.watch(isRecipeSavingProvider(recipe.id));
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    return GestureDetector(
      onTap:
          isLoading
              ? null
              : () async {
                onToggle?.call();

                // ignore: unused_local_variable
                final success = await favoritesNotifier.toggleFavorite(recipe);

                if (context.mounted) {
                  final message =
                      isFavorited
                          ? 'Eliminada de favoritas'
                          : 'Guardada en favoritas';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFavorited ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.red.shade400),
                  ),
                )
                : Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color:
                      isFavorited ? Colors.red.shade400 : Colors.grey.shade500,
                  size: 16,
                ),
      ),
    );
  }
}

/// INFO: Favorite button with count for recipe screens
/// USAGE: Shows how many people favorited the recipe (placeholder for now)
class FavoriteButtonWithCount extends ConsumerWidget {
  final Recipe recipe;
  final int? favoriteCount; // Placeholder for future backend feature
  final VoidCallback? onToggle;

  const FavoriteButtonWithCount({
    super.key,
    required this.recipe,
    this.favoriteCount,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isRecipeFavoritedProvider(recipe.id));
    final isLoading = ref.watch(isRecipeSavingProvider(recipe.id));
    final favoritesNotifier = ref.read(favoriteRecipesProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap:
              isLoading
                  ? null
                  : () async {
                    onToggle?.call();

                    // ignore: unused_local_variable
                    final success = await favoritesNotifier.toggleFavorite(
                      recipe,
                    );

                    if (context.mounted) {
                      final message =
                          isFavorited
                              ? '${recipe.name} eliminada de favoritas'
                              : '${recipe.name} guardada en favoritas';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFavorited ? Colors.red.shade50 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child:
                isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.red.shade400),
                      ),
                    )
                    : Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorited
                              ? Colors.red.shade400
                              : Colors.grey.shade500,
                      size: 20,
                    ),
          ),
        ),
        if (favoriteCount != null) ...[
          const SizedBox(height: 4),
          Text(
            '$favoriteCount',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
