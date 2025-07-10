import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget para mostrar un gráfico de impacto ambiental
class ImpactChart extends StatelessWidget {
  const ImpactChart({super.key});

  @override
  Widget build(BuildContext context) {
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
}
