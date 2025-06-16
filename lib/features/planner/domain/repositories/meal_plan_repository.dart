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

  /// INFO: Save meal plan for a specific date
  /// USAGE: Save complete meal plan with breakfast, lunch, dinner for a date
  /// RETURNS: Saved meal plan with UID and total calories
  Future<Map<String, dynamic>> saveMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  });

  /// INFO: Update existing meal plan
  /// USAGE: Update meal plan for a specific date with new meal data
  /// RETURNS: Updated meal plan with modifications
  Future<Map<String, dynamic>> updateMealPlan({
    required String date,
    required Map<String, dynamic> meals,
  });

  /// INFO: Get meal plan by specific date
  /// USAGE: Retrieve meal plan for a specific date (YYYY-MM-DD format)
  /// RETURNS: Meal plan with breakfast, lunch, dinner and total calories
  Future<Map<String, dynamic>> getMealPlanByDate(String date);

  /// INFO: Get all user's meal plans
  /// USAGE: Retrieve all meal plans created by the user
  /// RETURNS: Array of all meal plans with metadata
  Future<Map<String, dynamic>> getAllMealPlans();

  /// INFO: Get list of dates with existing meal plans
  /// USAGE: Get dates that have meal plans for calendar/navigation purposes
  /// RETURNS: Array of dates in YYYY-MM-DD format
  Future<Map<String, dynamic>> getMealPlanDates();

  /// INFO: Delete meal plan for specific date
  /// USAGE: Remove meal plan for a specific date
  /// RETURNS: Confirmation message
  Future<Map<String, dynamic>> deleteMealPlan(String date);
}
