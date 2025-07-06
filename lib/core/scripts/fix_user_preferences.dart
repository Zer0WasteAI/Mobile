// Command line script to manually fix a user's preferences completion flag
// Run with: dart run lib/core/scripts/fix_user_preferences.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to manually fix the initialPreferencesCompleted flag for a specific user
void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    final firestore = FirebaseFirestore.instance;
    
    // The specific user UID mentioned in the issue
    const userUid = "OQ7TFsYpxAZBfNyLsloVJXImyRm1";
    
    log('🔍 Checking user preferences for UID: $userUid');
    
    // Get current user data
    final userDoc = await firestore.collection('users').doc(userUid).get();
    
    if (!userDoc.exists) {
      log('❌ User document not found');
      return;
    }
    
    final userData = userDoc.data()!;
    
    // Log current state
    log('📊 Current user data:');
    log('  - cookingLevel: ${userData['cookingLevel']}');
    log('  - allergies: ${userData['allergies']}');
    log('  - specialDiets: ${userData['specialDiets']}');
    log('  - preferredFoodTypes: ${userData['preferredFoodTypes']}');
    log('  - initialPreferencesCompleted: ${userData['initialPreferencesCompleted']}');
    
    // Check if preferences are complete
    final cookingLevel = userData['cookingLevel'] as String?;
    final allergies = (userData['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
    final specialDiets = (userData['specialDiets'] as List<dynamic>?)?.cast<String>() ?? [];
    final preferredFoodTypes = (userData['preferredFoodTypes'] as List<dynamic>?)?.cast<String>() ?? [];
    final currentFlag = userData['initialPreferencesCompleted'] as bool? ?? false;
    
    final hasCookingLevel = cookingLevel != null && cookingLevel.isNotEmpty;
    final hasAnyPreferences = allergies.isNotEmpty || specialDiets.isNotEmpty || preferredFoodTypes.isNotEmpty;
    final isActuallyComplete = hasCookingLevel && hasAnyPreferences;
    
    log('🔍 Analysis:');
    log('  - Has cooking level: $hasCookingLevel');
    log('  - Has any preferences: $hasAnyPreferences');
    log('  - Is actually complete: $isActuallyComplete');
    log('  - Current flag: $currentFlag');
    log('  - Needs fix: ${isActuallyComplete && !currentFlag}');
    
    if (isActuallyComplete && !currentFlag) {
      log('🔧 Fixing preferences completion flag...');
      
      await firestore.collection('users').doc(userUid).update({
        'initialPreferencesCompleted': true,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'fixedByScript': true,
        'fixedAt': FieldValue.serverTimestamp(),
      });
      
      log('✅ Successfully updated initialPreferencesCompleted to true');
      
      // Verify the update
      final updatedDoc = await firestore.collection('users').doc(userUid).get();
      final updatedData = updatedDoc.data()!;
      log('✅ Verification: initialPreferencesCompleted = ${updatedData['initialPreferencesCompleted']}');
      
    } else if (currentFlag) {
      log('ℹ️ Preferences are already marked as complete - no action needed');
    } else {
      log('⚠️ Preferences are genuinely incomplete - manual user action required');
    }
    
  } catch (e) {
    log('❌ Error: $e');
  }
}