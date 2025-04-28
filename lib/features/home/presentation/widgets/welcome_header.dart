import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  // Define colors locally for simplicity in this widget, or pass from parent
  static const Color _mainTextColor = Color(0xFF3A3A3A);
  static const Color _secondaryTextColor = Color(0xFF70605A);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, Rafael 👋', // Replace with actual user name later
              style: GoogleFonts.inter(
                fontSize: 22, // Adjust size as needed
                fontWeight: FontWeight.bold,
                color: _mainTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Listo para salvar alimentos hoy?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _secondaryTextColor,
              ),
            ),
          ],
        ),
        const EcoCoinBadge(),
      ],
    );
  }
}

class EcoCoinBadge extends ConsumerWidget {
  const EcoCoinBadge({super.key});

  // Define colors locally
  static const Color _primaryColor = Color(0xFF00B894);
  static const Color _mainTextColor = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(ecoCoinsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simple Coin Icon Placeholder
          Image.asset('assets/icons/home/eco_coin.png', width: 18, height: 18),
          const SizedBox(width: 6),
          Text(
            '$coins EcoCoins',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _mainTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
