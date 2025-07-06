import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Constructores de widgets para la pantalla de perfil
class ProfileWidgetBuilders {

  /// Construir estadística del perfil
  static Widget buildProfileStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// Construir header de sección
  static Widget buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Construir grid de preferencias
  static Widget buildPreferencesGrid(BuildContext context, WidgetRef ref) {
    // Get user preferences from the provider in build method scope
    final profileState = ref.watch(userProfileProvider);
    final userPrefs = profileState.user?.prefs ?? const UserPreferencesModel();

    // Define colors for each preference item
    final List<Color> iconColors = [
      const Color(0xFFFF9800), // Cooking level (orange)
      const Color(0xFF4CAF50), // Food types (green)
      const Color(0xFFF44336), // Allergies (red)
      const Color(0xFF9C27B0), // Special diets (purple)
    ];

    final List<Color> bgColors = [
      const Color(0xFFFFF3E0), // Light orange
      const Color(0xFFE8F5E9), // Light green
      const Color(0xFFFFEBEE), // Light red
      const Color(0xFFF3E5F5), // Light purple
    ];

    // Helper function to get cooking level display text
    String getCookingLevelText() {
      switch (userPrefs.cookingLevel) {
        case 'beginner':
          return 'Principiante';
        case 'intermediate':
          return 'Intermedio';
        case 'advanced':
          return 'Avanzado';
        default:
          return 'No definido';
      }
    }

    // Helper function to get food types summary
    String getFoodTypesText() {
      final count = userPrefs.preferredFoodTypes.length;
      if (count == 0) return 'No definido';
      if (count == 1) return userPrefs.preferredFoodTypes.first;
      return '$count seleccionad...';
    }

    // Helper function to get allergies summary
    String getAllergiesText() {
      // Priorizar allergyItems (datos complejos), luego allergies (datos simples)
      List<String> allergyNames = [];

      if (userPrefs.allergyItems.isNotEmpty) {
        // Usar datos complejos si están disponibles
        allergyNames =
            userPrefs.allergyItems
                .map((item) => item['name'] as String? ?? '')
                .where((name) => name.isNotEmpty)
                .toList();
      } else if (userPrefs.allergies.isNotEmpty) {
        // Fallback a datos simples
        allergyNames = userPrefs.allergies;
      }

      final count = allergyNames.length;
      if (count == 0) return 'Ninguna';
      if (count == 1) return allergyNames.first;
      return '$count seleccionad...';
    }

    // Helper function to get diets summary
    String getDietsText() {
      // Priorizar specialDietItems (datos complejos), luego specialDiets (datos simples)
      List<String> dietNames = [];

      if (userPrefs.specialDietItems.isNotEmpty) {
        // Usar datos complejos si están disponibles
        dietNames =
            userPrefs.specialDietItems
                .map((item) => item['name'] as String? ?? '')
                .where((name) => name.isNotEmpty)
                .toList();
      } else if (userPrefs.specialDiets.isNotEmpty) {
        // Fallback a datos simples
        dietNames = userPrefs.specialDiets;
      }

      final count = dietNames.length;
      if (count == 0) return 'Ninguna';
      if (count == 1) return dietNames.first;
      return '$count seleccionad...';
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        buildPreferenceGridItem(
          context,
          icon: Icons.restaurant_rounded,
          title: 'Nivel de co...',
          value: getCookingLevelText(),
          iconColor: iconColors[0],
          bgColor: bgColors[0],
          onTap: () => context.go('/cooking-level-selector?from=profile'),
        ),
        buildPreferenceGridItem(
          context,
          icon: Icons.restaurant_menu_rounded,
          title: 'Tipos de co...',
          value: getFoodTypesText(),
          iconColor: iconColors[1],
          bgColor: bgColors[1],
          onTap: () => context.go('/preferred-food-type?from=profile'),
        ),
        buildPreferenceGridItem(
          context,
          icon: Icons.no_food_rounded,
          title: 'Alergias',
          value: getAllergiesText(),
          iconColor: iconColors[2],
          bgColor: bgColors[2],
          onTap: () => context.go('/allergy-selector?from=profile'),
        ),
        buildPreferenceGridItem(
          context,
          icon: Icons.spa_rounded,
          title: 'Dietas esp...',
          value: getDietsText(),
          iconColor: iconColors[3],
          bgColor: bgColors[3],
          onTap: () => context.go('/special-diet-selector?from=profile'),
        ),
      ],
    );
  }

  /// Construir item del grid de preferencias
  static Widget buildPreferenceGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir tarjeta de impacto
  static Widget buildImpactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BFA5).withValues(alpha: 0.1),
            const Color(0xFF00BFA5).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFA5).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF00BFA5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tu impacto ambiental',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              buildImpactMetric(
                context,
                icon: Icons.delete_outline,
                value: '2.5 kg',
                label: 'Desperdicio\nevitado',
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              buildImpactMetric(
                context,
                icon: Icons.monetization_on_outlined,
                value: '\$25',
                label: 'Dinero\nahorrado',
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              buildImpactMetric(
                context,
                icon: Icons.local_florist_outlined,
                value: '12',
                label: 'Días\nsostenibles',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construir métrica de impacto
  static Widget buildImpactMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construir tarjeta de configuración
  static Widget buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          buildSettingsItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Configura tus alertas y recordatorios',
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          const Divider(height: 24),
          buildSettingsItem(
            context,
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Español',
            onTap: () {
              // Show language selector
            },
          ),
          const Divider(height: 24),
          buildSettingsItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: 'Claro',
            onTap: () {
              // Show theme selector
            },
          ),
        ],
      ),
    );
  }

  /// Construir tarjeta de información
  static Widget buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: 'Centro de ayuda',
            subtitle: 'Preguntas frecuentes y soporte',
            onTap: () {
              // Navigate to help center
            },
          ),
          const Divider(height: 24),
          buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Versión 1.0.0',
            onTap: () {
              // Show about dialog
            },
          ),
          const Divider(height: 24),
          buildSettingsItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidad',
            subtitle: 'Términos y condiciones',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          const Divider(height: 24),
          buildSettingsItem(
            context,
            icon: Icons.star_outline,
            title: 'Calificar app',
            subtitle: 'Ayúdanos a mejorar',
            onTap: () {
              // Open app store rating
            },
          ),
          const Divider(height: 24),
          buildSettingsItem(
            context,
            icon: Icons.share_outlined,
            title: 'Compartir app',
            subtitle: 'Recomienda a tus amigos',
            onTap: () {
              // Share app
            },
          ),
        ],
      ),
    );
  }

  /// Construir item de configuración
  static Widget buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir botón de cerrar sesión
  static Widget buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutConfirmDialog(context, ref);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Cerrar sesión',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Mostrar diálogo de confirmación de cierre de sesión
  static void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión? Tendrás que iniciar sesión nuevamente para acceder a tu cuenta.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Cerrando sesión...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                
                try {
                  // Perform actual logout
                  await ref.read(authControllerProvider.notifier).signOut();
                  
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  
                  // Navigation will be handled automatically by router
                  // when auth state changes to null
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al cerrar sesión. Intenta de nuevo.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}