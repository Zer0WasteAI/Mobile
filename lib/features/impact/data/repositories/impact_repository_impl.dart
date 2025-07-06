import 'package:zer0_waste_ai/core/services/api_service.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_impact.dart';
import 'package:zer0_waste_ai/features/impact/domain/models/environmental_summary.dart';
import 'package:zer0_waste_ai/features/impact/domain/repositories/impact_repository.dart';

class ImpactRepositoryImpl implements ImpactRepository {
  final ApiService _apiService;

  ImpactRepositoryImpl(this._apiService);

  @override
  Future<EnvironmentalImpact> calculateImpactFromTitle(String title) async {
    final result = await _apiService.calculateImpactFromTitle(title);
    return EnvironmentalImpact.fromJson(result);
  }

  @override
  Future<EnvironmentalImpact> calculateImpactFromUid(String recipeUid) async {
    final result = await _apiService.calculateImpactFromUid(recipeUid);
    return EnvironmentalImpact.fromJson(result);
  }

  @override
  Future<EnvironmentalCalculations> getAllCalculations() async {
    final result = await _apiService.getAllCalculations();
    return EnvironmentalCalculations.fromJson(result);
  }

  @override
  Future<EnvironmentalCalculations> getCalculationsByStatus(
    bool isCooked,
  ) async {
    final result = await _apiService.getCalculationsByStatus(isCooked);
    return EnvironmentalCalculations.fromJson(result);
  }

  @override
  Future<EnvironmentalSummary> getImpactSummary() async {
    final result = await _apiService.getImpactSummary();
    return EnvironmentalSummary.fromJson(result);
  }

  @override
  Future<EnvironmentalImpact> updateCalculationStatus(
    String recipeUid,
    bool isCooked,
  ) async {
    final result = await _apiService.updateCalculationStatus(
      recipeUid,
      isCooked,
    );
    return EnvironmentalImpact.fromJson(result);
  }
}
