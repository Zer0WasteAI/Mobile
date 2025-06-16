import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_backend_provider.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  // Controladores para los campos de texto
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // Estados para los selectores
  String _selectedRecipeType = 'fondo';
  String _selectedDifficulty = 'facil';
  int _preparationTime = 30;

  // Estado para la imagen de la receta
  File? _recipeImage;
  String _selectedEmoji = '🍳';

  // Lista de ingredientes y pasos
  final List<Map<String, dynamic>> _ingredients = [];
  final List<String> _steps = [''];

  // Etiquetas y opciones de sostenibilidad
  final Set<String> _selectedTags = {};
  final Set<String> _selectedSustainabilityOptions = {};

  // Para controlar la edición de ingredientes
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final TextEditingController _ingredientUnitController =
      TextEditingController();

  // Datos para selectores
  final Map<String, String> _recipeTypes = {
    'entrada': 'Entrada',
    'fondo': 'Plato principal',
    'postre': 'Postre',
    'bebida': 'Bebida',
    'snack': 'Snack',
  };

  final Map<String, String> _difficultyLevels = {
    'facil': 'Fácil',
    'intermedio': 'Intermedio',
    'dificil': 'Difícil',
  };

  final List<String> _dietaryTags = [
    'Vegetariana',
    'Vegana',
    'Sin gluten',
    'Sin lactosa',
    'Bajo en carbohidratos',
    'Alto en proteínas',
  ];

  final List<String> _sustainabilityOptions = [
    'Aprovecha sobrantes',
    'Bajo impacto ambiental',
    'Ingredientes de temporada',
  ];

  final List<String> _commonEmojis = [
    '🍳',
    '🥗',
    '🍲',
    '🍝',
    '🍔',
    '🍕',
    '🌮',
    '🥘',
    '🍰',
    '🧁',
    '🥞',
    '🍞',
    '🥪',
    '🍚',
    '🍖',
    '🍗',
    '🥩',
    '🍤',
    '🍣',
    '🥟',
    '🍱',
    '🥤',
    '🧃',
    '🍹',
  ];

  // Unidades de medida comunes
  final List<String> _commonUnits = [
    'g',
    'kg',
    'ml',
    'l',
    'taza(s)',
    'cucharada(s)',
    'cucharadita(s)',
    'unidad(es)',
    'pizca(s)',
    'al gusto',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _ingredientNameController.dispose();
    _ingredientQuantityController.dispose();
    _ingredientUnitController.dispose();
    super.dispose();
  }

  // Método para seleccionar imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _recipeImage = File(pickedFile.path);
        _selectedEmoji = ''; // Si hay imagen, no mostrar emoji
      });
    }
  }

  // Método para añadir un ingrediente
  void _addIngredient() {
    // Validar que haya un nombre
    if (_ingredientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El ingrediente debe tener un nombre')),
      );
      return;
    }

    setState(() {
      _ingredients.add({
        'name': _ingredientNameController.text.trim(),
        'quantity': _ingredientQuantityController.text.trim(),
        'unit': _ingredientUnitController.text.trim(),
      });

      // Limpiar los controladores
      _ingredientNameController.clear();
      _ingredientQuantityController.clear();
      _ingredientUnitController.clear();
    });
  }

  // Método para añadir un paso
  void _addStep() {
    setState(() {
      _steps.add('');
    });
  }

  // Método para guardar la receta
  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que haya al menos un ingrediente
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos un ingrediente')),
      );
      return;
    }

    // Validar que todos los pasos tengan contenido
    if (_steps.any((step) => step.trim().isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Completa todos los pasos')));
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Construir el objeto receta en el formato esperado por la API
      final recipeData = {
        'title': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients':
            _ingredients.map((ingredient) {
              return {
                'name': ingredient['name'],
                'quantity': ingredient['quantity'],
                'unit': ingredient['unit'],
              };
            }).toList(),
        'instructions': _steps.where((step) => step.trim().isNotEmpty).toList(),
        'prep_time': _preparationTime,
        'difficulty': _selectedDifficulty,
        'category': _selectedRecipeType,
        'diet_type':
            _selectedTags.contains('Vegetariana')
                ? 'Vegetariana'
                : _selectedTags.contains('Vegana')
                ? 'Vegana'
                : 'Omnívora',
        'tags': _selectedTags.toList(),
        'sustainability_options': _selectedSustainabilityOptions.toList(),
        'notes': _notesController.text.trim(),
        'emoji': _selectedEmoji.isNotEmpty ? _selectedEmoji : '🍽️',
      };

      // Guardar la receta usando el provider
      final recipeBackend = ref.read(recipeBackendProvider);
      final result = await recipeBackend.saveRecipe(recipeData);

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      log('Receta guardada exitosamente: $result');

      // Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Receta guardada correctamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla anterior
        Navigator.of(context).pop();
      }
    } catch (error) {
      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      log('Error al guardar receta: $error');

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la receta: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores según el tema
    final Color scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color cardBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color fieldBackgroundColor =
        isDark ? Colors.grey.shade800 : AppColors.lightFormBackground;

    // Colores para el tipo de receta
    final Map<String, Color> typeColors = {
      'entrada': Colors.blue,
      'fondo': Colors.deepPurple,
      'postre': Colors.pink,
      'bebida': Colors.teal,
      'snack': Colors.amber,
    };

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Crear Receta',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: mainTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: mainTextColor),
        actions: [
          // Botón para guardar
          TextButton(
            onPressed: _saveRecipe,
            child: Text(
              'Guardar',
              style: GoogleFonts.inter(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de imagen/emoji
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        _recipeImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _recipeImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedEmoji,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Toca para añadir\nimagen',
                                    style: GoogleFonts.inter(
                                      color: secondaryTextColor,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ),

              // Selector de emoji
              if (_recipeImage == null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        _commonEmojis.map((emoji) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEmoji = emoji;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    _selectedEmoji == emoji
                                        ? primaryColor.withValues(alpha: 0.2)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // Información básica
              Text(
                'Información básica',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 12),

              // Nombre de la receta
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.inter(color: mainTextColor),
                decoration: InputDecoration(
                  labelText: 'Nombre de la receta',
                  labelStyle: GoogleFonts.inter(color: secondaryTextColor),
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.restaurant_menu),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.inter(color: mainTextColor),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  labelStyle: GoogleFonts.inter(color: secondaryTextColor),
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 20),

              // Tipo de receta, dificultad y tiempo
              Row(
                children: [
                  // Tipo de receta
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de receta',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: fieldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedRecipeType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: fieldBackgroundColor,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: secondaryTextColor,
                            ),
                            style: GoogleFonts.inter(color: mainTextColor),
                            items:
                                _recipeTypes.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: typeColors[entry.key],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(entry.value),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRecipeType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Dificultad
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dificultad',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: fieldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedDifficulty,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: fieldBackgroundColor,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: secondaryTextColor,
                            ),
                            style: GoogleFonts.inter(color: mainTextColor),
                            items:
                                _difficultyLevels.entries.map((entry) {
                                  Color difficultyColor =
                                      entry.key == 'facil'
                                          ? Colors.green
                                          : entry.key == 'intermedio'
                                          ? Colors.orange
                                          : Colors.red;

                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Row(
                                      children: [
                                        Icon(
                                          entry.key == 'facil'
                                              ? Icons.sentiment_satisfied_alt
                                              : entry.key == 'intermedio'
                                              ? Icons.sentiment_neutral
                                              : Icons
                                                  .sentiment_very_dissatisfied,
                                          color: difficultyColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(entry.value),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tiempo de preparación
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiempo de preparación: $_preparationTime min',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: fieldBackgroundColor,
                      thumbColor: primaryColor,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20.0,
                      ),
                    ),
                    child: Slider(
                      value: _preparationTime.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23, // Para incrementos de 5 minutos
                      onChanged: (value) {
                        setState(() {
                          _preparationTime = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sección de ingredientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ingredientes',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Mostrar diálogo para añadir ingrediente
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (context) => _buildAddIngredientBottomSheet(
                              context,
                              fieldBackgroundColor,
                              mainTextColor,
                              secondaryTextColor,
                              primaryColor,
                              cardBackgroundColor,
                            ),
                      );
                    },
                    icon: Icon(Icons.add, color: primaryColor),
                    label: Text(
                      'Añadir',
                      style: GoogleFonts.inter(color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista de ingredientes
              if (_ingredients.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          size: 48,
                          color: secondaryTextColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ingredientes todavía',
                          style: GoogleFonts.inter(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          ingredient['name'],
                          style: GoogleFonts.inter(color: mainTextColor),
                        ),
                        subtitle:
                            ingredient['quantity'].isNotEmpty ||
                                    ingredient['unit'].isNotEmpty
                                ? Text(
                                  '${ingredient['quantity']} ${ingredient['unit']}',
                                  style: GoogleFonts.inter(
                                    color: secondaryTextColor,
                                  ),
                                )
                                : null,
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade300,
                          ),
                          onPressed: () {
                            setState(() {
                              _ingredients.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Sección de pasos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pasos de preparación',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: Icon(Icons.add, color: primaryColor),
                    label: Text(
                      'Añadir',
                      style: GoogleFonts.inter(color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista de pasos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Número de paso
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Campo de texto para el paso
                        Expanded(
                          child: TextFormField(
                            initialValue: _steps[index],
                            style: GoogleFonts.inter(color: mainTextColor),
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Describe el paso ${index + 1}',
                              hintStyle: GoogleFonts.inter(
                                color: secondaryTextColor.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              filled: true,
                              fillColor: fieldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _steps[index] = value;
                              });
                            },
                          ),
                        ),

                        // Botón para eliminar paso
                        if (_steps.length > 1)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade300,
                            ),
                            onPressed: () {
                              setState(() {
                                _steps.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Etiquetas de la receta
              Text(
                'Etiquetas',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 12),

              // Chips para seleccionar etiquetas
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _dietaryTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);

                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor: fieldBackgroundColor,
                        selectedColor: primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: primaryColor,
                        labelStyle: GoogleFonts.inter(
                          color: isSelected ? primaryColor : secondaryTextColor,
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 24),

              // Opciones de sostenibilidad
              Text(
                'Sostenibilidad',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 12),

              // Chips para sostenibilidad
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _sustainabilityOptions.map((option) {
                      final isSelected = _selectedSustainabilityOptions
                          .contains(option);

                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSustainabilityOptions.add(option);
                            } else {
                              _selectedSustainabilityOptions.remove(option);
                            }
                          });
                        },
                        backgroundColor: fieldBackgroundColor,
                        selectedColor: Colors.green.withValues(alpha: 0.2),
                        checkmarkColor: Colors.green,
                        labelStyle: GoogleFonts.inter(
                          color: isSelected ? Colors.green : secondaryTextColor,
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 24),

              // Notas adicionales
              Text(
                'Notas adicionales',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                style: GoogleFonts.inter(color: mainTextColor),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Consejos, variaciones, etc. (opcional)',
                  hintStyle: GoogleFonts.inter(
                    color: secondaryTextColor.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón de guardar
              Center(
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Guardar receta',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom sheet para añadir ingrediente
  Widget _buildAddIngredientBottomSheet(
    BuildContext context,
    Color fieldBackgroundColor,
    Color mainTextColor,
    Color secondaryTextColor,
    Color primaryColor,
    Color cardBackgroundColor,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Añadir ingrediente',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: secondaryTextColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nombre del ingrediente
          TextFormField(
            controller: _ingredientNameController,
            style: GoogleFonts.inter(color: mainTextColor),
            decoration: InputDecoration(
              labelText: 'Nombre del ingrediente',
              labelStyle: GoogleFonts.inter(color: secondaryTextColor),
              filled: true,
              fillColor: fieldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Cantidad y unidad
          Row(
            children: [
              // Cantidad
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _ingredientQuantityController,
                  style: GoogleFonts.inter(color: mainTextColor),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: GoogleFonts.inter(color: secondaryTextColor),
                    filled: true,
                    fillColor: fieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),

              // Unidad
              Expanded(
                flex: 3,
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _commonUnits.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (String selection) {
                    _ingredientUnitController.text = selection;
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    textEditingController.text = _ingredientUnitController.text;

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: GoogleFonts.inter(color: mainTextColor),
                      decoration: InputDecoration(
                        labelText: 'Unidad',
                        labelStyle: GoogleFonts.inter(
                          color: secondaryTextColor,
                        ),
                        filled: true,
                        fillColor: fieldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _ingredientUnitController.text = value;
                      },
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                  optionsViewBuilder: (
                    BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: cardBackgroundColor,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.inter(
                                      color: mainTextColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botón para añadir
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _addIngredient();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Añadir ingrediente',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
