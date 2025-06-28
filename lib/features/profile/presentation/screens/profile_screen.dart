// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/profile/application/providers/user_profile_provider.dart';
import 'package:zer0_waste_ai/features/profile/presentation/widgets/profile_dialog_manager.dart';
import 'package:zer0_waste_ai/features/profile/presentation/widgets/profile_widget_builders.dart';

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
                    ProfileDialogManager.showEditProfileDialog(context);
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
                                ProfileWidgetBuilders.buildProfileStat(
                                  context,
                                  icon: Icons.star_rounded,
                                  value: '3',
                                  label: 'Logros',
                                  color: const Color(0xFFFFC107),
                                  bgColor: const Color(0xFFFFF8E1),
                                ),
                                ProfileWidgetBuilders.buildProfileStat(
                                  context,
                                  icon: Icons.local_fire_department_rounded,
                                  value: '5',
                                  label: 'Racha',
                                  color: const Color(0xFFFF5722),
                                  bgColor: const Color(0xFFFFF3F0),
                                ),
                                ProfileWidgetBuilders.buildProfileStat(
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

                    ProfileWidgetBuilders.buildSectionHeader(context, 'Preferencias culinarias'),
                    const SizedBox(height: 8),
                    ProfileWidgetBuilders.buildPreferencesGrid(context, ref),

                    const SizedBox(height: 24),

                    ProfileWidgetBuilders.buildSectionHeader(context, 'Tu impacto'),
                    const SizedBox(height: 8),
                    ProfileWidgetBuilders.buildImpactCard(context),

                    const SizedBox(height: 24),

                    ProfileWidgetBuilders.buildSectionHeader(context, 'Configuración'),
                    const SizedBox(height: 8),
                    ProfileWidgetBuilders.buildSettingsCard(context),

                    const SizedBox(height: 24),

                    ProfileWidgetBuilders.buildSectionHeader(context, 'Información y ayuda'),
                    const SizedBox(height: 8),
                    ProfileWidgetBuilders.buildInfoCard(context),

                    const SizedBox(height: 24),

                    ProfileWidgetBuilders.buildLogoutButton(context, ref),
                    const SizedBox(height: 20),

                    // DEBUG: Botón para leer directamente de Firestore
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final profileState = ref.read(userProfileProvider);
                            print('🔥 DEBUG: Leyendo datos desde Firestore...');
                            print('📊 Profile state: $profileState');
                            print('👤 User: ${profileState.user}');
                            print('🔄 Is loading: ${profileState.isLoading}');
                            print('💾 Is backend synced: ${profileState.isBackendSynced}');

                            // Forzar refetch desde Firestore
                            // await ref.read(userProfileProvider.notifier).refreshFromFirestore();
                            print('✅ Refresh completed');
                          } catch (e) {
                            print('❌ Error durante refresh: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(
                          'DEBUG: Refrescar desde Firestore',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
}