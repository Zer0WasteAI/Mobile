import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zer0_waste_ai/features/recipes/domain/models/recipe_model.dart';
import 'package:uuid/uuid.dart';

class AIRecipeFirestoreRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _collectionPath = 'ai_recipes';

  AIRecipeFirestoreRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// Save an AI-generated recipe to Firestore
  Future<String> saveRecipe(Recipe recipe) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Generate new ID if none exists
      final String recipeId =
          recipe.id.isNotEmpty ? recipe.id : const Uuid().v4();

      // Prepare the recipe data for Firestore
      final recipeData = {
        ...recipe.toJson(),
        'id': recipeId,
        'userId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore
          .collection(_collectionPath)
          .doc(recipeId)
          .set(recipeData, SetOptions(merge: true));

      return recipeId;
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  /// Get all AI recipes for the current user
  Future<List<Recipe>> getUserRecipes() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return []; // Return empty list for non-authenticated users
      }

      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .where('userId', isEqualTo: currentUser.uid)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Make sure the ID from the document is used
        data['id'] = doc.id;
        return Recipe.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user recipes: $e');
    }
  }

  /// Get all AI recipes (for admin users or public recipes)
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Make sure the ID from the document is used
        data['id'] = doc.id;
        return Recipe.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all recipes: $e');
    }
  }

  /// Delete a recipe by ID
  Future<void> deleteRecipe(String recipeId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership before deletion
      final docRef = _firestore.collection(_collectionPath).doc(recipeId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Recipe not found');
      }

      final data = doc.data();
      if (data?['userId'] != currentUser.uid) {
        throw Exception('You do not have permission to delete this recipe');
      }

      await docRef.delete();
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  /// Update an existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Verify the recipe exists and belongs to the user
      final docRef = _firestore.collection(_collectionPath).doc(recipe.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Recipe not found');
      }

      final data = doc.data();
      if (data?['userId'] != currentUser.uid) {
        throw Exception('You do not have permission to update this recipe');
      }

      // Update the recipe
      await docRef.update({
        ...recipe.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }
}
