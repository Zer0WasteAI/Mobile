// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/recognition_provider.dart';
import 'package:zer0_waste_ai/features/recognition/data/models/recognition_result_model.dart';
import 'package:zer0_waste_ai/features/recognition/utils/recognition_to_inventory_converter.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';

class CameraRecognitionPage extends ConsumerStatefulWidget {
  const CameraRecognitionPage({super.key});

  @override
  ConsumerState<CameraRecognitionPage> createState() =>
      _CameraRecognitionPageState();
}

class _CameraRecognitionPageState extends ConsumerState<CameraRecognitionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _recognitionType = 'food'; // 'food' or 'ingredient'
  bool _useCompleteAnalysis = false; // Toggle para reconocimiento completo

  @override
  Widget build(BuildContext context) {
    final recognitionState = ref.watch(recognitionProvider);
    final recognitionNotifier = ref.read(recognitionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconocimiento de Alimentos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recognition type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Reconocimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Alimentos'),
                            value: 'food',
                            groupValue: _recognitionType,
                            onChanged: (value) {
                              setState(() {
                                _recognitionType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Ingredientes'),
                            value: 'ingredient',
                            groupValue: _recognitionType,
                            onChanged: (value) {
                              setState(() {
                                _recognitionType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // 🆕 Toggle para reconocimiento completo (solo para ingredientes)
                    if (_recognitionType == 'ingredient') ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text(
                          'Mostrar Datos Ambientales',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Monitorea y muestra impacto ambiental cuando esté disponible',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _useCompleteAnalysis,
                        onChanged: (value) {
                          setState(() {
                            _useCompleteAnalysis = value;
                          });
                        },
                        activeColor: Colors.green,
                        secondary: Icon(
                          _useCompleteAnalysis ? Icons.eco : Icons.eco_outlined,
                          color:
                              _useCompleteAnalysis ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Image selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Selected image preview
            if (_selectedImage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              recognitionState.isLoading
                                  ? null
                                  : _recognizeImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child:
                              recognitionState.isLoading
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Analizando...'),
                                    ],
                                  )
                                  : Text(
                                    'Reconocer ${_recognitionType == 'food' ? 'Alimento' : 'Ingrediente'}',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Error display
            if (recognitionState.error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Error',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recognitionState.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => recognitionNotifier.clearError(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ),

            // 🆕 Status message for async image generation
            if (recognitionState.statusMessage != null)
              Card(
                color: _getStatusColor(recognitionState.imageGenerationStatus),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      _getStatusIcon(recognitionState.imageGenerationStatus),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recognitionState.statusMessage!,
                          style: TextStyle(
                            color: _getStatusTextColor(
                              recognitionState.imageGenerationStatus,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (recognitionState.imageGenerationStatus ==
                          'generating')
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Results display
            if (recognitionState.result != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Resultados del Reconocimiento',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (recognitionState.taskId != null &&
                                recognitionState.imageGenerationStatus ==
                                    'generating')
                              TextButton.icon(
                                onPressed: () {
                                  ref
                                      .read(recognitionProvider.notifier)
                                      .checkImageGenerationStatus();
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Verificar estado'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                recognitionState.result!.recognizedItems.length,
                            itemBuilder: (context, index) {
                              final item =
                                  recognitionState
                                      .result!
                                      .recognizedItems[index];

                              // 🆕 Detectar el tipo de resultado para obtener imageStatus
                              String? imageStatus;
                              if (recognitionState.result
                                  is IngredientRecognitionResultModel) {
                                final ingredients =
                                    (recognitionState.result
                                            as IngredientRecognitionResultModel)
                                        .ingredients;
                                if (index < ingredients.length) {
                                  imageStatus = ingredients[index].imageStatus;
                                }
                              } else if (recognitionState.result
                                  is FoodRecognitionResultModel) {
                                final foods =
                                    (recognitionState.result
                                            as FoodRecognitionResultModel)
                                        .foods;
                                if (index < foods.length) {
                                  imageStatus = foods[index].imageStatus;
                                }
                              }

                              return _buildRecognitionItemCard(
                                item,
                                index,
                                imageStatus,
                                recognitionState.result,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              recognitionNotifier.clearState();
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Nuevo Análisis'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// INFO: Add recognized item to inventory
  /// USAGE: Converts recognition result to inventory format and adds to backend
  Future<void> _addToInventory(RecognizedItemModel item, int index) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Agregando al inventario...'),
                ],
              ),
            ),
      );

      // Get the actual recognized item (ingredient or food)
      dynamic recognizedItem;
      final recognitionState = ref.read(recognitionProvider);

      if (recognitionState.result is IngredientRecognitionResultModel) {
        final ingredients =
            (recognitionState.result as IngredientRecognitionResultModel)
                .ingredients;
        if (index < ingredients.length) {
          recognizedItem = ingredients[index];
        }
      } else if (recognitionState.result is FoodRecognitionResultModel) {
        final foods =
            (recognitionState.result as FoodRecognitionResultModel).foods;
        if (index < foods.length) {
          recognizedItem = foods[index];
        }
      }

      if (recognizedItem == null) {
        throw Exception('No se pudo obtener el item reconocido');
      }

      // Convert to inventory format using smart converter
      final inventoryItemData =
          RecognitionToInventoryConverter.smartConvertToInventoryItem(
            recognizedItem,
          );

      // Add to inventory via backend
      final inventoryNotifier = ref.read(inventoryRealProvider.notifier);
      await inventoryNotifier.addSingleItemToInventory(inventoryItemData);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${item.name}" agregado al inventario'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al agregar "${item.name}": $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Clear previous results
        ref.read(recognitionProvider.notifier).clearState();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _recognizeImage() async {
    if (_selectedImage == null) return;

    final recognitionNotifier = ref.read(recognitionProvider.notifier);
    final itemName = 'item_${DateTime.now().millisecondsSinceEpoch}';

    if (_recognitionType == 'food') {
      await recognitionNotifier.uploadAndRecognizeFood(
        _selectedImage!,
        itemName,
      );
    } else {
      if (_useCompleteAnalysis) {
        // Usar reconocimiento completo con datos ambientales
        final imagePath = await recognitionNotifier.uploadImage(
          imageFile: _selectedImage!,
          itemName: itemName,
          imageType: 'ingredient',
        );

        if (imagePath != null) {
          await recognitionNotifier.recognizeIngredientsWithEnvironmentalImpact(
            [imagePath],
          );
          _startImageGenerationMonitoring();
        }
      } else {
        // Reconocimiento básico sin datos ambientales
        await recognitionNotifier.uploadAndRecognizeIngredient(
          _selectedImage!,
          itemName,
        );
      }
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) return Icons.check_circle;
    if (confidence >= 0.6) return Icons.warning;
    return Icons.error;
  }

  // 🆕 NUEVO: Helpers para el estado de generación asíncrona
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'generating':
        return Colors.blue.shade50;
      case 'generated':
        return Colors.green.shade50;
      case 'failed':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Icon _getStatusIcon(String? status) {
    switch (status) {
      case 'generating':
        return Icon(Icons.auto_awesome, color: Colors.blue.shade600);
      case 'generated':
        return Icon(Icons.check_circle, color: Colors.green.shade600);
      case 'failed':
        return Icon(Icons.error, color: Colors.red.shade600);
      default:
        return Icon(Icons.info, color: Colors.grey.shade600);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case 'generating':
        return Colors.blue.shade700;
      case 'generated':
        return Colors.green.shade700;
      case 'failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getImageStatusIcon(String status) {
    switch (status) {
      case 'generating':
        return Icons.hourglass_empty;
      case 'generated':
        return Icons.image;
      case 'failed':
        return Icons.broken_image;
      default:
        return Icons.help_outline;
    }
  }

  String _getImageStatusText(String status) {
    switch (status) {
      case 'generating':
        return 'Generando';
      case 'generated':
        return 'Imagen lista';
      case 'failed':
        return 'Error';
      default:
        return 'Desconocido';
    }
  }

  // 🆕 NUEVO: Builder para mostrar cada item reconocido con detalles completos
  Widget _buildRecognitionItemCard(
    RecognizedItemModel item,
    int index,
    String? imageStatus,
    dynamic recognitionResult,
  ) {
    // Obtener datos específicos del reconocimiento completo
    dynamic fullItem;
    if (recognitionResult is CompleteIngredientRecognitionResultModel) {
      final ingredients = recognitionResult.ingredients;
      if (index < ingredients.length) {
        fullItem = ingredients[index];
      }
    } else if (recognitionResult is IngredientRecognitionResultModel) {
      final ingredients = recognitionResult.ingredients;
      if (index < ingredients.length) {
        fullItem = ingredients[index];
      }
    } else if (recognitionResult is FoodRecognitionResultModel) {
      final foods = recognitionResult.foods;
      if (index < foods.length) {
        fullItem = foods[index];
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y confianza
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getConfidenceColor(item.confidence),
                  child: Text(
                    '${(item.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Categoría: ${item.category}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado de imagen
                if (imageStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(imageStatus),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusTextColor(imageStatus),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getImageStatusIcon(imageStatus),
                          size: 12,
                          color: _getStatusTextColor(imageStatus),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getImageStatusText(imageStatus),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusTextColor(imageStatus),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // 🆕 Mostrar sección ambiental si el toggle está activado
            if (_useCompleteAnalysis && _recognitionType == 'ingredient') ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Icon(Icons.eco, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Impacto Ambiental',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  if (fullItem is! CompleteRecognizedIngredientModel ||
                      fullItem.environmentalImpact == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.blue.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cargando...',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Mostrar datos si están disponibles
              if (fullItem is CompleteRecognizedIngredientModel &&
                  fullItem.environmentalImpact != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildEnvironmentalMetric(
                        'Huella de Carbono',
                        '${fullItem.environmentalImpact!.carbonFootprint.value} ${fullItem.environmentalImpact!.carbonFootprint.unit}',
                        Icons.cloud,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEnvironmentalMetric(
                        'Huella Hídrica',
                        '${fullItem.environmentalImpact!.waterFootprint.value} ${fullItem.environmentalImpact!.waterFootprint.unit}',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                if (fullItem
                    .environmentalImpact!
                    .sustainabilityMessage
                    .isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fullItem.environmentalImpact!.sustainabilityMessage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // No hay datos ambientales disponibles (reconocimiento básico)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Activa "Mostrar Datos Ambientales" para ver el impacto ecológico',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // 🆕 Mostrar ideas de utilización si el toggle está activado
            if (_useCompleteAnalysis && _recognitionType == 'ingredient') ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ideas de Utilización',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mostrar ideas de utilización reales del API
              if (fullItem is CompleteRecognizedIngredientModel &&
                  fullItem.utilizationIdeas.isNotEmpty)
                ...fullItem.utilizationIdeas
                    .take(2)
                    .map(
                      (idea) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                idea.type == 'receta'
                                    ? Icons.restaurant
                                    : Icons.lightbulb_outline,
                                color: Colors.amber.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      idea.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      idea.description,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ],

            // Botón de agregar al inventario
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getConfidenceIcon(item.confidence),
                  color: _getConfidenceColor(item.confidence),
                  size: 18,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _addToInventory(item, index),
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Agregar al Inventario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 NUEVO: Widget para mostrar métricas ambientales
  Widget _buildEnvironmentalMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🆕 NUEVO: Iniciar monitoreo automático de generación de imágenes
  void _startImageGenerationMonitoring() {
    // Verificar el estado cada 15 segundos durante los primeros 2 minutos
    Timer.periodic(const Duration(seconds: 15), (timer) {
      final recognitionState = ref.read(recognitionProvider);

      // Detener el timer si ya no hay task_id o si las imágenes ya están listas
      if (recognitionState.taskId == null ||
          recognitionState.imageGenerationStatus == 'generated' ||
          recognitionState.imageGenerationStatus == 'failed') {
        timer.cancel();
        return;
      }

      // Verificar estado de generación
      ref.read(recognitionProvider.notifier).checkImageGenerationStatus();

      // Detener después de 2 minutos (8 intentos)
      if (timer.tick >= 8) {
        timer.cancel();
      }
    });
  }
}
