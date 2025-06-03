import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/data/repositories/recognition_repository_impl.dart';
import 'package:zer0_waste_ai/features/recognition/domain/repositories/recognition_repository.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/allergy_alert.dart';

// Repository provider
final recognitionRepositoryProvider = Provider<RecognitionRepository>((ref) {
  return RecognitionRepositoryImpl();
});

// Recognition state - Updated to support multiple result types
class RecognitionState {
  final bool isLoading;
  final dynamic
  result; // Can be RecognitionResultModel, FoodRecognitionResultModel, or IngredientRecognitionResultModel
  final String? error;
  final List<String> uploadedImagePaths;
  // 🆕 NUEVO: Campos para alertas de alergia según CAMBIOS_ENDPOINTS.md
  final List<AllergyAlert> allergyAlerts;
  final bool hasAllergens;

  const RecognitionState({
    this.isLoading = false,
    this.result,
    this.error,
    this.uploadedImagePaths = const [],
    this.allergyAlerts = const [],
    this.hasAllergens = false,
  });

  RecognitionState copyWith({
    bool? isLoading,
    dynamic result,
    String? error,
    List<String>? uploadedImagePaths,
    List<AllergyAlert>? allergyAlerts,
    bool? hasAllergens,
  }) {
    return RecognitionState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
      uploadedImagePaths: uploadedImagePaths ?? this.uploadedImagePaths,
      allergyAlerts: allergyAlerts ?? this.allergyAlerts,
      hasAllergens: hasAllergens ?? this.hasAllergens,
    );
  }
}

// Recognition provider - 🆕 ACTUALIZADO con soporte para alertas de alergia
class RecognitionNotifier extends StateNotifier<RecognitionState> {
  final RecognitionRepository _repository;

  RecognitionNotifier(this._repository) : super(const RecognitionState());

  // Upload image and get path
  Future<String?> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.uploadImage(
        imageFile: imageFile,
        itemName: itemName,
        imageType: imageType,
      );

      final newPaths = [...state.uploadedImagePaths, result.image.imagePath];
      state = state.copyWith(isLoading: false, uploadedImagePaths: newPaths);

      return result.image.imagePath;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // 🆕 ACTUALIZADO: Recognize foods from uploaded images with allergy support
  Future<void> recognizeFoods(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeFoods(imagePaths);

      // 🆕 Extraer alertas de alergia del resultado
      state = state.copyWith(
        isLoading: false,
        result: result,
        allergyAlerts: result.allergyAlerts,
        hasAllergens: result.hasAllergens,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 🆕 ACTUALIZADO: Recognize ingredients from uploaded images with allergy support
  Future<void> recognizeIngredients(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeIngredients(imagePaths);

      // 🆕 Extraer alertas de alergia del resultado
      state = state.copyWith(
        isLoading: false,
        result: result,
        allergyAlerts: result.allergyAlerts,
        hasAllergens: result.hasAllergens,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 🆕 ACTUALIZADO: Batch recognition with allergy support
  Future<void> recognizeBatch(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeBatch(imagePaths);

      // 🆕 Extraer alertas de alergia del resultado
      state = state.copyWith(
        isLoading: false,
        result: result,
        allergyAlerts: result.allergyAlerts,
        hasAllergens: result.hasAllergens,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Upload and recognize food in one step
  Future<void> uploadAndRecognizeFood(File imageFile, String itemName) async {
    final imagePath = await uploadImage(
      imageFile: imageFile,
      itemName: itemName,
      imageType: 'food',
    );

    if (imagePath != null) {
      await recognizeFoods([imagePath]);
    }
  }

  // Upload and recognize ingredient in one step
  Future<void> uploadAndRecognizeIngredient(
    File imageFile,
    String itemName,
  ) async {
    final imagePath = await uploadImage(
      imageFile: imageFile,
      itemName: itemName,
      imageType: 'ingredient',
    );

    if (imagePath != null) {
      await recognizeIngredients([imagePath]);
    }
  }

  // Search similar images
  Future<List<SimilarImageModel>> searchSimilarImages(String itemName) async {
    try {
      return await _repository.searchSimilarImages(itemName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  // 🆕 NUEVO: Simular reconocimiento con alertas de alergia para testing
  Future<void> recognizeWithAllergyCheck(List<String> imagePaths) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simular delay de reconocimiento
      await Future.delayed(const Duration(seconds: 2));

      // Simular resultado de reconocimiento con alertas de alergia
      final mockResult = RecognitionResultModel(
        recognitionId: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        recognizedItems: [
          const RecognizedItemModel(
            name: 'Maní',
            confidence: 0.92,
            allergyAlert: true,
            allergens: ['frutos secos', 'maní'],
            category: 'frutos secos',
          ),
          const RecognizedItemModel(
            name: 'Leche',
            confidence: 0.89,
            allergyAlert: true,
            allergens: ['lácteos'],
            category: 'lácteos',
          ),
          const RecognizedItemModel(
            name: 'Manzana',
            confidence: 0.95,
            allergyAlert: false,
            allergens: [],
            category: 'frutas',
          ),
        ],
        allergyAlerts: [
          const AllergyAlert(
            item: 'Maní',
            allergens: ['frutos secos', 'maní'],
            message:
                'ADVERTENCIA: Este alimento contiene maní. Evite si tiene alergia a los frutos secos.',
            confidence: 0.92,
          ),
          const AllergyAlert(
            item: 'Leche',
            allergens: ['lácteos'],
            message:
                'ADVERTENCIA: Este producto contiene lácteos. Evite si tiene intolerancia a la lactosa.',
            confidence: 0.89,
          ),
        ],
        hasAllergens: true,
        processingTime: '2.3s',
        totalDetected: 3,
      );

      state = state.copyWith(
        isLoading: false,
        result: mockResult,
        allergyAlerts: mockResult.allergyAlerts,
        hasAllergens: mockResult.hasAllergens,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 🆕 NUEVO: Limpiar las alertas de alergia
  void clearAllergyAlerts() {
    state = state.copyWith(allergyAlerts: [], hasAllergens: false);
  }

  // Clear state
  void clearState() {
    state = const RecognitionState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for recognition notifier
final recognitionProvider =
    StateNotifierProvider<RecognitionNotifier, RecognitionState>((ref) {
      final repository = ref.watch(recognitionRepositoryProvider);
      return RecognitionNotifier(repository);
    });

// 🆕 ACTUALIZADOS: Convenience providers for specific states with allergy support
final isRecognitionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(recognitionProvider).isLoading;
});

final recognitionResultProvider = Provider<dynamic>((ref) {
  return ref.watch(recognitionProvider).result;
});

final recognitionErrorProvider = Provider<String?>((ref) {
  return ref.watch(recognitionProvider).error;
});

final uploadedImagePathsProvider = Provider<List<String>>((ref) {
  return ref.watch(recognitionProvider).uploadedImagePaths;
});

// 🆕 NUEVOS: Providers específicos para alertas de alergia según CAMBIOS_ENDPOINTS.md
final allergyAlertsProvider = Provider<List<AllergyAlert>>((ref) {
  return ref.watch(recognitionProvider).allergyAlerts;
});

final hasAllergensProvider = Provider<bool>((ref) {
  return ref.watch(recognitionProvider).hasAllergens;
});

/// Provider para obtener solo los items con alertas de alergia
final allergenicItemsProvider = Provider<List<RecognizedItemModel>>((ref) {
  final result = ref.watch(recognitionResultProvider);
  if (result == null) return [];

  return result.recognizedItems.where((item) => item.allergyAlert).toList();
});

/// Provider para obtener el número total de alertas activas
final totalAllergyAlertsProvider = Provider<int>((ref) {
  return ref.watch(allergyAlertsProvider).length;
});
