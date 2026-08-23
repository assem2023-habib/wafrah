import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_date_field.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_number_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/page_header.dart';
import 'add_reading_controller.dart';

class AddReadingView extends StatelessWidget {
  const AddReadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddReadingController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: AppStrings.addReading,
                onBack: Get.back,
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  if (controller.loading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    padding: const EdgeInsets.all(AppDimens.spacingMd),
                    children: [
                      if (controller.error.isNotEmpty &&
                          controller.error.value !=
                              AppStrings.amountPositive) ...[
                        AppErrorBanner(
                          message: controller.error.value,
                          onClose: controller.clearError,
                        ),
                        const SizedBox(height: AppDimens.gapMd),
                      ],
                      if (controller.hasPrevious) ...[
                        _PreviousReadingCard(controller: controller),
                        const SizedBox(height: AppDimens.gapMd),
                      ],
                      AppNumberField(
                        label: AppStrings.currentReading,
                        controller: controller.valueCtrl,
                        suffix: AppStrings.kwhUnit,
                        errorText:
                            controller.error.value == AppStrings.amountPositive
                                ? controller.error.value
                                : null,
                        onChanged: (_) => controller.clearError(),
                      ),
                      const SizedBox(height: AppDimens.gapMd),
                      _PreviewCard(controller: controller),
                      const SizedBox(height: AppDimens.gapMd),
                      AppDateField(
                        label: AppStrings.fromDate,
                        value: controller.fromDate.value,
                        onChanged: controller.setFromDate,
                      ),
                      const SizedBox(height: AppDimens.gapMd),
                      _OptionalEndDate(controller: controller),
                      const SizedBox(height: AppDimens.gapMd),
                      AppTextField(
                        label: AppStrings.note,
                        controller: controller.noteCtrl,
                        hint: AppStrings.noteHint,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          child: Obx(
            () => AppPrimaryButton(
              label: AppStrings.saveReading,
              onPressed: controller.saving.value ? null : controller.save,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviousReadingCard extends StatelessWidget {
  const _PreviousReadingCard({required this.controller});

  final AddReadingController controller;

  @override
  Widget build(BuildContext context) {
    final previous = controller.previousReading!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.previousReading,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.gapXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                NumberFormatter.formatNumber(previous.kwhValue),
                style: TextStyle(
                  fontSize: AppDimens.fontSizeHeadingLg,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimens.gapXs),
              Text(
                AppStrings.kwhUnit,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapXs),
          Text(
            NumberFormatter.formatDate(previous.fromDate),
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.controller});

  final AddReadingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (!controller.showPreview) {
          return const SizedBox.shrink();
        }
        return AppCard(
          color: context.primary.withValues(alpha: 0.08),
          padding: const EdgeInsets.all(AppDimens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.consumption,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.gapSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.consumption,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeLabel,
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    '${NumberFormatter.formatNumber(controller.previewConsumption)} ${AppStrings.kwhUnit}',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeLabel,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.gapXs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.cost,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeLabel,
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    '${NumberFormatter.formatSyp(controller.previewCost)} ${AppStrings.currencyUnit}',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeLabel,
                      fontWeight: AppDimens.fontWeightMedium,
                      color: context.secondary,
                    ),
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

class _OptionalEndDate extends StatelessWidget {
  const _OptionalEndDate({required this.controller});

  final AddReadingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final end = controller.toDate.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDateField(
              label: '${AppStrings.toDate} (${AppStrings.optional})',
              value: end,
              onChanged: controller.setToDate,
            ),
            if (end != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => controller.setToDate(null),
                  child: Text(
                    AppStrings.clearEndDate,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      color: context.danger,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
