import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/domain/repositories/recognition_repository.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/recognition_result.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/reference_image.dart';

/// Implementation of RecognitionRepository using ZeroWasteAI backend
class RecognitionRepositoryImpl implements RecognitionRepository {
  final ApiService _apiService;

  RecognitionRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<FoodRecognitionResultModel> recognizeFoods(
    List<String> imagePaths,
  ) async {
    try {
      final response = await _apiService.recognizeFoods(imagePaths);
      return FoodRecognitionResultModel.fromJson(response);
    } catch (e) {
      throw Exception(
        'Food recognition failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<IngredientRecognitionResultModel> recognizeIngredients(
    List<String> imagePaths,
  ) async {
    try {
      final response = await _apiService.recognizeIngredients(imagePaths);
      return IngredientRecognitionResultModel.fromJson(response);
    } catch (e) {
      throw Exception(
        'Ingredient recognition failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<CompleteIngredientRecognitionResultModel> recognizeIngredientsComplete(
    List<String> imagePaths,
  ) async {
    try {
      final response = await _apiService.recognizeIngredientsComplete(
        imagePaths,
      );
      return CompleteIngredientRecognitionResultModel.fromJson(response);
    } catch (e) {
      throw Exception(
        'Complete ingredient recognition failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<RecognitionImageStatusModel> getRecognitionImageStatus(
    String taskId,
  ) async {
    try {
      final response = await _apiService.getRecognitionImageStatus(taskId);
      return RecognitionImageStatusModel.fromJson(response);
    } catch (e) {
      throw Exception(
        'Get recognition image status failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  Future<RecognitionImagesResponseModel> getRecognitionImages(
    String recognitionId,
  ) async {
    try {
      final response = await _apiService.getRecognitionImages(recognitionId);
      return RecognitionImagesResponseModel.fromJson(response);
    } catch (e) {
      throw Exception(
        'Get recognition images failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<RecognitionResultModel> recognizeBatch(List<String> imagePaths) async {
    try {
      final response = await _apiService.recognizeBatch(imagePaths);
      return RecognitionResultModel.fromJson(response);
    } catch (e) {
      throw Exception(
        'Batch recognition failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<ImageUploadResultModel> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType,
  }) async {
    try {
      final response = await _apiService.uploadImage(
        imageFile: imageFile,
        itemName: itemName,
        imageType: imageType,
      );
      return ImageUploadResultModel.fromJson(response);
    } catch (e) {
      throw Exception('Image upload failed: ${_apiService.getErrorMessage(e)}');
    }
  }

  @override
  Future<List<SimilarImageModel>> searchSimilarImages(String itemName) async {
    try {
      final response = await _apiService.searchSimilarImages(itemName);
      return response.map((data) => SimilarImageModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception(
        'Similar images search failed: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> assignImage(String itemName, String imagePath) async {
    try {
      await _apiService.assignImage(itemName, imagePath);
    } catch (e) {
      throw Exception('Image assignment failed: ${e.toString()}');
    }
  }

  // Legacy methods - keeping for backward compatibility
  @override
  Future<RecognitionResult> recognizeFood(File imageFile) async {
    try {
      // Convert to the new format by uploading and then recognizing
      final uploadResult = await uploadImage(
        imageFile: imageFile,
        itemName: 'uploaded_food',
        imageType: 'food',
      );

      final recognitionResult = await recognizeFoods([
        uploadResult.image.imagePath,
      ]);

      // Convert to legacy format using new FoodRecognitionResultModel structure
      if (recognitionResult.foods.isNotEmpty) {
        return RecognitionResult(
          recognitionId:
              'food_${DateTime.now().millisecondsSinceEpoch}', // Generate ID since foods model doesn't have one
          results:
              recognitionResult.foods
                  .map(
                    (food) => FoodRecognitionItem(
                      foodName: food.name,
                      confidence: food.confidence ?? 0.0,
                    ),
                  )
                  .toList(),
          processedImageUrl: uploadResult.image.imagePath,
        );
      } else {
        throw Exception('No foods recognized');
      }
    } catch (e) {
      throw Exception('Food recognition failed: ${e.toString()}');
    }
  }

  @override
  Future<ReferenceImage> uploadReferenceImage(
    File imageFile, {
    String? label,
    String? category,
  }) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'reference_image.jpg',
        ),
        if (label != null) 'label': label,
        if (category != null) 'category': category,
      });

      // Make API call
      final response = await _apiService.uploadReferenceImage(formData);

      // API service returns Map<String, dynamic> directly
      return ReferenceImage.fromJson(response);
    } catch (e) {
      throw Exception(
        'Error uploading reference image: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<List<ReferenceImage>> getReferenceImages({
    String? category,
    String? label,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.getReferenceImages(
        page: page,
        limit: perPage,
        category: category,
        imageType: label,
      );

      // API service returns Map<String, dynamic> directly
      final List<dynamic> items = response['items'] ?? [];
      return items.map((item) => ReferenceImage.fromJson(item)).toList();
    } catch (e) {
      throw Exception(
        'Error getting reference images: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<ReferenceImage> getReferenceImage(String imageId) async {
    try {
      final response = await _apiService.getReferenceImage(imageId);

      // API service returns Map<String, dynamic> directly
      return ReferenceImage.fromJson(response);
    } catch (e) {
      throw Exception(
        'Error getting reference image: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> deleteReferenceImage(String imageId) async {
    try {
      await _apiService.deleteReferenceImage(imageId);
      // API service handles success/failure internally
    } catch (e) {
      throw Exception(
        'Error deleting reference image: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<ReferenceImage> updateReferenceImage(
    String imageId, {
    String? label,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (label != null) updateData['label'] = label;
      if (category != null) updateData['category'] = category;

      final response = await _apiService.updateReferenceImage(
        imageId,
        updateData,
      );

      // API service returns Map<String, dynamic> directly
      return ReferenceImage.fromJson(response);
    } catch (e) {
      throw Exception(
        'Error updating reference image: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getRecognitionHistory() async {
    try {
      return await _apiService.getRecognitionHistory();
    } catch (e) {
      throw Exception(
        'Failed to get recognition history: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> submitRecognitionFeedback({
    required String recognitionId,
    required String feedback,
  }) async {
    try {
      return await _apiService.submitRecognitionFeedback(
        recognitionId: recognitionId,
        feedback: feedback,
      );
    } catch (e) {
      throw Exception(
        'Failed to submit recognition feedback: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getImageStatus(String? taskId) async {
    try {
      return await _apiService.getImageStatus(taskId);
    } catch (e) {
      throw Exception(
        'Failed to get image status: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> recognizeIngredientsAsync(File imageFile) async {
    try {
      return await _apiService.recognizeIngredientsAsync(imageFile);
    } catch (e) {
      throw Exception('Async ingredient recognition failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> checkRecognitionStatus(String taskId) async {
    try {
      return await _apiService.checkRecognitionStatus(taskId);
    } catch (e) {
      throw Exception('Check recognition status failed: ${e.toString()}');
    }
  }

  /// ✨ NEW: Simplified ingredient recognition with immediate response
  @override
  Future<IngredientRecognitionResultModel> recognizeIngredientsSimplified(
    List<File> imageFiles,
  ) async {
    try {
      final result = await _apiService.recognizeIngredientsSimplified(
        imageFiles,
      );
      return IngredientRecognitionResultModel.fromJson(result);
    } catch (e) {
      throw Exception(
        'Simplified ingredient recognition failed: ${e.toString()}',
      );
    }
  }

  /// ✨ NEW: Check image generation status for a recognition
  @override
  Future<IngredientRecognitionResultModel> checkRecognitionImages(
    String recognitionId,
  ) async {
    try {
      final result = await _apiService.checkRecognitionImages(recognitionId);
      return IngredientRecognitionResultModel.fromJson(result);
    } catch (e) {
      throw Exception('Check recognition images failed: ${e.toString()}');
    }
  }

  /// ✨ NEW: Simplified food recognition with immediate response
  @override
  Future<FoodRecognitionResultModel> recognizeFoodsSimplified(
    List<File> imageFiles,
  ) async {
    try {
      final result = await _apiService.recognizeFoodsSimplified(imageFiles);
      return FoodRecognitionResultModel.fromJson(result);
    } catch (e) {
      throw Exception('Simplified food recognition failed: ${e.toString()}');
    }
  }

  /// ✨ NEW: Check food image generation status for a recognition
  @override
  Future<FoodRecognitionResultModel> checkFoodRecognitionImages(
    String recognitionId,
  ) async {
    try {
      log(
        '🔍 [SIMPLIFIED FOODS] Checking images for food recognition: $recognitionId',
      );
      final result = await _apiService.checkFoodRecognitionImages(
        recognitionId,
      );
      log('📊 [SIMPLIFIED FOODS] Images status response received');
      log('📊 [SIMPLIFIED FOODS] Images status: ${result['images_status']}');
      log('🔍 [SIMPLIFIED FOODS] Response keys: ${result.keys.toList()}');
      log('🔍 [SIMPLIFIED FOODS] Full response: $result');

      return FoodRecognitionResultModel.fromJson(result);
    } catch (e) {
      throw Exception('Check food recognition images failed: ${e.toString()}');
    }
  }

  /// ✨ NEW: Get food recognition by ID with updated images
  Future<FoodRecognitionResultModel> getFoodRecognitionById(
    String recognitionId,
  ) async {
    try {
      log(
        '🔍 [SIMPLIFIED FOODS] Getting food recognition by ID: $recognitionId',
      );
      final result = await _apiService.getFoodRecognitionById(recognitionId);
      log('📊 [SIMPLIFIED FOODS] Food recognition data received');

      return FoodRecognitionResultModel.fromJson(result);
    } catch (e) {
      throw Exception('Get food recognition by ID failed: ${e.toString()}');
    }
  }
}
