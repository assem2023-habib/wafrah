import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? requiredField(String? v) {
    if (v == null || v.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    return null;
  }

  static const Map<String, String> _arabicDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  static String _toAsciiDigits(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(_arabicDigits[char] ?? char);
    }
    return buffer.toString();
  }

  static double? parseNumber(String? v) {
    if (v == null) {
      return null;
    }
    final cleaned = _toAsciiDigits(
      v.trim().replaceAll(',', '').replaceAll('،', '').replaceAll('٬', ''),
    );
    return double.tryParse(cleaned);
  }

  static String? positiveNumber(String? v) {
    final value = parseNumber(v);
    if (value == null || value <= 0) {
      return AppStrings.amountPositive;
    }
    return null;
  }

  static String? dateRequired(DateTime? d) =>
      d == null ? AppStrings.dateRequired : null;

  static String? toDateAfterFrom(DateTime? from, DateTime? to) {
    if (from == null || to == null) {
      return null;
    }
    if (to.isAfter(from)) {
      return null;
    }
    return AppStrings.toDateAfterFrom;
  }
}
