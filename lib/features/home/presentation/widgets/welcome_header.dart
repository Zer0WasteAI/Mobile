import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/features/home/application/providers/home_providers.dart'; // Import provider
import 'package:zer0_waste_ai/core/theme/app_colors.dart'; // Import AppColors
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart'; // Import auth provider

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get colors from theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mainTextColor =
        isDark ? AppColors.darkMainText : AppColors.lightMainText;
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    // Get user data from authControllerProvider for more complete data
    final authState = ref.watch(authControllerProvider);
    final userName = authState.value?.displayName ?? 'Usuario';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar y texto a la izquierda
        Expanded(
          child: Row(
            children: [
              // Avatar más grande
              const UserAvatar(size: 52),
              const SizedBox(width: 16),
              // Mensaje de bienvenida
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName 👋',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¿Listo para salvar alimentos hoy?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: secondaryTextColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // EcoCoins a la derecha
        const EcoCoinBadge(),
      ],
    );
  }
}

class UserAvatar extends ConsumerWidget {
  final double size;

  const UserAvatar({super.key, this.size = 38});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final Color backgroundColor = primaryColor.withOpacity(0.15);
    final Color textColor = primaryColor;

    // Get user data from auth state
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final hasPhoto = user?.photoURL != null && user!.photoURL!.isNotEmpty;

    // Determine the display letter (first letter of display name or default)
    final String displayLetter =
        user?.displayName?.isNotEmpty == true
            ? user!.displayName![0].toUpperCase()
            : 'U';

    return GestureDetector(
      onTap: () {
        // Navegar al perfil
        context.go('/profile');
      },
      child: Stack(
        children: [
          // Avatar principal
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Hero(
              tag: 'user-avatar',
              child:
                  hasPhoto
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(user!.photoURL!),
                        backgroundColor: backgroundColor,
                      )
                      : CircleAvatar(
                        backgroundColor: backgroundColor,
                        child: Text(
                          displayLetter,
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: size * 0.45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
          ),
          // Badge pequeño que indique que es clicable
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.person, color: Colors.white, size: size * 0.2),
            ),
          ),
        ],
      ),
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

    return GestureDetector(
      onTap: () {
        // Navegar al perfil
        context.go('/profile');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/home/eco_coin.png',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 4),
            Text(
              '$coins',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
