/// INFO: Repository interface for system administration operations
/// WARNING: These endpoints require admin role permissions
/// USAGE: Implement this interface for different admin data sources
abstract class AdminRepository {
  /// INFO: Get all users in the system
  /// WARNING: Admin only - requires admin role
  /// RETURNS: Map with users array and metadata
  Future<Map<String, dynamic>> getUsers();

  /// INFO: Synchronize reference images database
  /// WARNING: Admin only - maintenance operation
  /// RETURNS: Sync operation result with status
  Future<Map<String, dynamic>> syncImages();

  /// INFO: Get system statistics
  /// WARNING: Admin only - system metrics and usage stats
  /// RETURNS: Complete system statistics including users, recipes, etc.
  Future<Map<String, dynamic>> getSystemStats();

  /// INFO: Get system health status
  /// WARNING: Admin only - comprehensive health monitoring
  /// RETURNS: System health with database, memory, CPU, disk info
  Future<Map<String, dynamic>> getSystemHealth();

  /// INFO: Get public system status
  /// USAGE: Check if the API is operational and responsive
  /// RETURNS: Public system status information
  Future<Map<String, dynamic>> getSystemStatus();
}
