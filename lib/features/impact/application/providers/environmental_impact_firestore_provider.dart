import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_impact_firestore.dart';

/// Provider para el usuario actual
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Notifier para manejar el impacto ambiental en Firestore
class EnvironmentalImpactFirestoreNotifier extends StateNotifier<AsyncValue<List<EnvironmentalImpactFirestore>>> {
  EnvironmentalImpactFirestoreNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  void _initialize() {
    // Escuchar cambios del usuario y cargar datos
    _ref.listen<AsyncValue<User?>>(
      currentUserProvider,
      (previous, next) {
        next.when(
          data: (user) {
            if (user != null) {
              _loadUserImpacts(user.uid);
            } else {
              state = const AsyncValue.data([]);
            }
          },
          loading: () => state = const AsyncValue.loading(),
          error: (error, stack) => state = AsyncValue.error(error, stack),
        );
      },
      fireImmediately: true,
    );
  }

  /// Cargar todos los impactos del usuario
  void _loadUserImpacts(String userId) {
    _firestore
        .collection('environmental_impact')
        .doc(userId)
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final impacts = snapshot.docs
                  .map((doc) => EnvironmentalImpactFirestore.fromFirestore(doc))
                  .toList();
              state = AsyncValue.data(impacts);
            } catch (error, stack) {
              state = AsyncValue.error(error, stack);
            }
          },
          onError: (error, stack) {
            state = AsyncValue.error(error, stack);
          },
        );
  }

  /// Guardar un nuevo impacto ambiental
  Future<void> saveImpact({
    required String recipeTitle,
    required Map<String, dynamic> impactData,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final impact = EnvironmentalImpactFirestore.fromLocal(
        recipeTitle: recipeTitle,
        impactData: impactData,
        userId: user.uid,
      );

      await _firestore
          .collection('environmental_impact')
          .doc(user.uid)
          .collection('recipes')
          .add(impact.toFirestore());

      print('✅ Impacto guardado en Firestore: $recipeTitle');
    } catch (error) {
      print('❌ Error guardando impacto en Firestore: $error');
      // No lanzar error para no afectar la experiencia del usuario
    }
  }

  /// Actualizar estado de una receta (cocinada/pendiente)
  Future<void> updateRecipeStatus(String impactId, bool isCooked) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore
          .collection('environmental_impact')
          .doc(user.uid)
          .collection('recipes')
          .doc(impactId)
          .update({
        'isCooked': isCooked,
        'updatedAt': Timestamp.now(),
      });

      print('✅ Estado actualizado: $impactId -> ${isCooked ? 'Cocinado' : 'Pendiente'}');
    } catch (error) {
      print('❌ Error actualizando estado: $error');
    }
  }

  /// Eliminar un impacto
  Future<void> deleteImpact(String impactId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore
          .collection('environmental_impact')
          .doc(user.uid)
          .collection('recipes')
          .doc(impactId)
          .delete();

      print('✅ Impacto eliminado: $impactId');
    } catch (error) {
      print('❌ Error eliminando impacto: $error');
    }
  }

  /// Obtener estadísticas del usuario
  Map<String, dynamic> getStats() {
    return state.when(
      data: (impacts) {
        final cookedRecipes = impacts.where((i) => i.isCooked).toList();
        
        if (cookedRecipes.isEmpty) {
          return {
            'totalRecipes': 0,
            'totalCO2': 0.0,
            'totalWater': 0.0,
            'avgSustainability': 0.0,
            'totalWastePrevention': 0.0,
          };
        }

        final totalCO2 = cookedRecipes.fold<double>(0, (total, impact) => total + impact.co2Emissions);
        final totalWater = cookedRecipes.fold<double>(0, (total, impact) => total + impact.waterUsage);
        final totalWastePrevention = cookedRecipes.fold<double>(0, (total, impact) => total + impact.wastePreventionScore);
        final avgSustainability = cookedRecipes.fold<double>(0, (total, impact) => total + impact.sustainabilityScore) / cookedRecipes.length;

        return {
          'totalRecipes': cookedRecipes.length,
          'totalCO2': totalCO2,
          'totalWater': totalWater,
          'avgSustainability': avgSustainability,
          'totalWastePrevention': totalWastePrevention,
        };
      },
      loading: () => {
        'totalRecipes': 0,
        'totalCO2': 0.0,
        'totalWater': 0.0,
        'avgSustainability': 0.0,
        'totalWastePrevention': 0.0,
      },
      error: (_, _) => {
        'totalRecipes': 0,
        'totalCO2': 0.0,
        'totalWater': 0.0,
        'avgSustainability': 0.0,
        'totalWastePrevention': 0.0,
      },
    );
  }
}

/// Provider para el notifier de Firestore
final environmentalImpactFirestoreProvider = 
    StateNotifierProvider<EnvironmentalImpactFirestoreNotifier, AsyncValue<List<EnvironmentalImpactFirestore>>>((ref) {
  return EnvironmentalImpactFirestoreNotifier(ref);
});

/// Provider para obtener solo las recetas cocinadas
final cookedRecipesFirestoreProvider = Provider<List<EnvironmentalImpactFirestore>>((ref) {
  final impactsAsync = ref.watch(environmentalImpactFirestoreProvider);
  return impactsAsync.when(
    data: (impacts) => impacts.where((impact) => impact.isCooked).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider para obtener estadísticas
final impactStatsFirestoreProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(environmentalImpactFirestoreProvider.notifier).getStats();
});

/// Provider para verificar si el usuario está autenticado
final isUserAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, _) => false,
  );
});