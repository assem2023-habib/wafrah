import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import 'app_buttons.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          AppIconButton(
            icon: TablerIcons.chevron_right,
            onPressed: onBack,
          ),
          const SizedBox(width: AppDimens.gapSm),
        ],
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimens.fontSizeHeading,
              fontWeight: AppDimens.fontWeightMedium,
              color: context.textPrimary,
            ),
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: AppDimens.gapSm),
          action!,
        ],
      ],
    );
  }
}