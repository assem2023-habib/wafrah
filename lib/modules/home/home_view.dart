import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_service.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/transaction.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/skeleton_card.dart';
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
            const Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _Content()),
                  Positioned(
                    bottom: AppDimens.gapMd,
                    left: AppDimens.spacingMd,
                    child: _SpeedDial(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.welcome,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeCaption,
                  color: context.textSecondary,
                ),
              ),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeHeading,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          AppIconButton(
            icon: TablerIcons.moon,
            onPressed: () {
              final mode = Get.isDarkMode ? ThemeMode.light : ThemeMode.dark;
              Get.changeThemeMode(mode);
              ThemeService.save(mode);
            },
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
          return const _HomeSkeleton();
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

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spacingMd,
        AppDimens.spacingMd,
        AppDimens.spacingMd,
        88,
      ),
      children: const [
        SkeletonCard(height: 150),
        SizedBox(height: AppDimens.gapMd),
        Row(
          children: [
            Expanded(child: SkeletonCard(height: 124)),
            SizedBox(width: AppDimens.gapSm),
            Expanded(child: SkeletonCard(height: 124)),
          ],
        ),
        SizedBox(height: AppDimens.spacingLg),
        SkeletonCard(height: 72),
        SizedBox(height: AppDimens.gapMd),
        SkeletonCard(height: 72),
      ],
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
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spacingMd,
        AppDimens.spacingMd,
        AppDimens.spacingMd,
        88,
      ),
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
                color: context.primary,
              ),
            ),
            const SizedBox(width: AppDimens.gapSm),
            Expanded(
              child: _SummaryCard(
                icon: TablerIcons.arrow_down,
                label: AppStrings.totalExpense,
                value: controller.totalExpense,
                color: context.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingLg),
        Row(
          children: [
            Text(
              AppStrings.recentTransactions,
              style: TextStyle(
                fontSize: AppDimens.fontSizeBody,
                fontWeight: AppDimens.fontWeightMedium,
                color: context.textPrimary,
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
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.border,
                  ),
                _StaggeredItem(
                  index: i,
                  transaction: lastFive[i],
                  categoryName:
                      controller.categoryNameFor(lastFive[i].categoryId),
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
      color: context.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.balance,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.onPrimary.withValues(alpha: 0.8),
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
                  duration: Motion.dur(const Duration(milliseconds: 800)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Text(
                    NumberFormatter.formatSyp(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeStatLg,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.gapXs),
              Text(
                AppStrings.currencyUnit,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  color: context.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapSm),
          Text(
            AppStrings.allTransactions,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.onPrimary.withValues(alpha: 0.6),
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
            Row(
              children: [
                Icon(icon, size: AppDimens.iconSm, color: color),
                const SizedBox(width: AppDimens.gapXs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeCaption,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapSm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: Motion.dur(AppDimens.durCount),
              curve: Curves.easeOut,
              builder: (context, animated, child) => Text(
                NumberFormatter.formatSyp(animated),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.gapXs),
            Text(
              AppStrings.currencyUnit,
              style: TextStyle(
                fontSize: AppDimens.fontSizeCaption,
                color: context.textSecondary,
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
      duration: Motion.dur(Duration(milliseconds: 400 + index * 80)),
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
        onTap: () => Get.toNamed(
          AppRoutes.transactionDetail,
          arguments: transaction.id,
        ),
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

  static const double _fabSize = 56;

  void _close() {
    if (_open) {
      setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: _fabSize + AppDimens.gapMd,
            left: 0,
            child: IgnorePointer(
              ignoring: !_open,
              child: AnimatedOpacity(
                opacity: _open ? 1 : 0,
                duration: Motion.dur(AppDimens.durBase),
                child: AnimatedScale(
                  scale: _open ? 1 : 0.85,
                  duration: Motion.dur(AppDimens.durBase),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ActionPill(
                        label: AppStrings.addIncome,
                        color: context.primary,
                        onTap: () {
                          _close();
                          Get.toNamed(AppRoutes.addIncome);
                        },
                      ),
                      const SizedBox(height: AppDimens.gapMd),
                      _ActionPill(
                        label: AppStrings.addExpense,
                        color: context.secondary,
                        onTap: () {
                          _close();
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
            bottom: 0,
            left: 0,
            child: _PressableScale(
              onTap: () => setState(() => _open = !_open),
              child: AnimatedContainer(
                width: _fabSize,
                height: _fabSize,
                duration: Motion.dur(AppDimens.durFast),
                decoration: BoxDecoration(
                  color: _open ? context.textPrimary : context.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: AnimatedRotation(
                  turns: _open ? 0.125 : 0,
                  duration: Motion.dur(AppDimens.durBase),
                  alignment: Alignment.center,
                  child: Icon(
                    TablerIcons.plus,
                    size: 26,
                    color: _open ? context.background : context.onPrimary,
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

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1,
          duration: Motion.dur(AppDimens.durFast),
          curve: Curves.easeOut,
          child: widget.child,
        ),
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
    final isIncome = label == AppStrings.addIncome;
    return _PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingMd,
          vertical: AppDimens.gapSm + 2,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIncome ? TablerIcons.trending_up : TablerIcons.trending_down,
              size: 15,
              color: context.onPrimary,
            ),
            const SizedBox(width: AppDimens.gapXs),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimens.fontSizeLabel,
                fontWeight: AppDimens.fontWeightMedium,
                color: context.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}