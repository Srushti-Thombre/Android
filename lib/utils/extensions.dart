import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  DateTime copyWithTime({required int hour, required int minute}) {
    return DateTime(year, month, day, hour, minute);
  }

  DateTime startOfMonth() {
    return DateTime(year, month, 1);
  }

  DateTime endOfMonth() {
    return DateTime(year, month + 1, 0);
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  bool isValidEmail() {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(this);
  }
}

extension DoubleExtension on double {
  String toCurrency([String currency = '₹']) {
    return '$currency${toStringAsFixed(2)}';
  }

  String toPercentage() {
    return '${toStringAsFixed(1)}%';
  }
}

extension ColorExtension on Color {
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
