import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/domain/repositories/recognition_repository.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/recognition_provider.dart';

/// ✨ Simplified Recognition State
class SimplifiedRecognitionState {
  final bool isLoading;
  final String currentStep;
  final IngredientRecognitionResultModel? result;
  final String? error;
  final String? recognitionId;
  final String? imagesStatus; // 'generating', 'ready', 'failed'
  final Timer? imageCheckTimer;

  const SimplifiedRecognitionState({
    this.isLoading = false,
    this.currentStep = '',
    this.result,
    this.error,
    this.recognitionId,
    this.imagesStatus,
    this.imageCheckTimer,
  });

  SimplifiedRecognitionState copyWith({
    bool? isLoading,
    String? currentStep,
    IngredientRecognitionResultModel? result,
    String? error,
    String? recognitionId,
    String? imagesStatus,
    Timer? imageCheckTimer,
  }) {
    return SimplifiedRecognitionState(
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      result: result ?? this.result,
      error: error ?? this.error,
      recognitionId: recognitionId ?? this.recognitionId,
      imagesStatus: imagesStatus ?? this.imagesStatus,
      imageCheckTimer: imageCheckTimer ?? this.imageCheckTimer,
    );
  }

  List<RecognizedIngredientModel> get ingredients => result?.ingredients ?? [];
  bool get hasResults => result != null && ingredients.isNotEmpty;
}

/// ✨ Simplified Recognition Provider
class SimplifiedRecognitionNotifier
    extends StateNotifier<SimplifiedRecognitionState> {
  final RecognitionRepository _repository;

  SimplifiedRecognitionNotifier(this._repository)
    : super(const SimplifiedRecognitionState());

  /// ✨ Main method: Recognize ingredients with immediate response
  Future<void> recognizeIngredients(List<File> imageFiles) async {
    try {
      _setLoading(true, 'Iniciando reconocimiento...');

      log(
        '🚀 [SIMPLIFIED] Starting recognition with ${imageFiles.length} images',
      );

      // Call simplified recognition - gets immediate response
      final result = await _repository.recognizeIngredientsSimplified(
        imageFiles,
      );

      log('✅ [SIMPLIFIED] Recognition completed!');
      log('📋 [SIMPLIFIED] Recognition ID: ${result.recognitionId}');
      log('🖼️ [SIMPLIFIED] Found ${result.ingredients.length} ingredients');

      // Update state with results
      state = state.copyWith(
        isLoading: false,
        currentStep: '',
        result: result,
        recognitionId: result.recognitionId,
        imagesStatus: _getImagesStatus(result),
        error: null,
      );

      // Start checking for image updates if images are still generating
      // Wait 10 seconds before starting to poll to give backend time to set up
      if (state.imagesStatus == 'generating') {
        Future.delayed(const Duration(seconds: 10), () {
          if (state.imagesStatus == 'generating' &&
              state.recognitionId != null) {
            _startImagePolling();
          }
        });
      }
    } catch (e) {
      log('❌ [SIMPLIFIED] Recognition error: $e');

      // Handle authentication errors specifically
      final errorString = e.toString();
      if (errorString.contains('401') || errorString.contains('unauthorized')) {
        state = state.copyWith(
          isLoading: false,
          currentStep: '',
          error: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          currentStep: '',
          error: errorString,
        );
      }
    }
  }

  /// ✨ Check images status and update if ready
  void _startImagePolling() {
    if (state.recognitionId == null) return;

    log('🎨 [SIMPLIFIED] Starting image polling for: ${state.recognitionId}');

    final timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (state.recognitionId == null) {
        timer.cancel();
        return;
      }

      try {
        log('🔍 [SIMPLIFIED] Checking images for: ${state.recognitionId}');

        final updatedResult = await _repository.checkRecognitionImages(
          state.recognitionId!,
        );
        final newImagesStatus = _getImagesStatus(updatedResult);

        log('📊 [SIMPLIFIED] Images status: $newImagesStatus');

        // Update state with new results
        state = state.copyWith(
          result: updatedResult,
          imagesStatus: newImagesStatus,
        );

        // 🔍 DEBUG: Log detailed ingredient info
        log('🔍 [SIMPLIFIED] Updated ingredients:');
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
          log('✅ [SIMPLIFIED] All images ready! Stopping polling.');
          timer.cancel();

          // Update state to remove timer reference
          state = state.copyWith(imageCheckTimer: null);
        }
      } catch (e) {
        log('❌ [SIMPLIFIED] Image polling error: $e');
        timer.cancel();
        state = state.copyWith(imageCheckTimer: null);
      }
    });

    // Store timer reference
    state = state.copyWith(imageCheckTimer: timer);
  }

  /// Determine overall images status from ingredients
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

    log('🎨 [SIMPLIFIED] Images: $ready ready, $generating generating');

    if (generating > 0) return 'generating';
    return 'ready';
  }

  /// Helper method to set loading state
  void _setLoading(bool loading, String step) {
    state = state.copyWith(isLoading: loading, currentStep: step);
  }

  /// Clear all state
  void clearState() {
    // Cancel any active timer
    state.imageCheckTimer?.cancel();

    state = const SimplifiedRecognitionState();
  }

  /// Clear error only
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Force check images status (for manual refresh)
  Future<void> forceCheckImages() async {
    if (state.recognitionId == null) return;

    try {
      log('🔄 [SIMPLIFIED] Force checking images for: ${state.recognitionId}');

      final updatedResult = await _repository.checkRecognitionImages(
        state.recognitionId!,
      );
      final newImagesStatus = _getImagesStatus(updatedResult);

      log('📊 [SIMPLIFIED] Force check - Images status: $newImagesStatus');

      // Update state with new results
      state = state.copyWith(
        result: updatedResult,
        imagesStatus: newImagesStatus,
      );

      // 🔍 DEBUG: Log detailed ingredient info
      log('🔍 [SIMPLIFIED] Force check - Updated ingredients:');
      for (int i = 0; i < updatedResult.ingredients.length; i++) {
        final ingredient = updatedResult.ingredients[i];
        log('   ${i + 1}. ${ingredient.name}:');
        log('      📷 imagePath: ${ingredient.imagePath}');
        log('      📊 imageStatus: ${ingredient.imageStatus}');
        log('      🔗 hasImage: ${ingredient.imagePath?.isNotEmpty ?? false}');
      }

      // Start polling if still generating
      if (newImagesStatus == 'generating' && state.imageCheckTimer == null) {
        _startImagePolling();
      } else if (newImagesStatus == 'ready') {
        // Stop any existing polling
        state.imageCheckTimer?.cancel();
        state = state.copyWith(imageCheckTimer: null);
      }
    } catch (e) {
      log('❌ [SIMPLIFIED] Force check error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    // Cancel timer when provider is disposed
    state.imageCheckTimer?.cancel();
    super.dispose();
  }
}

/// ✨ Provider for simplified recognition
final simplifiedRecognitionProvider = StateNotifierProvider<
  SimplifiedRecognitionNotifier,
  SimplifiedRecognitionState
>((ref) {
  final repository = ref.watch(recognitionRepositoryProvider);
  return SimplifiedRecognitionNotifier(repository);
});

/// ✨ Convenience providers
final simplifiedRecognitionResultProvider =
    Provider<IngredientRecognitionResultModel?>((ref) {
      return ref.watch(simplifiedRecognitionProvider).result;
    });

final simplifiedRecognitionIngredientsProvider =
    Provider<List<RecognizedIngredientModel>>((ref) {
      return ref.watch(simplifiedRecognitionProvider).ingredients;
    });

final simplifiedRecognitionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(simplifiedRecognitionProvider).isLoading;
});

final simplifiedRecognitionErrorProvider = Provider<String?>((ref) {
  return ref.watch(simplifiedRecognitionProvider).error;
});

final simplifiedRecognitionImagesStatusProvider = Provider<String?>((ref) {
  return ref.watch(simplifiedRecognitionProvider).imagesStatus;
});
