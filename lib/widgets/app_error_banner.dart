import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.onClose,
  });

  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingMd,
        vertical: AppDimens.gapSm,
      ),
      decoration: BoxDecoration(
        color: context.dangerBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            TablerIcons.alert_triangle,
            size: AppDimens.iconMd,
            color: context.danger,
          ),
          const SizedBox(width: AppDimens.gapSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppDimens.fontSizeLabel,
                fontWeight: AppDimens.fontWeightMedium,
                color: context.danger,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              style: IconButton.styleFrom(
                fixedSize:
                    const Size(AppDimens.iconButton, AppDimens.iconButton),
              ),
              icon: Icon(
                TablerIcons.x,
                size: AppDimens.iconMd,
                color: context.danger,
              ),
            ),
        ],
      ),
    );
  }
}