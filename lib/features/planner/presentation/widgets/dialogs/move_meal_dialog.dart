import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zer0_waste_ai/features/planner/domain/models/meal_plan.dart';

class MoveMealDialog extends StatefulWidget {
  final MealPlan meal;
  final String currentDateKey;
  final DateTime currentDate;
  final Function(String fromDate, String toDate, MealPlan meal) onMoveMeal;

  const MoveMealDialog({
    super.key,
    required this.meal,
    required this.currentDateKey,
    required this.currentDate,
    required this.onMoveMeal,
  });

  @override
  State<MoveMealDialog> createState() => _MoveMealDialogState();
}

class _MoveMealDialogState extends State<MoveMealDialog> {
  late DateTime _selectedDate;
  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    // Fechas para seleccionar (2 semanas)
    _availableDates = List.generate(
      14,
      (index) => widget.currentDate.add(Duration(days: index - 7)),
    );

    // Remover la fecha actual de las opciones
    _availableDates.removeWhere(
      (date) => DateFormat('yyyy-MM-dd').format(date) == widget.currentDateKey,
    );

    // Fecha seleccionada (por defecto mañana)
    _selectedDate = widget.currentDate.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Mover a otro día',
        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona una fecha:',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: _availableDates.length,
                itemBuilder: (context, index) {
                  final date = _availableDates[index];
                  final isSelected =
                      DateFormat('yyyy-MM-dd').format(date) ==
                      DateFormat('yyyy-MM-dd').format(_selectedDate);

                  return ListTile(
                    title: Text(
                      DateFormat('EEEE d MMMM', 'es_ES').format(date),
                      style: GoogleFonts.inter(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    leading: Radio<DateTime>(
                      value: date,
                      groupValue: _selectedDate,
                      activeColor: const Color(0xFF00BFA5),
                      onChanged: (value) {
                        setState(() {
                          _selectedDate = value!;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Formatear la fecha de destino
            final targetDateKey = DateFormat(
              'yyyy-MM-dd',
            ).format(_selectedDate);

            // Mover la comida
            widget.onMoveMeal(
              widget.currentDateKey,
              targetDateKey,
              widget.meal,
            );

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
          ),
          child: const Text('Mover'),
        ),
      ],
    );
  }

  // ignore: unused_element
  static void show(
    BuildContext context, {
    required MealPlan meal,
    required String currentDateKey,
    required DateTime currentDate,
    required Function(String fromDate, String toDate, MealPlan meal) onMoveMeal,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => MoveMealDialog(
            meal: meal,
            currentDateKey: currentDateKey,
            currentDate: currentDate,
            onMoveMeal: onMoveMeal,
          ),
    );
  }
}
