import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExpirationFormatting on DateTime? {
  /// Formats the expiration date into a user-friendly string relative to today.
  String formatExpirationStatus() {
    if (this == null) {
      // Although backend guarantees a date, handle defensively
      return 'Sin fecha';
    }
    final expirationDate = this!;
    final now = DateTime.now();
    // Compare dates only, ignoring time for day difference calculation
    final today = DateUtils.dateOnly(now);
    final expiryDateOnly = DateUtils.dateOnly(expirationDate);
    final differenceInDays = expiryDateOnly.difference(today).inDays;

    if (differenceInDays < -1) {
      return 'Vencido hace ${differenceInDays.abs()} días';
    } else if (differenceInDays == -1) {
      return 'Vencido ayer';
    } else if (differenceInDays == 0) {
      // Check if it actually expired today based on time
      return expirationDate.isBefore(now) ? 'Vencido hoy' : 'Vence hoy';
    } else if (differenceInDays == 1) {
      return 'Vence mañana';
    } else if (differenceInDays <= 5) {
      // Example threshold for 'days'
      return 'Vence en $differenceInDays días';
    } else {
      // If further out, show the date
      return 'Vence el ${DateFormat('dd/MM/yyyy').format(expirationDate)}';
    }
  }
}
