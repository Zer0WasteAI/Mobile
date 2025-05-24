import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:zer0_waste_ai/core/theme/app_colors.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

class CustomLoadingScreen extends ConsumerStatefulWidget {
  final String message;
  final String? subMessage;

  const CustomLoadingScreen({
    super.key,
    this.message = 'Cargando...',
    this.subMessage,
  });

  @override
  ConsumerState<CustomLoadingScreen> createState() =>
      _CustomLoadingScreenState();
}

class _CustomLoadingScreenState extends ConsumerState<CustomLoadingScreen> {
  // Evitar que Key se genere cada vez para prevenir conflictos
  static const Key _containerKey1 = Key('loadingContainer1');
  static const Key _containerKey2 = Key('loadingContainer2');
  static const Key _containerKey3 = Key('loadingContainer3');

  bool _hasNavigated = false;

  void _checkSyncronizationStatus() {
    // Escuchar cambios en las preferencias de usuario
    ref.listen<UserPreferencesState>(userPreferencesProvider, (previous, next) {
      // Si ya no está cargando, verificar hacia dónde navegar
      if (!next.isLoading) {
        _navigateBasedOnSyncStatus(next);
      }
    });

    // También verificar el estado inicial por si ya se completó la sincronización
    final userPreferences = ref.read(userPreferencesProvider);
    if (!userPreferences.isLoading) {
      _navigateBasedOnSyncStatus(userPreferences);
    }
  }

  void _navigateBasedOnSyncStatus(UserPreferencesState userPreferences) {
    // Para evitar el flash de allergy-selector, verificar AMBOS estados
    final authState = ref.read(authControllerProvider);
    final user = authState.value;

    if (_hasNavigated) return; // Evitar múltiples navegaciones

    if (user != null) {
      final firestoreCompleted = user.initialPreferencesCompleted;
      final memoryCompleted = userPreferences.hasCompletedPreferences;

      print('🔍 Loading: Verificando estado de sincronización');
      print('  - Firestore: $firestoreCompleted');
      print('  - Memoria: $memoryCompleted');

      // Si Firestore dice que SÍ tiene preferencias, confiar en eso para usuarios existentes
      if (firestoreCompleted) {
        print(
          '🚀 Loading: Usuario existente con preferencias - navegando a auth-transition',
        );
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/auth-transition?from=loading');
          }
        });
      } else {
        // Solo ir a allergy-selector si AMBOS estados confirman que no hay preferencias
        print(
          '🚀 Loading: Usuario sin preferencias - navegando a allergy-selector',
        );
        _hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/allergy-selector?from=loading');
          }
        });
      }
    } else {
      // Si no hay usuario, ir a login
      print('🚀 Loading: No hay usuario - navegando a login');
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login?from=loading');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = ref.watch(userPreferencesProvider);

    // Escuchar cambios y navegar cuando la sincronización termine usando el nuevo método
    ref.listen<UserPreferencesState>(userPreferencesProvider, (previous, next) {
      if (!next.isLoading) {
        _navigateBasedOnSyncStatus(next);
      }
    });

    // También verificar el estado actual
    if (!userPreferences.isLoading) {
      _navigateBasedOnSyncStatus(userPreferences);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use appropriate colors based on theme
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryColor =
        isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondaryColor =
        isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;
    final textColor =
        isDarkMode ? AppColors.darkMainText : AppColors.lightMainText;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              key: _containerKey1,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -30,
            child: Container(
              key: _containerKey2,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation container
                Container(
                  key: _containerKey3,
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/food-loading.json',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      frameRate: FrameRate.max,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Main message
                Text(
                  widget.message,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Sub message if provided
                if (widget.subMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      widget.subMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 32),

                // Animated progress indicator
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    backgroundColor: primaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
