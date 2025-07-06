import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class FAQsScreen extends ConsumerStatefulWidget {
  const FAQsScreen({super.key});

  static const String routeName = 'faqs';
  static const String routePath = '/faqs';

  @override
  ConsumerState<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends ConsumerState<FAQsScreen> {
  // Esta lista almacena los índices de las FAQs expandidas
  final List<int> _expandedFAQs = [];

  // Lista de preguntas frecuentes
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: '¿Cómo funciona la detección de alimentos?',
      answer:
          'La app utiliza inteligencia artificial para reconocer los alimentos que fotografías. Simplemente toma una foto de tus ingredientes o alimentos y la IA identificará qué son, añadiéndolos automáticamente a tu inventario con fechas de caducidad estimadas.',
      category: FAQCategory.features,
    ),
    FAQItem(
      question: '¿Cómo edito un alimento en mi inventario?',
      answer:
          'Para editar un alimento, ve a la sección de Inventario, selecciona el alimento que deseas modificar y toca el ícono de edición (lápiz). Allí podrás cambiar la cantidad, fecha de caducidad y otras propiedades.',
      category: FAQCategory.inventory,
    ),
    FAQItem(
      question: '¿Qué significa mi impacto ambiental?',
      answer:
          'Tu impacto ambiental muestra cuánto contribuyes a reducir el desperdicio alimentario. Medimos los kilogramos de comida que has salvado, los litros de agua ahorrados y el CO₂ no emitido gracias a tu gestión eficiente de alimentos.',
      category: FAQCategory.sustainability,
    ),
    FAQItem(
      question: '¿Puedo usar la app sin conexión a internet?',
      answer:
          'La mayoría de las funciones básicas como ver tu inventario y recetas guardadas funcionan sin internet. Sin embargo, la detección de alimentos por fotos, generación de recetas con IA y sincronización de datos requieren conexión a internet.',
      category: FAQCategory.technical,
    ),
    FAQItem(
      question: '¿Cómo genero recetas con los alimentos que tengo?',
      answer:
          'Ve a la sección de Recetas y selecciona "Generar receta". La aplicación analizará automáticamente tu inventario actual y te sugerirá recetas que puedes preparar con los ingredientes disponibles, priorizando aquellos que caducan pronto.',
      category: FAQCategory.recipes,
    ),
    FAQItem(
      question: '¿Puedo compartir mis recetas?',
      answer:
          'Sí, puedes compartir cualquier receta. Simplemente abre la receta que quieres compartir, toca el ícono de compartir y elige el método que prefieras (WhatsApp, correo electrónico, etc.).',
      category: FAQCategory.recipes,
    ),
    FAQItem(
      question: '¿Cómo configuro notificaciones de caducidad?',
      answer:
          'Ve a tu perfil, selecciona "Notificaciones" y activa las alertas de caducidad. Puedes personalizar con cuántos días de anticipación quieres recibir avisos sobre alimentos que van a caducar pronto.',
      category: FAQCategory.features,
    ),
    FAQItem(
      question: '¿Mis datos están seguros?',
      answer:
          'Sí, tu privacidad es nuestra prioridad. Todos tus datos se almacenan de forma segura y no compartimos tu información personal con terceros. Puedes consultar nuestra política de privacidad para más detalles.',
      category: FAQCategory.privacy,
    ),
    FAQItem(
      question: '¿Cómo puedo sugerir nuevas funciones?',
      answer:
          'Valoramos tus ideas para mejorar la app. Puedes enviarnos sugerencias desde la sección "Contacto y soporte" en tu perfil. Revisamos todas las sugerencias y las consideramos para futuras actualizaciones.',
      category: FAQCategory.other,
    ),
  ];

  // Filtro de categorías
  FAQCategory _selectedCategory = FAQCategory.all;

  // Lista filtrada de FAQs según la categoría seleccionada
  List<FAQItem> get _filteredFAQs {
    if (_selectedCategory == FAQCategory.all) {
      return _faqItems;
    } else {
      return _faqItems
          .where((faq) => faq.category == _selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: Text(
          'Preguntas frecuentes',
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
          // Filtros de categoría
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(FAQCategory.all, 'Todas'),
                  _buildCategoryChip(FAQCategory.features, 'Funciones'),
                  _buildCategoryChip(FAQCategory.inventory, 'Inventario'),
                  _buildCategoryChip(FAQCategory.recipes, 'Recetas'),
                  _buildCategoryChip(
                    FAQCategory.sustainability,
                    'Sostenibilidad',
                  ),
                  _buildCategoryChip(FAQCategory.technical, 'Técnicas'),
                  _buildCategoryChip(FAQCategory.privacy, 'Privacidad'),
                  _buildCategoryChip(FAQCategory.other, 'Otras'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Lista de FAQs
          Expanded(
            child:
                _filteredFAQs.isEmpty
                    ? Center(
                      child: Text(
                        'No hay preguntas en esta categoría',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _filteredFAQs.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final faq = _filteredFAQs[index];
                        final isExpanded = _expandedFAQs.contains(index);

                        return _buildFAQItem(
                          context,
                          faq: faq,
                          isExpanded: isExpanded,
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedFAQs.remove(index);
                              } else {
                                _expandedFAQs.add(index);
                              }
                            });
                          },
                        );
                      },
                    ),
          ),

          // Contacto para más preguntas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Color(0xFF00BFA5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿No encuentras tu pregunta?',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contáctanos y te responderemos lo antes posible',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/support'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00BFA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Contactar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(FAQCategory category, String label) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: GoogleFonts.inter(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFF00BFA5),
        checkmarkColor: Colors.white,
        elevation: 0,
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required FAQItem faq,
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
            // Pregunta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFF00BFA5),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),

            // Respuesta (solo visible si está expandida)
            if (isExpanded) ...[
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF2196F3),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        faq.answer,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Categorías de preguntas frecuentes
enum FAQCategory {
  all,
  features,
  inventory,
  recipes,
  sustainability,
  technical,
  privacy,
  other,
}

// Clase para los elementos de preguntas frecuentes
class FAQItem {
  final String question;
  final String answer;
  final FAQCategory category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
