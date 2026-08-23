import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';

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
    final (Color background, Color foreground) = switch (variant) {
      'secondary' => (context.secondary, context.onSecondary),
      'danger' => (context.danger, context.onPrimary),
      _ => (context.primary, context.onPrimary),
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
        foregroundColor: context.primary,
        side: BorderSide(color: context.primary),
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
        backgroundColor: context.surface,
        side: BorderSide(color: context.border),
      ),
      icon: Icon(icon, size: AppDimens.iconMd, color: context.textPrimary),
    );
  }
}
