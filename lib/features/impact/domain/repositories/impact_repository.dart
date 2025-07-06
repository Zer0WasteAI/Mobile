import 'package:zer0_waste_ai/features/impact/domain/models/environmental_impact.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_summary.dart';

abstract class ImpactRepository {
  Future<EnvironmentalImpact> calculateImpactFromTitle(String title);
  Future<EnvironmentalImpact> calculateImpactFromUid(String recipeUid);
  Future<EnvironmentalCalculations> getAllCalculations();
  Future<EnvironmentalCalculations> getCalculationsByStatus(bool isCooked);
  Future<EnvironmentalSummary> getImpactSummary();
  Future<EnvironmentalImpact> updateCalculationStatus(
    String recipeUid,
    bool isCooked,
  );
}
