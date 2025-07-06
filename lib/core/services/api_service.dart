import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

// Import extracted services
import 'admin_service.dart';
import 'auth_service.dart';
import 'environmental_service.dart';
import 'image_management_service.dart';
import 'inventory_service.dart';
import 'meal_planning_service.dart';
import 'recipe_service.dart';
import 'recognition_service.dart';
import 'user_profile_service.dart';

/// Central API Service that coordinates all backend operations through specialized services
/// This is the main entry point for all API interactions in the ZeroWasteAI app
/// 
/// Instead of being a God Class, this service now delegates to specialized services:
/// - AuthService: Authentication and token management
/// - RecognitionService: AI food/ingredient recognition
/// - InventoryService: Inventory management operations
/// - RecipeService: Recipe generation and management
/// - MealPlanningService: Meal planning and scheduling
/// - UserProfileService: User profile and preferences
/// - ImageManagementService: Image upload and processing
/// - AdminService: Administrative operations
/// - EnvironmentalService: Environmental impact calculations
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();

  // Specialized services
  late final AuthService _authService;
  late final RecognitionService _recognitionService;
  late final InventoryService _inventoryService;
  late final RecipeService _recipeService;
  late final MealPlanningService _mealPlanningService;
  late final UserProfileService _userProfileService;
  late final ImageManagementService _imageManagementService;
  late final AdminService _adminService;
  late final EnvironmentalService _environmentalService;

  ApiService._internal() {
    _initializeServices();
  }

  void _initializeServices() {
    log('🔧 Initializing ApiService with specialized services');
    
    // Initialize all specialized services
    _authService = AuthService.instance;
    _recognitionService = RecognitionService.instance;
    _inventoryService = InventoryService.instance;
    _recipeService = RecipeService.instance;
    _mealPlanningService = MealPlanningService.instance;
    _userProfileService = UserProfileService.instance;
    _imageManagementService = ImageManagementService.instance;
    _adminService = AdminService.instance;
    _environmentalService = EnvironmentalService.instance;

    log('✅ ApiService initialized with 9 specialized services');
  }

  // ==================== SERVICE ACCESSORS ====================
  
  /// Get authentication service
  AuthService get auth => _authService;
  
  /// Get recognition service
  RecognitionService get recognition => _recognitionService;
  
  /// Get inventory service
  InventoryService get inventory => _inventoryService;
  
  /// Get recipe service
  RecipeService get recipe => _recipeService;
  
  /// Get meal planning service
  MealPlanningService get mealPlanning => _mealPlanningService;
  
  /// Get user profile service
  UserProfileService get userProfile => _userProfileService;
  
  /// Get image management service
  ImageManagementService get imageManagement => _imageManagementService;
  
  /// Get admin service
  AdminService get admin => _adminService;
  
  /// Get environmental service
  EnvironmentalService get environmental => _environmentalService;

  // ==================== AUTHENTICATION METHODS ====================
  
  /// Exchange Firebase ID Token for application JWT tokens
  Future<Map<String, dynamic>> firebaseSignIn(String firebaseIdToken) async {
    return await _authService.firebaseSignIn(firebaseIdToken);
  }

  /// Refresh JWT tokens with automatic rotation
  Future<String?> refreshTokens() async {
    return await _authService.refreshTokens();
  }

  /// Secure logout with token blacklisting
  Future<void> logout() async {
    return await _authService.logout();
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _authService.getAccessToken();
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _authService.getRefreshToken();
  }

  /// Clear stored tokens
  Future<void> clearTokens() async {
    return await _authService.clearTokens();
  }

  /// Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    return await _authService.hasValidTokens();
  }

  // ==================== USER PROFILE METHODS ====================

  /// Get complete user profile
  Future<Map<String, dynamic>> getProfile() async {
    return await _userProfileService.getProfile();
  }

  /// Update user profile with new data
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    return await _userProfileService.updateProfile(profileData);
  }

  /// Update specific profile field
  Future<Map<String, dynamic>> updateProfileField(String field, dynamic value) async {
    return await _userProfileService.updateProfileField(field, value);
  }

  /// Update user preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    return await _userProfileService.updatePreferences(preferences);
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    return await _userProfileService.getUserStatistics();
  }

  // ==================== RECOGNITION METHODS ====================

  /// AI recognition of prepared foods/dishes
  Future<Map<String, dynamic>> recognizeFoods(List<String> imagePaths) async {
    return await _recognitionService.recognizeFoods(imagePaths);
  }

  /// AI recognition of individual ingredients
  Future<Map<String, dynamic>> recognizeIngredients(List<String> imagePaths) async {
    return await _recognitionService.recognizeIngredients(imagePaths);
  }

  /// Batch recognition for mixed content
  Future<Map<String, dynamic>> recognizeBatch(List<String> imagePaths) async {
    return await _recognitionService.recognizeBatch(imagePaths);
  }

  /// Get recognition history
  Future<Map<String, dynamic>> getRecognitionHistory() async {
    return await _recognitionService.getRecognitionHistory();
  }

  /// Start async ingredient recognition
  Future<Map<String, dynamic>> recognizeIngredientsAsync(File imageFile) async {
    return await _recognitionService.recognizeIngredientsAsync(imageFile);
  }

  /// Check recognition task status
  Future<Map<String, dynamic>> checkRecognitionStatus(String taskId) async {
    return await _recognitionService.checkRecognitionStatus(taskId);
  }

  /// Simplified ingredient recognition
  Future<Map<String, dynamic>> recognizeIngredientsSimplified(List<File> imageFiles) async {
    // Convert files to paths for the service
    final imagePaths = imageFiles.map((file) => file.path).toList();
    return await _recognitionService.recognizeIngredientsSimplified(imagePaths);
  }

  /// Complete ingredient recognition
  Future<Map<String, dynamic>> recognizeIngredientsComplete(List<String> imagePaths) async {
    return await _recognitionService.recognizeIngredientsComplete(imagePaths);
  }

  /// Get recognition image status
  Future<Map<String, dynamic>> getRecognitionImageStatus(String taskId) async {
    return await _recognitionService.getRecognitionImageStatus(taskId);
  }

  /// Get recognition images
  Future<Map<String, dynamic>> getRecognitionImages(String recognitionId) async {
    return await _recognitionService.getRecognitionImages(recognitionId);
  }

  /// Check recognition images
  Future<Map<String, dynamic>> checkRecognitionImages(String recognitionId) async {
    return await _recognitionService.checkRecognitionImages(recognitionId);
  }

  /// Submit recognition feedback
  Future<Map<String, dynamic>> submitRecognitionFeedback({
    required String recognitionId,
    required String feedback,
  }) async {
    return await _recognitionService.submitRecognitionFeedback(
      recognitionId: recognitionId,
      feedback: feedback,
    );
  }

  /// Recognize foods simplified
  Future<Map<String, dynamic>> recognizeFoodsSimplified(List<File> imageFiles) async {
    final imagePaths = imageFiles.map((file) => file.path).toList();
    return await _recognitionService.recognizeFoodsSimplified(imagePaths);
  }

  /// Check food recognition images
  Future<Map<String, dynamic>> checkFoodRecognitionImages(String recognitionId) async {
    return await _recognitionService.checkFoodRecognitionImages(recognitionId);
  }

  /// Get food recognition by ID
  Future<Map<String, dynamic>> getFoodRecognitionById(String recognitionId) async {
    return await _recognitionService.getFoodRecognitionById(recognitionId);
  }

  // ==================== INVENTORY METHODS ====================

  /// Get complete user inventory
  Future<Map<String, dynamic>> getInventory() async {
    return await _inventoryService.getInventory();
  }

  /// Get simplified inventory
  Future<Map<String, dynamic>> getInventorySimple() async {
    return await _inventoryService.getInventorySimple();
  }

  /// Add ingredients to inventory
  Future<Map<String, dynamic>> addIngredients(List<Map<String, dynamic>> ingredients) async {
    return await _inventoryService.addIngredients(ingredients);
  }

  /// Add single item to inventory
  Future<Map<String, dynamic>> addInventoryItem(Map<String, dynamic> item) async {
    return await _inventoryService.addInventoryItem(item);
  }

  /// Update ingredient quantity
  Future<Map<String, dynamic>> updateIngredientQuantity(
    String ingredientName,
    String addedAt,
    double newQuantity,
    String unit,
  ) async {
    return await _inventoryService.updateIngredientQuantity(ingredientName, addedAt, newQuantity, unit);
  }

  /// Delete ingredient from inventory
  Future<Map<String, dynamic>> deleteIngredient(String ingredientName, String addedAt) async {
    return await _inventoryService.deleteIngredient(ingredientName, addedAt);
  }

  /// Get expiring items
  Future<Map<String, dynamic>> getExpiringItems(int days) async {
    return await _inventoryService.getExpiringItems(days);
  }

  /// Mark food as consumed
  Future<Map<String, dynamic>> markFoodAsConsumed(
    String foodName,
    String addedAt, {
    double? portions,
  }) async {
    if (portions != null) {
      return await _inventoryService.markFoodAsConsumed(foodName, addedAt, portions, 'portions');
    } else {
      return await _inventoryService.markFoodAsConsumed(foodName, addedAt, 1.0, 'portions');
    }
  }

  /// Update ingredient
  Future<Map<String, dynamic>> updateIngredient(
    String ingredientName,
    String addedAt,
    Map<String, dynamic> updateData,
  ) async {
    return await _inventoryService.updateIngredient(ingredientName, addedAt, updateData);
  }

  /// Update inventory item
  Future<Map<String, dynamic>> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    return await _inventoryService.updateInventoryItem(itemId, updateData);
  }

  /// Delete inventory item
  Future<Map<String, dynamic>> deleteInventoryItem(String itemId) async {
    return await _inventoryService.deleteInventoryItem(itemId);
  }

  /// Get ingredient detail
  Future<Map<String, dynamic>> getIngredientDetail(String ingredientName, String addedAt) async {
    return await _inventoryService.getIngredientDetail(ingredientName, addedAt);
  }

  /// Get food detail
  Future<Map<String, dynamic>> getFoodDetail(String foodName, String addedAt) async {
    return await _inventoryService.getFoodDetail(foodName, addedAt);
  }

  /// Get complete inventory
  Future<Map<String, dynamic>> getInventoryComplete() async {
    return await _inventoryService.getInventoryComplete();
  }

  /// Add ingredients from recognition
  Future<Map<String, dynamic>> addIngredientsFromRecognition(String recognitionId, List<String> selectedIngredients) async {
    return await _inventoryService.addIngredientsFromRecognition(recognitionId, selectedIngredients);
  }

  /// Add foods from recognition
  Future<Map<String, dynamic>> addFoodsFromRecognition(String recognitionId, List<String> selectedFoods) async {
    return await _inventoryService.addFoodsFromRecognition(recognitionId, selectedFoods);
  }

  /// Update food quantity
  Future<Map<String, dynamic>> updateFoodQuantity(
    String foodName,
    String addedAt,
    double quantity,
    String unit,
  ) async {
    return await _inventoryService.updateFoodQuantity(foodName, addedAt, quantity, unit);
  }

  /// Delete complete ingredient
  Future<Map<String, dynamic>> deleteCompleteIngredient(String ingredientName, String addedAt) async {
    return await _inventoryService.deleteCompleteIngredient(ingredientName, addedAt);
  }

  /// Mark ingredient consumed
  Future<Map<String, dynamic>> markIngredientConsumed(
    String ingredientName,
    String addedAt,
    double consumedQuantity,
    String unit,
  ) async {
    return await _inventoryService.markIngredientConsumed(ingredientName, addedAt, consumedQuantity, unit);
  }

  /// Get ingredients list
  Future<Map<String, dynamic>> getIngredientsList() async {
    return await _inventoryService.getIngredientsList();
  }

  /// Add single inventory item
  Future<Map<String, dynamic>> addSingleInventoryItem({
    required String name,
    required String category,
    double? quantity,
    String? unit,
    String? expirationDate,
  }) async {
    return await _inventoryService.addSingleInventoryItem(
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      expirationDate: expirationDate,
    );
  }

  // ==================== RECIPE METHODS ====================

  /// Generate recipes using current inventory
  Future<Map<String, dynamic>> generateRecipesFromInventory({
    List<String>? preferences,
  }) async {
    return await _recipeService.generateRecipesFromInventory();
  }

  /// Generate custom recipes with specific ingredients
  Future<Map<String, dynamic>> generateCustomRecipes({
    required List<String> ingredients,
    List<String>? preferences,
  }) async {
    return await _recipeService.generateCustomRecipes(
      ingredients: ingredients,
      preferences: preferences,
    );
  }

  /// Save a recipe to user's collection
  Future<Map<String, dynamic>> saveRecipe(Map<String, dynamic> recipe) async {
    return await _recipeService.saveRecipe(recipe);
  }

  /// Get all user's saved recipes
  Future<Map<String, dynamic>> getSavedRecipes() async {
    return await _recipeService.getSavedRecipes();
  }

  /// Get all available recipes
  Future<Map<String, dynamic>> getAllRecipes() async {
    return await _recipeService.getAllRecipes();
  }

  /// Delete a saved recipe
  Future<Map<String, dynamic>> deleteRecipe(String recipeId) async {
    return await _recipeService.deleteRecipe(recipeId);
  }

  /// Generate recipe
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
  }) async {
    return await _recipeService.generateRecipe(ingredients: ingredients);
  }

  /// Get default recipes
  Future<Map<String, dynamic>> getDefaultRecipes() async {
    return await _recipeService.getDefaultRecipes();
  }

  // ==================== MEAL PLANNING METHODS ====================

  /// Generate meal plan based on available ingredients
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
  }) async {
    return await _mealPlanningService.generateMealPlan(ingredients: ingredients);
  }

  /// Get meal planning history
  Future<Map<String, dynamic>> getMealPlanHistory() async {
    return await _mealPlanningService.getMealPlanHistory();
  }

  /// Save meal plan for a specific date
  Future<Map<String, dynamic>> saveMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    return await _mealPlanningService.saveMealPlan(date: date, meals: meals);
  }

  /// Update existing meal plan
  Future<Map<String, dynamic>> updateMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  }) async {
    return await _mealPlanningService.updateMealPlan(date: date, meals: meals);
  }

  /// Get meal plan by specific date
  Future<Map<String, dynamic>> getMealPlanByDate(String date) async {
    return await _mealPlanningService.getMealPlanByDate(date);
  }

  /// Get all user's meal plans
  Future<Map<String, dynamic>> getAllMealPlans() async {
    return await _mealPlanningService.getAllMealPlans();
  }

  /// Delete meal plan for specific date
  Future<Map<String, dynamic>> deleteMealPlan(String date) async {
    return await _mealPlanningService.deleteMealPlan(date);
  }

  /// Get meal plan dates
  Future<Map<String, dynamic>> getMealPlanDates() async {
    return await _mealPlanningService.getMealPlanDates();
  }

  // ==================== IMAGE MANAGEMENT METHODS ====================

  /// Upload image to backend
  Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String itemName,
    required String imageType,
    Map<String, dynamic>? metadata,
  }) async {
    return await _imageManagementService.uploadImage(
      imageFile: imageFile,
      itemName: itemName,
      imageType: imageType,
      metadata: metadata,
    );
  }

  /// Search for similar images
  Future<List<Map<String, dynamic>>> searchSimilarImages(String itemName) async {
    return await _imageManagementService.searchSimilarImages(itemName);
  }

  /// Assign reference image to an item
  Future<void> assignImage(String itemName, String imagePath) async {
    return await _imageManagementService.assignImage(itemName, imagePath);
  }

  /// Check image processing status
  Future<Map<String, dynamic>> getImageStatus(String? taskId) async {
    return await _imageManagementService.getImageStatus(taskId);
  }

  /// Upload reference image
  Future<Map<String, dynamic>> uploadReferenceImage(FormData formData) async {
    final response = await _imageManagementService.uploadReferenceImage(formData);
    return response.data as Map<String, dynamic>;
  }

  /// Get reference images
  Future<Map<String, dynamic>> getReferenceImages({
    int? page,
    int? limit,
    String? category,
    String? imageType,
  }) async {
    final response = await _imageManagementService.getReferenceImages(
      page: page,
      limit: limit,
      category: category,
      imageType: imageType,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get reference image
  Future<Map<String, dynamic>> getReferenceImage(String imageId) async {
    final response = await _imageManagementService.getReferenceImage(imageId);
    return response.data as Map<String, dynamic>;
  }

  /// Delete reference image
  Future<Map<String, dynamic>> deleteReferenceImage(String imageId) async {
    final response = await _imageManagementService.deleteReferenceImage(imageId);
    return response.data as Map<String, dynamic>;
  }

  /// Update reference image
  Future<Map<String, dynamic>> updateReferenceImage(String imageId, Map<String, dynamic> updateData) async {
    final response = await _imageManagementService.updateReferenceImage(imageId, updateData);
    return response.data as Map<String, dynamic>;
  }

  // ==================== ENVIRONMENTAL METHODS ====================

  /// Calculate environmental impact from recipe title
  Future<Map<String, dynamic>> calculateImpactFromTitle(String title) async {
    return await _environmentalService.calculateImpactFromTitle(title);
  }

  /// Calculate environmental impact from recipe UID
  Future<Map<String, dynamic>> calculateImpactFromUid(String recipeUid) async {
    return await _environmentalService.calculateImpactFromUid(recipeUid);
  }

  /// Get environmental impact summary
  Future<Map<String, dynamic>> getImpactSummary() async {
    return await _environmentalService.getImpactSummary();
  }

  /// Update calculation status
  Future<Map<String, dynamic>> updateCalculationStatus(String calculationId, bool isCooked) async {
    return await _environmentalService.updateCalculationStatus(calculationId, isCooked);
  }

  /// Get all environmental calculations
  Future<Map<String, dynamic>> getAllCalculations() async {
    return await _environmentalService.getAllCalculations();
  }

  /// Get calculations by status
  Future<Map<String, dynamic>> getCalculationsByStatus(bool isCooked) async {
    return await _environmentalService.getCalculationsByStatus(isCooked);
  }

  // ==================== ADMIN METHODS ====================

  /// Get all users (Admin only)
  Future<Map<String, dynamic>> getUsers({
    int? page,
    int? limit,
    String? search,
  }) async {
    return await _adminService.getUsers(page: page, limit: limit, search: search);
  }

  /// Get system statistics (Admin only)
  Future<Map<String, dynamic>> getSystemStats() async {
    return await _adminService.getSystemStats();
  }

  /// Get system health status (Admin only)
  Future<Map<String, dynamic>> getSystemHealth() async {
    return await _adminService.getSystemHealth();
  }

  /// Sync images (Admin only)
  Future<Map<String, dynamic>> syncImages() async {
    return await _adminService.syncImages();
  }

  /// Get system status
  Future<Map<String, dynamic>> getSystemStatus() async {
    return await _adminService.getSystemStatus();
  }

  // ==================== UTILITY METHODS ====================

  /// Check if a service is healthy
  Future<bool> isServiceHealthy(String serviceName) async {
    try {
      switch (serviceName.toLowerCase()) {
        case 'auth':
          return await _authService.hasValidTokens();
        case 'recognition':
          final history = await _recognitionService.getRecognitionHistory();
          return history.isNotEmpty;
        case 'inventory':
          final inventory = await _inventoryService.getInventory();
          return inventory.isNotEmpty;
        case 'recipe':
          final recipes = await _recipeService.getAllRecipes();
          return recipes.isNotEmpty;
        case 'mealplanning':
          final plans = await _mealPlanningService.getAllMealPlans();
          return plans.isNotEmpty;
        case 'profile':
          final profile = await _userProfileService.getProfile();
          return profile.isNotEmpty;
        case 'environmental':
          final summary = await _environmentalService.getImpactSummary();
          return summary.isNotEmpty;
        default:
          return false;
      }
    } catch (e) {
      log('❌ Service health check failed for $serviceName: $e');
      return false;
    }
  }

  /// Get health status of all services
  Future<Map<String, bool>> getAllServicesHealth() async {
    final services = [
      'auth',
      'recognition', 
      'inventory',
      'recipe',
      'mealplanning',
      'profile',
      'environmental',
    ];

    final healthStatus = <String, bool>{};
    
    for (final service in services) {
      healthStatus[service] = await isServiceHealthy(service);
    }

    return healthStatus;
  }

  /// Get error message for exceptions
  String getErrorMessage(dynamic error) {
    // Provide basic error handling
    if (error.toString().contains('DioException')) {
      return 'Error de conexión. Verifica tu internet e intenta nuevamente.';
    }
    return error.toString();
  }
}