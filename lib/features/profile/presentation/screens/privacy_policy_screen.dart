import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  static const String routeName = 'privacy_policy';
  static const String routePath = '/privacy-policy';

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
  final Set<int> _expandedSections = {};

  // Lista de secciones de la política de privacidad
  final List<PolicySection> _sections = [
    PolicySection(
      title: 'Introducción',
      content:
          'Esta Política de Privacidad describe cómo Zer0 Waste AI recopila, utiliza y comparte la información personal que obtenemos cuando utilizas nuestra aplicación móvil.\n\nNos comprometemos a proteger tu privacidad y a manejar tus datos personales con transparencia y de acuerdo con las leyes de protección de datos aplicables. Por favor, lee esta política detenidamente para entender nuestras prácticas respecto a tu información personal.',
      icon: Icons.info_outline,
    ),
    PolicySection(
      title: 'Información que recopilamos',
      content:
          'Recopilamos los siguientes tipos de información:\n\n• Información de registro: cuando creas una cuenta, podemos recopilar tu nombre, dirección de correo electrónico y contraseña.\n\n• Datos del inventario de alimentos: información sobre los alimentos que registras, fechas de caducidad y cantidades.\n\n• Preferencias culinarias: tus preferencias alimentarias, alergias y nivel de cocina.\n\n• Fotos de alimentos: las imágenes que tomas para identificar alimentos mediante nuestra tecnología de IA.\n\n• Datos de uso: cómo interactúas con la aplicación, funciones que utilizas y tiempo de uso.\n\n• Información del dispositivo: modelo, sistema operativo y configuración regional.',
      icon: Icons.data_usage,
    ),
    PolicySection(
      title: 'Cómo utilizamos tu información',
      content:
          'Utilizamos la información recopilada para:\n\n• Proporcionar las funcionalidades principales de la aplicación, como gestión de inventario de alimentos, detección de alimentos y recomendaciones de recetas.\n\n• Personalizar tu experiencia según tus preferencias culinarias y comportamiento de uso.\n\n• Mejorar la precisión de nuestros algoritmos de reconocimiento de alimentos y caducidad.\n\n• Calcular tu impacto ambiental basado en tus hábitos de consumo.\n\n• Enviar notificaciones sobre alimentos próximos a caducar y sugerencias de recetas.\n\n• Mejorar y optimizar nuestra aplicación mediante análisis de uso.',
      icon: Icons.analytics_outlined,
    ),
    PolicySection(
      title: 'Compartición de información',
      content:
          'No vendemos ni alquilamos tu información personal a terceros con fines de marketing. Podemos compartir tu información en las siguientes circunstancias:\n\n• Con proveedores de servicios que nos ayudan a operar la aplicación (como servicios de nube, análisis o procesamiento de pagos).\n\n• Si decides compartir recetas o consejos con otros usuarios a través de la plataforma.\n\n• En forma anónima y agregada para análisis estadísticos o investigaciones sobre reducción de desperdicio alimentario.\n\n• Si estamos obligados por ley o proceso legal, o para proteger nuestros derechos o propiedad.',
      icon: Icons.share_outlined,
    ),
    PolicySection(
      title: 'Conservación de datos',
      content:
          'Conservamos tu información personal mientras mantengas una cuenta activa con nosotros o según sea necesario para proporcionarte nuestros servicios. Si solicitas la eliminación de tu cuenta, eliminaremos o anonimizaremos tu información personal, excepto cuando sea necesario conservarla por razones legales o de interés legítimo.\n\nTus datos de inventario de alimentos se mantienen disponibles mientras uses la aplicación y pueden ser eliminados en cualquier momento por ti.',
      icon: Icons.av_timer_outlined,
    ),
    PolicySection(
      title: 'Seguridad de los datos',
      content:
          'Implementamos medidas de seguridad técnicas, administrativas y físicas diseñadas para proteger tu información personal contra acceso, pérdida, alteración o destrucción no autorizados. Estas medidas incluyen encriptación de datos, acceso restringido a empleados y proveedores de servicios, y auditorías regulares de seguridad.\n\nAunque nos esforzamos por proteger tu información, ningún método de transmisión por Internet o almacenamiento electrónico es 100% seguro. Por lo tanto, no podemos garantizar su seguridad absoluta.',
      icon: Icons.security,
    ),
    PolicySection(
      title: 'Tus derechos',
      content:
          'Dependiendo de tu ubicación, puedes tener los siguientes derechos respecto a tu información personal:\n\n• Acceder a la información personal que tenemos sobre ti.\n\n• Rectificar información inexacta o incompleta.\n\n• Eliminar tu información personal bajo ciertas circunstancias.\n\n• Restringir u oponerte al procesamiento de tu información.\n\n• Solicitar la portabilidad de tus datos a otro servicio.\n\n• Retirar tu consentimiento en cualquier momento.\n\nPara ejercer estos derechos, contacta con nosotros a través de la sección de "Contacto y soporte" en la aplicación.',
      icon: Icons.gavel_outlined,
    ),
    PolicySection(
      title: 'Cambios en esta política',
      content:
          'Podemos modificar esta Política de Privacidad de vez en cuando para reflejar cambios en nuestras prácticas o por otros motivos operativos, legales o regulatorios. Te notificaremos cualquier cambio material mediante un aviso en la aplicación o por correo electrónico antes de que el cambio entre en vigor.\n\nTe recomendamos revisar periódicamente esta política para estar informado sobre cómo protegemos tu información.',
      icon: Icons.update,
    ),
    PolicySection(
      title: 'Contacto',
      content:
          'Si tienes preguntas, comentarios o inquietudes sobre esta Política de Privacidad o nuestras prácticas de protección de datos, no dudes en contactarnos:\n\nCorreo electrónico: privacy@zerowaste.ai\nDirección: Avenida Virtual 123, 28100 Madrid, España\n\nResponderemos a tu consulta lo antes posible, generalmente dentro de los 30 días siguientes a su recepción.',
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
          'Política de Privacidad',
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
                  Icons.privacy_tip_outlined,
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

                return _buildPolicySection(
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                'Entendido',
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

  Widget _buildPolicySection(
    BuildContext context, {
    required PolicySection section,
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
                    color: Colors.black.withValues(alpha: 0.05),
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

// Clase para las secciones de la política
class PolicySection {
  final String title;
  final String content;
  final IconData icon;

  PolicySection({
    required this.title,
    required this.content,
    required this.icon,
  });
}
