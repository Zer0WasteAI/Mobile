import 'dart:developer';
import 'dart:io';
import 'dart:async';
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
  // 🆕 NUEVO: Campos para generación asíncrona de imágenes
  final String? recognitionId;
  final String? taskId;
  final String? imageGenerationStatus; // pending, processing, completed, failed
  final String? statusMessage;
  final int progressPercentage;
  final bool isPolling;
  // 🆕 NUEVO: Campos para polling automático como SimplifiedRecognitionProvider
  final String? imagesStatus; // 'generating', 'ready', 'failed'
  final Timer? imageCheckTimer;

  const RecognitionState({
    this.isLoading = false,
    this.result,
    this.error,
    this.uploadedImagePaths = const [],
    this.allergyAlerts = const [],
    this.hasAllergens = false,
    this.recognitionId,
    this.taskId,
    this.imageGenerationStatus,
    this.statusMessage,
    this.progressPercentage = 0,
    this.isPolling = false,
    this.imagesStatus,
    this.imageCheckTimer,
  });

  RecognitionState copyWith({
    bool? isLoading,
    dynamic result,
    String? error,
    List<String>? uploadedImagePaths,
    List<AllergyAlert>? allergyAlerts,
    bool? hasAllergens,
    String? recognitionId,
    String? taskId,
    String? imageGenerationStatus,
    String? statusMessage,
    int? progressPercentage,
    bool? isPolling,
    String? imagesStatus,
    Timer? imageCheckTimer,
  }) {
    return RecognitionState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
      uploadedImagePaths: uploadedImagePaths ?? this.uploadedImagePaths,
      allergyAlerts: allergyAlerts ?? this.allergyAlerts,
      hasAllergens: hasAllergens ?? this.hasAllergens,
      recognitionId: recognitionId ?? this.recognitionId,
      taskId: taskId ?? this.taskId,
      imageGenerationStatus:
          imageGenerationStatus ?? this.imageGenerationStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isPolling: isPolling ?? this.isPolling,
      imagesStatus: imagesStatus ?? this.imagesStatus,
      imageCheckTimer: imageCheckTimer ?? this.imageCheckTimer,
    );
  }
}

// Recognition provider - 🆕 ACTUALIZADO con soporte para alertas de alergia
class RecognitionNotifier extends StateNotifier<RecognitionState> {
  final RecognitionRepository _repository;
  Timer? _pollingTimer;

  RecognitionNotifier(this._repository) : super(const RecognitionState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    state.imageCheckTimer?.cancel();
    super.dispose();
  }

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

  // 🆕 ACTUALIZADO: Recognize foods from uploaded images with allergy + async support
  Future<void> recognizeFoods(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeFoods(imagePaths);

      // 🆕 Extraer información de generación asíncrona
      state = state.copyWith(
        isLoading: false,
        result: result,
        allergyAlerts: result.allergyAlerts,
        hasAllergens: result.hasAllergens,
        recognitionId: result.recognitionId,
        taskId: result.images?.taskId,
        imageGenerationStatus: result.images?.status,
        statusMessage: result.message,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 🆕 ACTUALIZADO: Recognize ingredients from uploaded images with allergy + async support
  Future<void> recognizeIngredients(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeIngredients(imagePaths);

      // 🆕 Extraer información de generación asíncrona
      state = state.copyWith(
        isLoading: false,
        result: result,
        allergyAlerts: result.allergyAlerts,
        hasAllergens: result.hasAllergens,
        recognitionId: result.recognitionId,
        taskId: result.images?.taskId,
        imageGenerationStatus: result.images?.status,
        statusMessage: result.message,
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

  // Upload and recognize food in one step - UPDATED to use simplified method
  Future<void> uploadAndRecognizeFood(File imageFile, String itemName) async {
    // For now, use the simplified ingredients method as the backend logic is similar
    await recognizeIngredientsSimplified([imageFile]);
  }

  // Upload and recognize ingredient in one step - UPDATED to use simplified method
  Future<void> uploadAndRecognizeIngredient(
    File imageFile,
    String itemName,
  ) async {
    // Use the new simplified method directly with the image file
    await recognizeIngredientsSimplified([imageFile]);
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

  // 🆕 NUEVO: Reconocimiento completo de ingredientes con impacto ambiental
  Future<void> recognizeIngredientsWithEnvironmentalImpact(
    List<String> imagePaths,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeIngredientsComplete(imagePaths);

      state = state.copyWith(
        isLoading: false,
        result: result,
        recognitionId: result.recognitionId,
        statusMessage: 'Reconocimiento completo con impacto ambiental exitoso',
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
    // Cancel any active timer
    state.imageCheckTimer?.cancel();
    state = const RecognitionState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// ✨ NEW: Simplified ingredient recognition (based on working simplified flow)
  Future<void> recognizeIngredientsSimplified(List<File> imageFiles) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      log(
        '🚀 [RECOGNITION] Starting simplified recognition with ${imageFiles.length} images',
      );

      // Use the simplified recognition method that works
      final result = await _repository.recognizeIngredientsSimplified(
        imageFiles,
      );

      log('✅ [RECOGNITION] Simplified recognition completed!');
      log('📋 [RECOGNITION] Recognition ID: ${result.recognitionId}');
      log('🖼️ [RECOGNITION] Found ${result.ingredients.length} ingredients');

      // Determine images status
      final imagesStatus = _getImagesStatus(result);

      // Update state with results and images status
      state = state.copyWith(
        isLoading: false,
        result: result,
        allergyAlerts: result.allergyAlerts,
        hasAllergens: result.hasAllergens,
        recognitionId: result.recognitionId,
        imagesStatus: imagesStatus,
        error: null,
      );

      // Start background polling for image updates if needed
      if (imagesStatus == 'generating') {
        log('🎨 [RECOGNITION] Starting background image polling');
        _startImagePolling(result.recognitionId);
      }
    } catch (e) {
      log('❌ [RECOGNITION] Simplified recognition error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Helper method to determine overall images status
  String _getImagesStatus(IngredientRecognitionResultModel result) {
    if (result.ingredients.isEmpty) return 'ready';

    int generating = 0;
    int ready = 0;

    for (final ingredient in result.ingredients) {
      final status = ingredient.imageStatus;
      if (status == 'generating' || status == null || status == '') {
        generating++;
      } else if (status == 'ready' || status == 'generated') {
        ready++;
      }
    }

    log('🎨 [RECOGNITION] Images: $ready ready, $generating generating');

    if (generating > 0) return 'generating';
    return 'ready';
  }

  /// Start background polling for image updates (copied from SimplifiedRecognitionProvider)
  void _startImagePolling(String recognitionId) {
    // Wait 10 seconds before starting to poll to give backend time to set up
    Future.delayed(const Duration(seconds: 10), () {
      if (state.recognitionId == recognitionId &&
          state.imageCheckTimer == null) {
        log('🎨 [RECOGNITION] Starting image polling for: $recognitionId');

        final timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
          if (state.recognitionId == null ||
              state.recognitionId != recognitionId) {
            timer.cancel();
            return;
          }

          try {
            log('🔍 [RECOGNITION] Checking images for: $recognitionId');

            final updatedResult = await _repository.checkRecognitionImages(
              recognitionId,
            );
            final newImagesStatus = _getImagesStatus(updatedResult);

            log('📊 [RECOGNITION] Images status: $newImagesStatus');

            // Update state with new results and images status
            state = state.copyWith(
              result: updatedResult,
              imagesStatus: newImagesStatus,
            );

            // 🔍 DEBUG: Log detailed ingredient info like SimplifiedRecognitionProvider
            log('🔍 [RECOGNITION] Updated ingredients:');
            for (int i = 0; i < updatedResult.ingredients.length; i++) {
              final ingredient = updatedResult.ingredients[i];
              log('   ${i + 1}. ${ingredient.name}:');
              log('      📷 imagePath: ${ingredient.imagePath}');
              log('      📊 imageStatus: ${ingredient.imageStatus}');
              log(
                '      🔗 hasImage: ${ingredient.imagePath?.isNotEmpty ?? false}',
              );
            }

            // Stop polling if all images are ready
            if (newImagesStatus == 'ready') {
              log('✅ [RECOGNITION] All images ready! Stopping polling.');
              timer.cancel();

              // Update state to remove timer reference
              state = state.copyWith(imageCheckTimer: null);
            }
          } catch (e) {
            log('❌ [RECOGNITION] Image polling error: $e');
            timer.cancel();
            state = state.copyWith(imageCheckTimer: null);
          }
        });

        // Store timer reference in state
        state = state.copyWith(imageCheckTimer: timer);
      }
    });
  }

  /// Legacy async method for compatibility (kept for existing code)
  Future<void> recognizeIngredientsAsync(File imageFile) async {
    // Convert single image to list and use simplified method
    await recognizeIngredientsSimplified([imageFile]);
  }

  /// Force refresh images for current recognition (copied from SimplifiedRecognitionProvider)
  Future<void> forceRefreshImages() async {
    if (state.recognitionId == null || state.recognitionId!.isEmpty) {
      log('⚠️ [REFRESH] No recognition ID available for refresh');
      return;
    }

    try {
      log('🔄 [RECOGNITION] Force checking images for: ${state.recognitionId}');

      final updatedResult = await _repository.checkRecognitionImages(
        state.recognitionId!,
      );
      final newImagesStatus = _getImagesStatus(updatedResult);

      log('📊 [RECOGNITION] Force check - Images status: $newImagesStatus');

      // Update state with new results and images status
      state = state.copyWith(
        result: updatedResult,
        imagesStatus: newImagesStatus,
      );

      // 🔍 DEBUG: Log detailed ingredient info
      log('🔍 [RECOGNITION] Force check - Updated ingredients:');
      for (int i = 0; i < updatedResult.ingredients.length; i++) {
        final ingredient = updatedResult.ingredients[i];
        log('   ${i + 1}. ${ingredient.name}:');
        log('      📷 imagePath: ${ingredient.imagePath}');
        log('      📊 imageStatus: ${ingredient.imageStatus}');
        log('      🔗 hasImage: ${ingredient.imagePath?.isNotEmpty ?? false}');
      }

      // Start polling if still generating and no timer is active
      if (newImagesStatus == 'generating' && state.imageCheckTimer == null) {
        log('🎨 [RECOGNITION] Starting polling after force check');
        _startImagePolling(state.recognitionId!);
      } else if (newImagesStatus == 'ready') {
        // Stop any existing polling
        state.imageCheckTimer?.cancel();
        state = state.copyWith(imageCheckTimer: null);
        log('✅ [RECOGNITION] All images ready after force check');
      }
    } catch (e) {
      log('❌ [RECOGNITION] Force check error: $e');
      state = state.copyWith(error: e.toString());
    }
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
