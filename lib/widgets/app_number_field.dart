import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';

class AppNumberField extends StatelessWidget {
  const AppNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.suffix,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final String? errorText;
  final ValueChanged<String>? onChanged;

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

  static String _formatInput(String raw) {
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      if (char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39) {
        buffer.write(char);
      }
    }
    final digits = buffer.toString().replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.isEmpty) return '';
    final result = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(_arabicDigits[digits[i]]);
    }
    return result.toString();
  }

  void _handleChanged(String value) {
    final formatted = _formatInput(value);
    if (formatted != value) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    onChanged?.call(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimens.fontSizeLabel,
            fontWeight: AppDimens.fontWeightMedium,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimens.gapSm),
        SizedBox(
          height: AppDimens.fieldHeight,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            onChanged: _handleChanged,
            style: const TextStyle(
              fontSize: AppDimens.fontSizeField,
              fontWeight: AppDimens.fontWeightMedium,
            ),
            decoration: InputDecoration(
              suffixText: suffix,
              suffixStyle: TextStyle(color: context.textSecondary),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
              isDense: true,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppDimens.gapXs),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.danger,
            ),
          ),
        ],
      ],
    );
  }
}