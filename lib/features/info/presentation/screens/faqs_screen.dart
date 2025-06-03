import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  static const String routeName = 'faqs';
  static const String routePath = '/faqs';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Preguntas Frecuentes',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Preguntas comunes sobre Zer0 Waste AI',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            _buildFaqItem(
              context,
              question: '¿Qué es Zer0 Waste AI?',
              answer:
                  'Zer0 Waste AI es una aplicación que te ayuda a reducir el desperdicio de alimentos mediante la gestión inteligente de tu inventario, sugerencias de recetas personalizadas y planificación de comidas.',
            ),

            _buildFaqItem(
              context,
              question: '¿Cómo escaneo los productos?',
              answer:
                  'Puedes escanear productos de dos formas: usando la cámara para reconocer el producto o escaneando el código de barras. La aplicación reconocerá automáticamente el producto y lo agregará a tu inventario.',
            ),

            _buildFaqItem(
              context,
              question: '¿Cómo se generan las recetas personalizadas?',
              answer:
                  'Las recetas se generan utilizando inteligencia artificial que considera tu inventario actual, preferencias alimentarias, alergias, nivel de cocina y tipo de dieta para sugerir las mejores opciones que minimicen el desperdicio.',
            ),

            _buildFaqItem(
              context,
              question: '¿Cómo se calcula mi impacto ambiental?',
              answer:
                  'Tu impacto ambiental se calcula mediante algoritmos que estiman la huella de carbono, agua y otros recursos salvados al evitar el desperdicio de alimentos específicos. Cada vez que consumes un producto antes de que se eche a perder, contribuyes positivamente.',
            ),

            _buildFaqItem(
              context,
              question: '¿Mis datos están seguros?',
              answer:
                  'Sí, tus datos están seguros. Utilizamos cifrado de extremo a extremo y nunca compartimos tu información personal con terceros sin tu consentimiento explícito. Puedes revisar nuestra política de privacidad para más detalles.',
            ),

            _buildFaqItem(
              context,
              question: '¿Cómo puedo contribuir al proyecto?',
              answer:
                  'Puedes contribuir usando la aplicación regularmente, proporcionando retroalimentación, reportando errores y compartiendo la aplicación con amigos y familiares. Tu experiencia nos ayuda a mejorar continuamente.',
            ),

            const SizedBox(height: 32),

            Text(
              '¿No encuentras la respuesta que buscas?',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: () {
                // Navegar a pantalla de contacto
              },
              icon: const Icon(Icons.email_outlined),
              label: const Text('Contáctanos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(
        question,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      collapsedIconColor: colorScheme.primary,
      iconColor: colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surface,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: GoogleFonts.inter(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
