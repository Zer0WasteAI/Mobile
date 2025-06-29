import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zer0_waste_ai/core/services/inventory_service.dart';
import 'package:zer0_waste_ai/core/services/recipe_service.dart';
import 'package:zer0_waste_ai/core/services/user_profile_service.dart';
import 'package:zer0_waste_ai/core/services/meal_planning_service.dart';
import 'package:zer0_waste_ai/core/services/admin_service.dart';
import 'package:zer0_waste_ai/core/services/environmental_service.dart';
import 'package:zer0_waste_ai/core/services/image_management_service.dart';
import 'package:zer0_waste_ai/core/services/recognition_service.dart';
import 'package:zer0_waste_ai/features/auth/presentation/providers/auth_provider.dart';

/// Helper para configurar el manejo de sesiones expiradas en todos los servicios
class SessionExpiryHelper {
  /// Configura todos los servicios para manejar sesiones expiradas
  static void setupSessionExpiryHandling(ProviderContainer container) {
    log('🔧 Setting up session expiry handling for all services');
    
    void onSessionExpired(String message) {
      log('🚪 Session expired detected globally: $message');
      try {
        container.read(authControllerProvider.notifier).handleSessionExpired(message);
      } catch (e) {
        log('❌ Error handling session expiry: $e');
      }
    }
    
    // Configurar todos los servicios
    final services = [
      () {
        InventoryService.setSessionExpiredCallback(onSessionExpired);
        log('✅ InventoryService session expiry configured');
      },
      () {
        RecipeService.setSessionExpiredCallback(onSessionExpired);
        log('✅ RecipeService session expiry configured');
      },
      () {
        UserProfileService.setSessionExpiredCallback(onSessionExpired);
        log('✅ UserProfileService session expiry configured');
      },
      () {
        MealPlanningService.setSessionExpiredCallback(onSessionExpired);
        log('✅ MealPlanningService session expiry configured');
      },
      () {
        AdminService.setSessionExpiredCallback(onSessionExpired);
        log('✅ AdminService session expiry configured');
      },
      () {
        EnvironmentalService.setSessionExpiredCallback(onSessionExpired);
        log('✅ EnvironmentalService session expiry configured');
      },
      () {
        ImageManagementService.setSessionExpiredCallback(onSessionExpired);
        log('✅ ImageManagementService session expiry configured');
      },
      () {
        RecognitionService.setSessionExpiredCallback(onSessionExpired);
        log('✅ RecognitionService session expiry configured');
      },
    ];
    
    for (final setup in services) {
      try {
        setup();
      } catch (e) {
        log('⚠️ Could not configure service: $e');
      }
    }
    
    log('✅ Session expiry handling setup completed for ${services.length} services');
  }
}