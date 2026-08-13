import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.spacingMd),
    this.margin,
    this.onTap,
    this.color = AppColors.surface,
    this.radius = AppDimens.radiusLg,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: onTap == null
          ? child
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: child,
              ),
            ),
    );
  }
}
