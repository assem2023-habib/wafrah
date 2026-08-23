import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/number_formatter.dart';
import 'app_date_picker.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => AppDatePicker(
        initialDate: value,
        onConfirm: (date) => Navigator.of(dialogContext).pop(date),
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
    if (picked != null) {
      onChanged(picked);
    }
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
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Container(
            height: AppDimens.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Icon(
                  TablerIcons.calendar,
                  size: AppDimens.iconMd,
                  color: context.textSecondary,
                ),
                const SizedBox(width: AppDimens.gapSm),
                Expanded(
                  child: Text(
                    value == null
                        ? AppStrings.chooseDate
                        : NumberFormatter.formatDate(value!),
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeBody,
                      color: value == null
                          ? context.textSecondary
                          : context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}