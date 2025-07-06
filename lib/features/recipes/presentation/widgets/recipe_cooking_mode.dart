import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeCookingMode extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onExit;
  final VoidCallback onComplete;

  const RecipeCookingMode({
    super.key,
    required this.recipe,
    required this.onExit,
    required this.onComplete,
  });

  @override
  State<RecipeCookingMode> createState() => _RecipeCookingModeState();
}

class _RecipeCookingModeState extends State<RecipeCookingMode> {
  late PageController _pageController;
  int _currentStep = 0;
  List<bool> _completedSteps = [];
  bool _timerActive = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    final steps = widget.recipe['steps'] as List<dynamic>;
    _completedSteps = List.generate(steps.length, (_) => false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : const Color(0xFFFAF9F6);
    final textColor = isDark ? Colors.white : const Color(0xFF3A3A3A);
    final primaryColor = isDark ? Colors.tealAccent : Colors.teal.shade700;

    final steps = widget.recipe['steps'] as List<dynamic>;
    final isLastStep = _currentStep == steps.length - 1;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('¿Salir del modo de cocción?'),
                    content: const Text('Tu progreso no se guardará.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onExit();
                        },
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
            );
          },
        ),
        title: Text(
          'Paso a paso',
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _timerActive ? Icons.timer : Icons.timer_outlined,
              color: _timerActive ? primaryColor : null,
            ),
            onPressed: () {
              setState(() {
                _timerActive = !_timerActive;
              });
              if (_timerActive) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Temporizador activado'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Paso ${_currentStep + 1} de ${steps.length}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ((_currentStep + 1) / steps.length),
                      minHeight: 8,
                      backgroundColor: primaryColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Steps PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildStepContent(
                  steps[index],
                  index,
                  textColor,
                  primaryColor,
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                _currentStep > 0
                    ? ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        foregroundColor: textColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                    : const SizedBox(width: 120), // Placeholder for alignment
                // Mark as completed/Next/Finish button
                ElevatedButton.icon(
                  icon: Icon(
                    isLastStep
                        ? Icons.check_circle_outline
                        : _completedSteps[_currentStep]
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    isLastStep
                        ? 'Finalizar'
                        : _completedSteps[_currentStep]
                        ? 'Siguiente'
                        : 'Completado',
                  ),
                  onPressed: () {
                    if (!_completedSteps[_currentStep]) {
                      setState(() {
                        _completedSteps[_currentStep] = true;
                      });

                      if (isLastStep) {
                        widget.onComplete();
                      }
                    } else if (!isLastStep) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onComplete();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    String step,
    int index,
    Color textColor,
    Color primaryColor,
  ) {
    final bool isCompleted = _completedSteps[index];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completado',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Step instruction
            Text(
              step,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: textColor,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Additional information or tips
            if (_hasCookingTip(step))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consejo',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCookingTip(step),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // If a timer would be useful for this step
            if (_hasTimerSuggestion(step))
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.timer),
                  label: Text(
                    'Iniciar temporizador: ${_getTimerDuration(step)}',
                  ),
                  onPressed: () {
                    setState(() {
                      _timerActive = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Temporizador iniciado: ${_getTimerDuration(step)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasCookingTip(String step) {
    // En un caso real, esto vendría de un campo específico en la receta
    // Para este ejemplo, creamos algunos consejos para ciertos pasos
    final stepLowerCase = step.toLowerCase();
    return stepLowerCase.contains('ajo') ||
        stepLowerCase.contains('cebolla') ||
        stepLowerCase.contains('pasta') ||
        stepLowerCase.contains('champiñones');
  }

  String _getCookingTip(String step) {
    final stepLowerCase = step.toLowerCase();
    if (stepLowerCase.contains('ajo')) {
      return 'Para intensificar el sabor del ajo, aplástalo ligeramente antes de picarlo y déjalo reposar 10 minutos.';
    } else if (stepLowerCase.contains('cebolla')) {
      return 'Para evitar llorar al picar cebolla, refrigérala antes de cortarla o usa un cuchillo bien afilado.';
    } else if (stepLowerCase.contains('pasta')) {
      return 'Para una pasta perfecta, asegúrate de que el agua esté hirviendo bien antes de añadirla y remueve durante los primeros minutos.';
    } else if (stepLowerCase.contains('champiñones')) {
      return 'No laves los champiñones bajo el grifo, simplemente límpialos con un paño húmedo para evitar que absorban agua.';
    }
    return '';
  }

  bool _hasTimerSuggestion(String step) {
    // Detectar si el paso menciona tiempos específicos
    return RegExp(r'\d+\s*(minutos?|min)').hasMatch(step);
  }

  String _getTimerDuration(String step) {
    // Extraer el tiempo mencionado en el paso
    final match = RegExp(r'(\d+)\s*(minutos?|min)').firstMatch(step);
    if (match != null) {
      return '${match.group(1)} min';
    }
    return '5 min'; // Valor por defecto
  }
}
