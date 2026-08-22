import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/models/transaction.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/transaction_item.dart';
import 'transactions_controller.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(title: AppStrings.transactionsLog),
            ),
            const _SearchBar(),
            _FilterBar(),
            const SizedBox(height: AppDimens.gapSm),
            Expanded(child: _Content()),
            const BottomNav(
              currentIndex: 1,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  static void _onNavTap(int index) {
    switch (index) {
      case 0:
        Get.toNamed(AppRoutes.home);
      case 2:
        Get.toNamed(AppRoutes.statistics);
      case 3:
        Get.toNamed(AppRoutes.electricity);
    }
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
      child: AppTextField(
        label: '',
        controller: _controller,
        hint: AppStrings.searchHint,
        prefix: const Icon(
          TablerIcons.search,
          size: AppDimens.iconMd,
          color: AppColors.textSecondary,
        ),
        onChanged: controller.setSearchQuery,
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    return Obx(
      () {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _FilterPill(
                    label: AppStrings.allTypes,
                    selected: controller.typeFilter.value == null,
                    onTap: () => controller.setTypeFilter(null),
                  ),
                  const SizedBox(width: AppDimens.gapSm),
                  _FilterPill(
                    label: AppStrings.typeIncome,
                    selected: controller.typeFilter.value ==
                        TransactionType.income,
                    onTap: () => controller
                        .setTypeFilter(TransactionType.income),
                  ),
                  const SizedBox(width: AppDimens.gapSm),
                  _FilterPill(
                    label: AppStrings.typeExpense,
                    selected: controller.typeFilter.value ==
                        TransactionType.expense,
                    onTap: () => controller
                        .setTypeFilter(TransactionType.expense),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.gapSm),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<Category>(
                      label: AppStrings.category,
                      items: controller.categoriesForFilter,
                      selected: controller.categoryFilter.value,
                      display: (category) => category.name,
                      hint: AppStrings.categoryRequired,
                      onChanged: controller.setCategoryFilter,
                    ),
                  ),
                  const SizedBox(width: AppDimens.gapSm),
                  Expanded(
                    child: AppDropdownField<Product>(
                      label: AppStrings.product,
                      items: controller.productsForFilter,
                      selected: controller.productFilter.value,
                      display: (product) => product.name,
                      hint: AppStrings.chooseProduct,
                      onChanged: controller.setProductFilter,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.gapSm),
              Row(
                children: [
                  _FilterPill(
                    label: AppStrings.today,
                    selected: controller.periodFilter.value ==
                        PeriodFilter.day,
                    onTap: () => controller.setPeriodFilter(
                      controller.periodFilter.value == PeriodFilter.day
                          ? null
                          : PeriodFilter.day,
                    ),
                  ),
                  const SizedBox(width: AppDimens.gapSm),
                  _FilterPill(
                    label: AppStrings.week,
                    selected: controller.periodFilter.value ==
                        PeriodFilter.week,
                    onTap: () => controller.setPeriodFilter(
                      controller.periodFilter.value == PeriodFilter.week
                          ? null
                          : PeriodFilter.week,
                    ),
                  ),
                  const SizedBox(width: AppDimens.gapSm),
                  _FilterPill(
                    label: AppStrings.month,
                    selected: controller.periodFilter.value ==
                        PeriodFilter.month,
                    onTap: () => controller.setPeriodFilter(
                      controller.periodFilter.value == PeriodFilter.month
                          ? null
                          : PeriodFilter.month,
                    ),
                  ),
                ],
              ),
              if (controller.hasFilters) ...[
                const SizedBox(height: AppDimens.gapSm),
                AppPrimaryButton(
                  label: AppStrings.clearFilters,
                  variant: 'danger',
                  onPressed: controller.clearFilters,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingMd,
          vertical: AppDimens.gapSm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected
                ? AppDimens.fontWeightMedium
                : AppDimens.fontWeightNormal,
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    return Obx(
      () {
        if (controller.loading.value) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.spacingMd),
            itemCount: 5,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppDimens.gapMd),
            itemBuilder: (_, _) => const SkeletonCard(height: 72),
          );
        }
        if (controller.all.isEmpty) {
          return const AppEmptyState(
            icon: TablerIcons.receipt,
            title: AppStrings.noTransactions,
          );
        }
        if (controller.filtered.isEmpty) {
          return AppEmptyState(
            icon: TablerIcons.search,
            title: AppStrings.noResults,
            description: AppStrings.noResultsDesc,
            actionLabel: controller.hasFilters ? AppStrings.clearFilters : null,
            onAction: controller.hasFilters ? controller.clearFilters : null,
          );
        }
        final groups = controller.groupedByDate;
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          itemCount: groups.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimens.gapMd),
          itemBuilder: (_, index) {
            final (day, transactions) = groups[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingSm,
                  ),
                  child: Text(
                    NumberFormatter.formatFullDate(day),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.gapSm),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.gapSm,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < transactions.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                        TransactionItem(
                          transaction: transactions[i],
                          categoryName:
                              controller.categoryNameFor(transactions[i].categoryId),
                          onTap: () => Get.toNamed(
                            AppRoutes.transactionDetail,
                            arguments: transactions[i].id,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}