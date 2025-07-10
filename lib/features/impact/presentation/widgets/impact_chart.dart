import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/impact/application/providers/impact_providers.dart';

/// Widget para mostrar un gráfico de impacto ambiental
class ImpactChart extends ConsumerWidget {
  const ImpactChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedRecipes = ref.watch(unifiedCompletedRecipesProvider);
    
    if (completedRecipes.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Gráfico de tendencia disponible\ncon más datos históricos',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Tomar las últimas 7 recetas para mostrar tendencia
    final recentRecipes = completedRecipes.take(7).toList();
    final maxScore = recentRecipes.isEmpty ? 100.0 : recentRecipes.map((r) => r['sustainabilityScore'] as double).reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxScore > 0 ? maxScore : 100.0;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendencia de Sostenibilidad',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: SustainabilityChartPainter(recentRecipes, normalizedMax),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
            const SizedBox(height: 8),
            if (recentRecipes.isNotEmpty)
              Text(
                'Últimas ${recentRecipes.length} recetas cocinadas',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SustainabilityChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> recipes;
  final double maxValue;

  SustainabilityChartPainter(this.recipes, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (recipes.isEmpty) return;

    // Paint for general use if needed in the future
    // final paint = Paint()
    //   ..strokeWidth = 3
    //   ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Dibujar grid horizontal
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (recipes.length == 1) {
      // Solo un punto
      final score = recipes[0]['sustainabilityScore'] as double;
      final normalizedY = size.height - (score / maxValue * size.height);
      final x = size.width / 2;
      
      pointPaint.color = _getScoreColor(score);
      canvas.drawCircle(Offset(x, normalizedY), 6, pointPaint);
      return;
    }

    // Dibujar línea de tendencia
    final path = Path();
    for (int i = 0; i < recipes.length; i++) {
      final score = recipes[i]['sustainabilityScore'] as double;
      final x = (size.width * i) / (recipes.length - 1);
      final y = size.height - (score / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, linePaint);

    // Dibujar puntos
    for (int i = 0; i < recipes.length; i++) {
      final score = recipes[i]['sustainabilityScore'] as double;
      final x = (size.width * i) / (recipes.length - 1);
      final y = size.height - (score / maxValue * size.height);
      
      pointPaint.color = _getScoreColor(score);
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
      
      // Círculo blanco interno
      pointPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF8BC34A);
    if (score >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
