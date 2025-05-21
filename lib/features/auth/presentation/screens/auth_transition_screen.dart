import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zer0_waste_ai/core/presentation/screens/custom_loading_screen.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/profile/presentation/screens/allergy_selector_screen.dart';

/// Pantalla de transición después del login mientras se verifican las preferencias del usuario
class AuthTransitionScreen extends ConsumerStatefulWidget {
  const AuthTransitionScreen({super.key});

  static const String routeName = 'auth_transition';
  static const String routePath = '/auth-transition';

  @override
  ConsumerState<AuthTransitionScreen> createState() =>
      _AuthTransitionScreenState();
}

class _AuthTransitionScreenState extends ConsumerState<AuthTransitionScreen>
    with SingleTickerProviderStateMixin {
  bool _hasCompletedCheck = false;
  String _nextRoute = '';
  late AnimationController _animationController;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animación para fade out suave
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Iniciar carga de preferencias de usuario apenas se monte el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPreferences();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    // Asegurar un tiempo mínimo de visualización para la animación
    // Aumentar el tiempo mínimo para evitar navegaciones rápidas que causen conflictos
    final minTimeCompleter = Future.delayed(const Duration(milliseconds: 2500));

    try {
      // Cargar preferencias del usuario usando el servicio dedicado
      final preferencesNotifier = ref.read(userPreferencesProvider.notifier);
      await preferencesNotifier.loadUserPreferences();

      // Esperar el tiempo mínimo para mostrar la animación
      await minTimeCompleter;

      if (!mounted) return;

      // Obtener el estado actualizado
      final preferences = ref.read(userPreferencesProvider);

      // Determinar la siguiente ruta basada en las preferencias
      final hasCompletedPreferences = preferences.hasCompletedPreferences;

      // Añadir un parámetro para indicar que venimos de auth_transition
      _nextRoute =
          hasCompletedPreferences
              ? '/home?from=auth_transition'
              : '${AllergySelectorScreen.routePath}?from=auth_transition';

      // Iniciar la transición de salida
      setState(() {
        _hasCompletedCheck = true;
      });

      // Pequeña pausa antes de iniciar animación
      await Future.delayed(const Duration(milliseconds: 300));

      // Iniciar la animación de fade out
      _animationController.forward();

      // Navegar después de que se complete la animación
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          print('Navegando desde AuthTransitionScreen a $_nextRoute');
          context.go(_nextRoute);
        }
      });
    } catch (e) {
      // En caso de error, manejar graciosamente
      print('Error al cargar preferencias: $e');

      // Esperar el tiempo mínimo incluso en caso de error
      await minTimeCompleter;

      if (!mounted) return;

      // Mostrar error pero continuar con navegación por defecto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar preferencias: $e'),
          backgroundColor: Colors.red,
        ),
      );

      // Usar home como ruta predeterminada en caso de error con parámetro
      setState(() {
        _hasCompletedCheck = true;
        _nextRoute = '/home?from=auth_transition_error';
      });

      // Iniciar la animación de salida después de una pequeña pausa
      await Future.delayed(const Duration(milliseconds: 300));
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _fadeOutAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeOutAnimation.value,
          child: Scaffold(
            backgroundColor: colorScheme.background,
            body: Stack(
              children: [
                // Círculos decorativos
                Positioned(
                  top: -150,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Contenido central
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animación de carga
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Mensaje principal
                      Text(
                        _hasCompletedCheck
                            ? '¡Listo para comenzar!'
                            : 'Preparando tu experiencia...',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Mensaje secundario
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _hasCompletedCheck
                              ? 'Abriendo tu Zer0 Waste AI'
                              : 'Cargando tus preferencias personalizadas',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
