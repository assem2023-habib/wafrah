import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_date_field.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_number_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/page_header.dart';
import 'add_expense_controller.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddExpenseController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: AppStrings.addExpenseTitle,
                onBack: Get.back,
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.all(AppDimens.spacingMd),
                  children: [
                    AppDropdownField<Category>(
                      label: AppStrings.category,
                      items: controller.categories,
                      selected: controller.selectedCategory.value,
                      display: (category) => category.name,
                      hint: AppStrings.categoryRequired,
                      onChanged: controller.selectCategory,
                    ),
                    const SizedBox(height: AppDimens.gapMd),
                    AppDropdownField<Product>(
                      label: AppStrings.product,
                      items: controller.products,
                      selected: controller.selectedProduct.value,
                      display: (product) => product.name,
                      hint: AppStrings.noProduct,
                      onChanged: controller.selectProduct,
                    ),
                    const SizedBox(height: AppDimens.gapMd),
                    AppNumberField(
                      label: AppStrings.amount,
                      controller: controller.amountCtrl,
                      suffix: AppStrings.currencyUnit,
                      errorText: controller.error.value == AppStrings.amountPositive
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
                    ),
                    if (controller.error.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.gapMd),
                      AppErrorBanner(
                        message: controller.error.value,
                        onClose: controller.clearError,
                      ),
                    ],
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
          child: AppPrimaryButton(
            variant: 'secondary',
            label: AppStrings.saveExpense,
            onPressed: controller.save,
          ),
        ),
      ),
    );
  }
}