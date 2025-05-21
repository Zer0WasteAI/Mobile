import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = 'profile';
  static const String routePath = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Forzar actualización completa de datos al construir la pantalla
    _refreshUserDataFromFirestore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Esto se llamará cuando la pantalla se active nuevamente después de navegar
    _refreshUserDataFromFirestore();
  }

  /// Método auxiliar para forzar la actualización de datos desde Firestore
  Future<void> _refreshUserDataFromFirestore() async {
    if (!mounted) return;

    setState(() {
      // Mostrar un indicador de carga si es necesario
    });

    try {
      // Primero actualizamos desde Firestore usando el método mejorado
      await ref
          .read(authControllerProvider.notifier)
          .refreshUserFromFirestore();

      // Pequeña pausa para asegurar que los datos se procesen completamente
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        // Forzar actualización de la UI
        setState(() {});

        // Debug de los datos actualizados
        final user = ref.read(authControllerProvider).value;
        print('DATOS ACTUALIZADOS:');
        print(' - cookingLevel: ${user?.cookingLevel}');
        print(' - preferredFoodTypes: ${user?.preferredFoodTypes}');
        print(' - allergies: ${user?.allergies}');
        print(' - specialDiets: ${user?.specialDiets}');
      }
    } catch (e) {
      print('Error al actualizar datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _ = theme.colorScheme;
    final _ = MediaQuery.of(context).size;

    // Obtener datos del usuario actual
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    // Valores predeterminados por si no hay usuario
    final String displayName = user?.displayName ?? 'Usuario';
    final String email = user?.email ?? 'usuario@ejemplo.com';
    final String? photoURL = user?.photoURL;
    final bool hasPhoto = photoURL != null && photoURL.isNotEmpty;

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
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Navigate to the Edit Profile screen
                    context.goNamed(EditProfileScreen.routeName);
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
                        child:
                            hasPhoto
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    photoURL,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildAvatarInitial(displayName);
                                    },
                                  ),
                                )
                                : _buildAvatarInitial(displayName),
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
                          Text(
                            displayName,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
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
                                value: '12',
                                label: 'Recetas',
                                color: const Color(0xFF4CAF50),
                                bgColor: const Color(0xFFE8F5E9),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'Preferencias culinarias'),
                    const SizedBox(height: 8),
                    _buildPreferencesGrid(context),

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

                    _buildLogoutButton(context, ref),
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
    final _ = theme.colorScheme;

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

  Widget _buildPreferencesGrid(BuildContext context) {
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

    // Obtener datos del usuario
    final user = ref.watch(authControllerProvider).value;

    // Debug information for user preferences
    print('User preferences debug in profile screen:');
    print(' - Allergies: ${user?.allergies?.length ?? 0} items');
    print(' - AllergyItems: ${user?.allergyItems?.length ?? 0} items');
    print(
      ' - Special Diets: ${user?.specialDiets?.length ?? 0} items: ${user?.specialDiets}',
    );
    print(
      ' - SpecialDietItems: ${user?.specialDietItems?.length ?? 0} items: ${user?.specialDietItems}',
    );
    print(
      ' - Preferred Food Types: ${user?.preferredFoodTypes?.length ?? 0} items',
    );
    print(
      ' - PreferredFoodTypeItems: ${user?.preferredFoodTypeItems?.length ?? 0} items',
    );

    // Valores para mostrar en las preferencias
    final String cookingLevelText = _getCookingLevelText(user?.cookingLevel);
    final String foodTypesText = _getFoodTypesText(user?.preferredFoodTypes);
    final String allergiesText = _getAllergiesText(user?.allergies);
    final String specialDietsText = _getSpecialDietsText(user?.specialDiets);

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
          value: cookingLevelText,
          iconColor: iconColors[0],
          bgColor: bgColors[0],
          onTap: () => context.push('/profile/cooking-level-selector'),
        ),
        _buildPreferenceGridItem(
          context,
          icon: Icons.restaurant_menu_rounded,
          title: 'Tipos de co...',
          value: foodTypesText,
          iconColor: iconColors[1],
          bgColor: bgColors[1],
          onTap: () => context.push('/profile/preferred-food-type'),
        ),
        _buildPreferenceGridItem(
          context,
          icon: Icons.no_food_rounded,
          title: 'Alergias',
          value: allergiesText,
          iconColor: iconColors[2],
          bgColor: bgColors[2],
          onTap: () => context.push('/profile/allergy-selector'),
        ),
        _buildPreferenceGridItem(
          context,
          icon: Icons.spa_rounded,
          title: 'Dietas esp...',
          value: specialDietsText,
          iconColor: iconColors[3],
          bgColor: bgColors[3],
          onTap: () => context.push('/profile/special-diet-selector'),
        ),
      ],
    );
  }

  // Función auxiliar para obtener el texto del nivel de cocina
  String _getCookingLevelText(String? cookingLevel) {
    if (cookingLevel == null || cookingLevel.isEmpty) {
      return 'No definido';
    }

    switch (cookingLevel.toLowerCase()) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return cookingLevel;
    }
  }

  // Función auxiliar para obtener el texto de tipos de comida
  String _getFoodTypesText(List<String>? foodTypes) {
    // First check the new preferredFoodTypeItems field from the user model
    final user = ref.watch(authControllerProvider).value;
    final foodTypeItems = user?.preferredFoodTypeItems;

    if (foodTypeItems != null && foodTypeItems.isNotEmpty) {
      if (foodTypeItems.length == 1) {
        // Get the name from the first item
        return foodTypeItems.first['name'] as String? ?? 'Comida';
      }
      return '${foodTypeItems.length} seleccionados';
    }

    // Fall back to legacy preferredFoodTypes field if needed
    if (foodTypes == null || foodTypes.isEmpty) {
      return 'No definido';
    }

    if (foodTypes.length == 1) {
      return foodTypes.first;
    }

    return '${foodTypes.length} seleccionados';
  }

  // Función auxiliar para obtener el texto de alergias
  String _getAllergiesText(List<String>? allergies) {
    // First check the new allergyItems field from the user model
    final user = ref.watch(authControllerProvider).value;
    final allergyItems = user?.allergyItems;

    if (allergyItems != null && allergyItems.isNotEmpty) {
      if (allergyItems.length == 1) {
        // Get the name from the first item
        return allergyItems.first['name'] as String? ?? 'Alergia';
      }
      return '${allergyItems.length} seleccionadas';
    }

    // Fall back to legacy allergies field if needed
    if (allergies == null || allergies.isEmpty) {
      return 'Ninguna';
    }

    if (allergies.length == 1) {
      return allergies.first;
    }

    return '${allergies.length} seleccionadas';
  }

  // Función auxiliar para obtener el texto de dietas especiales
  String _getSpecialDietsText(List<String>? diets) {
    // First check the new specialDietItems field from the user model
    final user = ref.watch(authControllerProvider).value;
    final dietItems = user?.specialDietItems;

    if (dietItems != null && dietItems.isNotEmpty) {
      if (dietItems.length == 1) {
        // Get the name from the first item
        return dietItems.first['name'] as String? ?? 'Dieta';
      }
      return '${dietItems.length} seleccionadas';
    }

    // Fall back to legacy specialDiets field if needed
    if (diets == null || diets.isEmpty) {
      return 'Ninguna';
    }

    if (diets.length == 1) {
      return diets.first;
    }

    return '${diets.length} seleccionadas';
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
    final user = ref.watch(authControllerProvider).value;
    // Get measurement unit to display
    final String measurementUnitDisplay =
        user?.measurementUnit == 'imperial' ? 'Imperiales' : 'Métricas';

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
            subtitle: measurementUnitDisplay,
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

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Mostrar un diálogo de confirmación
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                    style: GoogleFonts.inter(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancelar', style: GoogleFonts.inter()),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Cerrar sesión', style: GoogleFonts.inter()),
                    ),
                  ],
                ),
          );

          // Si el usuario confirma, cerrar la sesión
          if (result == true && context.mounted) {
            // IMPORTANTE: Usamos un widget de superposición opaco para prevenir interacciones
            // durante el cierre de sesión y evitar frames adicionales
            OverlayEntry overlayEntry = OverlayEntry(
              builder:
                  (context) => Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
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
                  ),
            );

            if (context.mounted) {
              // Mostrar overlay
              Overlay.of(context).insert(overlayEntry);
            }

            // Overlay tracking
            bool overlayRemoved = false;

            try {
              // Cerrar sesión (esto es asíncrono)
              await authController.signOut();

              // Pequeña pausa para asegurar que el estado se actualice completamente
              await Future.delayed(const Duration(milliseconds: 300));

              // Quitar overlay de forma segura
              if (!overlayRemoved) {
                try {
                  overlayEntry.remove();
                  overlayRemoved = true;
                } catch (overlayError) {
                  // Ignorar errores relacionados con el overlay
                  print('Error al quitar overlay: $overlayError');
                }
              }

              if (context.mounted) {
                // Usar replaceNamed en lugar de go para evitar el splash
                context.replace('/login');
              }
            } catch (e) {
              // En caso de error, quitar overlay si existe
              if (!overlayRemoved) {
                try {
                  overlayEntry.remove();
                  overlayRemoved = true;
                } catch (overlayError) {
                  // Ignorar errores relacionados con el overlay
                  print('Error al quitar overlay en catch: $overlayError');
                }
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cerrar sesión: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
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
    // Implementación simple del diálogo de edición de perfil
    showDialog(
      context: context,
      builder:
          (context) => Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Editar Perfil',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Esta funcionalidad estará disponible próximamente.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Entendido',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  // Método para construir avatar con la inicial del nombre
  Widget _buildAvatarInitial(String displayName) {
    // Obtener la primera letra del nombre o usar 'U' por defecto
    final String initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Center(
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00BFA5),
        ),
      ),
    );
  }
}
