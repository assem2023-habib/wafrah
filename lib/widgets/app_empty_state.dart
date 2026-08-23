import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import 'app_buttons.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: AppDimens.fontWeightMedium,
                color: context.textPrimary,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: AppDimens.gapSm),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  color: context.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimens.spacingLg),
              AppPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}