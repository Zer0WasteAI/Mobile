import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends ConsumerWidget {
  const AboutAppScreen({super.key});

  static const String routeName = 'about_app';
  static const String routePath = '/about-app';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Text(
          'Acerca de la app',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo y versión
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: const Color(0xFFE0F2F1),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 60,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Zer0 Waste AI',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versión 1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Descripción
            _buildInfoSection(
              context: context,
              title: 'Nuestra misión',
              content:
                  'Zer0 Waste AI es una aplicación diseñada para ayudarte a reducir el desperdicio de alimentos en tu hogar. Utilizamos inteligencia artificial para reconocer alimentos, hacer seguimiento de fechas de caducidad y sugerir recetas personalizadas para aprovechar los ingredientes que tienes.',
              icon: Icons.remove_red_eye_outlined,
            ),

            // Funcionalidades
            _buildInfoSection(
              context: context,
              title: 'Funcionalidades principales',
              content:
                  '• Reconocimiento de alimentos mediante IA\n• Seguimiento de inventario de tu nevera\n• Alertas de caducidad\n• Recetas personalizadas según tus preferencias\n• Calculadora de impacto ambiental\n• Planificador semanal de comidas',
              icon: Icons.star_outline_rounded,
            ),

            // Equipo
            _buildInfoSection(
              context: context,
              title: 'Equipo',
              content:
                  'Desarrollado por un equipo comprometido con la sostenibilidad y la reducción del desperdicio alimentario. Combinamos experiencia en desarrollo de aplicaciones, inteligencia artificial y nutrición para ofrecerte la mejor herramienta posible.',
              icon: Icons.people_outline_rounded,
            ),

            // Agradecimientos
            _buildInfoSection(
              context: context,
              title: 'Agradecimientos',
              content:
                  'Agradecemos a todos los beta testers y colaboradores que han hecho posible esta aplicación. Gracias también a las comunidades de código abierto cuyos recursos hemos utilizado.',
              icon: Icons.favorite_border_rounded,
            ),

            // Redes sociales
            /*Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.public_rounded,
                          color: Color(0xFF00BFA5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Síguenos',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildSocialButton(
                        context: context,
                        icon: FontAwesomeIcons.twitter,
                        label: 'Twitter',
                        color: const Color(0xFF1DA1F2),
                        onTap:
                            () =>
                                _launchURL('https://twitter.com/zerowaste_ai'),
                      ),
                      _buildSocialButton(
                        context: context,
                        icon: FontAwesomeIcons.instagram,
                        label: 'Instagram',
                        color: const Color(0xFFE1306C),
                        onTap:
                            () => _launchURL(
                              'https://instagram.com/zerowaste_ai',
                            ),
                      ),
                      _buildSocialButton(
                        context: context,
                        icon: FontAwesomeIcons.globe,
                        label: 'Web',
                        color: const Color(0xFF00BFA5),
                        onTap: () => _launchURL('https://zerowaste.ai'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
*/
            // Información legal
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.push('/privacy-policy'),
                    child: Text(
                      'Política de Privacidad',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF00BFA5),
                      ),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  TextButton(
                    onPressed: () => context.push('/terms-and-conditions'),
                    child: Text(
                      'Términos y Condiciones',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF00BFA5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Copyright
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              child: Text(
                '© 2025 Zer0 Waste AI. Todos los derechos reservados.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF00BFA5), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }
}
