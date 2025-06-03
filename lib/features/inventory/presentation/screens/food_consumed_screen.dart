import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';

class FoodConsumedScreen extends ConsumerStatefulWidget {
  final String foodName;
  final String foodEmoji;
  final double co2Saved;
  final int waterSaved;
  final int coinsEarned;

  const FoodConsumedScreen({
    super.key,
    required this.foodName,
    required this.foodEmoji,
    required this.co2Saved,
    required this.waterSaved,
    required this.coinsEarned,
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
  late Animation<double> _coinsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
    );

    _coinsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
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
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Define colors
    final Color backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final Color textColor =
        isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji y mensaje de felicitación con animación
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        Text(
                          widget.foodEmoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "¡Felicidades!",
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mensaje sobre desperdicios evitados con animación de fade
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Acabas de evitar desperdiciar ${widget.foodName}",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: textColor,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Estadísticas de impacto ambiental con animación
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(_statsAnimation),
                    child: FadeTransition(
                      opacity: _statsAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Tu impacto ambiental positivo:",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // CO2 ahorrado
                                Column(
                                  children: [
                                    Icon(
                                      Icons.cloud_outlined,
                                      size: 32,
                                      color: Colors.blue[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${widget.co2Saved} kg",
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      "CO₂",
                                      style: GoogleFonts.inter(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                // Agua ahorrada
                                Column(
                                  children: [
                                    Icon(
                                      Icons.water_drop_outlined,
                                      size: 32,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${widget.waterSaved} L",
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      "Agua",
                                      style: GoogleFonts.inter(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Monedas ganadas con animación
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_coinsAnimation),
                    child: FadeTransition(
                      opacity: _coinsAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/home/eco_coin.png',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "+${widget.coinsEarned}",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botones de acción
                  Row(
                    children: [
                      // Botón: Ver mi resumen de impacto
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navegar a la pantalla de resumen de impacto
                            // TODO: Implementar la navegación a la pantalla de resumen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Pantalla de resumen de impacto (por implementar)",
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bar_chart_outlined),
                          label: Text(
                            "Ver mi impacto",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor:
                                isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón: Explorar mi inventario
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Volver a la pantalla de inventario
                            Navigator.of(context).pop();
                            Navigator.of(
                              context,
                            ).pop(); // Doble pop para volver al inventario
                          },
                          icon: const Icon(Icons.home_outlined),
                          label: Text(
                            "Mi inventario",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Clase para animar monedas cayendo (para uso futuro)
class CoinPainter extends CustomPainter {
  final List<Coin> coins;

  CoinPainter(this.coins);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill;

    for (var coin in coins) {
      canvas.drawCircle(Offset(coin.x, coin.y), coin.size, paint);
    }
  }

  @override
  bool shouldRepaint(CoinPainter oldDelegate) => true;
}

class Coin {
  double x;
  double y;
  double size;
  double velocity;

  Coin({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
  });

  void update(double maxHeight) {
    y += velocity;
    if (y > maxHeight) {
      y = 0;
    }
  }
}
