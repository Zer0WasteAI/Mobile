class UrlEncodingHelper {
  /// Converts names with special characters to URL-safe format
  static String encodeItemName(String itemName) {
    return itemName
        .replaceAll('/', '_SLASH_') // Replace / with _SLASH_
        .trim();
  }

  /// Decodes names from URL-safe format (for displaying in UI)
  static String decodeItemName(String encodedName) {
    return encodedName
        .replaceAll('_SLASH_', '/') // Restore / from _SLASH_
        .trim();
  }

  /// Formats timestamp maintaining local time (critical for backend compatibility)
  static String formatTimestamp(DateTime dateTime) {
    // IMPORTANT: DO NOT use toUtc() - maintain local time
    String isoString = dateTime.toIso8601String();

    // Remove any existing Z suffix to avoid double-Z
    if (isoString.endsWith('Z')) {
      isoString = isoString.substring(0, isoString.length - 1);
    }

    // Ensure it has milliseconds (.000)
    if (!isoString.contains('.')) {
      isoString += '.000';
    }

    // Add Z suffix (but keep local time)
    return '${isoString}Z';
  }

  /// Validates that the timestamp has the correct format
  static bool isValidLocalTimestamp(String timestamp) {
    // Verify it's not an unwanted UTC conversion
    if (timestamp.contains('T') && timestamp.endsWith('Z')) {
      return true;
    }
    return false;
  }

  /// Debug helper to log encoding transformations
  static void debugEncoding(String originalName) {
    if (originalName.contains('/')) {
      print(
        '⚠️  WARNING: Ingredient name contains "/" - will be encoded to "_SLASH_"',
      );
      print('   Original: "$originalName"');
      print('   Encoded: "${encodeItemName(originalName)}"');
    }
  }
}
