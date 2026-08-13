import 'package:intl/intl.dart';

import '../constants/app_strings.dart';

class NumberFormatter {
  NumberFormatter._();

  static const Map<String, String> _arabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static String _toArabicDigits(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(_arabicDigits[char] ?? char);
    }
    return buffer.toString();
  }

  static String _formatCompact(num value, num divisor, String suffix) {
    final result = value / divisor;
    final text = result.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    return '${_toArabicDigits(text)} $suffix';
  }

  static String formatSyp(num value) {
    final abs = value.abs();
    if (abs >= 1000000000) {
      return _formatCompact(value, 1000000000, AppStrings.billion);
    }
    if (abs >= 1000000) {
      return _formatCompact(value, 1000000, AppStrings.million);
    }
    if (abs >= 1000) {
      return _toArabicDigits(NumberFormat('#,##0', 'en_US').format(value));
    }
    return _toArabicDigits(value.round().toString());
  }

  static String formatSypWithUnit(num value) =>
      '${formatSyp(value)} ${AppStrings.currencyUnit}';

  static String formatKwh(num value) {
    final pattern = value % 1 == 0 ? '#,##0' : '#,##0.##';
    final text = _toArabicDigits(NumberFormat(pattern, 'en_US').format(value));
    return '$text ${AppStrings.kwhUnit}';
  }

  static String formatNumber(num value) =>
      _toArabicDigits(NumberFormat('#,##0', 'en_US').format(value));

  static String formatDate(DateTime d) =>
      DateFormat('d MMMM yyyy', 'ar').format(d);

  static String formatShortDate(DateTime d) =>
      DateFormat('d/M', 'ar').format(d);

  static String formatFullDate(DateTime d) =>
      DateFormat('EEEE d MMMM yyyy', 'ar').format(d);

  static String formatMonthName(DateTime d) =>
      DateFormat('MMMM', 'ar').format(d);
}
