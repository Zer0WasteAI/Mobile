import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const String routeName = 'terms_conditions';
  static const String routePath = '/terms-conditions';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Términos y Condiciones',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Última actualización: 1 de Julio, 2023',
              style: GoogleFonts.inter(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              title: '1. ACEPTACIÓN DE LOS TÉRMINOS',
              content:
                  'Al descargar, acceder o utilizar la aplicación Zer0 Waste AI, aceptas estar legalmente vinculado por estos Términos y Condiciones. Si no estás de acuerdo con estos términos, no debes acceder o utilizar nuestra aplicación.',
            ),

            _buildSection(
              context,
              title: '2. DESCRIPCIÓN DEL SERVICIO',
              content:
                  'Zer0 Waste AI es una aplicación móvil diseñada para ayudar a los usuarios a reducir el desperdicio de alimentos mediante herramientas de gestión de inventario, reconocimiento de alimentos, sugerencias de recetas y planificación de comidas.',
            ),

            _buildSection(
              context,
              title: '3. REGISTRO DE CUENTA',
              content:
                  'Para acceder a ciertas funciones de nuestra aplicación, puedes necesitar crear una cuenta. Eres responsable de mantener la confidencialidad de tu información de cuenta y contraseña, y aceptas la responsabilidad de todas las actividades que ocurran bajo tu cuenta.',
            ),

            _buildSection(
              context,
              title: '4. LICENCIA DE USO',
              content:
                  'Sujeto a estos Términos, te otorgamos una licencia limitada, no exclusiva, no transferible y revocable para descargar e instalar una copia de la aplicación en un dispositivo móvil que poseas o controles, y para ejecutar dicha copia de la aplicación únicamente para tu uso personal.',
            ),

            _buildSection(
              context,
              title: '5. RESTRICCIONES DE USO',
              content:
                  'No puedes:\n\n'
                  '• Licenciar, vender, alquilar, arrendar, transferir, ceder, distribuir, alojar o explotar comercialmente la aplicación\n'
                  '• Modificar, realizar obras derivadas, desensamblar, descifrar, compilar o descompilar inversamente la aplicación\n'
                  '• Eliminar, alterar u ocultar cualquier aviso de propiedad en la aplicación\n'
                  '• Utilizar la aplicación para cualquier propósito ilegal o no autorizado',
            ),

            _buildSection(
              context,
              title: '6. PROPIEDAD INTELECTUAL',
              content:
                  'La aplicación y su contenido original, características y funcionalidad son y seguirán siendo propiedad exclusiva de Zer0 Waste AI y sus licenciantes. La aplicación está protegida por derechos de autor, marcas registradas y otras leyes.',
            ),

            _buildSection(
              context,
              title: '7. CONTENIDO GENERADO POR EL USUARIO',
              content:
                  'Al enviar, publicar o mostrar contenido en o a través de nuestra aplicación, nos otorgas una licencia mundial, no exclusiva, libre de regalías para usar, reproducir, modificar, adaptar, publicar, traducir, crear obras derivadas, distribuir y mostrar dicho contenido en cualquier medio.',
            ),

            _buildSection(
              context,
              title: '8. LIMITACIÓN DE RESPONSABILIDAD',
              content:
                  'En ningún caso Zer0 Waste AI, sus directores, empleados, socios, agentes, proveedores o afiliados serán responsables por cualquier daño indirecto, incidental, especial, consecuente o punitivo, incluyendo sin limitación, pérdida de beneficios, datos, uso, buena voluntad, u otras pérdidas intangibles.',
            ),

            _buildSection(
              context,
              title: '9. INDEMNIZACIÓN',
              content:
                  'Aceptas defender, indemnizar y mantener indemne a Zer0 Waste AI de y contra cualquier reclamación, responsabilidad, daño, pérdida y gasto, incluidos honorarios legales y contables razonables, que surjan de o estén relacionados de alguna manera con tu acceso o uso de la aplicación.',
            ),

            _buildSection(
              context,
              title: '10. CAMBIOS EN LOS TÉRMINOS',
              content:
                  'Nos reservamos el derecho, a nuestra sola discreción, de modificar o reemplazar estos términos en cualquier momento. Si una revisión es material, proporcionaremos al menos 30 días de aviso antes de que los nuevos términos entren en vigor.',
            ),

            _buildSection(
              context,
              title: '11. LEY APLICABLE',
              content:
                  'Estos términos se regirán e interpretarán de acuerdo con las leyes españolas, sin tener en cuenta sus disposiciones sobre conflictos de leyes.',
            ),

            _buildSection(
              context,
              title: '12. CONTACTO',
              content:
                  'Si tienes alguna pregunta sobre estos Términos, contáctanos en: legal@zerowaste-ai.com',
            ),

            const SizedBox(height: 32),

            // Botón para aceptar los términos
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Entendido',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
