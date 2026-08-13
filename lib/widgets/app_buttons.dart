import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = 'primary',
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final String variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (variant) {
      'secondary' => (AppColors.secondary, AppColors.onSecondary),
      'danger' => (AppColors.danger, AppColors.onPrimary),
      _ => (AppColors.primary, AppColors.onPrimary),
    };

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSizeBody,
          fontWeight: AppDimens.fontWeightMedium,
        ),
      ),
      child: icon == null
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppDimens.iconMd),
                const SizedBox(width: AppDimens.gapSm),
                Text(label),
              ],
            ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSizeBody,
          fontWeight: AppDimens.fontWeightMedium,
        ),
      ),
      child: icon == null
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppDimens.iconMd),
                const SizedBox(width: AppDimens.gapSm),
                Text(label),
              ],
            ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: const Size(AppDimens.iconButton, AppDimens.iconButton),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
      ),
      icon: Icon(icon, size: AppDimens.iconMd, color: AppColors.textPrimary),
    );
  }
}
