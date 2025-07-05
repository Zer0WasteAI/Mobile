import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/core/services/api_service.dart';

import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';

class AddInventoryItemScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? prefilledItems;

  const AddInventoryItemScreen({super.key, this.prefilledItems});

  // Define route name and path for GoRouter
  static const String routeName = 'addInventoryItem';
  static const String routePath = '/inventory/add';

  @override
  ConsumerState<AddInventoryItemScreen> createState() =>
      _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState
    extends ConsumerState<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tipsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _servingQuantityController = TextEditingController();

  double _quantity = 1.0;
  DateTime? _expirationDate;
  StorageType _selectedStorageType = StorageType.refrigerated;
  ItemCategory _selectedCategory = ItemCategory.food; // Default to Food
  String? _selectedUnitType; // Initially null

  // Image handling
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isImageUploading = false;
  bool _isSubmitting = false;

  // Define available units
  final Map<ItemCategory, List<String>> _categoryUnits = {
    ItemCategory.food: ['unidades', 'porciones', 'platos'],
    ItemCategory.ingredient: [
      'unidades',
      'kg',
      'g',
      'lt',
      'ml',
      'tazas',
      'cucharadas',
    ],
  };

  // Storage types based on category
  final Map<ItemCategory, List<StorageType>> _categoryStorage = {
    ItemCategory.food: [StorageType.refrigerated, StorageType.frozen],
    ItemCategory.ingredient: [
      StorageType.refrigerated,
      StorageType.frozen,
      StorageType.pantry,
      StorageType.ambient,
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializePrefilledData();
    _selectedUnitType = _categoryUnits[_selectedCategory]!.first;
  }

  void _initializePrefilledData() {
    if (widget.prefilledItems != null && widget.prefilledItems!.isNotEmpty) {
      // Use the first item for pre-filling (in case multiple items were scanned)
      final firstItem = widget.prefilledItems!.first;

      // Pre-fill the name field
      if (firstItem['name'] != null) {
        _nameController.text = firstItem['name'].toString();
      }

      // Pre-fill category if available
      if (firstItem['category'] != null) {
        final categoryString = firstItem['category'].toString().toLowerCase();
        if (categoryString.contains('food') ||
            categoryString.contains('alimento')) {
          _selectedCategory = ItemCategory.food;
        } else if (categoryString.contains('ingredient') ||
            categoryString.contains('ingrediente')) {
          _selectedCategory = ItemCategory.ingredient;
        }
      }

      // Set default values for scanned items
      _quantity = 1.0;
      _selectedUnitType = _categoryUnits[_selectedCategory]!.first;
      _selectedStorageType = StorageType.refrigerated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // --- Theme-aware Colors --- //
    final Color scaffoldBackgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : const Color(0xFF00B894);
    final Color onPrimaryColor =
        isDark ? Colors.black : Colors.white; // Fallback
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);
    final Color formFieldBackgroundColor =
        isDark ? AppColors.darkSurface : Colors.white;
    final Color chipSelectedColor = primaryColor;
    final Color chipUnselectedColor =
        isDark
            ? AppColors.darkSurface
            : formFieldBackgroundColor; // Dark uses surface, light uses its own bg
    final Color chipSelectedTextColor = onPrimaryColor;
    final Color chipUnselectedTextColor = secondaryTextColor;
    final Color chipUnselectedBorderColor =
        isDark ? AppColors.darkOutline : Colors.grey.shade300;
    // ignore: unused_local_variable
    final Color snackbarColor = primaryColor;
    // ------------------------- //

    // --- Define Consistent Hint Style --- //
    final TextStyle hintTextStyle = GoogleFonts.inter(
      color: secondaryTextColor.withValues(alpha: 0.8),
      fontSize:
          textTheme.bodyMedium?.fontSize ??
          14, // Use theme body size or fallback
    );
    // ------------------------------------ //

    // Re-define _inputDecoration inside build to access theme colors
    InputDecoration inputDecorationHelper({
      String? hintText,
      IconData? icon,
      Widget? suffixIcon,
      TextStyle? hintStyle, // Add parameter for hintStyle
      Widget? prefixIcon,
    }) {
      final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        // Use theme outline color for default border
        borderSide: BorderSide(color: chipUnselectedBorderColor, width: 1.0),
      );
      return InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: formFieldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 16.0,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: border,
        enabledBorder: border,
        // Use theme primary color for focused border
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: hintStyle,
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Agregar Ítem Manualmente',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: mainTextColor, // Updated
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: mainTextColor, // Updated
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Pre-filled Data Banner ---
              if (widget.prefilledItems != null &&
                  widget.prefilledItems!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Datos pre-llenados desde escaneo',
                          style: GoogleFonts.inter(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // --- Nombre del Alimento ---
              Text(
                'Nombre del Alimento',
                // Use theme text style directly or adapt
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: mainTextColor,
                ), // Ensure input text color adapts
                decoration: inputDecorationHelper(
                  hintText: 'Ej: Manzanas Rojas',
                  icon: Icons.restaurant_menu_outlined,
                  hintStyle: hintTextStyle, // Pass the style
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  if (value.trim().length > 50) {
                    return 'El nombre no puede exceder 50 caracteres';
                  }
                  // Validar que no contenga solo números
                  if (RegExp(r'^\d+$').hasMatch(value.trim())) {
                    return 'El nombre no puede ser solo números';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // --- Imagen del Producto ---
              Text(
                'Imagen del Producto',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedImage != null
                              ? primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child:
                      _selectedImage != null
                          ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toca para agregar imagen',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                'Galería o Cámara',
                                style: textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Tips/Consejos ---
              Text(
                'Tips/Consejos (Opcional)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tipsController,
                style: TextStyle(color: mainTextColor),
                maxLines: 3,
                maxLength: 200,
                decoration: inputDecorationHelper(
                  hintText: 'Ej: Mantener en lugar fresco y seco...',
                  icon: Icons.lightbulb_outline,
                  hintStyle: hintTextStyle,
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 5) {
                      return 'Los tips deben tener al menos 5 caracteres';
                    }
                    if (value.trim().length > 200) {
                      return 'Los tips no pueden exceder 200 caracteres';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Unidad --- (Movido antes que Cantidad)
              Text(
                'Unidad',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedUnitType,
                decoration: const InputDecoration(labelText: 'Unidad'),
                items:
                    _categoryUnits[_selectedCategory]!.map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnitType = newValue;
                    // Reset quantity to minimum when changing units
                    _quantity = _getMinQuantity();
                  });
                },
                validator:
                    (value) => value == null ? 'Selecciona una unidad' : null,
              ),
              const SizedBox(height: 20),

              // --- Cantidad --- (Ahora después de Unidad)
              Text(
                'Cantidad',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: primaryColor,
                    ),
                    iconSize: 30,
                    onPressed:
                        _selectedUnitType != null &&
                                _quantity >
                                    _getMinimumQuantity(_selectedUnitType!)
                            ? () => setState(
                              () =>
                                  _quantity -= _getQuantityStep(
                                    _selectedUnitType!,
                                  ),
                            )
                            : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      _selectedUnitType == null
                          ? _quantity.toInt().toString()
                          : _formatQuantity(_quantity, _selectedUnitType!),
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: primaryColor),
                    iconSize: 30,
                    onPressed:
                        _selectedUnitType != null && _quantity < 999
                            ? () => setState(
                              () =>
                                  _quantity += _getQuantityStep(
                                    _selectedUnitType!,
                                  ),
                            )
                            : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Fecha de Expiración ---
              Text(
                'Fecha de Expiración',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                style: TextStyle(color: mainTextColor),
                onTap: () => _selectDate(context),
                decoration: inputDecorationHelper(
                  hintText:
                      _expirationDate == null
                          ? 'Seleccionar fecha'
                          : DateFormat('dd/MM/yyyy').format(_expirationDate!),
                  icon: Icons.calendar_today_outlined,
                  hintStyle: hintTextStyle,
                  suffixIcon:
                      _expirationDate != null
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 20,
                              color: secondaryTextColor,
                            ),
                            onPressed:
                                () => setState(() => _expirationDate = null),
                          )
                          : null,
                ),
                validator: (value) {
                  if (_expirationDate == null) {
                    return 'Por favor selecciona una fecha de expiración';
                  }
                  // Validar que la fecha no sea en el pasado
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final selectedDate = DateTime(
                    _expirationDate!.year,
                    _expirationDate!.month,
                    _expirationDate!.day,
                  );

                  if (selectedDate.isBefore(today)) {
                    return 'La fecha de expiración no puede ser en el pasado';
                  }

                  // Validar que no sea más de 5 años en el futuro
                  final maxDate = today.add(const Duration(days: 365 * 5));
                  if (selectedDate.isAfter(maxDate)) {
                    return 'La fecha no puede ser más de 5 años en el futuro';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Tipo de Almacenamiento ---
              Text(
                'Tipo de Almacenamiento',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _categoryStorage[_selectedCategory]!.map((type) {
                      return ChoiceChip(
                        label: Text(
                          type.displayName,
                          style: GoogleFonts.inter(
                            color:
                                _selectedStorageType == type
                                    ? Colors.white
                                    : mainTextColor,
                          ),
                        ),
                        selected: _selectedStorageType == type,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedStorageType = type;
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),

              // --- Categoría del Producto ---
              Text(
                'Categoría del Producto',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children:
                    ItemCategory.values
                        .where((cat) => cat != ItemCategory.all)
                        .map(
                          (category) => ChoiceChip(
                            label: Text(category.displayName),
                            selected: _selectedCategory == category,
                            onSelected:
                                (_) => setState(
                                  () => _selectedCategory = category,
                                ),
                            avatar: Icon(
                              category.icon,
                              size: 18,
                              color:
                                  _selectedCategory == category
                                      ? chipSelectedTextColor // Updated
                                      : chipUnselectedTextColor, // Updated
                            ),
                            selectedColor: chipSelectedColor, // Updated
                            backgroundColor: chipUnselectedColor, // Updated
                            labelStyle: TextStyle(
                              color:
                                  _selectedCategory == category
                                      ? chipSelectedTextColor // Updated
                                      : chipUnselectedTextColor, // Updated
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color:
                                    _selectedCategory == category
                                        ? chipSelectedColor // Updated
                                        : chipUnselectedBorderColor, // Updated
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 40),

              // --- Botón Guardar ---
              ElevatedButton.icon(
                icon:
                    _isSubmitting
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              onPrimaryColor,
                            ),
                          ),
                        )
                        : Icon(
                          Icons.save_outlined,
                          size: 20,
                          color: onPrimaryColor,
                        ),
                label: Text(
                  _isSubmitting
                      ? (_isImageUploading
                          ? 'Subiendo imagen...'
                          : 'Guardando...')
                      : 'Agregar al Inventario',
                ),
                onPressed:
                    _isSubmitting
                        ? null
                        : (_nameController.text.trim().isNotEmpty &&
                            _selectedUnitType != null &&
                            _expirationDate != null)
                        ? () async => await _saveItem()
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                  disabledForegroundColor: onPrimaryColor.withValues(
                    alpha: 0.7,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add methods back
  @override
  void dispose() {
    _nameController.dispose();
    _tipsController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _servingQuantityController.dispose();
    super.dispose();
  }

  // Image handling methods
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Seleccionar imagen',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      context,
                      'Cámara',
                      Icons.camera_alt,
                      () => _pickImage(ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      context,
                      'Galería',
                      Icons.photo_library,
                      () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      // Validaciones adicionales antes de enviar
      if (_quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La cantidad debe ser mayor a 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedUnitType != null) {
        final minQuantity = _getMinimumQuantity(_selectedUnitType!);
        if (_quantity < minQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'La cantidad mínima para ${_selectedUnitType!} es $minQuantity',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        String? uploadedImagePath;

        // Step 1: Upload image if selected
        if (_selectedImage != null) {
          setState(() {
            _isImageUploading = true;
          });

          try {
            final uploadResponse = await ApiService.instance.uploadImage(
              imageFile: _selectedImage!,
              imageType:
                  _selectedCategory == ItemCategory.food
                      ? 'food'
                      : 'ingredient',
              itemName: _nameController.text.trim(),
            );

            uploadedImagePath = uploadResponse['image_path'] as String?;
            log('✅ Image uploaded successfully: $uploadedImagePath');
          } catch (e) {
            log('❌ Failed to upload image: $e');
            // Continue without image if upload fails
          } finally {
            setState(() {
              _isImageUploading = false;
            });
          }
        }

        // Step 2: Check for duplicate names (optional warning)
        final existingItems = ref.read(inventoryRealProvider).items;
        final itemName = _nameController.text.trim().toLowerCase();
        final hasDuplicate = existingItems.any(
          (item) => item.name.toLowerCase() == itemName,
        );

        if (hasDuplicate) {
          final shouldContinue = await _showDuplicateWarning();
          if (!shouldContinue) {
            setState(() {
              _isSubmitting = false;
            });
            return;
          }
        }

        // Step 3: Create item data for backend
        final itemData = {
          'name': _nameController.text.trim(),
          'quantity': _quantity,
          'type_unit': _selectedUnitType!,
          'storage_type': _getStorageTypeForAPI(_selectedStorageType),
          'expiration_time': _getExpirationDays(),
          'time_unit': 'Días',
          'tips':
              _tipsController.text.trim().isEmpty
                  ? null
                  : _tipsController.text.trim(),
        };

        // Step 3: Add item to backend inventory
        final response = await ref
            .read(inventoryRealProvider.notifier)
            .addSingleItemToInventory(itemData);

        log('✅ Item added to backend successfully: $response');

        // Step 4: Refresh inventory to show new item
        await ref.read(inventoryRealProvider.notifier).refreshInventory();

        // Step 5: Success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_nameController.text.trim()} agregado al inventario',
              ),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pop();
        }
      } catch (e) {
        log('❌ Failed to save item: $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  // Helper methods for backend integration
  String _getStorageTypeForAPI(StorageType type) {
    switch (type) {
      case StorageType.refrigerated:
        return 'refrigerated';
      case StorageType.frozen:
        return 'frozen';
      case StorageType.pantry:
        return 'pantry';
      case StorageType.cellar:
        return 'cellar';
      case StorageType.ambient:
        return 'ambient';
      case StorageType.sunlight:
        return 'sunlight';
      case StorageType.wineCellar:
        return 'wine_cellar';
      case StorageType.bulk:
        return 'bulk';
      case StorageType.fermentation:
        return 'fermentation';
    }
  }

  int _getExpirationDays() {
    return _selectedStorageType.daysToExpire;
  }

  // Helper methods for quantity logic (copied from other screens)
  double _getQuantityStep(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }

  double _getMinimumQuantity(String unitType) {
    switch (unitType.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lt':
      case 'ml':
        return 0.1;
      case 'unidades':
      default:
        return 1.0;
    }
  }

  String _formatQuantity(double quantity, String unitType) {
    if (unitType.toLowerCase() == 'unidades') {
      return quantity.toInt().toString();
    } else {
      if (quantity == quantity.truncate()) {
        return quantity.toInt().toString();
      } else {
        return quantity.toStringAsFixed(1);
      }
    }
  }

  double _getMinQuantity() {
    // Implementation of _getMinQuantity method
    return 1.0; // Placeholder return, actual implementation needed
  }

  Future<bool> _showDuplicateWarning() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Elemento Similar Encontrado'),
                content: Text(
                  'Ya existe un elemento con el nombre "${_nameController.text.trim()}" en tu inventario. '
                  '¿Deseas continuar agregando este elemento?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
