import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/core/admin/domain/repositories/admin_repository.dart';

/// INFO: Implementation of AdminRepository using ZeroWasteAI backend
/// WARNING: All methods require admin role permissions
/// USAGE: Use this through the adminRepositoryProvider
class AdminRepositoryImpl implements AdminRepository {
  final ApiService _apiService;

  AdminRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> getUsers() async {
    try {
      // WARNING: Admin only endpoint - requires admin role
      return await _apiService.getUsers();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception('Failed to get users: ${_apiService.getErrorMessage(e)}');
    }
  }

  @override
  Future<Map<String, dynamic>> syncImages() async {
    try {
      // WARNING: Admin only endpoint - maintenance operation
      return await _apiService.syncImages();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to sync images: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      // WARNING: Admin only endpoint - system metrics
      return await _apiService.getSystemStats();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get system stats: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      // WARNING: Admin only endpoint - health monitoring
      return await _apiService.getSystemHealth();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get system health: ${_apiService.getErrorMessage(e)}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      // INFO: Public endpoint - system status check
      return await _apiService.getSystemStatus();
    } catch (e) {
      // INFO: Convert API errors to domain-friendly error messages
      throw Exception(
        'Failed to get system status: ${_apiService.getErrorMessage(e)}',
      );
    }
  }
}
