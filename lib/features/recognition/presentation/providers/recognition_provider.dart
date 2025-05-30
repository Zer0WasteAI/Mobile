import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/data/repositories/recognition_repository_impl.dart';
import 'package:zer0_waste_ai/features/recognition/domain/repositories/recognition_repository.dart';

// Repository provider
final recognitionRepositoryProvider = Provider<RecognitionRepository>((ref) {
  return RecognitionRepositoryImpl();
});

// Recognition state
class RecognitionState {
  final bool isLoading;
  final RecognitionResultModel? result;
  final String? error;
  final List<String> uploadedImagePaths;

  const RecognitionState({
    this.isLoading = false,
    this.result,
    this.error,
    this.uploadedImagePaths = const [],
  });

  RecognitionState copyWith({
    bool? isLoading,
    RecognitionResultModel? result,
    String? error,
    List<String>? uploadedImagePaths,
  }) {
    return RecognitionState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
      uploadedImagePaths: uploadedImagePaths ?? this.uploadedImagePaths,
    );
  }
}

// Recognition provider
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

  // Recognize foods from uploaded images
  Future<void> recognizeFoods(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeFoods(imagePaths);

      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Recognize ingredients from uploaded images
  Future<void> recognizeIngredients(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeIngredients(imagePaths);

      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Batch recognition
  Future<void> recognizeBatch(List<String> imagePaths) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.recognizeBatch(imagePaths);

      state = state.copyWith(isLoading: false, result: result);
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

// Convenience providers for specific states
final isRecognitionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(recognitionProvider).isLoading;
});

final recognitionResultProvider = Provider<RecognitionResultModel?>((ref) {
  return ref.watch(recognitionProvider).result;
});

final recognitionErrorProvider = Provider<String?>((ref) {
  return ref.watch(recognitionProvider).error;
});

final uploadedImagePathsProvider = Provider<List<String>>((ref) {
  return ref.watch(recognitionProvider).uploadedImagePaths;
});
