import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/transaction.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/page_header.dart';
import 'transaction_detail_controller.dart';

class TransactionDetailView extends StatelessWidget {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionDetailController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: AppStrings.detailTitle,
                onBack: () => Get.back(),
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  final tx = controller.transaction.value;
                  if (tx == null) {
                    return const AppEmptyState(
                      icon: TablerIcons.alert_circle,
                      title: AppStrings.transactionNotFound,
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.spacingMd),
                    child: Column(
                      children: [
                        _HeroCard(transaction: tx),
                        const SizedBox(height: AppDimens.gapMd),
                        _DetailsCard(tx: tx, controller: controller),
                        const SizedBox(height: AppDimens.gapMd),
                        AppSecondaryButton(
                          label: AppStrings.editTransaction,
                          icon: TablerIcons.edit,
                          onPressed: controller.edit,
                        ),
                        const SizedBox(height: AppDimens.gapSm),
                        AppPrimaryButton(
                          label: AppStrings.deleteTransaction,
                          variant: 'danger',
                          icon: TablerIcons.trash,
                          onPressed: () =>
                              _confirmDelete(context, controller),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    TransactionDetailController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text(AppStrings.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.delete();
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.primary : AppColors.secondary;
    final icon = isIncome ? TablerIcons.arrow_up : TablerIcons.arrow_down;
    final badge = isIncome
        ? AppStrings.incomeBadge
        : AppStrings.expenseBadge;
    final sign = isIncome ? '+ ' : '- ';

    return AppCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppDimens.iconLg, color: color),
          ),
          const SizedBox(height: AppDimens.gapMd),
          Text(
            '$sign${NumberFormatter.formatSyp(transaction.amount)} '
            '${AppStrings.currencyUnit}',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 30,
              fontWeight: AppDimens.fontWeightMedium,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimens.gapSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingMd,
              vertical: AppDimens.gapXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeLabel,
                fontWeight: AppDimens.fontWeightMedium,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.tx, required this.controller});

  final Transaction tx;
  final TransactionDetailController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _DetailRow(
            label: AppStrings.category,
            value: controller.categoryName.value,
          ),
          if (controller.productName.value.isNotEmpty) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            _DetailRow(
              label: AppStrings.product,
              value: controller.productName.value,
            ),
          ],
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _DetailRow(
            label: AppStrings.date,
            value: NumberFormatter.formatFullDate(tx.date),
          ),
          if (tx.note != null && tx.note!.isNotEmpty) ...[
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            _DetailRow(label: AppStrings.note, value: tx.note!),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingMd,
        vertical: AppDimens.gapMd,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppDimens.fontSizeLabel,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeBody,
                fontWeight: AppDimens.fontWeightMedium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}