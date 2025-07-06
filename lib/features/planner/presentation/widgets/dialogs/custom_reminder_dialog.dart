// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomReminderDialog extends StatefulWidget {
  final String? initialText;
  final Function(String) onAdd;

  const CustomReminderDialog({
    super.key,
    this.initialText,
    required this.onAdd,
  });

  @override
  State<CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<CustomReminderDialog> {
  late final TextEditingController _controller;
  late final TextEditingController _customTimeController;

  // Opciones para los tipos de recordatorios
  final List<Map<String, dynamic>> _reminderIcons = [
    {'icon': Icons.event_note, 'color': Colors.blue},
    {'icon': Icons.restaurant, 'color': Colors.orange},
    {'icon': Icons.shopping_basket, 'color': Colors.green},
    {'icon': Icons.water_drop, 'color': Colors.lightBlue},
    {'icon': Icons.kitchen, 'color': Colors.purple},
    {'icon': Icons.alarm, 'color': Colors.red},
  ];

  // Opciones de tiempo relativo
  final List<Map<String, dynamic>> _timeOptions = [
    {'value': 0, 'label': 'A la hora programada'},
    {'value': 15, 'label': '15 minutos antes'},
    {'value': 30, 'label': '30 minutos antes'},
    {'value': 60, 'label': '1 hora antes'},
    {'value': 180, 'label': '3 horas antes'},
    {'value': 360, 'label': '6 horas antes'},
    {'value': 1440, 'label': '1 día antes'},
    {'value': -1, 'label': 'Personalizado'},
  ];

  // Opciones para unidades de tiempo personalizadas
  final List<Map<String, String>> _timeUnits = [
    {'value': 'minutes', 'label': 'minutos'},
    {'value': 'hours', 'label': 'horas'},
  ];

  // Índices seleccionados
  final int _selectedIconIndex = 0;
  int _selectedTimeIndex = 2; // 30 minutos antes por defecto
  int _selectedTimeUnitIndex = 0; // minutos por defecto
  bool _isCustomTime = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _customTimeController = TextEditingController(text: '30');
  }

  @override
  void dispose() {
    _controller.dispose();
    _customTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildTimeSelector(),
              if (_isCustomTime) _buildCustomTimeSection(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.edit_notifications,
            color: Colors.amber.shade700,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.initialText != null
              ? 'Editar recordatorio'
              : 'Nuevo recordatorio',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Descripción del recordatorio',
        hintText: 'Ej. Preparar ingredientes para la comida',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.amber.shade700, width: 2),
        ),
        floatingLabelStyle: GoogleFonts.inter(color: Colors.amber.shade700),
        prefixIcon: const Icon(Icons.event_note),
        suffixIcon: IconButton(
          onPressed: () => _controller.clear(),
          icon: const Icon(Icons.clear),
          splashRadius: 20,
        ),
      ),
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      autofocus: true,
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuándo quieres recibir el recordatorio?',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _timeOptions.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final option = _timeOptions[index];
              final isSelected = index == _selectedTimeIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeIndex = index;
                    _isCustomTime = option['value'] == -1;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.amber.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.amber.shade700
                              : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isSelected ? Colors.amber.shade700 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTimeSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza el tiempo del recordatorio',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Campo para introducir el tiempo
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _customTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '30',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Selector de unidad de tiempo
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unidad',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      value: _selectedTimeUnitIndex,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          _timeUnits.asMap().entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                entry.value['label']!,
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeUnitIndex = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed:
              _controller.text.trim().isEmpty
                  ? null
                  : () {
                    String reminderText = _controller.text.trim();

                    // Agregar información del tiempo si no es "a la hora programada"
                    if (_selectedTimeIndex != 0) {
                      if (_isCustomTime) {
                        final amount = _customTimeController.text;
                        final unit =
                            _timeUnits[_selectedTimeUnitIndex]['label'];
                        reminderText += ' ($amount $unit antes)';
                      } else {
                        final timeOption = _timeOptions[_selectedTimeIndex];
                        reminderText += ' (${timeOption['label']})';
                      }
                    }

                    widget.onAdd(reminderText);
                    Navigator.pop(context);
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(widget.initialText != null ? 'Actualizar' : 'Agregar'),
        ),
      ],
    );
  }

  // ignore: unused_element
  static void show(
    BuildContext context, {
    String? initialText,
    required Function(String) onAdd,
  }) {
    showDialog(
      context: context,
      builder:
          (context) =>
              CustomReminderDialog(initialText: initialText, onAdd: onAdd),
    );
  }
}
