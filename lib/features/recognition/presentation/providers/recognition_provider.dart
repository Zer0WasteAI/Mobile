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
    state = const RecognitionState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> recognizeIngredientsAsync(File imageFile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final initialResponse = await _repository.recognizeIngredientsAsync(
        imageFile,
      );
      final taskId = initialResponse['task_id'] as String?;

      if (taskId == null) {
        throw Exception("No se recibió un task_id del servidor.");
      }

      state = state.copyWith(
        isLoading: false,
        isPolling: true,
        taskId: taskId,
        imageGenerationStatus: initialResponse['status'] as String?,
        statusMessage: initialResponse['message'] as String?,
        progressPercentage: initialResponse['progress_percentage'] as int?,
      );

      _startPolling(taskId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPolling: false,
      );
    }
  }

  void _startPolling(String taskId) {
    _pollingTimer?.cancel(); // Cancel any existing timer
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!state.isPolling) {
        timer.cancel();
        return;
      }

      try {
        log('🔄 [POLLING] Checking status for task: $taskId');
        final statusResponse = await _repository.checkRecognitionStatus(taskId);
        final status = statusResponse['status'] as String;

        log(
          '📊 [POLLING] Status: $status, Progress: ${statusResponse['progress_percentage']}%',
        );

        state = state.copyWith(
          imageGenerationStatus: status,
          progressPercentage: statusResponse['progress_percentage'] as int?,
          statusMessage: statusResponse['current_step'] as String?,
        );

        if (status == 'completed' || status == 'failed') {
          _pollingTimer?.cancel();
          state = state.copyWith(isPolling: false);

          if (status == 'completed') {
            log('✅ [POLLING] Task completed! Processing result data...');
            final resultData =
                statusResponse['result_data'] as Map<String, dynamic>;
            log('🔍 [POLLING] Result data keys: ${resultData.keys.toList()}');

            // Add detailed JSON structure logging
            log('📋 [POLLING] Full result data structure:');
            log(resultData.toString());

            try {
              final recognitionResult =
                  IngredientRecognitionResultModel.fromJson(resultData);

              // Debug: Print image URLs
              log(
                '🖼️ [POLLING] Found ${recognitionResult.ingredients.length} ingredients:',
              );
              for (final ingredient in recognitionResult.ingredients) {
                log(
                  '   - ${ingredient.name}: ${ingredient.imagePath ?? "NO IMAGE"}',
                );
              }

              state = state.copyWith(
                result: recognitionResult,
                allergyAlerts: recognitionResult.allergyAlerts,
                hasAllergens: recognitionResult.hasAllergens,
              );
            } catch (parseError) {
              log('❌ [POLLING] JSON parsing error: $parseError');
              log(
                '📋 [POLLING] Raw JSON being parsed: ${resultData.toString()}',
              );

              // Try to parse each ingredient individually to find the problem
              if (resultData.containsKey('ingredients') &&
                  resultData['ingredients'] is List) {
                final ingredients = resultData['ingredients'] as List;
                log(
                  '🔍 [POLLING] Trying to parse ${ingredients.length} ingredients individually...',
                );

                for (int i = 0; i < ingredients.length; i++) {
                  try {
                    final ingredient = ingredients[i] as Map<String, dynamic>;
                    log('   Ingredient $i: ${ingredient.toString()}');

                    final parsed = RecognizedIngredientModel.fromJson(
                      ingredient,
                    );
                    log(
                      '   ✅ Ingredient $i parsed successfully: ${parsed.name}',
                    );
                  } catch (ingredientError) {
                    log('   ❌ Ingredient $i failed: $ingredientError');
                    log('   Raw data: ${ingredients[i].toString()}');
                  }
                }
              }

              state = state.copyWith(
                error: "Error parsing result: $parseError",
              );
            }
          } else {
            log('❌ [POLLING] Task failed: ${statusResponse['error_message']}');
            state = state.copyWith(
              error:
                  statusResponse['error_message'] as String? ??
                  'La tarea de reconocimiento falló sin un mensaje de error.',
            );
          }
        }
      } catch (e) {
        log('💥 [POLLING] Error during polling: $e');
        _pollingTimer?.cancel();
        state = state.copyWith(
          isPolling: false,
          error: "Error durante el sondeo: ${e.toString()}",
        );
      }
    });
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
