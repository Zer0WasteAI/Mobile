import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Import AppColors

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Get colors from theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

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
                color: mainTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Listo para salvar alimentos hoy?',
              style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get colors from theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;

    final coins = ref.watch(ecoCoinsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
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
              color: mainTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
