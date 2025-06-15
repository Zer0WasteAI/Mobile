import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';

/// Dialog for marking ingredients as consumed with consumption details
class MarkConsumedDialog extends ConsumerStatefulWidget {
  final InventoryItem item;

  const MarkConsumedDialog({super.key, required this.item});

  @override
  ConsumerState<MarkConsumedDialog> createState() => _MarkConsumedDialogState();
}

class _MarkConsumedDialogState extends ConsumerState<MarkConsumedDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _recipeController = TextEditingController();

  double _consumedQuantity = 1.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with minimum quantity
    final notifier = ref.read(inventoryRealProvider.notifier);
    _consumedQuantity = notifier.getMinimumQuantity(widget.item.unitType);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _recipeController.dispose();
    super.dispose();
  }

  double get _maxQuantity => widget.item.quantity;
  double get _minQuantity {
    final notifier = ref.read(inventoryRealProvider.notifier);
    return notifier.getMinimumQuantity(widget.item.unitType);
  }

  double get _step {
    final notifier = ref.read(inventoryRealProvider.notifier);
    return notifier.getQuantityStep(widget.item.unitType);
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    } else {
      return quantity.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor =
        isDark ? AppColors.darkPrimary : const Color(0xFF00B894);
    final backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);
    final inputFillColor =
        isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      elevation: 8,
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Icon(Icons.restaurant, size: 48, color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Marcar como Consumido',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Disponible: ${_formatQuantity(widget.item.quantity)} ${widget.item.unitType}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quantity selector
              Text(
                'Cantidad Consumida',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Decrement button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          bottomLeft: Radius.circular(16.0),
                        ),
                        onTap: () {
                          setState(() {
                            _consumedQuantity = (_consumedQuantity - _step)
                                .clamp(_minQuantity, _maxQuantity);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          child: Icon(
                            Icons.remove_circle,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    // Vertical divider
                    Container(
                      height: 30,
                      width: 1,
                      color: primaryColor.withValues(alpha: 0.2),
                    ),

                    // Quantity display
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          '${_formatQuantity(_consumedQuantity)} ${widget.item.unitType}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Vertical divider
                    Container(
                      height: 30,
                      width: 1,
                      color: primaryColor.withValues(alpha: 0.2),
                    ),

                    // Increment button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                        onTap: () {
                          setState(() {
                            _consumedQuantity = (_consumedQuantity + _step)
                                .clamp(_minQuantity, _maxQuantity);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          child: Icon(
                            Icons.add_circle,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Consumption reason
              Text(
                'Motivo del Consumo (Opcional)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'Ej: Preparé ensalada, Snack, etc.',
                  hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                style: GoogleFonts.inter(color: textColor),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Recipe used
              Text(
                'Receta Utilizada (Opcional)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _recipeController,
                decoration: InputDecoration(
                  hintText: 'Ej: Ensalada César, Pasta con tomate, etc.',
                  hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                style: GoogleFonts.inter(color: textColor),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _markAsConsumed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Marcar Consumido',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsConsumed() async {
    if (_consumedQuantity <= 0 || _consumedQuantity > _maxQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cantidad inválida. Debe estar entre ${_formatQuantity(_minQuantity)} y ${_formatQuantity(_maxQuantity)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(inventoryRealProvider.notifier)
          .markIngredientAsConsumed(
            widget.item.id,
            consumedQuantity: _consumedQuantity,
            consumptionReason:
                _reasonController.text.trim().isEmpty
                    ? null
                    : _reasonController.text.trim(),
            recipeUsed:
                _recipeController.text.trim().isEmpty
                    ? null
                    : _recipeController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.item.name} marcado como consumido: ${_formatQuantity(_consumedQuantity)} ${widget.item.unitType}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar como consumido: ${e.toString()}'),
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

/// Helper function to show the mark consumed dialog
Future<void> showMarkConsumedDialog(BuildContext context, InventoryItem item) {
  return showDialog<void>(
    context: context,
    builder: (context) => MarkConsumedDialog(item: item),
  );
}
