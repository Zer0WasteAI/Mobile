import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/favorites/presentation/screens/favorites_screen.dart';

/// INFO: Redirects to the unified FavoritesScreen
/// USAGE: Used for backwards compatibility with recipes module
class FavoriteRecipesScreen extends ConsumerWidget {
  const FavoriteRecipesScreen({super.key});

  static const String routeName = 'favorite-recipes';
  static const String routePath = '/recipes/favorites';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FavoritesScreen();
  }
}