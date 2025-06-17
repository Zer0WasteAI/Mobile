import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/simplified_recognition_provider.dart';

import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';

class SimplifiedRecognitionScreen extends ConsumerStatefulWidget {
  static const String routeName = '/simplified-recognition';

  const SimplifiedRecognitionScreen({super.key});

  @override
  ConsumerState<SimplifiedRecognitionScreen> createState() =>
      _SimplifiedRecognitionScreenState();
}

class _SimplifiedRecognitionScreenState
    extends ConsumerState<SimplifiedRecognitionScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simplifiedRecognitionProvider);
    final notifier = ref.read(simplifiedRecognitionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Reconocimiento Simplificado'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (state.hasResults) ...[
            // 🔄 Force refresh button
            IconButton(
              onPressed: () => _forceRefreshImages(notifier, state),
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar Imágenes',
            ),
            // 🔍 Debug button
            IconButton(
              onPressed: () => _showDebugInfo(context, state),
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug Info',
            ),
            IconButton(
              onPressed: () => notifier.clearState(),
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar resultados',
            ),
          ],
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SimplifiedRecognitionState state,
    SimplifiedRecognitionNotifier notifier,
  ) {
    if (state.isLoading) {
      return _buildLoadingView(state);
    }

    if (state.error != null) {
      return _buildErrorView(state, notifier);
    }

    if (!state.hasResults) {
      return _buildEmptyView(notifier);
    }

    return _buildResultsView(state);
  }

  Widget _buildLoadingView(SimplifiedRecognitionState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            state.currentStep,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    SimplifiedRecognitionState state,
    SimplifiedRecognitionNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error en el reconocimiento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.clearError(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(SimplifiedRecognitionNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Reconoce ingredientes con IA!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toma fotos de ingredientes y obtén resultados inmediatos',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _selectImagesAndRecognize(notifier),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Fotos'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(SimplifiedRecognitionState state) {
    return Column(
      children: [
        // Images status indicator
        if (state.imagesStatus == 'generating')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '🎨 Generando imágenes en segundo plano...',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ],
            ),
          ),

        // Results header with action buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist_rtl,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ingredientes encontrados (${state.ingredients.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showDebugInfo(context, state),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Debug Info'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed:
                        () => _forceRefreshImages(
                          ref.read(simplifiedRecognitionProvider.notifier),
                          state,
                        ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Actualizar Imágenes'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = state.ingredients[index];
              return _buildIngredientCard(ingredient);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(RecognizedIngredientModel ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildIngredientImage(ingredient),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${ingredient.quantity} ${ingredient.typeUnit}'),
            Text('Almacenamiento: ${ingredient.storageType}'),
            Text('Vence: ${_formatDate(ingredient.expirationDate)}'),
            if (ingredient.allergyAlert)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red.shade800),
                    const SizedBox(width: 4),
                    Text(
                      'Alerta de alergia',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: _buildImageStatusIcon(ingredient.imageStatus),
        isThreeLine: true,
      ),
    );
  }

  /// Build ingredient image with proper error handling and local placeholder
  Widget _buildIngredientImage(RecognizedIngredientModel ingredient) {
    debugPrint('🖼️ [UI] ${ingredient.name}:');
    debugPrint('   📷 imagePath: ${ingredient.imagePath}');
    debugPrint('   📊 imageStatus: ${ingredient.imageStatus}');
    debugPrint('   🔗 isEmpty: ${ingredient.imagePath?.isEmpty ?? true}');

    final imagePath = ingredient.imagePath;
    final imageStatus = ingredient.imageStatus;

    // Show local placeholder if no image or still generating
    if (imagePath == null ||
        imagePath.isEmpty ||
        imagePath.contains('placeholder') ||
        imageStatus == 'generating') {
      return _buildLocalPlaceholder(imageStatus == 'generating');
    }

    // Show actual image directly - let the backend handle authentication
    return _buildNetworkImage(imagePath);
  }

  /// Build regular network image
  Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            debugPrint('✅ [UI] Image loaded successfully: $imageUrl');
            return child;
          }
          return _buildLocalPlaceholder(true);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ [UI] Error loading image $imageUrl: $error');
          return _buildLocalPlaceholder(false);
        },
      ),
    );
  }

  /// Build local placeholder widget
  Widget _buildLocalPlaceholder(bool isGenerating) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGenerating) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 2),
            Text(
              'Generando...',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(Icons.image_outlined, size: 20, color: Colors.grey[400]),
            const SizedBox(height: 2),
            Text(
              'Sin imagen',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageStatusIcon(String? imageStatus) {
    switch (imageStatus) {
      case 'generating':
        return Icon(Icons.hourglass_empty, color: Colors.orange.shade600);
      case 'ready':
      case 'generated':
        return Icon(Icons.check_circle, color: Colors.green.shade600);
      case 'failed':
        return Icon(Icons.error, color: Colors.red.shade600);
      default:
        return Icon(Icons.help_outline, color: Colors.grey.shade600);
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'No especificado';

    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  Future<void> _selectImagesAndRecognize(
    SimplifiedRecognitionNotifier notifier,
  ) async {
    try {
      // Select multiple images
      final List<XFile> pickedFiles = await _picker.pickMultipleMedia(
        limit: 5,
        imageQuality: 80,
      );

      if (pickedFiles.isEmpty) return;

      // Convert to File objects
      final List<File> imageFiles =
          pickedFiles.map((xFile) => File(xFile.path)).toList();

      // Start recognition
      await notifier.recognizeIngredients(imageFiles);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error seleccionando imágenes: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDebugInfo(BuildContext context, SimplifiedRecognitionState state) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🔍 Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Recognition ID: ${state.recognitionId ?? "null"}'),
                  Text('Images Status: ${state.imagesStatus ?? "null"}'),
                  Text('Ingredients Count: ${state.ingredients.length}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...state.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ${ingredient.name}'),
                          Text(
                            '  📷 Image: ${ingredient.imagePath ?? "null"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '  📊 Status: ${ingredient.imageStatus ?? "null"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '  🔗 HasImage: ${ingredient.imagePath?.isNotEmpty ?? false}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Future<void> _forceRefreshImages(
    SimplifiedRecognitionNotifier notifier,
    SimplifiedRecognitionState state,
  ) async {
    if (state.recognitionId == null) return;

    try {
      debugPrint('🔄 [UI] Force refreshing images for: ${state.recognitionId}');

      // Use the provider's force check method
      await notifier.forceCheckImages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Imágenes actualizadas')),
        );
      }
    } catch (e) {
      debugPrint('❌ [UI] Force refresh error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error actualizando: $e')));
      }
    }
  }
}
