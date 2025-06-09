/// INFO: Repository interface for AI-powered meal planning
/// ADVICE: This defines the contract for all meal planning operations
/// USAGE: Implement this interface to create different meal plan data sources
abstract class MealPlanRepository {
  /// INFO: Generate meal plan based on available ingredients
  /// ADVICE: AI analyzes your inventory and suggests optimal meal plans
  /// RETURNS: Complete meal plan with days, meals, and recipes
  Future<Map<String, dynamic>> generateMealPlan({
    required List<Map<String, dynamic>> ingredients,
  });

  /// INFO: Get meal planning history
  /// USAGE: Retrieve past meal plans and their execution status
  /// RETURNS: List of historical meal plans with metadata
  Future<Map<String, dynamic>> getMealPlanHistory();
}
