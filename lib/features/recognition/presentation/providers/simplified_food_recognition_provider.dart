import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/domain/repositories/recognition_repository.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/recognition_provider.dart';

/// ✨ Simplified Food Recognition State
class SimplifiedFoodRecognitionState {
  final bool isLoading;
  final String currentStep;
  final FoodRecognitionResultModel? result;
  final String? error;
  final String? recognitionId;
  final String? imagesStatus; // 'generating', 'ready', 'failed'
  final Timer? imageCheckTimer;

  const SimplifiedFoodRecognitionState({
    this.isLoading = false,
    this.currentStep = '',
    this.result,
    this.error,
    this.recognitionId,
    this.imagesStatus,
    this.imageCheckTimer,
  });

  SimplifiedFoodRecognitionState copyWith({
    bool? isLoading,
    String? currentStep,
    FoodRecognitionResultModel? result,
    String? error,
    String? recognitionId,
    String? imagesStatus,
    Timer? imageCheckTimer,
  }) {
    return SimplifiedFoodRecognitionState(
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      result: result ?? this.result,
      error: error ?? this.error,
      recognitionId: recognitionId ?? this.recognitionId,
      imagesStatus: imagesStatus ?? this.imagesStatus,
      imageCheckTimer: imageCheckTimer ?? this.imageCheckTimer,
    );
  }

  List<RecognizedFoodModel> get foods => result?.foods ?? [];
  bool get hasResults => result != null && foods.isNotEmpty;
}

/// ✨ Simplified Food Recognition Provider
class SimplifiedFoodRecognitionNotifier
    extends StateNotifier<SimplifiedFoodRecognitionState> {
  final RecognitionRepository _repository;

  SimplifiedFoodRecognitionNotifier(this._repository)
    : super(const SimplifiedFoodRecognitionState());

  /// ✨ Main method: Recognize foods with immediate response
  Future<void> recognizeFoods(List<File> imageFiles) async {
    try {
      _setLoading(true, 'Iniciando reconocimiento de comidas...');

      log(
        '🚀 [SIMPLIFIED FOODS] Starting recognition with ${imageFiles.length} images',
      );

      // Call simplified food recognition - gets immediate response
      final result = await _repository.recognizeFoodsSimplified(imageFiles);

      log('✅ [SIMPLIFIED FOODS] Recognition completed!');
      log('📋 [SIMPLIFIED FOODS] Recognition ID: ${result.recognitionId}');
      log('🖼️ [SIMPLIFIED FOODS] Found ${result.foods.length} foods');

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
      log('❌ [SIMPLIFIED FOODS] Recognition error: $e');

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

    log(
      '🎨 [SIMPLIFIED FOODS] Starting image polling for: ${state.recognitionId}',
    );

    final timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (state.recognitionId == null) {
        timer.cancel();
        return;
      }

      try {
        log(
          '🔍 [SIMPLIFIED FOODS] Checking images for: ${state.recognitionId}',
        );

        final updatedResult = await _repository.checkFoodRecognitionImages(
          state.recognitionId!,
        );
        final newImagesStatus = _getImagesStatus(updatedResult);

        log('📊 [SIMPLIFIED FOODS] Images status: $newImagesStatus');

        // Update state with new results
        state = state.copyWith(
          result: updatedResult,
          imagesStatus: newImagesStatus,
        );

        // 🔍 DEBUG: Log detailed food info
        log('🔍 [SIMPLIFIED FOODS] Updated foods:');
        for (int i = 0; i < updatedResult.foods.length; i++) {
          final food = updatedResult.foods[i];
          log('   ${i + 1}. ${food.name}:');
          log('      📷 imagePath: ${food.imagePath}');
          log('      📊 imageStatus: ${food.imageStatus}');
          log('      🔗 hasImage: ${food.imagePath?.isNotEmpty ?? false}');
        }

        // Stop polling if all images are ready
        if (newImagesStatus == 'ready') {
          log('✅ [SIMPLIFIED FOODS] All images ready! Stopping polling.');
          timer.cancel();

          // Update state to remove timer reference
          state = state.copyWith(imageCheckTimer: null);
        }
      } catch (e) {
        log('❌ [SIMPLIFIED FOODS] Image polling error: $e');
        timer.cancel();
        state = state.copyWith(imageCheckTimer: null);
      }
    });

    // Store timer reference
    state = state.copyWith(imageCheckTimer: timer);
  }

  /// Determine overall images status from foods
  String _getImagesStatus(FoodRecognitionResultModel result) {
    if (result.foods.isEmpty) return 'ready';

    int generating = 0;
    int ready = 0;

    for (final food in result.foods) {
      // Check if food has a REAL image URL (not null, not empty, and not a placeholder)
      if (food.imagePath != null &&
          food.imagePath!.isNotEmpty &&
          !food.imagePath!.contains('via.placeholder.com')) {
        ready++;
      } else {
        generating++;
      }
    }

    log('🎨 [SIMPLIFIED FOODS] Images: $ready ready, $generating generating');

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

    state = const SimplifiedFoodRecognitionState();
    log('🧹 [SIMPLIFIED FOODS] State cleared');
  }

  @override
  void dispose() {
    // Clean up timer when provider is disposed
    state.imageCheckTimer?.cancel();
    super.dispose();
  }
}

/// ✨ Simplified Food Recognition Provider
final simplifiedFoodRecognitionProvider = StateNotifierProvider<
  SimplifiedFoodRecognitionNotifier,
  SimplifiedFoodRecognitionState
>(
  (ref) => SimplifiedFoodRecognitionNotifier(
    ref.watch(recognitionRepositoryProvider),
  ),
);
