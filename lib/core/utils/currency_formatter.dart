import 'package:intl/intl.dart';

/// MacroFinance — Indian Currency Formatter
/// Formats amounts in Indian numbering system (₹1,23,456.78)
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _indianFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format as ₹1,23,456
  static String format(double amount) {
    return _indianFormat.format(amount);
  }

  /// Format as ₹1,23,456.78
  static String formatWithDecimals(double amount) {
    return _indianFormatWithDecimals.format(amount);
  }

  /// Format as ₹1.2L, ₹50K, etc.
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return _indianFormat.format(amount);
  }

  /// Format as percentage: 12.50%
  static String formatPercent(double rate) {
    return '${rate.toStringAsFixed(2)}%';
  }

  /// Format interest rate with "p.a." suffix
  static String formatInterestRate(double rate) {
    return '${rate.toStringAsFixed(2)}% p.a.';
  }

  /// Parse Indian formatted string back to double
  static double? parse(String value) {
    try {
      final cleaned = value.replaceAll(RegExp(r'[₹,\s]'), '');
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Format duration in months to human readable
  static String formatTenure(int months) {
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) return '$years ${years == 1 ? 'year' : 'years'}';
    return '$years ${years == 1 ? 'year' : 'years'} $remaining months';
  }

  /// Format date to dd MMM yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date to dd/MM/yyyy
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
