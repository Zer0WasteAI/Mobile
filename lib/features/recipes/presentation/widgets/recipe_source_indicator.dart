import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_providers.dart';

class RecipeSourceIndicator extends ConsumerWidget {
  final String recipeId;

  const RecipeSourceIndicator({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeState = ref.watch(
      recipeControllerProviderFamily(RecipeMode.explore),
    );
    final sourceMessage = recipeState.getRecipeSourceMessage(recipeId);

    if (sourceMessage.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sourceMessage,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
        ),
      ),
    );
  }
}
