import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/number_formatter.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeleton_card.dart';
import 'electricity_home_controller.dart';

class ElectricityHomeView extends StatelessWidget {
  const ElectricityHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ElectricityHomeController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(title: AppStrings.electricityHome),
            ),
            Expanded(child: _Body(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final ElectricityHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const _ElectricitySkeleton();
      }
      if (!controller.showGauge) {
        return AppEmptyState(
          icon: TablerIcons.bolt,
          title: AppStrings.noReadings,
          description: AppStrings.noReadingsDesc,
          actionLabel: AppStrings.addReading,
          onAction: () => Get.toNamed(AppRoutes.addReading),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(AppDimens.spacingMd),
        children: [
          _GaugeCard(controller: controller),
          const SizedBox(height: AppDimens.gapMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _StatCard(
                  label: AppStrings.estimatedCost,
                  value: NumberFormatter.formatSyp(controller.estimatedCost.value),
                  unit: AppStrings.currencyUnit,
                  valueColor: context.secondary,
                ),
              ),
              const SizedBox(width: AppDimens.gapSm),
              Expanded(
                child: _StatCard(
                  label: AppStrings.lastReading,
                  value: NumberFormatter.formatNumber(controller.lastReadingValue),
                  unit: AppStrings.kwhUnit,
                  valueColor: context.textPrimary,
                ),
              ),
            ],
          ),
          if (controller.showComparison) ...[
            const SizedBox(height: AppDimens.gapMd),
            const _ComparisonCard(),
          ],
          const SizedBox(height: AppDimens.spacingLg),
          AppPrimaryButton(
            label: AppStrings.newReading,
            icon: TablerIcons.plus,
            onPressed: () => Get.toNamed(AppRoutes.addReading),
          ),
          const SizedBox(height: AppDimens.gapSm),
          AppSecondaryButton(
            label: AppStrings.readingLog,
            icon: TablerIcons.list,
            onPressed: () => Get.toNamed(AppRoutes.readingLog),
          ),
        ],
      );
    });
  }
}

class _GaugeCard extends StatelessWidget {
  const _GaugeCard({required this.controller});

  final ElectricityHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final progress = controller.cycleProgress.value;
        final warning = controller.warning.value;
        final ringColor = warning ? context.danger : context.primary;
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingLg),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: Motion.dur(AppDimens.durCount),
                curve: Curves.easeOut,
                builder: (context, animated, _) => _PulseOnWarning(
                  warning: warning,
                  child: _EnergyGauge(
                    progress: animated,
                    color: ringColor,
                    trackColor: context.muted,
                    valueText: NumberFormatter.formatNumber(
                      controller.consumption.value,
                    ),
                    valueColor:
                        warning ? context.danger : context.textPrimary,
                    iconColor: warning ? context.danger : context.primary,
                    unitColor: context.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.gapMd),
              Text(
                AppStrings.consumption,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              AnimatedOpacity(
                opacity: warning ? 1 : 0,
                duration: AppDimens.durBase,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppDimens.gapXs),
                  child: Text(
                    '${AppStrings.warning} — ${AppStrings.nearLimit}',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PulseOnWarning extends StatefulWidget {
  const _PulseOnWarning({required this.warning, required this.child});

  final bool warning;
  final Widget child;

  @override
  State<_PulseOnWarning> createState() => _PulseOnWarningState();
}

class _PulseOnWarningState extends State<_PulseOnWarning>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didUpdateWidget(_PulseOnWarning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.warning && !oldWidget.warning && !Motion.reduced.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _pulseValue(double t) =>
      1 + 0.05 * sin(2 * pi * 2 * t) * (1 - t);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale =
            _controller.isAnimating ? _pulseValue(_controller.value) : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

class _EnergyGauge extends StatelessWidget {
  const _EnergyGauge({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.valueText,
    required this.valueColor,
    required this.iconColor,
    required this.unitColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final String valueText;
  final Color valueColor;
  final Color iconColor;
  final Color unitColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _GaugePainter(
              progress: progress,
              color: color,
              trackColor: trackColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(TablerIcons.bolt, size: AppDimens.iconMd, color: iconColor),
              const SizedBox(height: AppDimens.gapXs),
              Text(
                valueText,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeStat,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: valueColor,
                ),
              ),
              Text(
                AppStrings.kwhUnit,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeCaption,
                  color: unitColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const stroke = 10.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawCircle(rect.center, radius, track);

    if (progress <= 0) {
      return;
    }
    const startAngle = -pi / 2;
    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, startAngle, sweep, false, fill);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
          const SizedBox(height: AppDimens.gapSm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppDimens.fontSizeHeading,
              fontWeight: AppDimens.fontWeightMedium,
              color: valueColor,
            ),
          ),
          const SizedBox(height: AppDimens.gapXs),
          Text(
            unit,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ElectricityHomeController>();
    return Obx(
      () {
        final current = controller.consumption.value;
        final previous = controller.previousConsumption;
        final increased = current > previous;
        final diff = (current - previous).abs();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.comparePrevious,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.gapMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ComparisonSide(
                    label: AppStrings.previousReading,
                    value:
                        '${NumberFormatter.formatNumber(previous)} ${AppStrings.kwhUnit}',
                    valueColor: context.textPrimary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.gapSm + 2,
                      vertical: AppDimens.gapXs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: increased
                          ? context.dangerBg
                          : context.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Text(
                      '${increased ? '▲' : '▼'} '
                      '${NumberFormatter.formatNumber(diff)} ${AppStrings.kwhUnit}',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeLabel,
                        fontWeight: AppDimens.fontWeightMedium,
                        color: increased ? context.danger : context.primary,
                      ),
                    ),
                  ),
                  _ComparisonSide(
                    label: AppStrings.month,
                    value:
                        '${NumberFormatter.formatNumber(current)} ${AppStrings.kwhUnit}',
                    valueColor: controller.warning.value
                        ? context.danger
                        : context.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComparisonSide extends StatelessWidget {
  const _ComparisonSide({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimens.fontSizeCaption,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimens.gapXs),
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimens.fontSizeHeadingLg - 4,
            fontWeight: AppDimens.fontWeightMedium,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ElectricitySkeleton extends StatelessWidget {
  const _ElectricitySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      children: [
        Center(
          child: SkeletonCard(
            width: 200,
            height: 200,
            radius: AppDimens.radiusFull,
          ),
        ),
        const SizedBox(height: AppDimens.spacingLg),
        Row(
          children: [
            const Expanded(child: SkeletonCard(height: 96)),
            const SizedBox(width: AppDimens.gapSm),
            Expanded(child: SkeletonCard(height: 96)),
          ],
        ),
        const SizedBox(height: AppDimens.gapMd),
        const SkeletonCard(height: 110),
      ],
    );
  }
}
