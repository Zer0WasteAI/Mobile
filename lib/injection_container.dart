import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zer0_waste_ai/core/local_storage/hive_config.dart';
import 'package:zer0_waste_ai/core/local_storage/shared_prefs_helper.dart';
import 'package:zer0_waste_ai/core/navigation/app_router.dart';
import 'package:zer0_waste_ai/core/theme/theme.dart';

/// Initialize all dependencies
class DependencyInjection {
  /// Initialize all services
  static Future<ProviderContainer> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive
    await HiveService.init();
    
    // Initialize SharedPreferences
    final sharedPrefs = await SharedPreferences.getInstance();
    final sharedPrefsHelper = SharedPreferencesHelper(sharedPrefs);
    
    // Create ProviderContainer with overrides
    final container = ProviderContainer(
      overrides: [
        // Override the SharedPreferencesHelper provider
        sharedPrefsProvider.overrideWithValue(sharedPrefsHelper),
      ],
    );
    
    return container;
  }
}

/// Global providers
class AppProviders {
  /// Router provider
  static final router = routerProvider;
  
  /// Theme provider
  static final theme = themeProvider;
  
  /// Settings box provider
  static final settingsBox = settingsBoxProvider;
  
  /// User box provider
  static final userBox = userBoxProvider;
  
  /// SharedPreferences provider
  static final sharedPrefs = sharedPrefsProvider;
}