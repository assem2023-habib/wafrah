import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/page_header.dart';
import '../../widgets/skeleton_card.dart';
import 'reading_log_controller.dart';

class ReadingLogView extends StatelessWidget {
  const ReadingLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReadingLogController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(title: AppStrings.readingLog),
            ),
            Expanded(
              child: Obx(() => _Content(controller: controller)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final ReadingLogController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.loading.value) {
          return ListView(
            padding: const EdgeInsets.all(AppDimens.spacingMd),
            children: const [
              SkeletonCard(height: 110),
              SizedBox(height: AppDimens.gapMd),
              SkeletonCard(height: 110),
              SizedBox(height: AppDimens.gapMd),
              SkeletonCard(height: 110),
            ],
          );
        }
        if (controller.rows.isEmpty) {
          return AppEmptyState(
            icon: TablerIcons.bolt,
            title: AppStrings.noReadings,
            description: AppStrings.noReadingsDesc,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          children: [
            if (controller.error.value.isNotEmpty) ...[
              AppErrorBanner(
                message: controller.error.value,
                onClose: controller.clearError,
              ),
              const SizedBox(height: AppDimens.gapMd),
            ],
            for (final row in controller.rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.gapMd),
                child: _ReadingCard(row: row, controller: controller),
              ),
          ],
        );
      },
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.row, required this.controller});

  final ReadingRow row;
  final ReadingLogController controller;

  @override
  Widget build(BuildContext context) {
    final reading = row.reading;
    final period = reading.toDate == null
        ? NumberFormatter.formatShortDate(reading.fromDate)
        : '${NumberFormatter.formatShortDate(reading.fromDate)} '
            '– ${NumberFormatter.formatShortDate(reading.toDate!)}';
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeLabel,
                    fontWeight: AppDimens.fontWeightMedium,
                    color: context.textPrimary,
                  ),
                ),
                if (reading.note != null && reading.note!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.gapXs),
                  Text(
                    reading.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      color: context.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.gapSm),
                Row(
                  children: [
                    _Metric(
                      label: AppStrings.lastReading,
                      value: NumberFormatter.formatNumber(reading.kwhValue),
                      unit: AppStrings.kwhUnit,
                      valueColor: context.textPrimary,
                    ),
                    const SizedBox(width: AppDimens.gapMd),
                    _Metric(
                      label: AppStrings.consumption,
                      value: NumberFormatter.formatNumber(row.consumption),
                      unit: AppStrings.kwhUnit,
                      valueColor: context.primary,
                    ),
                    const SizedBox(width: AppDimens.gapMd),
                    _Metric(
                      label: AppStrings.cost,
                      value: NumberFormatter.formatSyp(row.cost),
                      unit: AppStrings.currencyUnit,
                      valueColor: context.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.gapSm),
          if (row.canDelete)
            AppIconButton(
              icon: TablerIcons.trash,
              tooltip: AppStrings.delete,
              onPressed: () => controller.delete(reading.id),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
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
    return Column(
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
        Text.rich(
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: AppDimens.fontSizeBody,
              fontWeight: AppDimens.fontWeightMedium,
              color: valueColor,
            ),
            children: [
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontSize: AppDimens.fontSizeCaption,
                  fontWeight: AppDimens.fontWeightNormal,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
