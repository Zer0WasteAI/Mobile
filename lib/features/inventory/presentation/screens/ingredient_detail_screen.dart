import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/ingredient_detail.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_backend_provider.dart';

// TODO: Define route name constant if needed elsewhere
// const String ingredientDetailRouteName = 'ingredientDetail';

/// INFO: Pantalla de detalle completo de un ingrediente del inventario
/// USAGE: Muestra información enriquecida con IA: impacto ambiental, ideas de utilización, consejos
/// IMPORTANT: Usa IngredientDetail model con manejo correcto de campos nullable
class IngredientDetailScreen extends ConsumerStatefulWidget {
  final String ingredientName;

  const IngredientDetailScreen({super.key, required this.ingredientName});

  @override
  ConsumerState<IngredientDetailScreen> createState() =>
      _IngredientDetailScreenState();
}

class _IngredientDetailScreenState
    extends ConsumerState<IngredientDetailScreen> {
  IngredientDetail? _ingredientDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadIngredientDetail();
  }

  Future<void> _loadIngredientDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final backendNotifier = ref.read(inventoryBackendProvider);
      final response = await backendNotifier.getIngredientDetail(
        widget.ingredientName,
      );

      setState(() {
        _ingredientDetail = IngredientDetail.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_ingredientDetail?.name ?? widget.ingredientName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIngredientDetail,
          ),
        ],
      ),
      body: _buildBody(),
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
            Text('Cargando detalles del ingrediente...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los detalles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadIngredientDetail,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_ingredientDetail == null) {
      return const Center(
        child: Text('No se encontraron detalles del ingrediente'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          _buildStacksCard(),
          const SizedBox(height: 20),
          // Secciones condicionales basadas en campos nullable
          if (_ingredientDetail!.environmentalImpact != null) ...[
            _buildEnvironmentalImpactCard(),
            const SizedBox(height: 20),
          ],
          if (_ingredientDetail!.utilizationIdeas != null &&
              _ingredientDetail!.utilizationIdeas!.isNotEmpty) ...[
            _buildUtilizationIdeasCard(),
            const SizedBox(height: 20),
          ],
          if (_ingredientDetail!.consumptionAdvice != null) ...[
            _buildConsumptionAdviceCard(),
            const SizedBox(height: 20),
          ],
          if (_ingredientDetail!.beforeConsumptionAdvice != null) ...[
            _buildBeforeConsumptionAdviceCard(),
            const SizedBox(height: 20),
          ],
          _buildMetadataCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Imagen del ingrediente con fallback
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child:
                  _ingredientDetail!.imagePath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _ingredientDetail!.imagePath!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                      : const Icon(Icons.eco, size: 40, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ingredientDetail!.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(_ingredientDetail!.storageType),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          '${_ingredientDetail!.stackCount} ${_ingredientDetail!.stackCount == 1 ? 'lote' : 'lotes'}',
                        ),
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${_ingredientDetail!.totalQuantity} ${_ingredientDetail!.typeUnit}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStacksCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lotes en inventario',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_ingredientDetail!.stacks.map(
              (stack) => _buildStackItem(stack),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStackItem(IngredientStack stack) {
    Color statusColor = Colors.green;
    if (stack.isExpired) {
      statusColor = Colors.red;
    } else if (stack.daysToExpire <= 3) {
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stack.quantity} ${stack.typeUnit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Vence: ${stack.expirationDate}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (stack.isExpired)
                  const Text(
                    '¡VENCIDO!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'Faltan ${stack.daysToExpire} días',
                    style: TextStyle(color: statusColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard() {
    final impact = _ingredientDetail!.environmentalImpact!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Impacto Ambiental',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Huella de carbono (nullable)
            if (impact.carbonFootprint != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Huella de Carbono',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${impact.carbonFootprint!.value} ${impact.carbonFootprint!.unit}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            impact.carbonFootprint!.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Huella hídrica (nullable)
            if (impact.waterFootprint != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.water_drop_outlined, color: Colors.cyan[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Huella Hídrica',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${impact.waterFootprint!.value} ${impact.waterFootprint!.unit}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            impact.waterFootprint!.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Mensaje de sostenibilidad (nullable)
            if (impact.sustainabilityMessage != null &&
                impact.sustainabilityMessage!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.nature, color: Colors.green[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        impact.sustainabilityMessage!,
                        style: const TextStyle(fontSize: 14),
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

  Widget _buildUtilizationIdeasCard() {
    final ideas = _ingredientDetail!.utilizationIdeas!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  'Ideas de Utilización',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ideas.map(
              (idea) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(idea.description),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(idea.type),
                      backgroundColor: Colors.amber.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(fontSize: 12),
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

  Widget _buildConsumptionAdviceCard() {
    final advice = _ingredientDetail!.consumptionAdvice!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Consejos de Consumo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAdviceContent(advice),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeConsumptionAdviceCard() {
    final advice = _ingredientDetail!.beforeConsumptionAdvice!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Antes del Consumo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAdviceContent(advice),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceContent(ConsumptionAdvice advice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Consumo óptimo (nullable)
        if (advice.optimalConsumption != null &&
            advice.optimalConsumption!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consumo Óptimo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(advice.optimalConsumption!),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Tips de preparación (nullable)
        if (advice.preparationTips != null &&
            advice.preparationTips!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips de Preparación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(advice.preparationTips!),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Beneficios nutricionales (nullable)
        if (advice.nutritionalBenefits != null &&
            advice.nutritionalBenefits!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Beneficios Nutricionales',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(advice.nutritionalBenefits!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Sistema',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Tips adicionales (nullable)
            if (_ingredientDetail!.tips != null &&
                _ingredientDetail!.tips!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tips Adicionales',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(_ingredientDetail!.tips!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Vencimiento más próximo (nullable)
            if (_ingredientDetail!.nearestExpiration != null) ...[
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Próximo vencimiento: ${_ingredientDetail!.nearestExpiration}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Datos enriquecidos
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enriquecido con: ${_ingredientDetail!.enrichedWith.join(', ')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Actualizado: ${_formatDateTime(_ingredientDetail!.fetchedAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Helper extension for ExpirationStatus (if not already defined elsewhere)
// You might already have this in your project
/*
extension ExpirationStatusExtension on ExpirationStatus {
  IconData get icon {
    switch (this) {
      case ExpirationStatus.expired:
        return Icons.error_outline;
      case ExpirationStatus.expiringSoon:
        return Icons.warning_amber_outlined;
      case ExpirationStatus.fresh:
        return Icons.check_circle_outline;
      case ExpirationStatus.unknown:
      default:
        return Icons.help_outline; // Or another suitable icon
    }
  }

  static ExpirationStatus fromDate(DateTime? date) {
     if (date == null) return ExpirationStatus.unknown;
     final now = DateTime.now();
     final difference = date.difference(now).inDays;
     final startOfToday = DateTime(now.year, now.month, now.day);
     final startOfExpirationDay = DateTime(date.year, date.month, date.day);
     final dayDifference = startOfExpirationDay.difference(startOfToday).inDays;


     if (dayDifference < 0) {
       return ExpirationStatus.expired;
     } else if (dayDifference <= 5) { // Expiring within 5 days (inclusive of today)
       return ExpirationStatus.expiringSoon;
     } else {
       return ExpirationStatus.fresh;
     }
   }
}
*/

// Add an empty factory to InventoryItem for the orElse case
/*
extension InventoryItemExtension on InventoryItem {
  static InventoryItem empty() => InventoryItem(
    id: '',
    name: '',
    image: '',
    quantity: 0,
    storageType: StorageType.unknown,
    category: ItemCategory.food, // Or a default category
    addedDate: DateTime.now(),
    // Add other fields with default values if necessary
    unitType: 'unidades',
    tips: null,
    expirationDate: null,
  );
}
 */
