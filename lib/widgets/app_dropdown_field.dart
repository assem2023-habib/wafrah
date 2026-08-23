import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.selected,
    required this.display,
    this.onChanged,
    this.hint,
  });

  final String label;
  final List<T> items;
  final T? selected;
  final String Function(T) display;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  Future<void> _showSheet(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppDimens.spacingMd),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingSm),
          decoration: BoxDecoration(
            color: sheetContext.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(color: sheetContext.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in items)
                  ListTile(
                    onTap: () => Navigator.of(sheetContext).pop(item),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    tileColor: item == selected ? sheetContext.muted : null,
                    title: Text(
                      display(item),
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeBody,
                        fontWeight: item == selected
                            ? AppDimens.fontWeightMedium
                            : AppDimens.fontWeightNormal,
                        color: item == selected
                            ? sheetContext.primary
                            : sheetContext.textPrimary,
                      ),
                    ),
                    trailing: item == selected
                        ? Icon(
                            TablerIcons.check,
                            size: AppDimens.iconMd,
                            color: sheetContext.primary,
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null) {
      onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = selected;
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
          onTap: () => _showSheet(context),
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
                Expanded(
                  child: Text(
                    current == null ? (hint ?? '') : display(current),
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeBody,
                      color: selected == null
                          ? context.textSecondary
                          : context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  TablerIcons.chevron_down,
                  size: AppDimens.iconMd,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
