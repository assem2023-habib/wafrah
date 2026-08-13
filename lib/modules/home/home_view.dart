import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/transaction.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/transaction_item.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const Expanded(child: _Content()),
            const _SpeedDial(),
            const BottomNav(currentIndex: 0, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  static void _onNavTap(int index) {
    switch (index) {
      case 1:
        Get.toNamed(AppRoutes.transactions);
      case 2:
        Get.toNamed(AppRoutes.statistics);
      case 3:
        Get.toNamed(AppRoutes.electricity);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.welcome,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeCaption,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeHeading,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          AppIconButton(
            icon: TablerIcons.moon,
            onPressed: () => Get.changeThemeMode(
              Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
          const SizedBox(width: AppDimens.gapSm),
          AppIconButton(
            icon: TablerIcons.settings,
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Obx(
      () {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.spacingMd),
            child: AppErrorBanner(
              message: controller.error.value,
              onClose: controller.clearError,
            ),
          );
        }
        if (controller.transactions.isEmpty) {
          return AppEmptyState(
            icon: TablerIcons.credit_card,
            title: AppStrings.welcomeEmptyTitle,
            description: AppStrings.welcomeEmptyDesc,
            actionLabel: AppStrings.addTransaction,
            onAction: () => Get.toNamed(AppRoutes.addExpense),
          );
        }
        return _HomeList(controller);
      },
    );
  }
}

class _HomeList extends StatelessWidget {
  const _HomeList(this.controller);

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final lastFive = controller.lastFive;
    return ListView(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      children: [
        _BalanceCard(controller),
        const SizedBox(height: AppDimens.gapMd),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: TablerIcons.arrow_up,
                label: AppStrings.totalIncome,
                value: controller.totalIncome,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimens.gapSm),
            Expanded(
              child: _SummaryCard(
                icon: TablerIcons.arrow_down,
                label: AppStrings.totalExpense,
                value: controller.totalExpense,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingLg),
        Row(
          children: [
            const Text(
              AppStrings.recentTransactions,
              style: TextStyle(
                fontSize: AppDimens.fontSizeBody,
                fontWeight: AppDimens.fontWeightMedium,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.transactions),
              child: const Text(AppStrings.viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.gapSm),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.gapSm),
          child: Column(
            children: [
              for (var i = 0; i < lastFive.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                _StaggeredItem(
                  index: i,
                  transaction: lastFive[i],
                  categoryName: controller.categoryNameFor(lastFive[i].categoryId),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(this.controller);

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.balance,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: AppColors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppDimens.gapSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: controller.balance),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Text(
                    NumberFormatter.formatSyp(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppDimens.fontSizeStatLg,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.gapXs),
              const Text(
                AppStrings.currencyUnit,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapSm),
          Text(
            AppStrings.allTransactions,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: AppColors.onPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.spacingMd),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppDimens.iconLg, color: color),
            const SizedBox(height: AppDimens.gapSm),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeCaption,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimens.gapXs),
            Text(
              NumberFormatter.formatSyp(value),
              style: TextStyle(
                fontSize: 18,
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

class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({
    required this.index,
    required this.transaction,
    this.categoryName,
  });

  final int index;
  final Transaction transaction;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
      child: TransactionItem(
        transaction: transaction,
        categoryName: categoryName,
      ),
    );
  }
}

class _SpeedDial extends StatefulWidget {
  const _SpeedDial();

  @override
  State<_SpeedDial> createState() => _SpeedDialState();
}

class _SpeedDialState extends State<_SpeedDial> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          Positioned(
            bottom: AppDimens.gapMd,
            left: AppDimens.spacingMd,
            child: IgnorePointer(
              ignoring: !_open,
              child: AnimatedOpacity(
                opacity: _open ? 1 : 0,
                duration: AppDimens.durFast,
                child: AnimatedScale(
                  scale: _open ? 1 : 0.85,
                  duration: AppDimens.durFast,
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ActionPill(
                        label: AppStrings.addIncome,
                        color: AppColors.primary,
                        onTap: () {
                          setState(() => _open = false);
                          Get.toNamed(AppRoutes.addIncome);
                        },
                      ),
                      const SizedBox(height: AppDimens.gapSm),
                      _ActionPill(
                        label: AppStrings.addExpense,
                        color: AppColors.secondary,
                        onTap: () {
                          setState(() => _open = false);
                          Get.toNamed(AppRoutes.addExpense);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppDimens.gapMd,
            left: AppDimens.spacingMd,
            child: GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: AnimatedRotation(
                turns: _open ? 0.125 : 0,
                duration: AppDimens.durBase,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    TablerIcons.plus,
                    size: 26,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingMd,
          vertical: AppDimens.gapSm,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: AppDimens.fontSizeLabel,
            fontWeight: AppDimens.fontWeightMedium,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
