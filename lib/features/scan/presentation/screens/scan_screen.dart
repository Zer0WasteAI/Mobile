import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recognition/presentation/providers/recognition_provider.dart';
import 'package:go_router/go_router.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _recognitionType = 'ingredient'; // 'food' or 'ingredient'
  bool _showInstructions = true;

  @override
  Widget build(BuildContext context) {
    final recognitionState = ref.watch(recognitionProvider);
    final recognitionNotifier = ref.read(recognitionProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Escanear Alimento',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedImage != null || recognitionState.result != null)
            IconButton(
              onPressed: _resetScan,
              icon: const Icon(Icons.refresh),
              tooltip: 'Nuevo escaneo',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            if (_showInstructions && _selectedImage == null)
              _buildInstructionsCard(
                surfaceColor,
                textColor,
                secondaryTextColor,
              ),

            const SizedBox(height: 16),

            // Recognition type selector
            _buildRecognitionTypeSelector(
              surfaceColor,
              textColor,
              primaryColor,
            ),

            const SizedBox(height: 16),

            // Camera buttons
            if (_selectedImage == null)
              _buildCameraButtons()
            else
              _buildImagePreviewCard(surfaceColor, textColor, recognitionState),

            const SizedBox(height: 16),

            // Error display
            if (recognitionState.error != null)
              _buildErrorCard(recognitionState.error!, recognitionNotifier),

            // Results display
            if (recognitionState.result != null)
              _buildResultsCard(recognitionState, surfaceColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Card(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Consejos para mejores resultados',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showInstructions = false),
                  icon: const Icon(Icons.close, size: 20),
                  color: secondaryTextColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('📸', 'Toma la foto con buena iluminación'),
            _buildInstructionItem('🎯', 'Centra el alimento en la imagen'),
            _buildInstructionItem('🔍', 'Asegúrate de que se vea claramente'),
            _buildInstructionItem(
              '🍎',
              'Selecciona el tipo correcto (ingrediente/comida)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildRecognitionTypeSelector(
    Color surfaceColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Card(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Qué quieres escanear?',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    'ingredient',
                    'Ingredientes',
                    '🥕 Frutas, verduras, etc.',
                    FontAwesomeIcons.carrot,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    'food',
                    'Comida Preparada',
                    '🍝 Platos, recetas, etc.',
                    FontAwesomeIcons.utensils,
                    primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color primaryColor,
  ) {
    final isSelected = _recognitionType == value;
    return GestureDetector(
      onTap: () => setState(() => _recognitionType = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryColor : Colors.grey.shade700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButtons() {
    return Column(
      children: [
        // Camera button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt, size: 24),
            label: Text(
              'Tomar Foto',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Gallery button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library, size: 24),
            label: Text(
              'Elegir de Galería',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewCard(
    Color surfaceColor,
    Color textColor,
    RecognitionState recognitionState,
  ) {
    return Card(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: recognitionState.isLoading ? null : _recognizeImage,
                icon:
                    recognitionState.isLoading
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
                        : const Icon(Icons.auto_awesome),
                label: Text(
                  recognitionState.isLoading
                      ? 'Analizando con IA...'
                      : 'Analizar con IA',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, RecognitionNotifier notifier) {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Error en el reconocimiento',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(error, style: GoogleFonts.inter(color: Colors.red.shade600)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => notifier.clearError(),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(
    RecognitionState recognitionState,
    Color surfaceColor,
    Color textColor,
  ) {
    return Card(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultados del Análisis',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recognitionState.result!.recognizedItems.length,
              itemBuilder: (context, index) {
                final item = recognitionState.result!.recognizedItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
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
                    title: Text(
                      item.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Categoría: ${item.category}',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    trailing: Icon(
                      _getConfidenceIcon(item.confidence),
                      color: _getConfidenceColor(item.confidence),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetScan,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nuevo Análisis'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _addToInventory(
                          recognitionState.result!.recognizedItems,
                        ),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
        ref.read(recognitionProvider.notifier).clearState();
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar imagen: $e', isError: true);
    }
  }

  Future<void> _recognizeImage() async {
    if (_selectedImage == null) return;

    final recognitionNotifier = ref.read(recognitionProvider.notifier);
    final itemName = 'scan_${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (_recognitionType == 'food') {
        await recognitionNotifier.uploadAndRecognizeFood(
          _selectedImage!,
          itemName,
        );
      } else {
        await recognitionNotifier.uploadAndRecognizeIngredient(
          _selectedImage!,
          itemName,
        );
      }
    } catch (e) {
      _showSnackBar('Error en el análisis: $e', isError: true);
    }
  }

  void _resetScan() {
    setState(() {
      _selectedImage = null;
    });
    ref.read(recognitionProvider.notifier).clearState();
  }

  void _addToInventory(List items) {
    // Navigate to inventory add screen with recognized items
    // ✅ RESOLVED: Navigation to inventory with pre-filled data implemented

    // Convert recognized items to the format expected by AddInventoryItemScreen
    final List<Map<String, dynamic>> prefilledItems =
        items.map((item) {
          return {
            'name': item.name ?? 'Producto escaneado',
            'category': item.category ?? 'food',
            'confidence': item.confidence ?? 0.0,
          };
        }).toList();

    // Navigate to add inventory screen with pre-filled data
    context.pushNamed('addInventoryItem', extra: prefilledItems);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
}
