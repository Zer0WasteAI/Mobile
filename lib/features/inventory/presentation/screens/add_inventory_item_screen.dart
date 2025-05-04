import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:flutter/services.dart'; // Import for InputFormatters
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';

class AddInventoryItemScreen extends ConsumerStatefulWidget {
  const AddInventoryItemScreen({super.key});

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
  final _emojiController = TextEditingController();
  double _quantity = 1.0;
  DateTime? _expirationDate;
  StorageType? _selectedStorageType;
  ItemCategory _selectedCategory = ItemCategory.food; // Default to Food
  String? _selectedUnitType; // Initially null
  final _uuid = const Uuid();

  // Define available units
  final List<String> _availableUnits = ['unidades', 'kg', 'g', 'lt', 'ml'];

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
    final Color snackbarColor = primaryColor;
    // ------------------------- //

    // --- Define Consistent Hint Style --- //
    final TextStyle hintTextStyle = GoogleFonts.inter(
      color: secondaryTextColor.withOpacity(0.8),
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
        prefixIcon:
            icon != null
                ? Icon(icon, color: secondaryTextColor, size: 20)
                : null,
        suffixIcon: suffixIcon,
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
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // --- Emoji / Icono ---
              Text(
                'Emoji o Ícono (Opcional)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emojiController,
                style: TextStyle(color: mainTextColor),
                // Limit to a single character
                maxLength: 1,
                inputFormatters: [LengthLimitingTextInputFormatter(1)],
                decoration: inputDecorationHelper(
                  hintText: '🍎',
                  icon: Icons.emoji_emotions_outlined,
                  hintStyle: hintTextStyle, // Pass the style
                  suffixIcon: IconButton(
                    icon: Icon(Icons.auto_awesome, color: primaryColor),
                    tooltip: 'Generar con IA',
                    onPressed: _showAIDialog,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Cantidad ---
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

              // --- Unidad --- (New Section)
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
                items:
                    _availableUnits
                        .map(
                          (String unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(
                              unit,
                              style: TextStyle(color: mainTextColor),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnitType = value;
                    // Reset quantity and update controller when unit changes
                    if (value != null) {
                      _quantity = _getMinimumQuantity(value);
                      _updateQuantityController();
                    }
                  });
                },
                decoration: inputDecorationHelper(
                  hintText: 'Seleccionar unidad',
                  icon: Icons.straighten_outlined, // Ruler icon
                  hintStyle: hintTextStyle, // Pass the style
                ),
                validator:
                    (value) => value == null ? 'Selecciona una unidad' : null,
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                style: TextStyle(color: mainTextColor),
              ),
              const SizedBox(height: 20),

              // --- Fecha de Expiración ---
              Text(
                'Fecha de Expiración (Opcional)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                style: TextStyle(
                  color: mainTextColor,
                ), // Ensure display text color adapts
                onTap: () => _selectDate(context),
                decoration: inputDecorationHelper(
                  hintText:
                      _expirationDate == null
                          ? 'Seleccionar fecha'
                          : DateFormat('dd/MM/yyyy').format(_expirationDate!),
                  icon: Icons.calendar_today_outlined,
                  hintStyle: hintTextStyle, // Pass the style
                  suffixIcon:
                      _expirationDate != null
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 20,
                              color: secondaryTextColor, // Updated
                            ),
                            onPressed:
                                () => setState(() => _expirationDate = null),
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 20),

              // --- Tipo de Almacenamiento ---
              Text(
                'Tipo de Almacenamiento',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mainTextColor,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<StorageType>(
                value: _selectedStorageType,
                // Style the dropdown itself
                style: TextStyle(
                  color: mainTextColor,
                ), // Text style for selected item
                dropdownColor:
                    isDark
                        ? AppColors.darkSurface
                        : Colors.white, // Background of dropdown menu
                items:
                    StorageType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  type.icon,
                                  size: 20,
                                  color: secondaryTextColor,
                                ), // Updated
                                const SizedBox(width: 10),
                                Text(
                                  type.displayName,
                                  style: TextStyle(color: mainTextColor),
                                ), // Ensure item text adapts
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedStorageType = value),
                decoration: inputDecorationHelper(
                  hintText: 'Seleccionar almacenamiento',
                  icon: null, // Icon is inside items
                  hintStyle: hintTextStyle, // Pass the style
                ),
                validator:
                    (value) => value == null ? 'Selecciona un tipo' : null,
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
                icon: Icon(
                  Icons.save_outlined,
                  size: 20,
                  color: onPrimaryColor,
                ), // Updated icon color
                label: Text('Agregar al Inventario'),
                onPressed:
                    (_nameController.text.trim().isNotEmpty &&
                            _selectedStorageType != null &&
                            _selectedUnitType !=
                                null // Check unit type
                                )
                        ? _saveItem
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Updated
                  foregroundColor: onPrimaryColor, // Updated
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  disabledForegroundColor: onPrimaryColor.withOpacity(0.7),
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
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      // TODO: Add theme for DatePicker if needed
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = InventoryItem(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        image:
            _emojiController.text.trim().isEmpty
                ? '❓'
                : _emojiController.text.trim(),
        quantity: _quantity,
        unitType: _selectedUnitType!,
        expirationDate: _expirationDate,
        storageType: _selectedStorageType!,
        category: _selectedCategory,
        addedDate: DateTime.now(),
      );

      ref.read(inventoryProvider.notifier).addItems([newItem]);

      // Use theme-aware color for SnackBar
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final Color snackbarColor =
          isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItem.name} agregado al inventario'),
          backgroundColor: snackbarColor, // Updated
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // --- Dialog for AI Confirmation ---
  Future<void> _showAIDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Use theme colors for dialog
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color dialogBgColor =
            isDark ? AppColors.darkSurface : Colors.white;
        final Color primaryColor =
            isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        final Color textColor =
            isDark ? AppColors.darkMainText : AppColors.lightMainText;

        return AlertDialog(
          backgroundColor: dialogBgColor,
          title: Text('Generar con IA', style: TextStyle(color: textColor)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Deseas que la IA sugiera un emoji o icono para este alimento?',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
              child: const Text('Generar'),
              onPressed: () {
                // TODO: Implement AI emoji/icon generation logic
                print('AI Generation triggered!');
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Potentially update _emojiController.text here after generation
              },
            ),
          ],
        );
      },
    );
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

  void _updateQuantityController() {
    // Implementation of _updateQuantityController method
  }
}
