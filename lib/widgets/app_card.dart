import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.spacingMd),
    this.margin,
    this.onTap,
    this.color,
    this.radius = AppDimens.radiusLg,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  /// Pass null (default) to use the theme surface color.
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? context.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? child
            : InkWell(
                onTap: onTap,
                child: child,
              ),
      ),
    );
  }
}
