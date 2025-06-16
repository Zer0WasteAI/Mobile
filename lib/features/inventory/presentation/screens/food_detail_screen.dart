// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/food_detail.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_backend_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/consumption_tracking.dart';
import 'package:zer0_waste_ai/features/inventory/presentation/screens/food_consumed_screen.dart';

// ✅ RESOLVED: Route name constant already defined in app_router.dart as 'foodDetailRouteName'

class FoodDetailScreen extends ConsumerStatefulWidget {
  final String foodName;
  final String addedAt;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.addedAt,
  });

  static const String routePath = '/inventory/food/detail';
  static const String routeName = 'foodDetail';

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  FoodDetail? _foodDetail;
  bool _isLoading = true;
  bool _isMarkingConsumed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFoodDetail();
  }

  Future<void> _loadFoodDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final backendNotifier = ref.read(inventoryBackendProvider);
      final response = await backendNotifier.getFoodDetail(
        widget.foodName,
        widget.addedAt,
      );

      setState(() {
        _foodDetail = FoodDetail.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsConsumed() async {
    if (_foodDetail == null || _isMarkingConsumed) return;

    // Show confirmation dialog
    final shouldConsume = await _showConsumeConfirmationDialog();
    if (!shouldConsume) return;

    try {
      setState(() {
        _isMarkingConsumed = true;
      });

      final backendNotifier = ref.read(inventoryBackendProvider);
      final response = await backendNotifier.markFoodAsConsumed(
        widget.foodName,
        widget.addedAt,
      );

      final tracking = ConsumptionTracking.fromJson(response);

      // Show success feedback
      _showConsumptionSuccess(tracking);
    } catch (e) {
      setState(() {
        _isMarkingConsumed = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al marcar como consumido: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showConsumeConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Marcar como consumido'),
                content: Text(
                  '¿Estás seguro que quieres marcar "${_foodDetail!.name}" como consumido?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sí, consumido'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showConsumptionSuccess(ConsumptionTracking tracking) {
    setState(() {
      _isMarkingConsumed = false;
    });

    // Calculate environmental impact
    final co2Saved =
        tracking.environmentalImpact?['co2_saved']?.toDouble() ?? 1.2;
    final waterSaved =
        tracking.environmentalImpact?['water_saved']?.toInt() ?? 150;

    // Navigate to success screen
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => FoodConsumedScreen(
                  foodName: widget.foodName,
                  foodEmoji: '🍽️',
                  co2Saved: co2Saved,
                  waterSaved: waterSaved,
                ),
          ),
        )
        .then((_) {
          // Navigate back to inventory after success screen
          Navigator.of(context).pop();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_foodDetail?.displayName ?? widget.foodName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFoodDetail,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          _foodDetail != null && !_foodDetail!.isExpired
              ? FloatingActionButton.extended(
                onPressed: _isMarkingConsumed ? null : _markAsConsumed,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon:
                    _isMarkingConsumed
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.restaurant),
                label: Text(
                  _isMarkingConsumed ? 'Marcando...' : 'Consumido',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              )
              : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando detalles de la comida...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los detalles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFoodDetail,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_foodDetail == null) {
      return const Center(
        child: Text('No se encontraron detalles de la comida'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildNutritionalInfoCard(),
          const SizedBox(height: 16),
          _buildIngredientsCard(),
          const SizedBox(height: 16),
          if (_foodDetail!.nutritionalAnalysis != null)
            _buildNutritionalAnalysisCard(),
          const SizedBox(height: 16),
          if (_foodDetail!.consumptionIdeas != null &&
              _foodDetail!.consumptionIdeas!.isNotEmpty)
            _buildConsumptionIdeasCard(),
          const SizedBox(height: 16),
          if (_foodDetail!.storageAdvice != null) _buildStorageAdviceCard(),
          const SizedBox(height: 16),
          _buildExpirationCard(),
          const SizedBox(height: 16),
          _buildMetadataCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagen de la comida (puede ser null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child:
                      _foodDetail!.imagePath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _foodDetail!.imagePath!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                          : const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _foodDetail!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _foodDetail!.category,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_foodDetail!.servingQuantity} ${_foodDetail!.servingQuantity == 1 ? 'porción' : 'porciones'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Almacenamiento: ${_foodDetail!.storageType}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_foodDetail!.description != null &&
                _foodDetail!.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _foodDetail!.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_foodDetail!.tips != null && _foodDetail!.tips!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _foodDetail!.tips!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Información Nutricional',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionalItem(
                    'Calorías Totales',
                    '${_foodDetail!.totalCalories}',
                    'kcal',
                    Colors.red[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNutritionalItem(
                    'Por Porción',
                    '${_foodDetail!.caloriesPerServing.toInt()}',
                    'kcal',
                    Colors.orange[600]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalItem(
    String title,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Ingredientes Principales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _foodDetail!.mainIngredients
                      .map(
                        (ingredient) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Text(
                            ingredient,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalAnalysisCard() {
    final analysis = _foodDetail!.nutritionalAnalysis!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Análisis Nutricional',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (analysis.macronutrients != null) ...[
              _buildAnalysisSection('Macronutrientes', Icons.pie_chart, [
                if (analysis.macronutrients!.carbohydrates != null)
                  'Carbohidratos: ${analysis.macronutrients!.carbohydrates!}',
                if (analysis.macronutrients!.proteins != null)
                  'Proteínas: ${analysis.macronutrients!.proteins!}',
                if (analysis.macronutrients!.fats != null)
                  'Grasas: ${analysis.macronutrients!.fats!}',
              ]),
            ],
            if (analysis.vitaminsMinerals != null &&
                analysis.vitaminsMinerals!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAnalysisSection(
                'Vitaminas y Minerales',
                Icons.health_and_safety,
                analysis.vitaminsMinerals!,
              ),
            ],
            if (analysis.healthBenefits != null &&
                analysis.healthBenefits!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAnalysisItem(
                'Beneficios para la Salud',
                analysis.healthBenefits!,
                Icons.favorite,
                Colors.red,
              ),
            ],
            if (analysis.dietaryConsiderations != null &&
                analysis.dietaryConsiderations!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAnalysisItem(
                'Consideraciones Dietéticas',
                analysis.dietaryConsiderations!,
                Icons.warning_amber,
                Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 4),
            child: Text(
              '• $item',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(content, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionIdeasCard() {
    final ideas = _foodDetail!.consumptionIdeas!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Ideas de Consumo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ideas.map(
              (idea) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            idea.title,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            idea.type,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      idea.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageAdviceCard() {
    final advice = _foodDetail!.storageAdvice!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.kitchen, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  'Consejos de Almacenamiento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (advice.optimalTemperature != null &&
                advice.optimalTemperature!.isNotEmpty) ...[
              _buildStorageAdviceItem(
                'Temperatura Óptima',
                advice.optimalTemperature!,
                Icons.thermostat,
              ),
            ],
            if (advice.reheatingTips != null &&
                advice.reheatingTips!.isNotEmpty) ...[
              _buildStorageAdviceItem(
                'Consejos de Recalentamiento',
                advice.reheatingTips!,
                Icons.microwave,
              ),
            ],
            if (advice.shelfLifeExtension != null &&
                advice.shelfLifeExtension!.isNotEmpty) ...[
              _buildStorageAdviceItem(
                'Extensión de Vida Útil',
                advice.shelfLifeExtension!,
                Icons.schedule,
              ),
            ],
            if (advice.qualityIndicators != null &&
                advice.qualityIndicators!.isNotEmpty) ...[
              _buildStorageAdviceItem(
                'Indicadores de Calidad',
                advice.qualityIndicators!,
                Icons.check_circle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorageAdviceItem(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationCard() {
    final isExpired = _foodDetail!.isExpired;
    final isExpiringSoon = _foodDetail!.daysToExpire <= 1 && !isExpired;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isExpired ? Icons.warning : Icons.schedule,
                  color:
                      isExpired
                          ? Colors.red[600]
                          : isExpiringSoon
                          ? Colors.orange[600]
                          : Colors.green[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado de Vencimiento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isExpired
                        ? Colors.red[50]
                        : isExpiringSoon
                        ? Colors.orange[50]
                        : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isExpired
                          ? Colors.red[200]!
                          : isExpiringSoon
                          ? Colors.orange[200]!
                          : Colors.green[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpired
                        ? '⚠️ VENCIDO'
                        : isExpiringSoon
                        ? '⏰ Vence pronto'
                        : '✅ En buen estado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isExpired
                              ? Colors.red[700]
                              : isExpiringSoon
                              ? Colors.orange[700]
                              : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha de vencimiento: ${_formatDate(_foodDetail!.expirationDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isExpired
                        ? 'Vencido hace ${(-_foodDetail!.daysToExpire).abs()} días'
                        : 'Días restantes: ${_foodDetail!.daysToExpire}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isExpired
                              ? Colors.red[600]
                              : isExpiringSoon
                              ? Colors.orange[600]
                              : Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Agregado: ${_formatDate(_foodDetail!.addedAt)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Información del Sistema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ID único: ${_foodDetail!.uniqueId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Datos enriquecidos con: ${_foodDetail!.enrichedWith.join(', ')}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${_formatDate(_foodDetail!.fetchedAt.toIso8601String())}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}


// Helper extension for ExpirationStatus (copy if not globally available)
// Placeholder - assumes ExpirationStatusExtension exists as defined previously
/*
extension ExpirationStatusExtension on ExpirationStatus {
  IconData get icon { ... }
  static ExpirationStatus fromDate(DateTime? date) { ... }
}
*/

// Placeholder - assumes InventoryItem.empty() exists
/*
extension InventoryItemExtension on InventoryItem {
 static InventoryItem empty() => InventoryItem(...);
 // Need to add fields like:
 // description: null,
 // calories: null,
 // servingQuantity: null,
 // mainIngredients: null,
 // foodCategory: null,
}
*/

// ✅ COMPLETED: All required fields are already in InventoryItem model:
// - String? description ✅
// - int? calories ✅
// - int? servingQuantity ✅
// - List<String>? mainIngredients ✅
// - String? foodCategory ✅

// ✅ COMPLETED: NutritionInfoChip widget created
// Location: lib/features/inventory/presentation/widgets/nutrition_info_chip.dart
/*
class NutritionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const NutritionInfoChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Fit content
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
*/


