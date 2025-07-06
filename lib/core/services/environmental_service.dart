import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Service for environmental impact calculations and savings tracking
class EnvironmentalService {
  static EnvironmentalService? _instance;
  static EnvironmentalService get instance => _instance ??= EnvironmentalService._internal();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  
  // Callback para manejar errores de sesión
  static void Function(String)? _onSessionExpired;

  // Environmental savings endpoints
  static const String _envSavingsCalculateFromTitle = '/api/environmental_savings/calculate/from-title';
  static const String _envSavingsCalculateFromUid = '/api/environmental_savings/calculate/from-uid';
  static const String _envSavingsCalculations = '/api/environmental_savings/calculations';
  static const String _envSavingsCalculationsByStatus = '/api/environmental_savings/calculations/status';
  static const String _envSavingsSummary = '/api/environmental_savings/summary';
  static const String _envSavingsUpdateCalculation = '/api/environmental_savings/calculations';

  EnvironmentalService._internal() {
    _initializeDio();
  }
  
  /// Configurar callback para manejar errores de sesión
  static void setSessionExpiredCallback(void Function(String) callback) {
    _onSessionExpired = callback;
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
            try {
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
            } catch (refreshError) {
              log('❌ Token refresh failed in interceptor: $refreshError');
              
              // If it's a session expired error, trigger logout callback
              if (refreshError is SessionExpiredException) {
                log('🚪 Session expired - triggering logout callback');
                _onSessionExpired?.call(refreshError.message);
                
                // Still reject the request with a clear error
                handler.reject(DioException(
                  requestOptions: error.requestOptions,
                  error: refreshError,
                  type: DioExceptionType.unknown,
                ));
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

  // ==================== IMPACT CALCULATIONS ====================

  /// Calculate environmental impact from recipe title
  Future<Map<String, dynamic>> calculateImpactFromTitle(String title) async {
    try {
      log('🌱 Calculating environmental impact for recipe: $title');

      final response = await _dio.post(
        _envSavingsCalculateFromTitle,
        data: {'title': title},
      );

      log('✅ Environmental impact calculation completed');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('❌ Error calculating impact from title: $e');

      // Handle specific case when recipe is not found
      if (e.response?.statusCode == 404) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        if (errorData != null && errorData.containsKey('error')) {
          final errorMessage = errorData['error'] as String;
          log('🔍 Recipe not found in database: $errorMessage');
          throw Exception(
            'Esta receta no está disponible para el cálculo de impacto ambiental. Es posible que sea una receta personalizada.',
          );
        }
        throw Exception(
          'Esta receta no está disponible para el cálculo de impacto ambiental.',
        );
      }

      throw Exception('Error calculating environmental impact: ${e.toString()}');
    } catch (e) {
      log('❌ Calculate impact from title error: $e');
      throw Exception('Calculate impact from title error: ${e.toString()}');
    }
  }

  /// Calculate environmental impact from recipe UID
  Future<Map<String, dynamic>> calculateImpactFromUid(String recipeUid) async {
    try {
      log('🌱 Calculating environmental impact for recipe UID: $recipeUid');

      final response = await _dio.post('$_envSavingsCalculateFromUid/$recipeUid');

      log('✅ Environmental impact calculation by UID completed');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('❌ Error calculating impact from UID: $e');
      throw Exception('Error calculating environmental impact: ${e.toString()}');
    } catch (e) {
      log('❌ Calculate impact from UID error: $e');
      throw Exception('Calculate impact from UID error: ${e.toString()}');
    }
  }

  /// Calculate impact for multiple recipes
  Future<Map<String, dynamic>> calculateBatchImpact(List<String> recipeTitles) async {
    try {
      log('🌱 Calculating batch environmental impact for ${recipeTitles.length} recipes');

      final results = <String, Map<String, dynamic>>{};
      
      for (final title in recipeTitles) {
        try {
          final impact = await calculateImpactFromTitle(title);
          results[title] = impact;
        } catch (e) {
          log('⚠️ Failed to calculate impact for recipe: $title - $e');
          results[title] = {'error': e.toString()};
        }
      }

      log('✅ Batch environmental impact calculation completed');
      return {'results': results, 'total_processed': recipeTitles.length};
    } catch (e) {
      log('❌ Calculate batch impact error: $e');
      throw Exception('Calculate batch impact error: ${e.toString()}');
    }
  }

  // ==================== CALCULATIONS MANAGEMENT ====================

  /// Get complete history of environmental calculations
  Future<Map<String, dynamic>> getAllCalculations() async {
    try {
      log('📊 Getting all environmental calculations');

      final response = await _dio.get(_envSavingsCalculations);

      log('✅ All calculations retrieved successfully');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('❌ Error getting all calculations: $e');
      throw Exception('Error getting calculations: ${e.toString()}');
    } catch (e) {
      log('❌ Get all calculations error: $e');
      throw Exception('Get all calculations error: ${e.toString()}');
    }
  }

  /// Filter environmental calculations by cooking status
  Future<Map<String, dynamic>> getCalculationsByStatus(bool isCooked) async {
    try {
      log('📊 Getting calculations by status: ${isCooked ? "cooked" : "not cooked"}');

      final response = await _dio.get(
        _envSavingsCalculationsByStatus,
        queryParameters: {'is_cooked': isCooked},
      );

      log('✅ Calculations by status retrieved successfully');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('❌ Error getting calculations by status: $e');
      throw Exception('Error getting calculations by status: ${e.toString()}');
    } catch (e) {
      log('❌ Get calculations by status error: $e');
      throw Exception('Get calculations by status error: ${e.toString()}');
    }
  }

  /// Update the status of an environmental calculation
  Future<Map<String, dynamic>> updateCalculationStatus(
    String calculationId,
    bool isCooked,
  ) async {
    try {
      log('📝 Updating calculation status: $calculationId to ${isCooked ? "cooked" : "not cooked"}');

      final response = await _dio.put(
        '$_envSavingsUpdateCalculation/$calculationId',
        data: {'is_cooked': isCooked},
      );

      log('✅ Calculation status updated successfully');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('❌ Error updating calculation status: $e');
      throw Exception('Error updating calculation status: ${e.toString()}');
    } catch (e) {
      log('❌ Update calculation status error: $e');
      throw Exception('Update calculation status error: ${e.toString()}');
    }
  }

  // ==================== IMPACT SUMMARY ====================

  /// Get total environmental impact summary
  Future<Map<String, dynamic>> getImpactSummary() async {
    try {
      log('📈 Getting environmental impact summary');

      final response = await _dio.get(_envSavingsSummary);

      log('✅ Impact summary retrieved successfully');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      log('❌ Error getting impact summary: $e');
      throw Exception('Error getting impact summary: ${e.toString()}');
    } catch (e) {
      log('❌ Get impact summary error: $e');
      throw Exception('Get impact summary error: ${e.toString()}');
    }
  }

  /// Get impact summary for date range
  Future<Map<String, dynamic>> getImpactSummaryForDateRange({
    required String startDate,
    required String endDate,
  }) async {
    try {
      log('📈 Getting impact summary for date range: $startDate to $endDate');

      final response = await _dio.get(
        _envSavingsSummary,
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      log('✅ Impact summary for date range retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get impact summary for date range error: $e');
      throw Exception('Get impact summary for date range error: ${e.toString()}');
    }
  }

  /// Get monthly impact summary
  Future<Map<String, dynamic>> getMonthlyImpactSummary({int? year, int? month}) async {
    try {
      final now = DateTime.now();
      final targetYear = year ?? now.year;
      final targetMonth = month ?? now.month;

      final firstDay = DateTime(targetYear, targetMonth, 1);
      final lastDay = DateTime(targetYear, targetMonth + 1, 0);

      final startDate = _formatDate(firstDay);
      final endDate = _formatDate(lastDay);

      log('📈 Getting monthly impact summary for $targetYear-${targetMonth.toString().padLeft(2, '0')}');

      return await getImpactSummaryForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      log('❌ Get monthly impact summary error: $e');
      throw Exception('Get monthly impact summary error: ${e.toString()}');
    }
  }

  /// Get yearly impact summary
  Future<Map<String, dynamic>> getYearlyImpactSummary({int? year}) async {
    try {
      final targetYear = year ?? DateTime.now().year;

      final startDate = '$targetYear-01-01';
      final endDate = '$targetYear-12-31';

      log('📈 Getting yearly impact summary for $targetYear');

      return await getImpactSummaryForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      log('❌ Get yearly impact summary error: $e');
      throw Exception('Get yearly impact summary error: ${e.toString()}');
    }
  }

  // ==================== IMPACT ANALYTICS ====================

  /// Get impact trends over time
  Future<Map<String, dynamic>> getImpactTrends({
    required String period, // 'daily', 'weekly', 'monthly'
    int? days,
  }) async {
    try {
      log('📊 Getting impact trends for period: $period');

      final response = await _dio.get(
        '$_envSavingsSummary/trends',
        queryParameters: {
          'period': period,
          if (days != null) 'days': days,
        },
      );

      log('✅ Impact trends retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get impact trends error: $e');
      throw Exception('Get impact trends error: ${e.toString()}');
    }
  }

  /// Get top contributing recipes to environmental savings
  Future<Map<String, dynamic>> getTopContributingRecipes({int limit = 10}) async {
    try {
      log('🏆 Getting top contributing recipes (limit: $limit)');

      final response = await _dio.get(
        '$_envSavingsCalculations/top',
        queryParameters: {'limit': limit},
      );

      log('✅ Top contributing recipes retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get top contributing recipes error: $e');
      throw Exception('Get top contributing recipes error: ${e.toString()}');
    }
  }

  /// Compare impact with other users (anonymized)
  Future<Map<String, dynamic>> compareImpactWithCommunity() async {
    try {
      log('👥 Getting community impact comparison');

      final response = await _dio.get('$_envSavingsSummary/community-comparison');

      log('✅ Community impact comparison retrieved successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('❌ Get community impact comparison error: $e');
      throw Exception('Get community impact comparison error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get today's date formatted
  String getTodayFormatted() {
    return _formatDate(DateTime.now());
  }

  /// Calculate total savings from impact data
  Map<String, double> calculateTotalSavings(Map<String, dynamic> impactData) {
    final savings = <String, double>{};
    
    if (impactData.containsKey('water_saved_liters')) {
      savings['water'] = (impactData['water_saved_liters'] as num).toDouble();
    }
    
    if (impactData.containsKey('co2_saved_kg')) {
      savings['co2'] = (impactData['co2_saved_kg'] as num).toDouble();
    }
    
    if (impactData.containsKey('energy_saved_kwh')) {
      savings['energy'] = (impactData['energy_saved_kwh'] as num).toDouble();
    }
    
    return savings;
  }

  /// Format impact value for display
  String formatImpactValue(double value, String unit) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k $unit';
    } else if (value >= 1) {
      return '${value.toStringAsFixed(1)} $unit';
    } else {
      return '${(value * 1000).toStringAsFixed(0)}m $unit';
    }
  }
}