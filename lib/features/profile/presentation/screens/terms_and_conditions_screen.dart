import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class TermsAndConditionsScreen extends ConsumerStatefulWidget {
  const TermsAndConditionsScreen({super.key});

  static const String routeName = 'terms_and_conditions';
  static const String routePath = '/terms-and-conditions';

  @override
  ConsumerState<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState
    extends ConsumerState<TermsAndConditionsScreen> {
  final Set<int> _expandedSections = {};

  // Lista de secciones de los términos y condiciones
  final List<TermsSection> _sections = [
    TermsSection(
      title: 'Aceptación de términos',
      content:
          'Al utilizar la aplicación Zer0 Waste AI, aceptas estos Términos y Condiciones en su totalidad. Si no estás de acuerdo con alguna parte de estos términos, no deberías utilizar nuestra aplicación.\n\nEsta aplicación está diseñada para ayudarte a reducir el desperdicio de alimentos mediante el seguimiento de inventario, reconocimiento de alimentos y recomendaciones personalizadas.',
      icon: Icons.check_circle_outline,
    ),
    TermsSection(
      title: 'Cuenta de usuario',
      content:
          'Para utilizar todas las funciones de Zer0 Waste AI, debes crear una cuenta. Al registrarte, te comprometes a proporcionar información precisa y mantenerla actualizada.\n\nEres responsable de mantener la confidencialidad de tu contraseña y de todas las actividades que ocurran bajo tu cuenta. Notifícanos inmediatamente si sospechas de cualquier uso no autorizado de tu cuenta.\n\nNos reservamos el derecho de suspender o terminar cuentas que violen estos términos o por inactividad prolongada.',
      icon: Icons.person_outline,
    ),
    TermsSection(
      title: 'Uso de la aplicación',
      content:
          'Te concedemos una licencia limitada, no exclusiva y no transferible para descargar e instalar la aplicación en tu dispositivo personal y utilizarla según estos términos.\n\nQueda prohibido:\n\n• Utilizar la aplicación para fines ilegales o no autorizados.\n\n• Subir contenido ofensivo, difamatorio o que infrinja derechos de terceros.\n\n• Intentar acceder, modificar o interferir con partes del sistema a las que no tienes autorización.\n\n• Realizar ingeniería inversa, descompilar o modificar la aplicación.\n\n• Transferir tu cuenta a otra persona sin nuestro consentimiento.',
      icon: Icons.rule_outlined,
    ),
    TermsSection(
      title: 'Contenido del usuario',
      content:
          'Al subir fotos de alimentos, recetas, comentarios u otro contenido a la aplicación, mantienes la propiedad de dicho contenido pero nos otorgas una licencia mundial, no exclusiva y libre de regalías para usar, reproducir, modificar y mostrar dicho contenido en relación con el funcionamiento de la aplicación.\n\nDeclararas que tienes el derecho de conceder esta licencia y que el contenido no infringe los derechos de terceros ni viola ninguna ley.',
      icon: Icons.upload_file_outlined,
    ),
    TermsSection(
      title: 'Propiedad intelectual',
      content:
          'Zer0 Waste AI y todo su contenido, características y funcionalidades (incluyendo pero no limitado a texto, gráficos, logos, iconos, imágenes, clips de audio, descargas digitales, compilaciones de datos y software) son propiedad de nuestra empresa o de nuestros licenciantes y están protegidos por leyes de propiedad intelectual.\n\nNo se permite el uso de ningún material de nuestra aplicación sin nuestro consentimiento previo por escrito.',
      icon: Icons.copyright_outlined,
    ),
    TermsSection(
      title: 'Disponibilidad y actualizaciones',
      content:
          'Nos esforzamos por mantener la aplicación operativa y actualizada, pero no garantizamos que la aplicación esté disponible de forma ininterrumpida o libre de errores.\n\nPodemos lanzar actualizaciones periódicamente, que pueden incluir correcciones de errores, mejoras de funciones o cambios en la interfaz de usuario. Al continuar utilizando la aplicación después de dichas actualizaciones, aceptas los cambios implementados.',
      icon: Icons.system_update_outlined,
    ),
    TermsSection(
      title: 'Limitación de responsabilidad',
      content:
          'En la medida permitida por la ley, Zer0 Waste AI y sus afiliados no serán responsables por daños indirectos, incidentales, especiales, consecuentes o punitivos, o por pérdida de beneficios o ingresos, ya sea directa o indirectamente, o por pérdida de datos, uso, fondo de comercio u otras pérdidas intangibles.\n\nLa aplicación se proporciona "tal cual" y "según disponibilidad" sin garantías de ningún tipo. No garantizamos que las funciones de reconocimiento de alimentos o fechas de caducidad sean siempre precisas.',
      icon: Icons.gavel_outlined,
    ),
    TermsSection(
      title: 'Indemnización',
      content:
          'Aceptas indemnizar y mantener indemne a Zer0 Waste AI y sus afiliados, directores, empleados y agentes de y contra cualquier reclamo, responsabilidad, daño, pérdida y gasto (incluyendo costos legales razonables) que surjan de o estén relacionados con tu uso de la aplicación o cualquier violación de estos Términos.',
      icon: Icons.shield_outlined,
    ),
    TermsSection(
      title: 'Modificaciones de los términos',
      content:
          'Podemos modificar estos Términos en cualquier momento publicando los términos revisados en la aplicación. Los cambios importantes serán notificados a través de la aplicación o por correo electrónico. Tu uso continuado de la aplicación después de dichos cambios constituye tu aceptación de los nuevos términos.\n\nTe recomendamos revisar periódicamente estos Términos para estar al tanto de cualquier cambio.',
      icon: Icons.update_outlined,
    ),
    TermsSection(
      title: 'Ley aplicable',
      content:
          'Estos Términos se regirán e interpretarán de acuerdo con las leyes de España, sin tener en cuenta sus normas de conflicto de leyes.\n\nCualquier disputa que surja en relación con estos Términos estará sujeta a la jurisdicción exclusiva de los tribunales de Madrid, España.',
      icon: Icons.balance_outlined,
    ),
    TermsSection(
      title: 'Contacto',
      content:
          'Si tienes preguntas sobre estos Términos y Condiciones, puedes contactarnos:\n\nCorreo electrónico: terms@zerowaste.ai\nDirección: Avenida Virtual 123, 28100 Madrid, España',
      icon: Icons.contact_support_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Text(
          'Términos y Condiciones',
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
      body: Column(
        children: [
          // Nota informativa superior
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE0F2F1),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF00BFA5),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Última actualización: 1 de junio de 2024',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de secciones expandibles
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              itemCount: _sections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isExpanded = _expandedSections.contains(index);

                return _buildTermsSection(
                  context,
                  section: section,
                  isExpanded: isExpanded,
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedSections.remove(index);
                      } else {
                        _expandedSections.add(index);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Botón de aceptar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Guardar aceptación y volver
                context.pop();
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
                'Aceptar',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(
    BuildContext context, {
    required TermsSection section,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow:
            isExpanded
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      section.icon,
                      color: const Color(0xFF00BFA5),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ],
              ),
            ),

            // Contenido de la sección (solo visible si está expandida)
            if (isExpanded) ...[
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  section.content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Clase para las secciones de términos
class TermsSection {
  final String title;
  final String content;
  final IconData icon;

  TermsSection({
    required this.title,
    required this.content,
    required this.icon,
  });
}
