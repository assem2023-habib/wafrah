import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/number_formatter.dart';

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.unit,
    this.animate = true,
  });

  final String label;
  final double value;
  final Color color;
  final String? unit;
  final bool animate;

  String _format(double number) {
    final text = unit == AppStrings.currencyUnit
        ? NumberFormatter.formatSyp(number)
        : NumberFormatter.formatNumber(number);
    return (unit == null || unit!.isEmpty) ? text : '$text $unit';
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: AppDimens.fontSizeStat,
      fontWeight: AppDimens.fontWeightMedium,
      color: color,
    );

    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.gapXs),
          if (animate)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: AppDimens.durSlow,
              curve: Curves.easeOut,
              builder: (context, number, child) =>
                  Text(_format(number), style: style),
            )
          else
            Text(_format(value), style: style),
        ],
      ),
    );
  }
}