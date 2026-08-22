import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_date_field.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_number_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/page_header.dart';
import 'add_income_controller.dart';

class AddIncomeView extends StatelessWidget {
  const AddIncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddIncomeController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: Obx(
                () => PageHeader(
                  title: controller.isEdit.value
                      ? AppStrings.editIncomeTitle
                      : AppStrings.addIncomeTitle,
                  onBack: Get.back,
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView(
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
                    AppNumberField(
                      label: AppStrings.amount,
                      controller: controller.amountCtrl,
                      suffix: AppStrings.currencyUnit,
                      errorText:
                          controller.error.value == AppStrings.amountPositive
                              ? controller.error.value
                              : null,
                      onChanged: (_) => controller.clearError(),
                    ),
                    const SizedBox(height: AppDimens.gapMd),
                    AppDateField(
                      label: AppStrings.date,
                      value: controller.date.value,
                      onChanged: controller.setDate,
                    ),
                    const SizedBox(height: AppDimens.gapMd),
                    AppTextField(
                      label: AppStrings.note,
                      controller: controller.noteCtrl,
                      hint: AppStrings.noteHint,
                    ),
                  ],
                ),
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
              variant: 'primary',
              label: controller.isEdit.value
                  ? AppStrings.updateIncome
                  : AppStrings.saveIncome,
              onPressed: controller.saving.value ? null : controller.save,
            ),
          ),
        ),
      ),
    );
  }
}
