import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/page_header.dart';
import 'products_controller.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: AppStrings.manageProducts,
                action: IconButton(
                  onPressed: controller.startAdd,
                  tooltip: AppStrings.addProduct,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(
                      AppDimens.iconButton,
                      AppDimens.iconButton,
                    ),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  icon: const Icon(
                    TablerIcons.plus,
                    size: AppDimens.iconMd,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  return ListView(
                    padding: const EdgeInsets.all(AppDimens.spacingMd),
                    children: [
                      if (controller.refsError.value.isNotEmpty) ...[
                        AppErrorBanner(
                          message: controller.refsError.value,
                          onClose: controller.clearRefsError,
                        ),
                        const SizedBox(height: AppDimens.gapMd),
                      ],
                      if (controller.showForm) ...[
                        _ProductForm(controller: controller),
                        const SizedBox(height: AppDimens.gapMd),
                      ],
                      if (controller.products.isEmpty)
                        const AppEmptyState(
                          icon: TablerIcons.box,
                          title: AppStrings.noProducts,
                          description: AppStrings.noProductsDesc,
                        )
                      else
                        for (final group in controller.groups)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimens.gapMd,
                            ),
                            child: _ProductGroup(
                              category: group.$1,
                              products: group.$2,
                              controller: controller,
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({required this.controller});

  final ProductsController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => AppTextField(
              label: AppStrings.name,
              controller: controller.nameCtrl,
              errorText: controller.nameError.value.isEmpty
                  ? null
                  : controller.nameError.value,
            ),
          ),
          const SizedBox(height: AppDimens.gapMd),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDropdownField<Category>(
                  label: AppStrings.category,
                  items: controller.categoryOptions,
                  selected: controller.selectedCategory.value,
                  display: (category) => category.name,
                  hint: AppStrings.categoryRequired,
                  onChanged: (value) {
                    controller.selectedCategory.value = value;
                    controller.categoryError.value = '';
                  },
                ),
                if (controller.categoryError.value.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.gapXs),
                  Text(
                    controller.categoryError.value,
                    style: const TextStyle(
                      fontSize: AppDimens.fontSizeCaption,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gapMd),
          AppPrimaryButton(
            label: AppStrings.save,
            onPressed: controller.save,
          ),
          const SizedBox(height: AppDimens.gapSm),
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: controller.cancelEdit,
          ),
        ],
      ),
    );
  }
}

class _ProductGroup extends StatelessWidget {
  const _ProductGroup({
    required this.category,
    required this.products,
    required this.controller,
  });

  final Category category;
  final List<Product> products;
  final ProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSm),
          child: Row(
            children: [
              Container(
                width: AppDimens.iconXl,
                height: AppDimens.iconXl,
                decoration: const BoxDecoration(
                  color: AppColors.muted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ProductsController.categoryIconFor(category.iconCode),
                  size: AppDimens.iconMd,
                  color: AppColors.onMuted,
                ),
              ),
              const SizedBox(width: AppDimens.gapMd),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: AppDimens.fontSizeBody,
                    fontWeight: AppDimens.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gapSm),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.gapSm),
          child: Column(
            children: [
              for (var i = 0; i < products.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                _ProductRow(product: products[i], controller: controller),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.controller});

  final Product product;
  final ProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingMd,
        vertical: AppDimens.gapXs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeBody,
                fontWeight: AppDimens.fontWeightMedium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.gapSm),
          AppIconButton(
            icon: TablerIcons.edit,
            tooltip: AppStrings.edit,
            onPressed: () => controller.startEdit(product),
          ),
          const SizedBox(width: AppDimens.gapSm),
          AppIconButton(
            icon: TablerIcons.trash,
            tooltip: AppStrings.delete,
            onPressed: () => controller.delete(product),
          ),
        ],
      ),
    );
  }
}