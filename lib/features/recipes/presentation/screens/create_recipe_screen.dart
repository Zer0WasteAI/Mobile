import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zer0_waste_ai/features/recipes/application/providers/recipe_backend_provider.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  // Form controllers and keys
  final _formKey = GlobalKey<FormState>();
  final _ingredientFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _servingsController = TextEditingController(
    text: '4',
  ); // Default 4 servings
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();

  // Recipe metadata
  final String _selectedRecipeType = 'fondo';
  final String _selectedDifficulty = 'facil';
  final int _preparationTime = 30;
  bool _isSubmitting = false;

  // Recipe image/emoji
  File? _recipeImage;
  String _selectedEmoji = '🍳';

  // Ingredients and steps
  final List<Map<String, dynamic>> _ingredients = [];
  final List<String> _steps = [''];

  // Tags and sustainability options
  final List<String> _selectedTags = [];
  final List<String> _selectedSustainabilityOptions = [];

  // Common units for ingredients
  final List<String> _commonUnits = [
    'unidades',
    'kg',
    'g',
    'lt',
    'ml',
    'tazas',
    'cucharadas',
    'cucharaditas',
  ];

  // Dietary tags
  final List<String> _dietaryTags = [
    'Vegetariano',
    'Vegano',
    'Sin gluten',
    'Sin lácteos',
    'Bajo en calorías',
    'Alto en proteínas',
    'Keto',
    'Paleo',
  ];

  // Sustainability options
  final List<String> _sustainabilityOptions = [
    'Ingredientes locales',
    'De temporada',
    'Bajo impacto ambiental',
    'Zero waste',
    'Orgánico',
  ];

  // Common emojis for recipe types
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
    '🥑',
    '🥬',
    '🥦',
    '🍅',
    '🥕',
    '🌶️',
  ];

  @override
  void initState() {
    super.initState();
    // Add first empty step
    _steps.add('');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _servingsController.dispose();
    _ingredientNameController.dispose();
    _ingredientQuantityController.dispose();
    _ingredientUnitController.dispose();
    super.dispose();
  }

  // Image handling methods
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _recipeImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar la imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Ingredient handling methods
  void _addIngredient() {
    if (_ingredientFormKey.currentState?.validate() ?? false) {
      setState(() {
        _ingredients.add({
          'name': _ingredientNameController.text.trim(),
          'quantity': _ingredientQuantityController.text.trim(),
          'unit': _ingredientUnitController.text.trim(),
        });

        // Clear the form
        _ingredientNameController.clear();
        _ingredientQuantityController.clear();
        _ingredientUnitController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _editIngredient(int index) {
    final ingredient = _ingredients[index];
    _ingredientNameController.text = ingredient['name'];
    _ingredientQuantityController.text = ingredient['quantity'];
    _ingredientUnitController.text = ingredient['unit'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _buildIngredientForm(
              onSave: () {
                if (!_ingredientFormKey.currentState!.validate()) return;

                setState(() {
                  _ingredients[index] = {
                    'name': _ingredientNameController.text.trim(),
                    'quantity': _ingredientQuantityController.text.trim(),
                    'unit': _ingredientUnitController.text.trim(),
                  };
                });

                Navigator.pop(context);
                _ingredientNameController.clear();
                _ingredientQuantityController.clear();
                _ingredientUnitController.clear();
              },
            ),
          ),
    );
  }

  // Step handling methods
  void _addStep() {
    setState(() {
      _steps.add('');
    });
  }

  void _removeStep(int index) {
    if (_steps.length > 1) {
      setState(() => _steps.removeAt(index));
    }
  }

  // Save recipe method
  Future<void> _saveRecipe() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final recipeData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients':
            _ingredients
                .map(
                  (ingredient) => {
                    'name': ingredient['name'],
                    'quantity': double.parse(ingredient['quantity']),
                    'unit': ingredient['unit'],
                  },
                )
                .toList(),
        'instructions': _steps.where((step) => step.trim().isNotEmpty).toList(),
        'prep_time': _preparationTime,
        'cook_time': _preparationTime ~/ 2,
        'servings': int.parse(_servingsController.text),
        'difficulty': _selectedDifficulty,
        'type': _selectedRecipeType,
        'tags': _selectedTags,
        'sustainability_options': _selectedSustainabilityOptions,
        'notes': _notesController.text.trim(),
        'image': _recipeImage?.path,
        'emoji': _selectedEmoji,
      };

      await ref.read(recipeBackendProvider).saveRecipe(recipeData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Receta guardada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la receta: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear receta'),
        actions: [
          if (!_isSubmitting)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveRecipe),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildIngredientsSection(),
            const SizedBox(height: 24),
            _buildStepsSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildSustainabilitySection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen o emoji',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                _recipeImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_recipeImage!, fit: BoxFit.cover),
                    )
                    : Column(
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
                            color:
                                Theme.of(context).textTheme.labelMedium?.color
                                    ?.withValues(alpha: 0.7) ??
                                Colors.grey.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
          ),
        ),
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
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.2)
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
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información básica',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.inter(
            color:
                Theme.of(context).textTheme.labelLarge?.color ?? Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Nombre de la receta',
            labelStyle: GoogleFonts.inter(
              color:
                  Theme.of(
                    context,
                  ).textTheme.labelMedium?.color?.withValues(alpha: 0.7) ??
                  Colors.grey.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
        TextFormField(
          controller: _descriptionController,
          style: GoogleFonts.inter(
            color:
                Theme.of(context).textTheme.labelLarge?.color ?? Colors.black,
          ),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descripción (opcional)',
            labelStyle: GoogleFonts.inter(
              color:
                  Theme.of(
                    context,
                  ).textTheme.labelMedium?.color?.withValues(alpha: 0.7) ??
                  Colors.grey.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.description),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredientes',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (_ingredients.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 48,
                  color:
                      Theme.of(
                        context,
                      ).textTheme.labelMedium?.color?.withValues(alpha: 0.5) ??
                      Colors.grey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay ingredientes todavía',
                  style: GoogleFonts.inter(
                    color:
                        Theme.of(context).textTheme.labelMedium?.color
                            ?.withValues(alpha: 0.7) ??
                        Colors.grey.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = _ingredients[index];
              return ListTile(
                title: Text(ingredient['name']),
                subtitle: Text(
                  '${ingredient['quantity']} ${ingredient['unit']}',
                  style: GoogleFonts.inter(
                    color:
                        Theme.of(context).textTheme.labelMedium?.color
                            ?.withValues(alpha: 0.7) ??
                        Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editIngredient(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: _buildIngredientForm(
                      onSave: () {
                        _addIngredient();
                        Navigator.pop(context);
                      },
                    ),
                  ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar ingrediente'),
        ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
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
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _steps[index],
                      onChanged: (value) {
                        setState(() {
                          _steps[index] = value;
                        });
                      },
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Describe el paso ${index + 1}',
                        hintStyle: GoogleFonts.inter(
                          color:
                              Theme.of(context).textTheme.labelMedium?.color
                                  ?.withValues(alpha: 0.7) ??
                              Colors.grey.withValues(alpha: 0.7),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon:
                            index > 0
                                ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeStep(index),
                                )
                                : null,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, describe este paso';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addStep,
          icon: const Icon(Icons.add),
          label: const Text('Agregar paso'),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _dietaryTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  backgroundColor:
                      Theme.of(context).inputDecorationTheme.fillColor,
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                  labelStyle: GoogleFonts.inter(
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.labelMedium?.color
                                    ?.withValues(alpha: 0.7) ??
                                Colors.grey.withValues(alpha: 0.7),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSustainabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sostenibilidad',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _sustainabilityOptions.map((option) {
                final isSelected = _selectedSustainabilityOptions.contains(
                  option,
                );
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSustainabilityOptions.add(option);
                      } else {
                        _selectedSustainabilityOptions.remove(option);
                      }
                    });
                  },
                  backgroundColor:
                      Theme.of(context).inputDecorationTheme.fillColor,
                  selectedColor: Colors.green.withValues(alpha: 0.2),
                  checkmarkColor: Colors.green,
                  labelStyle: GoogleFonts.inter(
                    color:
                        isSelected
                            ? Colors.green
                            : Theme.of(context).textTheme.labelMedium?.color
                                    ?.withValues(alpha: 0.7) ??
                                Colors.grey.withValues(alpha: 0.7),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas adicionales',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Consejos, variaciones, etc. (opcional)',
            hintStyle: GoogleFonts.inter(
              color:
                  Theme.of(
                    context,
                  ).textTheme.labelMedium?.color?.withValues(alpha: 0.7) ??
                  Colors.grey.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientForm({required VoidCallback onSave}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _ingredientFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ingredientNameController,
              decoration: InputDecoration(
                labelText: 'Nombre del ingrediente',
                labelStyle: GoogleFonts.inter(
                  color:
                      Theme.of(
                        context,
                      ).textTheme.labelMedium?.color?.withValues(alpha: 0.7) ??
                      Colors.grey.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ingredientQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: GoogleFonts.inter(
                        color:
                            Theme.of(context).textTheme.labelMedium?.color
                                ?.withValues(alpha: 0.7) ??
                            Colors.grey.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ingredientUnitController,
                    decoration: InputDecoration(
                      labelText: 'Unidad',
                      labelStyle: GoogleFonts.inter(
                        color:
                            Theme.of(context).textTheme.labelMedium?.color
                                ?.withValues(alpha: 0.7) ??
                            Colors.grey.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (String value) {
                          _ingredientUnitController.text = value;
                        },
                        itemBuilder: (BuildContext context) {
                          return _commonUnits.map((String unit) {
                            return PopupMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onSave, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
