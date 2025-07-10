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

      // Imprimir información de depuración
      print('🔍 Buscando recetas para usuario: ${currentUser.uid}');
      print('🔍 Colección: $_collectionPath');

      // Consulta temporal sin ordenamiento mientras se crea el índice
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .where('userId', isEqualTo: currentUser.uid)
              .get();

      // Nota: Normalmente usaríamos .orderBy('createdAt', descending: true)
      // pero eso requiere un índice compuesto que puede estar en proceso de creación

      print('📊 Encontradas ${snapshot.docs.length} recetas en Firestore');

      final recipes =
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                // Make sure the ID from the document is used
                data['id'] = doc.id;

                try {
                  // Asegurarse de que las categorías estén correctamente mapeadas como lista
                  if (data.containsKey('categories')) {
                    if (data['categories'] is List) {
                      // Ya está en formato correcto
                    } else if (data['categories'] is String) {
                      // Convertir string a lista
                      data['categories'] = [data['categories']];
                    } else {
                      // Valor por defecto si no es reconocible
                      data['categories'] = ['General'];
                    }
                  } else {
                    // Si no existe el campo, agregar valor por defecto
                    data['categories'] = ['General'];
                  }
                  
                  return Recipe.fromJson(data);
                } catch (e) {
                  print('❌ Error al convertir documento a Recipe: $e');
                  print('📄 Datos del documento: $data');
                  return null;
                }
              })
              .where((recipe) => recipe != null)
              .cast<Recipe>()
              .toList();

      // Ordenar los resultados en el cliente (temporalmente mientras se crea el índice)
      recipes.sort((a, b) {
        // Intentar extraer las fechas de creación si están disponibles
        final aTimestamp = a.toJson()['createdAt'];
        final bTimestamp = b.toJson()['createdAt'];
        
        if (aTimestamp != null && bTimestamp != null) {
          // Ordenar de más reciente a más antiguo
          return bTimestamp.compareTo(aTimestamp);
        }
        return 0; // Sin cambios si no hay timestamps
      });
      
      print('✅ Convertidas y ordenadas ${recipes.length} recetas correctamente');
      return recipes;
    } catch (e) {
      print('❌ Error al obtener recetas del usuario: $e');
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
