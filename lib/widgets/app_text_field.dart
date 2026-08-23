import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.errorText,
    this.keyboardType,
    this.suffixText,
    this.prefix,
    this.obscureText = false,
    this.onChanged,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final String? suffixText;
  final Widget? prefix;
  final bool obscureText;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimens.fontSizeLabel,
              fontWeight: AppDimens.fontWeightMedium,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.gapSm),
        ],
        SizedBox(
          height: AppDimens.fieldHeight,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            style: const TextStyle(fontSize: AppDimens.fontSizeBody),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: context.textSecondary),
              prefixIcon: prefix,
              suffixText: suffixText,
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