// Extensión para capitalizar strings
extension StringExtensionPlanner on String {
  String capitalizePlanner() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
