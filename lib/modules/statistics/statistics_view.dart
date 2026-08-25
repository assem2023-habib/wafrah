import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeleton_card.dart';
import 'statistics_controller.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  static const List<(int, String)> _periodLabels = [
    (1, 'هذا الشهر'),
    (3, '3 أشهر'),
    (6, '6 أشهر'),
    (12, 'سنة'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(title: AppStrings.statsTitle),
            ),
            _PeriodBar(controller: controller),
            Expanded(child: _Content(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _PeriodBar extends StatelessWidget {
  const _PeriodBar({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingMd,
        vertical: AppDimens.gapSm,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(
          top: BorderSide(color: context.border),
          bottom: BorderSide(color: context.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              for (final (months, label) in StatisticsView._periodLabels) ...[
                if (months != 1) const SizedBox(width: AppDimens.gapSm),
                ChoiceChip(
                  label: Text(label),
                  selected: controller.periodMonths.value == months,
                  onSelected: (_) => controller.setPeriod(months),
                  selectedColor: context.primary,
                  labelStyle: TextStyle(
                    color: controller.periodMonths.value == months
                        ? context.onPrimary
                        : context.textSecondary,
                    fontSize: AppDimens.fontSizeLabel,
                    fontWeight: AppDimens.fontWeightMedium,
                  ),
                  backgroundColor: context.muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    side: BorderSide(
                      color: controller.periodMonths.value == months
                          ? context.primary
                          : context.border,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingMd,
                    vertical: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loading.value) {
      return const _StatisticsSkeleton();
    }
    if (controller.inPeriod.isEmpty) {
      return AppEmptyState(
        icon: Icons.pie_chart_outline,
        title: AppStrings.noData,
        description: AppStrings.noDataDesc,
      );
    }
    final pieData = controller.expenseByCategory;
    final barData = controller.monthlyBuckets;
    return ListView(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      children: [
        _SummaryRow(controller: controller),
        if (pieData.isNotEmpty) ...[
          const SizedBox(height: AppDimens.gapMd),
          _PieCard(controller: controller),
        ],
        if (barData.isNotEmpty) ...[
          const SizedBox(height: AppDimens.gapMd),
          _BarCard(controller: controller),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.incomeTotal,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.gapXs),
                  Text(
                    NumberFormatter.formatSyp(controller.totalIncome),
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeBody,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.primary,
                    ),
                  ),
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
          ),
          const SizedBox(width: AppDimens.gapSm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              decoration: BoxDecoration(
                color: context.secondary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.expenseTotal,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.gapXs),
                  Text(
                    NumberFormatter.formatSyp(controller.totalExpense),
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeBody,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.secondary,
                    ),
                  ),
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
          ),
        ],
      ),
    );
  }
}

class _PieCard extends StatelessWidget {
  const _PieCard({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final data = controller.expenseByCategory;
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }
        final colors = context.chartColors;
        return Container(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: context.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.expenseDistribution,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeBody,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.gapMd),
              Obx(
                () => AnimatedOpacity(
                  opacity: 1,
                  duration: Motion.dur(AppDimens.durSlow),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Motion.dur(AppDimens.durSlow),
                    curve: Curves.easeOut,
                    builder: (context, progress, child) {
                      return SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 55,
                            sections: [
                              for (var i = 0; i < data.length; i++)
                                PieChartSectionData(
                                  value: data[i].value * progress,
                                  color: colors[i % colors.length],
                                  radius: 30,
                                  showTitle: false,
                                ),
                            ],
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {},
                            ),
                          ),
                          duration:
                              Motion.dur(const Duration(milliseconds: 800)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.gapSm),
              for (var i = 0;
                  i < data.length && i < 5;
                  i++) ...[
                if (i > 0) const SizedBox(height: AppDimens.gapXs),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimens.gapSm),
                    Expanded(
                      child: Text(
                        data[i].category?.name ?? AppStrings.noProduct,
                        style: TextStyle(
                          fontSize: AppDimens.fontSizeCaption,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.gapSm),
                    Text(
                      NumberFormatter.formatSyp(data[i].value),
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeCaption,
                        fontWeight: AppDimens.fontWeightMedium,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BarCard extends StatelessWidget {
  const _BarCard({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final buckets = controller.monthlyBuckets;
        if (buckets.isEmpty) {
          return const SizedBox.shrink();
        }
        final maxY = buckets
            .map((b) => b.income > b.expense ? b.income : b.expense)
            .fold(0.0, (m, v) => v > m ? v : m);
        final topY = (maxY * 1.15).ceilToDouble().clamp(1000.0, double.infinity);
        return Container(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: context.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.incomeVsExpense,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeBody,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.gapMd),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: topY,
                    barTouchData: BarTouchData(enabled: false),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            meta: meta,
                            child: Text(
                              NumberFormatter.formatSyp(value.toInt()),
                              style: TextStyle(
                                fontSize: 9,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= buckets.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                buckets[index].label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < buckets.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: buckets[i].income,
                              color: context.primary,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: buckets[i].expense,
                              color: context.secondary,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  duration: Motion.dur(AppDimens.durSlow),
                ),
              ),
              const SizedBox(height: AppDimens.gapSm),
              for (var i = 0; i < buckets.length; i++) ...[
                if (i > 0) const SizedBox(height: AppDimens.gapXs),
                _MonthRow(bucket: buckets[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.bucket});

  final MonthlyBucket bucket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.gapSm + 2,
        vertical: AppDimens.gapXs + 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          Text(
            bucket.label,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              fontWeight: AppDimens.fontWeightMedium,
              color: context.textSecondary,
            ),
          ),
          const Spacer(),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle)),
          const SizedBox(width: AppDimens.gapXs),
          Text(
            AppStrings.typeIncome,
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
          const SizedBox(width: AppDimens.gapXs),
          Text(
            NumberFormatter.formatSyp(bucket.income),
            style: TextStyle(fontSize: 11, fontWeight: AppDimens.fontWeightMedium, color: context.primary),
          ),
          const SizedBox(width: AppDimens.gapMd),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: context.secondary, shape: BoxShape.circle)),
          const SizedBox(width: AppDimens.gapXs),
          Text(
            AppStrings.typeExpense,
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
          const SizedBox(width: AppDimens.gapXs),
          Text(
            NumberFormatter.formatSyp(bucket.expense),
            style: TextStyle(fontSize: 11, fontWeight: AppDimens.fontWeightMedium, color: context.secondary),
          ),
        ],
      ),
    );
  }
}

class _StatisticsSkeleton extends StatelessWidget {
  const _StatisticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      children: [
        Row(
          children: [
            const Expanded(child: SkeletonCard(height: 96)),
            const SizedBox(width: AppDimens.gapSm),
            Expanded(child: SkeletonCard(height: 96)),
          ],
        ),
        const SizedBox(height: AppDimens.gapMd),
        const SkeletonCard(height: 260),
        const SizedBox(height: AppDimens.gapMd),
        const SkeletonCard(height: 280),
      ],
    );
  }
}
