import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, [String currency = '₹']) {
    return '$currency${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM, yyyy').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  static String formatMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatNumber(double value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }

  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
