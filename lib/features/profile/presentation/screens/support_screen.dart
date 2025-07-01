import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  static const String routeName = 'support';
  static const String routePath = '/support';

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedIssueType = 'Problema técnico';

  final List<String> _issueTypes = [
    'Problema técnico',
    'Pregunta sobre la app',
    'Sugerencia de mejora',
    'Reporte de error',
    'Otro',
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Simulación de envío
      setState(() {
        _isSending = true;
      });

      // ✅ UPDATED: Immediate response without artificial delay
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF00BFA5),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Mensaje enviado!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu mensaje ha sido enviado correctamente. Te responderemos a la brevedad posible.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Aceptar',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    setState(() {
      _selectedIssueType = _issueTypes[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Text(
          'Contacto y Soporte',
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
            // Banner de soporte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              color: const Color(0xFFE0F2F1),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 40,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿Cómo podemos ayudarte?',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estamos aquí para resolver tus dudas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Opciones de contacto rápido
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'Contacto directo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactOption(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          subtitle: 'zerowasteai4@gmail.com',
                          color: const Color(0xFF2196F3),
                          onTap: () {
                            _launchURL('mailto:zerowasteai4@gmail.com');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactOption(
                          icon: Icons.phone_outlined,
                          title: 'Teléfono',
                          subtitle: '+51 994934431',
                          color: const Color(0xFFFF9800),
                          onTap: () {
                            _launchURL('tel:+51994934431');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildContactOption(
                          icon: FontAwesomeIcons.whatsapp,
                          title: 'WhatsApp',
                          subtitle: 'Mensajería directa',
                          color: const Color(0xFF25D366),
                          onTap: () {
                            _launchURL(
                              'https://wa.me/51994934431?text=Hola,+necesito+ayuda+con+la+app+Zer0+Waste+AI',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Consultas frecuentes
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          Icons.help_outline,
                          color: Color(0xFF00BFA5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Consultas frecuentes',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuickHelpItem(
                    title: 'Ver preguntas frecuentes',
                    icon: Icons.question_answer_outlined,
                    onTap: () => context.push('/faqs'),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickHelpItem(
                    title: 'Problemas con el reconocimiento de alimentos',
                    icon: Icons.image_search_outlined,
                    onTap: () {
                      // Navegar a sección específica de FAQs o mostrar info
                      context.push('/faqs');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickHelpItem(
                    title: 'Ver tutoriales de la app',
                    icon: Icons.video_library_outlined,
                    onTap: () {
                      _launchURL('https://zerowaste.ai/tutorials');
                    },
                  ),
                ],
              ),
            ),

            // Formulario de contacto
            Container(
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
                          Icons.mail_outline,
                          color: Color(0xFF00BFA5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Envíanos un mensaje',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre
                        _buildFormField(
                          controller: _nameController,
                          label: 'Nombre',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildFormField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu email';
                            }
                            // Validación básica de formato de email
                            final bool emailValid = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value);
                            if (!emailValid) {
                              return 'Por favor ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tipo de consulta
                        Text(
                          'Tipo de consulta',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedIssueType,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              items:
                                  _issueTypes.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconForIssueType(value),
                                            size: 20,
                                            color: const Color(0xFF00BFA5),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            value,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedIssueType = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mensaje
                        Text(
                          'Mensaje',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu mensaje';
                            }
                            if (value.trim().length < 10) {
                              return 'El mensaje debe tener al menos 10 caracteres';
                            }
                            return null;
                          },
                          maxLines: 5,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje aquí...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00BFA5),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            errorStyle: GoogleFonts.inter(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de envío
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BFA5),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(
                                0xFF00BFA5,
                              ).withValues(alpha: 0.5),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isSending
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : Text(
                                      'Enviar mensaje',
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
                ],
              ),
            ),

            // Footer con información de contacto adicional
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Text(
                    'Horario de atención: L-V de 9:00 a 18:00',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
            hintText: 'Ingresa tu $label',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00BFA5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            errorStyle: GoogleFonts.inter(color: Colors.red, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 115,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF00BFA5), size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForIssueType(String type) {
    switch (type) {
      case 'Problema técnico':
        return Icons.computer;
      case 'Pregunta sobre la app':
        return Icons.help_outline;
      case 'Sugerencia de mejora':
        return Icons.lightbulb_outline;
      case 'Reporte de error':
        return Icons.bug_report_outlined;
      case 'Otro':
        return Icons.question_mark;
      default:
        return Icons.help_outline;
    }
  }

  // ignore: unused_element
  void _showChatUnavailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Color(0xFFE53935),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chat no disponible',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lo sentimos, nuestro servicio de chat está fuera de horario. Por favor intenta durante nuestro horario de atención o utiliza otro método de contacto.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Entendido',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }
}
