import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for meal planning operations
class MealPlanningService {
  static MealPlanningService? _instance;
  static MealPlanningService get instance => _instance ??= MealPlanningService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;

  // Meal planning endpoints
  static const String _planGenerate = '/api/plan/generate';
  static const String _planHistory = '/api/plan/history';
  static const String _planningSave = '/api/planning/save';
  static const String _planningUpdate = '/api/planning/update';
  static const String _planningGet = '/api/planning/get';
  static const String _planningAll = '/api/planning/all';
  static const String _planningDates = '/api/planning/dates';
  static const String _planningDelete = '/api/planning/delete';

  // Timeout constants for AI operations
  static const Duration _aiProcessingTimeout = Duration(minutes: 3);
  static const Duration _uploadTimeout = Duration(minutes: 2);

  MealPlanningService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://127.0.0.1:3000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authHeaders = await _authService.getAuthHeaders();
          if (authHeaders != null) {
            options.headers.addAll(authHeaders);
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final newToken = await _authService.refreshTokens();
            if (newToken != null) {
              // Retry the request with new token
              final authHeaders = await _authService.getAuthHeaders();
              if (authHeaders != null) {
                error.requestOptions.headers.addAll(authHeaders);
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => log(obj.toString()),
      ),
    );
  }

  // ==================== MEAL PLAN GENERATION ====================

  /// Generate meal plan from ingredients
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
    int? days,
    List<String>? mealTypes,
    List<String>? dietaryRestrictions,
    int? caloriesPerDay,
  }) async {
    try {
      log('🍽️ Generating meal plan for ${ingredients.length} ingredients');

      final response = await _dio.post(
        _planGenerate,
        data: {
          'ingredients': ingredients,
          if (days != null) 'days': days,
          if (mealTypes != null) 'meal_types': mealTypes,
          if (dietaryRestrictions != null) 'dietary_restrictions': dietaryRestrictions,
          if (caloriesPerDay != null) 'calories_per_day': caloriesPerDay,
        },
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );

      log('✅ Meal plan generation successful');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Generate meal plan error: $e');
      throw Exception('Generate meal plan error: ${e.toString()}');
    }
  }

  /// Generate weekly meal plan
  Future<Map<String, dynamic>> generateWeeklyMealPlan({
    required List<Map<String, dynamic>> ingredients,
    List<String>? preferences,
    int? caloriesPerDay,
    bool includeSnacks = false,
  }) async {
    try {
      log('📅 Generating weekly meal plan');

      final response = await _dio.post(
        _planGenerate,
        data: {
          'ingredients': ingredients,
          'days': 7,
          'meal_types': includeSnacks 
            ? ['breakfast', 'lunch', 'dinner', 'snack']
            : ['breakfast', 'lunch', 'dinner'],
          if (preferences != null) 'preferences': preferences,
          if (caloriesPerDay != null) 'calories_per_day': caloriesPerDay,
        },
        options: Options(
          receiveTimeout: _aiProcessingTimeout,
          sendTimeout: _uploadTimeout,
        ),
      );

      log('✅ Weekly meal plan generation successful');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Generate weekly meal plan error: $e');
      throw Exception('Generate weekly meal plan error: ${e.toString()}');
    }
  }

  // ==================== MEAL PLAN MANAGEMENT ====================

  /// Save meal plan for a specific date
  Future<Map<String, dynamic>> saveMealPlan({
    required String date,
    required Map<String, dynamic> meals,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      log('💾 Saving meal plan for date: $date');

      final response = await _dio.post(
        _planningSave,
        data: {
          'date': date,
          'meals': meals,
          if (metadata != null) 'metadata': metadata,
        },
      );

      log('✅ Meal plan saved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Save meal plan error: $e');
      throw Exception('Save meal plan error: ${e.toString()}');
    }
  }

  /// Update existing meal plan
  Future<Map<String, dynamic>> updateMealPlan({
    required String date,
    required Map<String, dynamic> meals,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      log('📝 Updating meal plan for date: $date');

      final response = await _dio.put(
        _planningUpdate,
        data: {
          'date': date,
          'meals': meals,
          if (metadata != null) 'metadata': metadata,
        },
      );

      log('✅ Meal plan updated successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Update meal plan error: $e');
      throw Exception('Update meal plan error: ${e.toString()}');
    }
  }

  /// Delete meal plan for specific date
  Future<Map<String, dynamic>> deleteMealPlan(String date) async {
    try {
      log('🗑️ Deleting meal plan for date: $date');

      final response = await _dio.delete('$_planningDelete/$date');

      log('✅ Meal plan deleted successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Delete meal plan error: $e');
      throw Exception('Delete meal plan error: ${e.toString()}');
    }
  }

  // ==================== MEAL PLAN RETRIEVAL ====================

  /// Get meal plan by specific date
  Future<Map<String, dynamic>> getMealPlanByDate(String date) async {
    try {
      log('📅 Getting meal plan for date: $date');

      final response = await _dio.get(
        _planningGet,
        queryParameters: {'date': date},
      );

      log('✅ Meal plan for date retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get meal plan by date error: $e');
      throw Exception('Get meal plan by date error: ${e.toString()}');
    }
  }

  /// Get all user's meal plans
  Future<Map<String, dynamic>> getAllMealPlans() async {
    try {
      log('📚 Getting all meal plans');

      final response = await _dio.get(_planningAll);

      log('✅ All meal plans retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get all meal plans error: $e');
      throw Exception('Get all meal plans error: ${e.toString()}');
    }
  }

  /// Get meal planning history
  Future<Map<String, dynamic>> getMealPlanHistory() async {
    try {
      log('📜 Getting meal plan history');

      final response = await _dio.get(_planHistory);

      log('✅ Meal plan history retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get meal plan history error: $e');
      throw Exception('Get meal plan history error: ${e.toString()}');
    }
  }

  /// Get list of dates with existing meal plans
  Future<Map<String, dynamic>> getMealPlanDates() async {
    try {
      log('📅 Getting meal plan dates');

      final response = await _dio.get(_planningDates);

      log('✅ Meal plan dates retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get meal plan dates error: $e');
      throw Exception('Get meal plan dates error: ${e.toString()}');
    }
  }

  // ==================== MEAL PLAN UTILITIES ====================

  /// Get meal plans for date range
  Future<Map<String, dynamic>> getMealPlansForDateRange({
    required String startDate,
    required String endDate,
  }) async {
    try {
      log('📅 Getting meal plans for date range: $startDate to $endDate');

      final response = await _dio.get(
        _planningAll,
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      log('✅ Meal plans for date range retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get meal plans for date range error: $e');
      throw Exception('Get meal plans for date range error: ${e.toString()}');
    }
  }

  /// Get meal plans for current week
  Future<Map<String, dynamic>> getCurrentWeekMealPlans() async {
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));

      final startDate = _formatDate(monday);
      final endDate = _formatDate(sunday);

      log('📅 Getting current week meal plans ($startDate to $endDate)');

      return await getMealPlansForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      log('❌ Get current week meal plans error: $e');
      throw Exception('Get current week meal plans error: ${e.toString()}');
    }
  }

  /// Get meal plans for current month
  Future<Map<String, dynamic>> getCurrentMonthMealPlans() async {
    try {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      final startDate = _formatDate(firstDay);
      final endDate = _formatDate(lastDay);

      log('📅 Getting current month meal plans ($startDate to $endDate)');

      return await getMealPlansForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      log('❌ Get current month meal plans error: $e');
      throw Exception('Get current month meal plans error: ${e.toString()}');
    }
  }

  /// Check if meal plan exists for date
  Future<bool> hasMealPlanForDate(String date) async {
    try {
      await getMealPlanByDate(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Copy meal plan to another date
  Future<Map<String, dynamic>> copyMealPlan({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      log('📋 Copying meal plan from $fromDate to $toDate');

      // Get the source meal plan
      final sourcePlan = await getMealPlanByDate(fromDate);
      final meals = sourcePlan['meals'] as Map<String, dynamic>;

      // Save to the new date
      final result = await saveMealPlan(
        date: toDate,
        meals: meals,
      );

      log('✅ Meal plan copied successfully');
      return result;
    } catch (e) {
      log('❌ Copy meal plan error: $e');
      throw Exception('Copy meal plan error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse date string to DateTime
  DateTime _parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// Get today's date formatted
  String getTodayFormatted() {
    return _formatDate(DateTime.now());
  }

  /// Get tomorrow's date formatted
  String getTomorrowFormatted() {
    return _formatDate(DateTime.now().add(const Duration(days: 1)));
  }

  /// Get date for days ahead
  String getDateForDaysAhead(int days) {
    return _formatDate(DateTime.now().add(Duration(days: days)));
  }
}