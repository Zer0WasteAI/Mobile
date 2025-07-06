import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Debug helper functions for development and troubleshooting
class DebugHelpers {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Manually set initialPreferencesCompleted to true for a specific user
  /// This is a debug/admin function to fix stuck preference completion flags
  static Future<void> forceCompleteUserPreferences(String userUid) async {
    try {
      log('🔧 DEBUG: Forcing completion of preferences for user: $userUid');
      
      await _firestore.collection('users').doc(userUid).update({
        'initialPreferencesCompleted': true,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'debugUpdatedAt': FieldValue.serverTimestamp(),
        'debugNote': 'Manually updated via debug helper',
      });
      
      log('✅ DEBUG: Successfully updated initialPreferencesCompleted to true');
    } catch (e) {
      log('❌ DEBUG: Error updating preferences completion: $e');
      throw Exception('Failed to force complete preferences: $e');
    }
  }

  /// Check if user preferences are actually complete based on data
  static bool arePreferencesComplete({
    String? cookingLevel,
    List<String>? allergies,
    List<String>? specialDiets,
    List<String>? preferredFoodTypes,
  }) {
    // Check if user has at least:
    // - A cooking level set
    // - At least one allergy, special diet, or preferred food type
    final hasCookingLevel = cookingLevel != null && cookingLevel.isNotEmpty;
    final hasAllergies = allergies != null && allergies.isNotEmpty;
    final hasSpecialDiets = specialDiets != null && specialDiets.isNotEmpty;
    final hasPreferredFoods = preferredFoodTypes != null && preferredFoodTypes.isNotEmpty;
    
    final hasAtLeastOnePreference = hasAllergies || hasSpecialDiets || hasPreferredFoods;
    
    log('🔍 DEBUG: Preference completion check:');
    log('  - cookingLevel: $cookingLevel (has: $hasCookingLevel)');
    log('  - allergies: $allergies (has: $hasAllergies)');
    log('  - specialDiets: $specialDiets (has: $hasSpecialDiets)');
    log('  - preferredFoodTypes: $preferredFoodTypes (has: $hasPreferredFoods)');
    log('  - hasAtLeastOnePreference: $hasAtLeastOnePreference');
    log('  - overall complete: ${hasCookingLevel && hasAtLeastOnePreference}');
    
    return hasCookingLevel && hasAtLeastOnePreference;
  }

  /// Auto-detect and fix incomplete preference flags
  static Future<void> autoFixPreferencesCompletion(String userUid) async {
    try {
      log('🔍 DEBUG: Auto-detecting preferences completion for user: $userUid');
      
      final userDoc = await _firestore.collection('users').doc(userUid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }
      
      final userData = userDoc.data()!;
      final currentFlag = userData['initialPreferencesCompleted'] as bool? ?? false;
      
      if (currentFlag) {
        log('✅ DEBUG: Preferences already marked as complete');
        return;
      }
      
      final isActuallyComplete = arePreferencesComplete(
        cookingLevel: userData['cookingLevel'] as String?,
        allergies: (userData['allergies'] as List<dynamic>?)?.cast<String>(),
        specialDiets: (userData['specialDiets'] as List<dynamic>?)?.cast<String>(),
        preferredFoodTypes: (userData['preferredFoodTypes'] as List<dynamic>?)?.cast<String>(),
      );
      
      if (isActuallyComplete) {
        log('🔧 DEBUG: Preferences are actually complete, fixing flag...');
        await forceCompleteUserPreferences(userUid);
      } else {
        log('⚠️ DEBUG: Preferences are genuinely incomplete');
      }
    } catch (e) {
      log('❌ DEBUG: Error in auto-fix: $e');
      throw Exception('Failed to auto-fix preferences: $e');
    }
  }

  /// Get detailed user preference status
  static Future<Map<String, dynamic>> getUserPreferenceStatus(String userUid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userUid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }
      
      final userData = userDoc.data()!;
      final cookingLevel = userData['cookingLevel'] as String?;
      final allergies = (userData['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
      final specialDiets = (userData['specialDiets'] as List<dynamic>?)?.cast<String>() ?? [];
      final preferredFoodTypes = (userData['preferredFoodTypes'] as List<dynamic>?)?.cast<String>() ?? [];
      final currentFlag = userData['initialPreferencesCompleted'] as bool? ?? false;
      
      final actuallyComplete = arePreferencesComplete(
        cookingLevel: cookingLevel,
        allergies: allergies,
        specialDiets: specialDiets,
        preferredFoodTypes: preferredFoodTypes,
      );
      
      return {
        'userUid': userUid,
        'currentFlag': currentFlag,
        'actuallyComplete': actuallyComplete,
        'needsFix': !currentFlag && actuallyComplete,
        'preferences': {
          'cookingLevel': cookingLevel,
          'allergies': allergies,
          'specialDiets': specialDiets,
          'preferredFoodTypes': preferredFoodTypes,
        },
      };
    } catch (e) {
      log('❌ DEBUG: Error getting preference status: $e');
      throw Exception('Failed to get preference status: $e');
    }
  }
}