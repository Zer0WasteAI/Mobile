import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
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
  int _quantity = 1;
  DateTime? _expirationDate;
  StorageType? _selectedStorageType;
  ItemCategory _selectedCategory = ItemCategory.food; // Default to Food
  final _uuid = const Uuid();

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
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 5),
      ), // Limit to 5 years
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed to save
      final newItem = InventoryItem(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        image:
            _emojiController.text.trim().isEmpty
                ? '❓'
                : _emojiController.text.trim(), // Use emoji or default
        quantity: _quantity,
        expirationDate: _expirationDate,
        storageType:
            _selectedStorageType!, // Validation ensures this is not null
        category: _selectedCategory,
        addedDate: DateTime.now(),
      );

      ref.read(inventoryProvider.notifier).addItems([newItem]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItem.name} agregado al inventario'),
          backgroundColor: AppColors.lightPrimary, // Or use theme color
        ),
      );

      // Pop the screen after saving
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Colors
    const Color primaryColor = Color(0xFF00B894);
    const Color mainTextColor = Color(0xFF3A3A3A);
    const Color secondaryTextColor = Color(0xFF70605A);
    const Color screenBackgroundColor = Color(0xFFFAF9F6);
    const Color formFieldBackgroundColor = Colors.white;
    const Color disabledButtonColor = Colors.grey;

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Agregar Ítem Manualmente',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: mainTextColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: mainTextColor,
        ), // Back button color
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
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hintText: 'Ej: Manzanas Rojas',
                  icon: Icons.restaurant_menu_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                onChanged:
                    (value) => setState(
                      () {},
                    ), // Trigger rebuild to check button state
              ),
              const SizedBox(height: 20),

              // --- Emoji / Icono ---
              Text(
                'Emoji o Ícono (Opcional)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emojiController,
                maxLength: 2, // Limit to typical emoji length
                decoration: _inputDecoration(
                  hintText: '🍎',
                  icon: Icons.emoji_emotions_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // --- Cantidad ---
              Text(
                'Cantidad',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: primaryColor,
                    ),
                    iconSize: 30,
                    onPressed:
                        _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      '$_quantity',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: primaryColor,
                    ),
                    iconSize: 30,
                    onPressed:
                        _quantity <
                                999 // Limit quantity
                            ? () => setState(() => _quantity++)
                            : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Fecha de Expiración ---
              Text(
                'Fecha de Expiración (Opcional)',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: _inputDecoration(
                  hintText:
                      _expirationDate == null
                          ? 'Seleccionar fecha'
                          : DateFormat('dd/MM/yyyy').format(_expirationDate!),
                  icon: Icons.calendar_today_outlined,
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
                // No validator needed here as it's optional, but validation happens in _selectDate
              ),
              const SizedBox(height: 20),

              // --- Tipo de Almacenamiento ---
              Text(
                'Tipo de Almacenamiento',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<StorageType>(
                value: _selectedStorageType,
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
                                ),
                                const SizedBox(width: 10),
                                Text(type.displayName),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedStorageType = value),
                decoration: _inputDecoration(
                  hintText: 'Seleccionar almacenamiento',
                  icon: null, // Icon is inside items
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
                ),
              ),
              const SizedBox(height: 8),
              // Using ChoiceChips for Category
              Wrap(
                spacing: 8.0,
                children:
                    ItemCategory.values
                        .where(
                          (cat) => cat != ItemCategory.all,
                        ) // Exclude 'All' category
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
                                      ? Colors.white
                                      : secondaryTextColor,
                            ),
                            selectedColor: primaryColor,
                            backgroundColor: formFieldBackgroundColor,
                            labelStyle: TextStyle(
                              color:
                                  _selectedCategory == category
                                      ? Colors.white
                                      : secondaryTextColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color:
                                    _selectedCategory == category
                                        ? primaryColor
                                        : Colors.grey.shade300,
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
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Agregar al Inventario'),
                onPressed:
                    (_nameController.text.trim().isNotEmpty &&
                            _selectedStorageType != null)
                        ? _saveItem
                        : null, // Disable if name or storage type is missing
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  disabledForegroundColor: Colors.white70,
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

  // Helper for consistent InputDecoration
  InputDecoration _inputDecoration({
    String? hintText,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    const Color formFieldBackgroundColor = Colors.white;
    const Color secondaryTextColor = Color(0xFF70605A);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
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
          icon != null ? Icon(icon, color: secondaryTextColor, size: 20) : null,
      suffixIcon: suffixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
      ), // Or use theme color
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: secondaryTextColor.withOpacity(0.8)),
    );
  }
}
