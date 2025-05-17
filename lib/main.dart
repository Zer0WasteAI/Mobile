import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zer0_waste_ai/core/theme/theme.dart';
import 'package:zer0_waste_ai/injection_container.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependencies
  final container = await DependencyInjection.init();

  // Run app with ProviderScope
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// Main app widget
class MyApp extends ConsumerWidget {
  /// Constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
