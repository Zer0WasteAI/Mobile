import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:flutter/services.dart'; // Import for InputFormatters
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_state.dart'; // Importar para InventorySortCriteria
import 'package:zer0_waste_ai/features/inventory/domain/enums/item_category.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/storage_type.dart';
import 'package:zer0_waste_ai/features/inventory/domain/enums/expiration_status.dart'; // Importar ExpirationStatus
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/dialog_helper.dart';
import 'package:zer0_waste_ai/core/presentation/widgets/app_dialog.dart';

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

  // Lista de emojis de comida predefinidos
  final List<String> _foodEmojis = [
    '🍎',
    '🍐',
    '🍊',
    '🍋',
    '🍌',
    '🍉',
    '🍇',
    '🍓',
    '🫐',
    '🍈',
    '🍒',
    '🍑',
    '🥭',
    '🍍',
    '🥥',
    '🥝',
    '🍅',
    '🥑',
    '🥦',
    '🥬',
    '🥒',
    '🌶️',
    '🌽',
    '🥕',
    '🧅',
    '🧄',
    '🥔',
    '🍠',
    '🥐',
    '🥯',
    '🍞',
    '🥖',
    '🥨',
    '🧀',
    '🥚',
    '🍳',
    '🧈',
    '🥞',
    '🧇',
    '🥓',
    '🍔',
    '🍟',
    '🍕',
    '🌭',
    '🥪',
    '🌮',
    '🌯',
    '🥙',
    '🧆',
    '🥘',
    '🍲',
    '🥣',
    '🥗',
    '🍿',
    '🧈',
    '🧂',
    '🥫',
    '🍱',
    '🍘',
    '🍙',
    '🍚',
    '🍛',
    '🍜',
    '🍝',
    '🍣',
    '🍤',
    '🍥',
    '🥮',
    '🍢',
    '🧁',
    '🍰',
    '🎂',
    '🍭',
    '🍬',
    '🍫',
    '🍪',
    '🥛',
    '☕',
    '🧃',
    '🥤',
  ];

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
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 22, // Emoji más grande
                ),
                decoration: inputDecorationHelper(
                  hintText:
                      _emojiController.text.isEmpty ? 'Seleccionar emoji' : '',
                  hintStyle: hintTextStyle,
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: primaryColor,
                    ),
                    tooltip: 'Seleccionar emoji',
                    onPressed: _showEmojiSelector,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.auto_awesome, color: primaryColor),
                    tooltip: 'Generar con IA',
                    onPressed: _showAIDialog,
                  ),
                ),
                textAlign: TextAlign.center,
                readOnly: true, // Deshabilitar entrada directa
                onTap:
                    _showEmojiSelector, // También muestra el selector al hacer clic en el campo
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
                  return null;
                },
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
                ),
                label: Text('Agregar al Inventario'),
                onPressed:
                    (_nameController.text.trim().isNotEmpty &&
                            _selectedStorageType != null &&
                            _selectedUnitType != null &&
                            _expirationDate != null)
                        ? _saveItem
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
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

  // Mostrar el selector de emojis
  void _showEmojiSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final availableHeight = MediaQuery.of(context).size.height * 0.7;
        return Dialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selecciona un emoji',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: availableHeight * 0.6,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemCount: _foodEmojis.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _emojiController.text = _foodEmojis[index];
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _foodEmojis[index],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      // Generar un ID único para el nuevo ítem
      final String newItemId = _uuid.v4();

      final newItem = InventoryItem(
        id: newItemId,
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

      // Añadir el nuevo ítem al inventario
      ref.read(inventoryProvider.notifier).addItems([newItem]);

      // Limpiar los filtros para asegurar que el elemento nuevo sea visible
      final inventoryNotifier = ref.read(inventoryProvider.notifier);
      inventoryNotifier.setSearchQuery(''); // Limpiar búsqueda
      inventoryNotifier.setCategoryFilter(
        ItemCategory.all,
      ); // Mostrar todas las categorías
      inventoryNotifier.setStorageFilter(
        {},
      ); // Limpiar filtros de almacenamiento
      inventoryNotifier.setExpirationStatusFilter(
        ExpirationStatus.all,
      ); // Mostrar todos los estados

      // Establecer ordenación por fecha de adición (descendente, para que los nuevos aparezcan primero)
      inventoryNotifier.setSortCriteria(InventorySortCriteria.addedDate);
      inventoryNotifier.setSortDirection(
        false,
      ); // false = descendente (más reciente primero)

      // Use theme-aware color for SnackBar
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      final Color snackbarColor =
          isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItem.name} agregado al inventario'),
          backgroundColor: snackbarColor,
        ),
      );

      // Salir de la pantalla y volver al inventario
      if (mounted) {
        print('Elemento añadido con ID: $newItemId');
        Navigator.of(context).pop();
      }
    }
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

  // --- Dialog for AI Confirmation ---
  Future<void> _showAIDialog() async {
    final bool confirmed = await DialogHelper.showConfirmation(
      context: context,
      title: 'Generar con IA',
      message: '¿Deseas que la IA sugiera un emoji o icono para este alimento?',
      confirmText: 'Generar',
      cancelText: 'Cancelar',
      icon: Icons.auto_awesome,
      iconColor: Theme.of(context).colorScheme.primary,
    );

    if (confirmed) {
      // TODO: Implementar generación de emoji/icono con IA
      print(
        'AI Generation triggered! Esta funcionalidad está pendiente de implementación.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Funcionalidad de IA pendiente de implementación.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
