import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive box names
class HiveBoxes {
  /// Settings box name
  static const String settings = 'settingsBox';
  
  /// User box name
  static const String user = 'userBox';
}

/// Hive initialization service
class HiveService {
  /// Initialize Hive
  static Future<void> init() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters here if needed
      // Example: Hive.registerAdapter(UserAdapter());
      
      // Open boxes
      await Hive.openBox(HiveBoxes.settings);
      await Hive.openBox(HiveBoxes.user);
      
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }
}

/// Provider for settings box
final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box(HiveBoxes.settings);
});

/// Provider for user box
final userBoxProvider = Provider<Box>((ref) {
  return Hive.box(HiveBoxes.user);
});