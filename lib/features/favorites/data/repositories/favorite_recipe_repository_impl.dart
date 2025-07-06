import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/favorite_recipe_model.dart';
import '../../domain/repositories/favorite_recipe_repository.dart';

class FavoriteRecipeRepositoryImpl implements FavoriteRecipeRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'favorite_recipes';

  FavoriteRecipeRepositoryImpl(this._firestore);

  @override
  Future<void> addFavorite(FavoriteRecipe favoriteRecipe) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(favoriteRecipe.id)
          .set(favoriteRecipe.toJson());
    } catch (e) {
      throw Exception('Error al agregar favorito: $e');
    }
  }

  @override
  Future<void> removeFavorite(String recipeId, String userId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar favorito: $e');
    }
  }

  @override
  Future<bool> isFavorite(String recipeId, String userId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar favorito: $e');
    }
  }

  @override
  Future<List<FavoriteRecipe>> getFavorites(String userId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FavoriteRecipe.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener favoritos: $e');
    }
  }

  @override
  Future<void> updateFavorite(FavoriteRecipe favoriteRecipe) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(favoriteRecipe.id)
          .update(favoriteRecipe.toJson());
    } catch (e) {
      throw Exception('Error al actualizar favorito: $e');
    }
  }
}