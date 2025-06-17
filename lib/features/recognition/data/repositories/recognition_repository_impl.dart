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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReferenceImage.fromJson(response.data);
      }

      throw Exception('Failed to upload reference image');
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
        category,
        label,
        page,
        perPage,
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'];
        return items.map((item) => ReferenceImage.fromJson(item)).toList();
      }

      throw Exception('Failed to get reference images');
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

      if (response.statusCode == 200) {
        return ReferenceImage.fromJson(response.data);
      }

      throw Exception('Failed to get reference image');
    } catch (e) {
      throw Exception(
        'Error getting reference image: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<void> deleteReferenceImage(String imageId) async {
    try {
      final response = await _apiService.deleteReferenceImage(imageId);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete reference image');
      }
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
      final response = await _apiService.updateReferenceImage(
        imageId,
        label,
        category,
      );

      if (response.statusCode == 200) {
        return ReferenceImage.fromJson(response.data);
      }

      throw Exception('Failed to update reference image');
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
}
