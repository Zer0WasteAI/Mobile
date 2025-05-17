import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String routeName = 'privacy_policy';
  static const String routePath = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Política de Privacidad',
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
              title: '1. INTRODUCCIÓN',
              content:
                  'En Zer0 Waste AI, respetamos tu privacidad y nos comprometemos a proteger tus datos personales. Esta política de privacidad te informará sobre cómo cuidamos tus datos personales cuando utilizas nuestra aplicación y te informará sobre tus derechos de privacidad y cómo la ley te protege.',
            ),

            _buildSection(
              context,
              title: '2. DATOS QUE RECOPILAMOS',
              content:
                  'Podemos recopilar, usar, almacenar y transferir diferentes tipos de datos personales sobre ti que hemos agrupado de la siguiente manera:\n\n'
                  '• Datos de identidad: incluye nombre, apellido, nombre de usuario o identificador similar.\n'
                  '• Datos de contacto: incluye dirección de correo electrónico y número de teléfono.\n'
                  '• Datos técnicos: incluye dirección IP, datos de inicio de sesión, tipo y versión del navegador, zona horaria y ubicación, tipos y versiones de complementos del navegador, sistema operativo y plataforma.\n'
                  '• Datos de perfil: incluye tu nombre de usuario y contraseña, tus preferencias alimentarias, alergias y nivel de cocina.\n'
                  '• Datos de uso: incluye información sobre cómo utilizas nuestra aplicación y servicios.',
            ),

            _buildSection(
              context,
              title: '3. CÓMO UTILIZAMOS TUS DATOS',
              content:
                  'Utilizamos tus datos personales para los siguientes propósitos:\n\n'
                  '• Proporcionar y mejorar nuestros servicios\n'
                  '• Personalizar tu experiencia\n'
                  '• Procesar tus solicitudes y transacciones\n'
                  '• Comunicarnos contigo\n'
                  '• Mantener la seguridad de nuestra aplicación\n'
                  '• Cumplir con obligaciones legales',
            ),

            _buildSection(
              context,
              title: '4. COMPARTIR TUS DATOS',
              content:
                  'No vendemos tus datos personales a terceros. Podemos compartir tus datos personales con las siguientes categorías de destinatarios:\n\n'
                  '• Proveedores de servicios que actúan como procesadores de datos\n'
                  '• Autoridades reguladoras y otros organismos cuando sea necesario para cumplir con requisitos legales o regulatorios',
            ),

            _buildSection(
              context,
              title: '5. SEGURIDAD DE DATOS',
              content:
                  'Hemos implementado medidas de seguridad apropiadas para evitar que tus datos personales se pierdan, usen o accedan accidentalmente de manera no autorizada, se modifiquen o divulguen.',
            ),

            _buildSection(
              context,
              title: '6. TUS DERECHOS',
              content:
                  'Bajo ciertas circunstancias, tienes derechos bajo las leyes de protección de datos en relación con tus datos personales, incluyendo el derecho a:\n\n'
                  '• Solicitar acceso a tus datos personales\n'
                  '• Solicitar la corrección de tus datos personales\n'
                  '• Solicitar la eliminación de tus datos personales\n'
                  '• Oponerte al procesamiento de tus datos personales\n'
                  '• Solicitar la restricción del procesamiento de tus datos personales\n'
                  '• Solicitar la transferencia de tus datos personales\n'
                  '• Retirar el consentimiento',
            ),

            _buildSection(
              context,
              title: '7. CAMBIOS A ESTA POLÍTICA',
              content:
                  'Podemos actualizar nuestra política de privacidad de vez en cuando. Te notificaremos cualquier cambio publicando la nueva política de privacidad en esta página y, si los cambios son significativos, te enviaremos un aviso.',
            ),

            _buildSection(
              context,
              title: '8. CONTACTO',
              content:
                  'Si tienes alguna pregunta sobre esta política de privacidad o nuestras prácticas de privacidad, contáctanos en: privacy@zerowaste-ai.com',
            ),

            const SizedBox(height: 32),
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
