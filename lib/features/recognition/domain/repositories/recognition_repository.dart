import 'dart:io';

import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/recognition_result.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/reference_image.dart';

/// Repository for AI-powered food and ingredient recognition
abstract class RecognitionRepository {
  /// Upload an image to the backend
  Future<ImageUploadResultModel> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType,
  });

  /// Recognize foods/dishes from image paths
  /// Returns FoodRecognitionResultModel with detailed food information including allergen alerts
  Future<FoodRecognitionResultModel> recognizeFoods(List<String> imagePaths);

  /// Recognize individual ingredients from image paths
  /// Returns IngredientRecognitionResultModel with detailed ingredient information including allergen alerts
  Future<IngredientRecognitionResultModel> recognizeIngredients(
    List<String> imagePaths,
  );

  /// Complete ingredient recognition with environmental impact and utilization ideas
  /// Returns CompleteIngredientRecognitionResultModel with full environmental data
  Future<CompleteIngredientRecognitionResultModel> recognizeIngredientsComplete(
    List<String> imagePaths,
  );

  /// Batch recognition for mixed content (ingredients + foods)
  /// Returns general RecognitionResultModel for backward compatibility
  Future<RecognitionResultModel> recognizeBatch(List<String> imagePaths);

  /// Search for similar images
  Future<List<SimilarImageModel>> searchSimilarImages(String itemName);

  /// Assign an image to an item
  Future<void> assignImage(String itemName, String imagePath);

  /// Recognize food in an image
  Future<RecognitionResult> recognizeFood(File imageFile);

  /// Upload a reference image
  Future<ReferenceImage> uploadReferenceImage(
    File imageFile, {
    String? label,
    String? category,
  });

  /// Get a list of reference images
  Future<List<ReferenceImage>> getReferenceImages({
    String? category,
    String? label,
    int page = 1,
    int perPage = 20,
  });

  /// Get a single reference image by ID
  Future<ReferenceImage> getReferenceImage(String imageId);

  /// Delete a reference image
  Future<void> deleteReferenceImage(String imageId);

  /// Update a reference image
  Future<ReferenceImage> updateReferenceImage(
    String imageId, {
    String? label,
    String? category,
  });

  /// Get recognition history
  /// Returns past recognition sessions with all detected items
  Future<Map<String, dynamic>> getRecognitionHistory();

  /// Submit feedback on recognition results
  /// Helps improve AI recognition accuracy
  Future<Map<String, dynamic>> submitRecognitionFeedback({
    required String recognitionId,
    required String feedback,
  });

  /// Check image processing status
  /// Monitor the status of background image generation tasks
  Future<Map<String, dynamic>> getImageStatus(String? taskId);

  Future<RecognitionImageStatusModel> getRecognitionImageStatus(String taskId);

  Future<Map<String, dynamic>> recognizeIngredientsAsync(File imageFile);
  Future<Map<String, dynamic>> checkRecognitionStatus(String taskId);

  /// ✨ NEW: Simplified ingredient recognition with immediate response
  Future<IngredientRecognitionResultModel> recognizeIngredientsSimplified(
    List<File> imageFiles,
  );

  /// ✨ NEW: Check image generation status for a recognition
  Future<IngredientRecognitionResultModel> checkRecognitionImages(
    String recognitionId,
  );
}
