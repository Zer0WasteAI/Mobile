import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to expose the current navigation path (route)
final currentNavigationProvider = StateProvider<String>(
  (ref) => '/home',
); // Default to home

/// Provider to indicate if the Scan Options Modal is currently open
final isScanModalOpenProvider = StateProvider<bool>((ref) => false);

/// Provider to indicate if the "More" menu is currently open
final isMoreMenuOpenProvider = StateProvider<bool>((ref) => false);
