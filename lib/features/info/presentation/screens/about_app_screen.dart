import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String routeName = 'about_app';
  static const String routePath = '/about-app';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Acerca de la App',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Logo y nombre de la app
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.eco,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Zer0 Waste AI',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Versión 1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Descripción de la app
            _buildSection(
              context,
              title: 'Nuestra Misión',
              content:
                  'Zer0 Waste AI tiene como misión reducir el desperdicio de alimentos ayudando a las personas a gestionar mejor su inventario de alimentos y utilizarlos de manera eficiente, contribuyendo así a un planeta más sostenible.',
            ),

            _buildSection(
              context,
              title: 'Características Principales',
              content:
                  '• Escaneo y reconocimiento de alimentos con IA\n'
                  '• Gestión inteligente de inventario\n'
                  '• Recetas personalizadas basadas en tus preferencias\n'
                  '• Planificador de comidas semanal\n'
                  '• Seguimiento de impacto ambiental\n'
                  '• Recordatorios de caducidad\n'
                  '• Consejos para reducir el desperdicio',
            ),

            _buildSection(
              context,
              title: 'Desarrollado por',
              content:
                  'Zer0 Waste AI es una aplicación desarrollada por un equipo comprometido con la sostenibilidad y la tecnología innovadora.',
            ),

            const SizedBox(height: 24),

            // Redes sociales y contacto
            Text(
              'Síguenos',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  context,
                  icon: FontAwesomeIcons.instagram,
                  onTap: () {
                    // Abrir Instagram
                  },
                ),
                const SizedBox(width: 24),
                _buildSocialButton(
                  context,
                  icon: FontAwesomeIcons.twitter,
                  onTap: () {
                    // Abrir Twitter
                  },
                ),
                const SizedBox(width: 24),
                _buildSocialButton(
                  context,
                  icon: FontAwesomeIcons.facebookF,
                  onTap: () {
                    // Abrir Facebook
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Agradecimientos y créditos
            Text(
              'Agradecimientos especiales a todos nuestros usuarios que hacen posible reducir el desperdicio de alimentos día a día.',
              style: GoogleFonts.inter(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Copyright
            Text(
              '© 2023 Zer0 Waste AI. Todos los derechos reservados.',
              style: GoogleFonts.inter(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(icon, color: colorScheme.primary, size: 22),
        ),
      ),
    );
  }
}
