import 'package:flutter/material.dart';

enum ExpirationStatus {
  all, // New state for showing all
  expired,
  expiringSoon,
  normal,
}

extension ExpirationStatusExtension on ExpirationStatus {
  String get displayName {
    switch (this) {
      case ExpirationStatus.all:
        return 'Todos';
      case ExpirationStatus.expired:
        return 'Vencido';
      case ExpirationStatus.expiringSoon:
        return 'Próximo a vencer';
      case ExpirationStatus.normal:
        return 'No vencido';
    }
  }

  IconData? get icon {
    // Make icon nullable for 'Todos'
    switch (this) {
      case ExpirationStatus.expired:
        return Icons.error_outline;
      case ExpirationStatus.expiringSoon:
        return Icons.warning_amber_outlined;
      case ExpirationStatus.normal:
        return Icons.check_circle_outline;
      case ExpirationStatus.all:
        return null; // No specific icon for 'Todos' tab
    }
  }

  // Optional helper to determine status from a date
  static ExpirationStatus fromDate(DateTime? date, {int daysThreshold = 3}) {
    if (date == null) return ExpirationStatus.normal;
    final now = DateTime.now();

    // Use date-only comparison to be consistent with UI indicators
    final today = DateUtils.dateOnly(now);
    final expiryDate = DateUtils.dateOnly(date);
    final differenceInDays = expiryDate.difference(today).inDays;

    if (differenceInDays < 0) return ExpirationStatus.expired;
    if (differenceInDays <= daysThreshold) {
      return ExpirationStatus.expiringSoon;
    }
    return ExpirationStatus.normal;
  }
}
