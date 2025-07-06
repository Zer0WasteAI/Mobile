import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/admin/domain/repositories/admin_repository.dart';
import 'package:zer0_waste_ai/core/admin/data/repositories/admin_repository_impl.dart';

/// INFO: Provider for AdminRepository implementation
/// WARNING: Requires admin role permissions
/// USAGE: Use ref.watch(adminRepositoryProvider) to get repository instance
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl();
});

/// INFO: Provider for admin backend operations
/// WARNING: All operations require admin role
/// USAGE: Use this for admin panel functionality
final adminBackendProvider = Provider<AdminBackendNotifier>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminBackendNotifier(repository);
});

/// INFO: Backend notifier for admin operations
/// WARNING: All methods require admin role permissions
/// ADVICE: Handles all backend communication for system administration
class AdminBackendNotifier {
  final AdminRepository _repository;

  AdminBackendNotifier(this._repository);

  /// INFO: Get all users in the system
  /// WARNING: Admin only endpoint
  Future<Map<String, dynamic>> getUsers() async {
    return await _repository.getUsers();
  }

  /// INFO: Synchronize reference images database
  /// WARNING: Admin only maintenance operation
  Future<Map<String, dynamic>> syncImages() async {
    return await _repository.syncImages();
  }

  /// INFO: Get comprehensive system statistics
  /// WARNING: Admin only endpoint
  Future<Map<String, dynamic>> getSystemStats() async {
    return await _repository.getSystemStats();
  }

  /// INFO: Get detailed system health status
  /// WARNING: Admin only endpoint
  Future<Map<String, dynamic>> getSystemHealth() async {
    return await _repository.getSystemHealth();
  }

  /// INFO: Get public system status
  /// USAGE: Available to all users for system monitoring
  Future<Map<String, dynamic>> getSystemStatus() async {
    return await _repository.getSystemStatus();
  }
}
