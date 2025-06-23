import 'package:zer0_waste_ai/features/inventory/domain/models/inventory_item.dart';
import 'package:zer0_waste_ai/core/utils/url_encoding_helper.dart';

/// Extension for InventoryItem to handle URL encoding and timestamp formatting
extension InventoryItemExtension on InventoryItem {
  /// Get the safe name for URL encoding (handles special characters like "/")
  String get safeNameForUrl => UrlEncodingHelper.encodeItemName(name);
  
  /// Get the display name for UI (decodes special characters)
  String get displayName => UrlEncodingHelper.decodeItemName(name);
  
  /// Get the properly formatted timestamp for DELETE operations
  String get deleteTimestamp => UrlEncodingHelper.formatTimestamp(addedDate);
  
  /// Check if the item name contains special characters that need encoding
  bool get hasSpecialCharacters => name.contains('/');
} 