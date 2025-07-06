import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/ingredient_detail.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_backend_provider.dart';

/// Pantalla de detalle completo de un ingrediente del inventario
///
/// Muestra información enriquecida con IA: impacto ambiental,
/// ideas de utilización, consejos de consumo y preparación.
///
/// Usa IngredientDetail model con manejo correcto de campos nullable
class IngredientDetailScreen extends ConsumerStatefulWidget {
  final String ingredientName;

  const IngredientDetailScreen({super.key, required this.ingredientName});

  static const String routeName = 'ingredientDetail';

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

  // ============================================================================
  // DATA LOADING METHODS
  // ============================================================================

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

  // ============================================================================
  // BUILD METHODS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_ingredientDetail?.name ?? widget.ingredientName),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadIngredientDetail,
          tooltip: 'Actualizar información',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_ingredientDetail == null) {
      return _buildEmptyState();
    }

    return _buildContent();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando detalles del ingrediente...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los detalles',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadIngredientDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron detalles del ingrediente',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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

          if (_ingredientDetail!.beforeConsumptionAdvice != null ||
              _ingredientDetail!.tips != null ||
              _ingredientDetail!.nearestExpiration != null) ...[
            _buildEnhancedBeforeConsumptionCard(),
            const SizedBox(height: 20),
          ],

          // Solo mostrar información básica del sistema
          _buildSystemInfoCard(),
        ],
      ),
    );
  }

  // ============================================================================
  // CARD WIDGETS
  // ============================================================================

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            _buildIngredientImage(),
            const SizedBox(width: 16),
            Expanded(child: _buildIngredientInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          _ingredientDetail!.imagePath != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _ingredientDetail!.imagePath!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey[500],
                      ),
                ),
              )
              : Icon(Icons.eco, size: 40, color: Colors.green[600]),
    );
  }

  Widget _buildIngredientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _ingredientDetail!.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildInfoChip(
              label: _ingredientDetail!.storageType,
              backgroundColor: Colors.blue,
              icon: Icons.storage,
            ),
            _buildInfoChip(
              label:
                  '${_ingredientDetail!.stackCount} ${_ingredientDetail!.stackCount == 1 ? 'lote' : 'lotes'}',
              backgroundColor: Colors.orange,
              icon: Icons.inventory,
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Total: ${_ingredientDetail!.totalQuantity} ${_ingredientDetail!.typeUnit}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required MaterialColor backgroundColor,
    required IconData icon,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: backgroundColor[700]),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: backgroundColor[700],
        ),
      ),
      backgroundColor: backgroundColor.withValues(alpha: 0.1),
      side: BorderSide(color: backgroundColor.withValues(alpha: 0.3)),
    );
  }

  Widget _buildStacksCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.indigo[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Lotes en inventario',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
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
    String statusText = 'Faltan ${stack.daysToExpire} días';
    IconData statusIcon = Icons.check_circle;

    if (stack.isExpired) {
      statusColor = Colors.red;
      statusText = '¡VENCIDO!';
      statusIcon = Icons.error;
    } else if (stack.daysToExpire <= 3) {
      statusColor = Colors.orange;
      statusText = 'Vence pronto (${stack.daysToExpire} días)';
      statusIcon = Icons.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color: statusColor.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${stack.quantity} ${stack.typeUnit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(statusIcon, color: statusColor, size: 20),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  'Vence: ${stack.expirationDate}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),

                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Impacto Ambiental',
              icon: Icons.eco,
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Huella de carbono
            if (impact.carbonFootprint != null) ...[
              _buildImpactItem(
                title: 'Huella de Carbono',
                value:
                    '${impact.carbonFootprint!.value} ${impact.carbonFootprint!.unit}',
                description: impact.carbonFootprint!.description,
                icon: Icons.cloud_outlined,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
            ],

            // Huella hídrica
            if (impact.waterFootprint != null) ...[
              _buildImpactItem(
                title: 'Huella Hídrica',
                value:
                    '${impact.waterFootprint!.value} ${impact.waterFootprint!.unit}',
                description: impact.waterFootprint!.description,
                icon: Icons.water_drop_outlined,
                color: Colors.cyan,
              ),
              const SizedBox(height: 12),
            ],

            // Mensaje de sostenibilidad
            if (impact.sustainabilityMessage != null &&
                impact.sustainabilityMessage!.isNotEmpty) ...[
              _buildSustainabilityMessage(impact.sustainabilityMessage!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color[600], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactItem({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color[600], size: 20),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color[700],
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.nature, color: Colors.green[600], size: 20),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mensaje de Sostenibilidad',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),

                Text(message, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationIdeasCard() {
    final ideas = _ingredientDetail!.utilizationIdeas!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Ideas de Utilización',
              icon: Icons.lightbulb_outline,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),

            ...ideas.map((idea) => _buildUtilizationIdea(idea)),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizationIdea(UtilizationIdea idea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  idea.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  idea.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(idea.description, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildConsumptionAdviceCard() {
    final advice = _ingredientDetail!.consumptionAdvice!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Consejos de Consumo',
              icon: Icons.restaurant_menu,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),

            _buildAdviceContent(advice),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBeforeConsumptionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Antes del Consumo',
              icon: Icons.warning_amber_outlined,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),

            // Consejos de "antes del consumo" si existen
            if (_ingredientDetail!.beforeConsumptionAdvice != null) ...[
              _buildAdviceContent(_ingredientDetail!.beforeConsumptionAdvice!),
              const SizedBox(height: 16),
            ],

            // Información de vencimiento próximo
            if (_ingredientDetail!.nearestExpiration != null) ...[
              _buildExpirationWarningSection(),
              const SizedBox(height: 16),
            ],

            // Tips adicionales relacionados con el consumo
            if (_ingredientDetail!.tips != null &&
                _ingredientDetail!.tips!.isNotEmpty) ...[
              _buildConsumptionTipsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationWarningSection() {
    final expirationText = _ingredientDetail!.nearestExpiration!;
    final formattedExpiration = _formatExpirationDate(expirationText);
    final urgencyInfo = _getExpirationUrgency(expirationText);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: urgencyInfo['color'].withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: urgencyInfo['color'].withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                urgencyInfo['icon'],
                color: urgencyInfo['color'][600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estado de Vencimiento',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            formattedExpiration['main'] ?? 'Fecha no disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: urgencyInfo['color'][700],
            ),
          ),

          if (formattedExpiration['subtitle'] != null) ...[
            const SizedBox(height: 4),
            Text(
              formattedExpiration['subtitle']!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsumptionTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Consejos Importantes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(_ingredientDetail!.tips!, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAdviceContent(ConsumptionAdvice advice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Consumo óptimo
        if (advice.optimalConsumption != null &&
            advice.optimalConsumption!.isNotEmpty) ...[
          _buildAdviceSection(
            title: 'Consumo Óptimo',
            content: advice.optimalConsumption!,
            icon: Icons.star_outline,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
        ],

        // Tips de preparación
        if (advice.preparationTips != null &&
            advice.preparationTips!.isNotEmpty) ...[
          _buildAdviceSection(
            title: 'Tips de Preparación',
            content: advice.preparationTips!,
            icon: Icons.kitchen,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
        ],

        // Beneficios nutricionales
        if (advice.nutritionalBenefits != null &&
            advice.nutritionalBenefits!.isNotEmpty) ...[
          _buildAdviceSection(
            title: 'Beneficios Nutricionales',
            content: advice.nutritionalBenefits!,
            icon: Icons.health_and_safety,
            color: Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildAdviceSection({
    required String title,
    required String content,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color[600], size: 18),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),

                Text(content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Información del Sistema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Solo información básica del sistema
            _buildMetadataItem(
              icon: Icons.access_time,
              title: 'Última Actualización',
              content: _formatDateTime(_ingredientDetail!.fetchedAt),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String title,
    required String content,
    required MaterialColor color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color[600], size: 20),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                content,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, String?> _formatExpirationDate(String dateString) {
    try {
      // Intentar parsear diferentes formatos de fecha
      DateTime? expirationDate;

      // Formato ISO: 2025-06-25T19:38:45
      if (dateString.contains('T')) {
        expirationDate = DateTime.tryParse(dateString);
      }
      // Formato simple: 2025-06-25
      else if (dateString.contains('-')) {
        expirationDate = DateTime.tryParse(dateString);
      }
      // Formato DD/MM/YYYY
      else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            expirationDate = DateTime(year, month, day);
          }
        }
      }

      if (expirationDate == null) {
        return {'main': dateString, 'subtitle': null};
      }

      final now = DateTime.now();
      final difference = expirationDate.difference(now).inDays;

      // Nombres de meses en español
      final months = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];

      // Nombres de días en español
      final weekdays = [
        'lunes',
        'martes',
        'miércoles',
        'jueves',
        'viernes',
        'sábado',
        'domingo',
      ];

      String mainText;
      String? subtitleText;

      if (difference < 0) {
        final daysPast = difference.abs();
        mainText = daysPast == 1 ? 'Venció ayer' : 'Venció hace $daysPast días';
        subtitleText =
            '${expirationDate.day} de ${months[expirationDate.month - 1]} de ${expirationDate.year}';
      } else if (difference == 0) {
        mainText = '¡Vence hoy!';
        subtitleText = 'Consumir con precaución';
      } else if (difference == 1) {
        mainText = 'Vence mañana';
        subtitleText =
            '${weekdays[expirationDate.weekday - 1]}, ${expirationDate.day} de ${months[expirationDate.month - 1]}';
      } else if (difference <= 7) {
        mainText = 'Vence en $difference días';
        subtitleText =
            '${weekdays[expirationDate.weekday - 1]}, ${expirationDate.day} de ${months[expirationDate.month - 1]}';
      } else if (difference <= 30) {
        mainText = 'Vence en $difference días';
        subtitleText =
            '${expirationDate.day} de ${months[expirationDate.month - 1]} de ${expirationDate.year}';
      } else {
        mainText =
            '${expirationDate.day} de ${months[expirationDate.month - 1]} de ${expirationDate.year}';
        subtitleText = 'Faltan $difference días';
      }

      return {'main': mainText, 'subtitle': subtitleText};
    } catch (e) {
      return {'main': dateString, 'subtitle': 'Formato de fecha no reconocido'};
    }
  }

  Map<String, dynamic> _getExpirationUrgency(String dateString) {
    try {
      DateTime? expirationDate;

      // Intentar parsear la fecha
      if (dateString.contains('T')) {
        expirationDate = DateTime.tryParse(dateString);
      } else if (dateString.contains('-')) {
        expirationDate = DateTime.tryParse(dateString);
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            expirationDate = DateTime(year, month, day);
          }
        }
      }

      if (expirationDate == null) {
        return {'color': Colors.grey, 'icon': Icons.help_outline};
      }

      final now = DateTime.now();
      final difference = expirationDate.difference(now).inDays;

      if (difference < 0) {
        // Vencido
        return {'color': Colors.red, 'icon': Icons.error};
      } else if (difference == 0) {
        // Vence hoy
        return {'color': Colors.red, 'icon': Icons.warning};
      } else if (difference <= 3) {
        // Vence en 1-3 días
        return {'color': Colors.orange, 'icon': Icons.warning_amber};
      } else if (difference <= 7) {
        // Vence en 4-7 días
        return {'color': Colors.amber, 'icon': Icons.schedule};
      } else {
        // Más de 7 días
        return {'color': Colors.green, 'icon': Icons.check_circle_outline};
      }
    } catch (e) {
      return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
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
