import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/number_formatter.dart';
import '../data/models/transaction.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    this.categoryName,
    this.onTap,
  });

  final Transaction transaction;
  final String? categoryName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? context.primary : context.secondary;
    final icon = isIncome ? TablerIcons.arrow_up : TablerIcons.arrow_down;
    final name = categoryName ??
        (isIncome ? AppStrings.incomeBadge : AppStrings.expenseBadge);
    final subtitle =
        transaction.note ?? NumberFormatter.formatShortDate(transaction.date);
    final sign = isIncome ? '+ ' : '- ';
    final amount = '$sign${NumberFormatter.formatSyp(transaction.amount)} '
        '${AppStrings.currencyUnit}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingMd,
          vertical: AppDimens.gapSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppDimens.iconMd, color: color),
            ),
            const SizedBox(width: AppDimens.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeBody,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.gapXs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.gapMd),
            Text(
              amount,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: AppDimens.fontSizeBody,
                fontWeight: AppDimens.fontWeightMedium,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}