import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/models/transaction.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/transaction_item.dart';
import 'transactions_controller.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(title: AppStrings.transactionsLog),
            ),
            _SearchAndFilterBar(
              showFilters: _showFilters,
              onToggleFilters: () =>
                  setState(() => _showFilters = !_showFilters),
            ),
            if (_showFilters) _FiltersPanel(controller: controller),
            Expanded(child: _Content(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.showFilters,
    required this.onToggleFilters,
  });

  final bool showFilters;
  final VoidCallback onToggleFilters;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingMd),
      child: Row(
        children: [
          Expanded(child: _SearchBar()),
          const SizedBox(width: AppDimens.gapSm),
          Obx(
            () => _FilterToggleButton(
              active: controller.hasFilters,
              expanded: showFilters,
              onTap: onToggleFilters,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterToggleButton extends StatelessWidget {
  const _FilterToggleButton({
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = active || expanded;
    return Tooltip(
      message: AppStrings.filter,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          width: AppDimens.fieldHeight,
          height: AppDimens.fieldHeight,
          decoration: BoxDecoration(
            color: highlighted ? context.primary : context.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: highlighted ? context.primary : context.border,
            ),
          ),
          child: Icon(
            TablerIcons.filter,
            size: AppDimens.iconMd,
            color: highlighted ? context.onPrimary : context.textSecondary,
          ),
        ),
      ),
    );
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
    return AppTextField(
      label: '',
      controller: _controller,
      hint: AppStrings.searchHint,
      prefix: Icon(
        TablerIcons.search,
        size: AppDimens.iconMd,
        color: context.textSecondary,
      ),
      onChanged: controller.setSearchQuery,
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({required this.controller});

  final TransactionsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.gapSm),
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(
        color: context.muted.withValues(alpha: 0.4),
        border: Border(
          top: BorderSide(color: context.border),
          bottom: BorderSide(color: context.border),
        ),
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<TransactionType>(
                    label: AppStrings.type,
                    items: TransactionType.values,
                    selected: controller.typeFilter.value,
                    display: _typeLabel,
                    hint: AppStrings.allTypes,
                    onChanged: controller.setTypeFilter,
                  ),
                ),
                const SizedBox(width: AppDimens.gapSm),
                Expanded(
                  child: AppDropdownField<Category>(
                    label: AppStrings.category,
                    items: controller.categoriesForFilter,
                    selected: controller.categoryFilter.value,
                    display: (category) => category.name,
                    hint: AppStrings.allCategories,
                    onChanged: controller.setCategoryFilter,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapSm),
            AppDropdownField<Product>(
              label: AppStrings.product,
              items: controller.productsForFilter,
              selected: controller.productFilter.value,
              display: (product) => product.name,
              hint: AppStrings.allProducts,
              onChanged: controller.setProductFilter,
            ),
            const SizedBox(height: AppDimens.gapSm),
            Row(
              children: [
                _PeriodPill(
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
                _PeriodPill(
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
                _PeriodPill(
                  label: AppStrings.month,
                  selected: controller.periodFilter.value ==
                      PeriodFilter.month,
                  onTap: () => controller.setPeriodFilter(
                    controller.periodFilter.value == PeriodFilter.month
                        ? null
                        : PeriodFilter.month,
                  ),
                ),
                const Spacer(),
                if (controller.hasFilters)
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                    },
                    child: Text(
                      AppStrings.clearFilters,
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeCaption,
                        color: context.danger,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(TransactionType type) {
    return switch (type) {
      TransactionType.income => AppStrings.typeIncome,
      TransactionType.expense => AppStrings.typeExpense,
    };
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
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
          vertical: AppDimens.gapXs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? context.primary : context.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(
            color: selected ? context.primary : context.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppDimens.fontSizeCaption,
            fontWeight: selected
                ? AppDimens.fontWeightMedium
                : AppDimens.fontWeightNormal,
            color: selected ? context.onPrimary : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final TransactionsController controller;

  @override
  Widget build(BuildContext context) {
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
          return AppEmptyState(
            icon: TablerIcons.receipt,
            title: AppStrings.noTransactions,
            description: AppStrings.noResultsDesc,
            actionLabel: AppStrings.addTransaction,
            onAction: () => Get.toNamed(AppRoutes.addExpense),
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.textSecondary,
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
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.border,
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