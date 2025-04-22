import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences instance
final sharedPrefsProvider = Provider<SharedPreferencesHelper>((ref) {
  throw UnimplementedError('SharedPreferencesHelper must be initialized first');
});

/// SharedPreferences initialization provider
final sharedPrefsInitProvider = FutureProvider<SharedPreferencesHelper>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SharedPreferencesHelper(prefs);
});

/// Helper class for SharedPreferences
class SharedPreferencesHelper {
  /// Constructor
  SharedPreferencesHelper(this._prefs);

  final SharedPreferences _prefs;

  /// Get a boolean value
  bool? getBool(String key) => _prefs.getBool(key);

  /// Set a boolean value
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Get a string value
  String? getString(String key) => _prefs.getString(key);

  /// Set a string value
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  /// Get an integer value
  int? getInt(String key) => _prefs.getInt(key);

  /// Set an integer value
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  /// Get a double value
  double? getDouble(String key) => _prefs.getDouble(key);

  /// Set a double value
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  /// Get a string list value
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  /// Set a string list value
  Future<bool> setStringList(String key, List<String> value) => 
      _prefs.setStringList(key, value);

  /// Check if a key exists
  bool containsKey(String key) => _prefs.containsKey(key);

  /// Remove a key
  Future<bool> remove(String key) => _prefs.remove(key);

  /// Clear all preferences
  Future<bool> clear() => _prefs.clear();

  /// Get all keys
  Set<String> getKeys() => _prefs.getKeys();
}