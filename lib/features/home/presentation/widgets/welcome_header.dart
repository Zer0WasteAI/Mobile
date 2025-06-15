import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors based on theme
    final Color backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFFAF9F6);
    final Color textColor =
        isDark ? AppColors.darkMainText : const Color(0xFF3A3A3A);
    final Color secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : const Color(0xFF70605A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: authState.when(
          data: (user) {
            if (user == null) {
              return _buildLoadingState(textColor, secondaryTextColor);
            }

            final displayName = user.displayName ?? 'Usuario';
            final firstName = displayName.split(' ').first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Saludo personalizado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            firstName,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar del usuario
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDark
                                ? AppColors.darkPrimary.withValues(alpha: 0.2)
                                : AppColors.lightPrimary.withValues(alpha: 0.2),
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                          width: 2,
                        ),
                      ),
                      child:
                          user.photoURL != null
                              ? ClipOval(
                                child: Image.network(
                                  user.photoURL!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color:
                                          isDark
                                              ? AppColors.darkPrimary
                                              : AppColors.lightPrimary,
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                              : Icon(
                                Icons.person,
                                color:
                                    isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary,
                                size: 24,
                              ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Mensaje motivacional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.darkPrimary.withValues(alpha: 0.1)
                            : AppColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark
                              ? AppColors.darkPrimary.withValues(alpha: 0.3)
                              : AppColors.lightPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color:
                            isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Cada acción cuenta para un planeta más sostenible!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(textColor, secondaryTextColor),
          error: (error, stackTrace) => _buildErrorState(textColor),
        ),
      ),
    );
  }

  Widget _buildLoadingState(Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 28,
                    width: 120,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryTextColor.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: secondaryTextColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Error al cargar',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No se pudo cargar la información del usuario',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }
}
