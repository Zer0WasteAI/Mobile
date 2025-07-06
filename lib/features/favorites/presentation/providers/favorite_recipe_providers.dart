import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/favorite_recipe_model.dart';
import '../../domain/repositories/favorite_recipe_repository.dart';
import '../../data/repositories/favorite_recipe_repository_impl.dart';

// Repository provider
final favoriteRecipeRepositoryProvider = Provider<FavoriteRecipeRepository>((ref) {
  return FavoriteRecipeRepositoryImpl(FirebaseFirestore.instance);
});

// Provider para obtener todos los favoritos del usuario
final userFavoritesProvider = StreamProvider<List<FavoriteRecipe>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('favorite_recipes')
          .where('userId', isEqualTo: user.id)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => FavoriteRecipe.fromJson(doc.data()))
              .toList());
    },
    loading: () => Stream.value([]),
    error: (_, _) => Stream.value([]),
  );
});

// Provider para verificar si una receta es favorita
final isFavoriteProvider = FutureProvider.family<bool, String>((ref, recipeId) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(favoriteRecipeRepositoryProvider);
  
  return await authState.when(
    data: (user) async {
      if (user == null) return false;
      try {
        return await repository.isFavorite(recipeId, user.id);
      } catch (e) {
        // Handle permission denied and other errors gracefully
        if (e.toString().contains('permission-denied')) {
          print('Permission denied for favorites - user may need to re-authenticate');
          return false; // Default to not favorite if permission denied
        }
        print('Error checking favorite status: $e');
        return false; // Default to not favorite on any error
      }
    },
    loading: () async => false,
    error: (_, _) async => false,
  );
});

// Provider para agregar/quitar favoritos
final favoriteActionProvider = StateNotifierProvider<FavoriteActionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(favoriteRecipeRepositoryProvider);
  return FavoriteActionNotifier(repository, ref);
});

class FavoriteActionNotifier extends StateNotifier<AsyncValue<void>> {
  final FavoriteRecipeRepository _repository;
  final Ref _ref;

  FavoriteActionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(String recipeId, String title, String description,
      List<String> ingredients, List<String> instructions, int prepTime,
      int cookTime, int servings, String difficulty, {String? imagePath, String? mealType}) async {
    
    final authState = _ref.read(authStateProvider);
    
    if (authState.value == null) {
      state = AsyncValue.error('Usuario no autenticado', StackTrace.current);
      return;
    }
    
    final userId = authState.value!.id;
    state = const AsyncValue.loading();

    try {
      final isFavorite = await _repository.isFavorite(recipeId, userId);
      
      if (isFavorite) {
        await _repository.removeFavorite(recipeId, userId);
      } else {
        // Parse ingredients to extract quantity and unit if available
        final favoriteIngredients = ingredients.map((ing) {
          // Check if ingredient has format "quantity unit name"
          final parts = ing.split(' ');
          if (parts.length >= 3) {
            final quantityStr = parts[0];
            final unit = parts[1];
            final name = parts.sublist(2).join(' ');
            
            final quantity = double.tryParse(quantityStr);
            if (quantity != null) {
              return FavoriteIngredient(
                name: name,
                quantity: quantity,
                unit: unit,
              );
            }
          }
          
          // Fallback: treat as simple ingredient name
          return FavoriteIngredient(
            name: ing,
            quantity: 1.0,
            unit: '',
          );
        }).toList();
        
        final favoriteRecipe = FavoriteRecipe(
          id: recipeId,
          userId: userId,
          title: title,
          description: description,
          ingredients: favoriteIngredients,
          instructions: instructions,
          prepTime: prepTime,
          cookTime: cookTime,
          servings: servings,
          difficulty: difficulty,
          imagePath: imagePath,
          mealType: mealType,
          createdAt: DateTime.now(),
        );
        await _repository.addFavorite(favoriteRecipe);
      }
      
      // Refresh favorites list
      _ref.invalidate(userFavoritesProvider);
      _ref.invalidate(isFavoriteProvider(recipeId));
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      // Handle permission denied errors with user-friendly message
      if (error.toString().contains('permission-denied')) {
        state = AsyncValue.error(
          'No tienes permisos para guardar favoritos. Intenta cerrar sesión y volver a iniciar.',
          stackTrace,
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}