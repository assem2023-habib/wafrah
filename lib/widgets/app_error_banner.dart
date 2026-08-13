import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';

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
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            TablerIcons.alert_triangle,
            size: AppDimens.iconMd,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppDimens.gapSm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeLabel,
                fontWeight: AppDimens.fontWeightMedium,
                color: AppColors.danger,
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
              icon: const Icon(
                TablerIcons.x,
                size: AppDimens.iconMd,
                color: AppColors.danger,
              ),
            ),
        ],
      ),
    );
  }
}
