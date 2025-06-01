import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

// Enum para los tipos de unidades
enum MeasurementUnit { metric, imperial }

// Provider para las unidades seleccionadas
final selectedUnitProvider = StateProvider<MeasurementUnit>((ref) {
  // Inicializar con el valor del usuario actual si existe
  final user = ref.watch(authControllerProvider).value;
  final measurementUnit = user?.prefs.measurementUnit ?? 'metric';

  print('Loading measurement unit from user data: $measurementUnit');

  if (measurementUnit == 'imperial') {
    return MeasurementUnit.imperial;
  }
  return MeasurementUnit.metric;
});

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  static const String routeName = 'units';
  static const String routePath = '/units';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUnit = ref.watch(selectedUnitProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    final user = ref.watch(authControllerProvider).value;

    // Log the current user's measurement unit setting
    print(
      'Current user measurement unit in Firestore: ${user?.prefs.measurementUnit}',
    );
    print('Current selected unit in UI: $selectedUnit');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Text(
          'Unidades de medida',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar unidades',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige las unidades de medida que prefieres usar',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Unidad métrica
            _buildUnitOption(
              context,
              title: 'Métricas',
              subtitle: 'Gramos, mililitros, kilogramos, litros',
              icon: Icons.straighten_rounded,
              isSelected: selectedUnit == MeasurementUnit.metric,
              onTap: () {
                ref.read(selectedUnitProvider.notifier).state =
                    MeasurementUnit.metric;
              },
            ),

            const SizedBox(height: 16),

            // Unidad imperial
            _buildUnitOption(
              context,
              title: 'Imperiales',
              subtitle: 'Onzas, libras, tazas, cucharadas',
              icon: Icons.scale_rounded,
              isSelected: selectedUnit == MeasurementUnit.imperial,
              onTap: () {
                ref.read(selectedUnitProvider.notifier).state =
                    MeasurementUnit.imperial;
              },
            ),

            const SizedBox(height: 32),

            // Ejemplo de conversión
            _buildConversionExample(context, selectedUnit),

            const SizedBox(height: 32),

            // Botón aplicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Convertir enum a string para guardar en Firestore
                  final String unitValue =
                      selectedUnit == MeasurementUnit.metric
                          ? 'metric'
                          : 'imperial';

                  print('Saving measurement unit: $unitValue');

                  // Guardar la selección en Firestore
                  try {
                    await authRepository.saveUserMeasurementUnit(unitValue);
                    print('Successfully saved measurement unit to Firestore');

                    // Actualizar el controlador de autenticación para reflejar los cambios
                    await ref
                        .read(authControllerProvider.notifier)
                        .refreshUserFromFirestore();

                    // Verify the user was updated
                    final updatedUser = ref.read(authControllerProvider).value;
                    print(
                      'Updated user measurement unit: ${updatedUser?.prefs.measurementUnit}',
                    );

                    // Mostrar mensaje de éxito y volver
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unidades guardadas correctamente'),
                          backgroundColor: Color(0xFF00BFA5),
                        ),
                      );
                      context.pop();
                    }
                  } catch (e) {
                    print('Error saving measurement unit: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aplicar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BFA5) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF00BFA5)
                        : const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF00BFA5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Indicador de selección
            if (isSelected)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00BFA5),
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionExample(BuildContext context, MeasurementUnit unit) {
    final String example;
    final Color bgColor = const Color(0xFFF5F5F5);

    if (unit == MeasurementUnit.metric) {
      example = '200g de harina\n500ml de agua\n1kg de patatas';
    } else {
      example = '7oz de harina\n2 tazas de agua\n2.2lb de patatas';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejemplo en la app:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            example,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
