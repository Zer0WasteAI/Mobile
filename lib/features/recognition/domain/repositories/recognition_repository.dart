import 'dart:io';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/recognition_result.dart';
import 'package:zer0_waste_ai/features/recognition/domain/models/reference_image.dart';

/// Repository interface for food and ingredient recognition
abstract class RecognitionRepository {
  /// Recognize foods from image paths
  Future<RecognitionResultModel> recognizeFoods(List<String> imagePaths);

  /// Recognize ingredients from image paths
  Future<RecognitionResultModel> recognizeIngredients(List<String> imagePaths);

  /// Batch recognition for multiple images
  Future<RecognitionResultModel> recognizeBatch(List<String> imagePaths);

  /// Upload an image to the backend
  Future<ImageUploadResultModel> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType,
  });

  /// Search for similar images
  Future<List<SimilarImageModel>> searchSimilarImages(String itemName);

  /// Assign an image to an item
  Future<Map<String, dynamic>> assignImage(String itemName);

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
}
 