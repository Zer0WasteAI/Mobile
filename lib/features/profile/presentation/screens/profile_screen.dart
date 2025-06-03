// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';
import 'package:zer0_waste_ai/features/auth/data/models/user_preferences_model.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String routeName = 'profile';
  static const String routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    // Watch the user profile provider for backend data
    final profileState = ref.watch(userProfileProvider);
    final user = profileState.user;
    final isLoading = profileState.isLoading;
    final isBackendSynced = profileState.isBackendSynced;

    final userPrefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF00BFA5), // Solid teal color
            stretch: true,
            title: Text(
              'Mi Perfil',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Mostrar diálogo para editar perfil
                    _showEditProfileDialog(context);
                  },
                  tooltip: 'Editar perfil',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile picture
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child:
                              user?.photoURL != null &&
                                      user!.photoURL!.isNotEmpty
                                  ? Image.network(
                                    user.photoURL!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 50,
                                        color: const Color(0xFF00BFA5),
                                      );
                                    },
                                  )
                                  : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: const Color(0xFF00BFA5),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    // User info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Loading state
                          if (isLoading)
                            const Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Color(0xFF00BFA5),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Cargando perfil...'),
                              ],
                            )
                          else ...[
                            // User name and email
                            Text(
                              user?.displayName ?? 'Usuario',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user?.email ?? 'usuario@ejemplo.com',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildProfileStat(
                                  context,
                                  icon: Icons.star_rounded,
                                  value: '3',
                                  label: 'Logros',
                                  color: const Color(0xFFFFC107),
                                  bgColor: const Color(0xFFFFF8E1),
                                ),
                                _buildProfileStat(
                                  context,
                                  icon: Icons.local_fire_department_rounded,
                                  value: '5',
                                  label: 'Racha',
                                  color: const Color(0xFFFF5722),
                                  bgColor: const Color(0xFFFFF3F0),
                                ),
                                _buildProfileStat(
                                  context,
                                  icon: Icons.restaurant_rounded,
                                  value: '${user?.favoriteRecipes.length ?? 0}',
                                  label: 'Recetas',
                                  color: const Color(0xFF4CAF50),
                                  bgColor: const Color(0xFFE8F5E9),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'Preferencias culinarias'),
                    const SizedBox(height: 8),
                    _buildPreferencesGrid(context, ref),

                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'Tu impacto'),
                    const SizedBox(height: 8),
                    _buildImpactCard(context),

                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'Configuración'),
                    const SizedBox(height: 8),
                    _buildSettingsCard(context),

                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'Información y ayuda'),
                    const SizedBox(height: 8),
                    _buildInfoCard(context),

                    const SizedBox(height: 24),

                    _buildLogoutButton(context),
                    const SizedBox(height: 20),

                    // DEBUG: Botón para leer directamente de Firestore
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final profileState = ref.read(userProfileProvider);
                            final user = profileState.user;

                            print('🔧 CURRENT USER MODEL DEBUG:');
                            print('  User exists: ${user != null}');
                            if (user != null) {
                              print('  User ID: ${user.id}');
                              print('  Display Name: ${user.displayName}');
                              print('  Email: ${user.email}');
                              print(
                                '  🎯 INITIAL PREFERENCES COMPLETED: ${user.initialPreferencesCompleted}',
                              );
                              print('  Prefs exists: ${user.prefs != null}');

                              final prefs = user.prefs;
                              print(
                                '  Prefs cookingLevel: ${prefs.cookingLevel}',
                              );
                              print('  Prefs allergies: ${prefs.allergies}');
                              print(
                                '  Prefs allergyItems: ${prefs.allergyItems}',
                              );
                              print(
                                '  Prefs specialDiets: ${prefs.specialDiets}',
                              );
                              print(
                                '  Prefs specialDietItems: ${prefs.specialDietItems}',
                              );
                              print(
                                '  Prefs preferredFoodTypes: ${prefs.preferredFoodTypes}',
                              );

                              // También forzar un refresh
                              print('🔧 Forcing auth state refresh...');
                              ref.invalidate(authStateProvider);
                              await Future.delayed(
                                Duration(milliseconds: 1000),
                              );
                              ref.invalidate(userProfileProvider);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Debug completado - revisa logs'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          } catch (e) {
                            print('❌ Error en debug: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.info),
                        label: Text(
                          'DEBUG: Ver datos actuales',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DEBUG: Botón para marcar preferencias como completadas manualmente
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final authRepository = ref.read(
                              authRepositoryProvider,
                            );
                            final authController = ref.read(
                              authControllerProvider.notifier,
                            );

                            print(
                              '🔧 MANUAL: Marcando preferencias como completadas...',
                            );

                            await authRepository
                                .markInitialPreferencesCompleted();

                            print(
                              '✅ MANUAL: Preferencias marcadas correctamente',
                            );

                            // Refresh data
                            await authController.refreshUserFromFirestore();
                            ref.invalidate(userProfileProvider);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Preferencias marcadas como completadas',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            print('❌ Error marcando preferencias: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          'DEBUG: Marcar como completado',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildPreferencesGrid(BuildContext context, WidgetRef ref) {
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
      // DEBUG: Mostrar qué datos tenemos
      print('🔧 DEBUG allergies:');
      print('  allergies (simple): ${userPrefs.allergies}');
      print('  allergyItems (complex): ${userPrefs.allergyItems}');

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
      // DEBUG: Mostrar qué datos tenemos
      print('🔧 DEBUG special diets:');
      print('  specialDiets (simple): ${userPrefs.specialDiets}');
      print('  specialDietItems (complex): ${userPrefs.specialDietItems}');

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
        _buildPreferenceGridItem(
          context,
          icon: Icons.restaurant_rounded,
          title: 'Nivel de co...',
          value: getCookingLevelText(),
          iconColor: iconColors[0],
          bgColor: bgColors[0],
          onTap: () => context.push('/profile/cooking-level-selector'),
        ),
        _buildPreferenceGridItem(
          context,
          icon: Icons.restaurant_menu_rounded,
          title: 'Tipos de co...',
          value: getFoodTypesText(),
          iconColor: iconColors[1],
          bgColor: bgColors[1],
          onTap: () => context.push('/profile/preferred-food-type'),
        ),
        _buildPreferenceGridItem(
          context,
          icon: Icons.no_food_rounded,
          title: 'Alergias',
          value: getAllergiesText(),
          iconColor: iconColors[2],
          bgColor: bgColors[2],
          onTap: () => context.push('/profile/allergy-selector'),
        ),
        _buildPreferenceGridItem(
          context,
          icon: Icons.spa_rounded,
          title: 'Dietas esp...',
          value: getDietsText(),
          iconColor: iconColors[3],
          bgColor: bgColors[3],
          onTap: () => context.push('/profile/special-diet-selector'),
        ),
      ],
    );
  }

  Widget _buildPreferenceGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: GoogleFonts.inter(fontSize: 12, color: iconColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Color(0xFF4CAF50),
                      size: 24,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Metrics section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactMetric(
                context,
                icon: Icons.food_bank_outlined,
                value: '2.5kg',
                label: 'Alimentos salvados',
                color: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
              ),
              _buildImpactMetric(
                context,
                icon: Icons.water_drop_outlined,
                value: '350L',
                label: 'Agua ahorrada',
                color: const Color(0xFF2196F3),
                bgColor: const Color(0xFFE3F2FD),
              ),
              _buildImpactMetric(
                context,
                icon: Icons.cloud_outlined,
                value: '4.2kg',
                label: 'CO₂ reducido',
                color: const Color(0xFF9E9E9E),
                bgColor: const Color(0xFFF5F5F5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/notifications'),
          ),
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
          _buildSettingsItem(
            context,
            icon: Icons.language_rounded,
            title: 'Idioma',
            subtitle: 'Español',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/language'),
          ),
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
          _buildSettingsItem(
            context,
            icon: Icons.straighten_rounded,
            title: 'Unidades de medida',
            subtitle: 'Métricas',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/units'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Preguntas frecuentes',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/faqs'),
          ),
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidad',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/privacy-policy'),
          ),
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
          _buildSettingsItem(
            context,
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/terms-and-conditions'),
          ),
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Acerca de la app',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/about-app'),
          ),
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
          _buildSettingsItem(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Contacto y soporte',
            color: const Color(0xFF00BFA5),
            bgColor: const Color(0xFFE0F2F1),
            showChevron: true,
            onTap: () => context.push('/support'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required Color bgColor,
    required bool showChevron,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          // Redirigir al usuario a la pantalla de login
          context.go('/login');
        },
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          'Cerrar sesión',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE), // Light red background
          foregroundColor: const Color(0xFFE53935), // Red text and icon
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    // Controladores para los campos de texto
    final nameController = TextEditingController(text: 'Usuario');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Editar perfil',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Foto de perfil
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Mostrar opciones para cambiar foto
                        _showPhotoSourceOptions(context);
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE0F2F1),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF00BFA5),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo de nombre
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: GoogleFonts.inter(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF00BFA5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00BFA5),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Texto para cambiar contraseña
                TextButton(
                  onPressed: () {
                    // Cerrar el diálogo actual
                    Navigator.of(context).pop();

                    // Mostrar diálogo para cambiar contraseña
                    _showChangePasswordDialog(context);
                  },
                  child: Text(
                    'Cambiar contraseña',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF00BFA5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para guardar los cambios
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil actualizado correctamente'),
                    backgroundColor: Color(0xFF00BFA5),
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Guardar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    // Controladores para los campos de texto
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // Variable para ocultar/mostrar contraseñas
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    // Para seguimiento de la fortaleza de la contraseña
    double _passwordStrength = 0.0;
    String _passwordStrengthText = 'Débil';
    Color _passwordStrengthColor = Colors.red;

    // Función para calcular la fortaleza de la contraseña
    void _calculatePasswordStrength(String password) {
      double strength = 0;

      if (password.isEmpty) {
        strength = 0;
      } else {
        // Criterios básicos
        if (password.length >= 8) strength += 0.25;
        if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
        if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
        if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
          strength += 0.25;
        }
      }

      _passwordStrength = strength;

      if (strength <= 0.25) {
        _passwordStrengthText = 'Débil';
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 0.5) {
        _passwordStrengthText = 'Regular';
        _passwordStrengthColor = Colors.orange;
      } else if (strength <= 0.75) {
        _passwordStrengthText = 'Buena';
        _passwordStrengthColor = Colors.yellow.shade800;
      } else {
        _passwordStrengthText = 'Fuerte';
        _passwordStrengthColor = Colors.green;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF00BFA5),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cambiar contraseña',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu contraseña debe tener al menos 8 caracteres',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contraseña actual
                    Text(
                      'Contraseña actual',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        hintText: 'Ingresa tu contraseña actual',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF00BFA5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00BFA5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Agregar enlace de "¿Olvidaste tu contraseña?"
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Cerrar diálogo actual
                          Navigator.pop(context);
                          // Mostrar flujo de recuperación de contraseña
                          _showForgotPasswordFlow(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF00BFA5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Divisor con texto
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Nueva contraseña',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nueva contraseña
                    TextField(
                      controller: newPasswordController,
                      obscureText: _obscureNewPassword,
                      onChanged: (value) {
                        setState(() {
                          _calculatePasswordStrength(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Crea una nueva contraseña',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF00BFA5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00BFA5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Indicador de fortaleza de contraseña
                    if (newPasswordController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: Colors.grey.shade200,
                              color: _passwordStrengthColor,
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _passwordStrengthText,
                            style: GoogleFonts.inter(
                              color: _passwordStrengthColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usa 8+ caracteres con letras, números y símbolos',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Confirmar contraseña
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirma tu nueva contraseña',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF00BFA5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00BFA5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Mostrar error si las contraseñas no coinciden
                    if (confirmPasswordController.text.isNotEmpty &&
                        newPasswordController.text.isNotEmpty &&
                        confirmPasswordController.text !=
                            newPasswordController.text) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Las contraseñas no coinciden',
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Verificar que las contraseñas coincidan
                    if (newPasswordController.text.isEmpty ||
                        currentPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, completa todos los campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las contraseñas no coinciden'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Aquí iría la lógica para cambiar la contraseña
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contraseña actualizada correctamente'),
                        backgroundColor: Color(0xFF00BFA5),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Actualizar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Agregar el nuevo método para el flujo de recuperación de contraseña
  void _showForgotPasswordFlow(BuildContext context) {
    // Para seguimiento del progreso
    int _currentStep = 0;
    // Para mostrar códigos enviados
    String? _verificationCode;
    // Controladores para los campos
    final emailController = TextEditingController(text: 'usuario@ejemplo.com');
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // Variables para ocultar/mostrar contraseñas
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Widget para el paso 1: Enviar código de verificación
            Widget _buildStep1() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Te enviaremos un código de verificación para confirmar tu identidad',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Email field (readonly - mostrado pero no editable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF00BFA5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'usuario@ejemplo.com',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Enviaremos instrucciones a esta dirección de email registrada',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            // Widget para el paso 2: Ingresar código de verificación
            Widget _buildStep2() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hemos enviado un código de verificación a tu email',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Simular que se muestra el código (para la demostración)
                  if (_verificationCode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF00BFA5),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Código de demostración: $_verificationCode',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF00BFA5),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Campo para ingresar el código
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Código de verificación',
                      hintText: 'Ingresa el código enviado a tu email',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.vpn_key_outlined,
                        color: Color(0xFF00BFA5),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00BFA5),
                          width: 1.5,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No recibiste el código?',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Simular reenvío de código
                          setState(() {
                            _verificationCode = _generateRandomCode();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código reenviado'),
                              backgroundColor: Color(0xFF00BFA5),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Reenviar código',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF00BFA5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Widget para el paso 3: Establecer nueva contraseña
            Widget _buildStep3() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Establece tu nueva contraseña',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Nueva contraseña
                  Text(
                    'Nueva contraseña',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newPasswordController,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      hintText: 'Crea una nueva contraseña',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF00BFA5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00BFA5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Confirmar contraseña
                  Text(
                    'Confirmar contraseña',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirma tu nueva contraseña',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF00BFA5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00BFA5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Mostrar error si las contraseñas no coinciden
                  if (confirmPasswordController.text.isNotEmpty &&
                      newPasswordController.text.isNotEmpty &&
                      confirmPasswordController.text !=
                          newPasswordController.text) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Las contraseñas no coinciden',
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }

            // Contenido según el paso actual
            Widget _getStepContent() {
              switch (_currentStep) {
                case 0:
                  return _buildStep1();
                case 1:
                  return _buildStep2();
                case 2:
                  return _buildStep3();
                default:
                  return Container();
              }
            }

            // Determinar el botón según el paso actual
            Widget _getStepButton() {
              switch (_currentStep) {
                case 0:
                  return ElevatedButton(
                    onPressed: () {
                      // Simular envío de código
                      setState(() {
                        _currentStep = 1;
                        _verificationCode = _generateRandomCode();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Enviar código',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  );
                case 1:
                  return ElevatedButton(
                    onPressed: () {
                      // Validar código
                      if (codeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, ingresa el código'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Simulación de verificación
                      // En producción, aquí se validaría contra el backend
                      if (codeController.text == _verificationCode) {
                        setState(() {
                          _currentStep = 2;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código incorrecto'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Verificar código',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  );
                case 2:
                  return ElevatedButton(
                    onPressed: () {
                      // Validar contraseñas
                      if (newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, completa todos los campos',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Las contraseñas no coinciden'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Simular cambio de contraseña exitoso
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Contraseña restablecida correctamente',
                          ),
                          backgroundColor: Color(0xFF00BFA5),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Guardar nueva contraseña',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  );
                default:
                  return Container();
              }
            }

            // Obtener el título según el paso actual
            String _getStepTitle() {
              switch (_currentStep) {
                case 0:
                  return 'Recuperar contraseña';
                case 1:
                  return 'Verificar código';
                case 2:
                  return 'Nueva contraseña';
                default:
                  return '';
              }
            }

            // Obtener icono según el paso actual
            IconData _getStepIcon() {
              switch (_currentStep) {
                case 0:
                  return Icons.mail_outline;
                case 1:
                  return Icons.security;
                case 2:
                  return Icons.lock_outline;
                default:
                  return Icons.error_outline;
              }
            }

            // Construir los indicadores de pasos
            Widget _buildStepIndicators() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepDot(0, _currentStep >= 0),
                  _buildStepLine(_currentStep >= 1),
                  _buildStepDot(1, _currentStep >= 1),
                  _buildStepLine(_currentStep >= 2),
                  _buildStepDot(2, _currentStep >= 2),
                ],
              );
            }

            // Construir el diálogo
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.all(16),
              title: Column(
                children: [
                  // Indicadores de pasos
                  _buildStepIndicators(),
                  const SizedBox(height: 16),

                  // Icono del paso actual
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStepIcon(),
                      color: const Color(0xFF00BFA5),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título del paso actual
                  Text(
                    _getStepTitle(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              content: _getStepContent(),
              actions: [
                // Botón para cancelar
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Botón dinámico según el paso
                _getStepButton(),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actionsAlignment: MainAxisAlignment.spaceBetween,
            );
          },
        );
      },
    );
  }

  // Método auxiliar para generar un indicador de paso
  Widget _buildStepDot(int step, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00BFA5) : Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? const Color(0xFF00BFA5) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: GoogleFonts.inter(
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Método auxiliar para generar una línea entre pasos
  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? const Color(0xFF00BFA5) : Colors.grey.shade200,
    );
  }

  // Método auxiliar para generar un código aleatorio
  String _generateRandomCode() {
    // En un entorno real, este código se generaría en el backend
    return (10000 + (DateTime.now().millisecondsSinceEpoch % 90000)).toString();
  }

  // Agregar este nuevo método para mostrar las opciones de cambio de foto
  void _showPhotoSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar foto de perfil',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF00BFA5),
                    size: 24,
                  ),
                ),
                title: Text(
                  'Tomar foto',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Usar la cámara para tomar una nueva foto',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                ),
                onTap: () {
                  // Cerrar el bottom sheet
                  Navigator.pop(context);

                  // Aquí iría la lógica para acceder a la cámara
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Accediendo a la cámara...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 70),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF00BFA5),
                    size: 24,
                  ),
                ),
                title: Text(
                  'Seleccionar de la galería',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Elegir una foto de tu galería',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                ),
                onTap: () {
                  // Cerrar el bottom sheet
                  Navigator.pop(context);

                  // Aquí iría la lógica para acceder a la galería
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Accediendo a la galería...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
