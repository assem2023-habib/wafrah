import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';

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
            style: const TextStyle(
              fontSize: AppDimens.fontSizeLabel,
              fontWeight: AppDimens.fontWeightMedium,
              color: AppColors.textSecondary,
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
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: prefix,
              suffixText: suffixText,
              suffixStyle: const TextStyle(color: AppColors.textSecondary),
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
            style: const TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}
