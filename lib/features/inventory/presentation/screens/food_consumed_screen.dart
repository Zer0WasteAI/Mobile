import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

class FoodConsumedScreen extends ConsumerStatefulWidget {
  final String foodName;
  final String foodEmoji;
  final double co2Saved;
  final int waterSaved;

  const FoodConsumedScreen({
    super.key,
    required this.foodName,
    required this.foodEmoji,
    required this.co2Saved,
    required this.waterSaved,
  });

  @override
  ConsumerState<FoodConsumedScreen> createState() => _FoodConsumedScreenState();
}

class _FoodConsumedScreenState extends ConsumerState<FoodConsumedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    );

    _statsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji animado
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  widget.foodEmoji,
                  style: const TextStyle(fontSize: 120),
                ),
              ),

              const SizedBox(height: 32),

              // Título principal
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  '¡Excelente!',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Has consumido ${widget.foodName}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 18, color: textColor),
                ),
              ),

              const SizedBox(height: 40),

              // Estadísticas de impacto
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_statsAnimation),
                child: FadeTransition(
                  opacity: _statsAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tu impacto ambiental',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // CO2 ahorrado
                        _buildImpactItem(
                          icon: Icons.cloud_off,
                          value: '${widget.co2Saved.toStringAsFixed(1)} kg',
                          label: 'CO₂ evitado',
                          color: Colors.blue,
                        ),

                        const SizedBox(height: 16),

                        // Agua ahorrada
                        _buildImpactItem(
                          icon: Icons.water_drop,
                          value: '${widget.waterSaved} L',
                          label: 'Agua ahorrada',
                          color: Colors.cyan,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Mensaje motivacional
              FadeTransition(
                opacity: _statsAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '¡Sigue así! Cada alimento que consumes antes de que expire ayuda al planeta.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón de continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
