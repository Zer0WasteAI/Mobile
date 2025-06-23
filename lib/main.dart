import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zer0_waste_ai/core/theme/theme.dart';
import 'package:zer0_waste_ai/features/auth/application/services/user_preferences_service.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:zer0_waste_ai/features/inventory/application/providers/inventory_provider.dart';
import 'package:zer0_waste_ai/injection_container.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependencies
  final container = await DependencyInjection.init();

  // Configurar callback global para invalidar providers después de actualizaciones de Firestore
  // AuthRepositoryImpl.setProviderRefreshCallback(() {
  //   print(
  //     '🔄 Callback global activado - refrescando preferencias desde Firestore para LOGIN',
  //   );

  //   // Para LOGIN: usar el método específico que SIEMPRE lee desde Firestore
  //   container
  //       .read(userPreferencesProvider.notifier)
  //       .loadUserPreferencesFromFirestore();
  // });

  // Run app with ProviderScope
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// Main app widget
class MyApp extends ConsumerStatefulWidget {
  /// Constructor
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Iniciar la carga de preferencias de usuario al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserPreferences();
    });
  }

  Future<void> _initializeUserPreferences() async {
    // Observar cambios de autenticación para cargar preferencias cuando cambie el usuario
    ref.listenManual(authStateProvider, (previous, next) {
      if (next.value != null) {
        // Si hay un usuario autenticado, cargar sus preferencias
        ref.read(userPreferencesProvider.notifier).loadUserPreferences();
        // 🚀 PROACTIVE: Load inventory immediately when user logs in
        _loadInventoryProactively();
      } else {
        // Si no hay usuario o se cerró sesión, resetear el estado
        ref.read(userPreferencesProvider.notifier).reset();
      }
    });

    // Verificar estado actual de autenticación para inicialización inicial
    final authState = ref.read(authStateProvider);
    if (authState.value != null) {
      // Si ya hay un usuario autenticado al inicio, cargar sus preferencias
      ref.read(userPreferencesProvider.notifier).loadUserPreferences();
      // 🚀 PROACTIVE: Load inventory immediately at app start
      _loadInventoryProactively();
    }
  }

  /// 🚀 Load inventory proactively in background for better UX
  void _loadInventoryProactively() {
    // Use Future.microtask to avoid blocking the UI thread
    Future.microtask(() async {
      try {
        log('🚀 Proactively loading inventory for better UX...');
        await ref.read(inventoryRealProvider.notifier).loadInventoryIfNeeded();
        log('✅ Proactive inventory loading completed');
      } catch (e) {
        log('⚠️ Proactive inventory loading failed (non-critical): $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the router from provider
    final router = ref.watch(AppProviders.router);

    // Get the theme mode from provider
    final themeMode = ref.watch(AppProviders.theme);

    return MaterialApp.router(
      title: 'zer0_waste_ai',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Use the router directly - observers are added during its creation
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
