import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/category.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/page_header.dart';
import 'categories_controller.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: AppStrings.manageCategories,
                action: IconButton(
                  onPressed: controller.startAdd,
                  tooltip: AppStrings.addCategory,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(
                      AppDimens.iconButton,
                      AppDimens.iconButton,
                    ),
                    backgroundColor: context.primary,
                    foregroundColor: context.onPrimary,
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
                        _CategoryForm(controller: controller),
                        const SizedBox(height: AppDimens.gapMd),
                      ],
                      if (controller.categories.isEmpty)
                        AppEmptyState(
                          icon: TablerIcons.category,
                          title: AppStrings.noCategories,
                          description: AppStrings.noCategoriesDesc,
                          actionLabel: AppStrings.addCategory,
                          onAction: controller.startAdd,
                        )
                      else
                        for (final category in controller.categories)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimens.gapSm,
                            ),
                            child: _CategoryRow(
                              category: category,
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

class _CategoryForm extends StatelessWidget {
  const _CategoryForm({required this.controller});

  final CategoriesController controller;

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
            () => AppDropdownField<CategoryType>(
              label: AppStrings.type,
              items: CategoryType.values,
              selected: controller.type.value,
              display: _typeLabel,
              onChanged: (value) {
                if (value != null) {
                  controller.type.value = value;
                }
              },
            ),
          ),
          const SizedBox(height: AppDimens.gapMd),
          Obx(
            () => Wrap(
              spacing: AppDimens.gapSm,
              runSpacing: AppDimens.gapSm,
              children: [
                for (final option in CategoriesController.iconOptions)
                  _IconChoice(
                    icon: option.$2,
                    selected: controller.iconCode.value == option.$1,
                    onTap: () => controller.iconCode.value = option.$1,
                  ),
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

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: AppDimens.touchTargetMin,
        height: AppDimens.touchTargetMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? context.primary.withValues(alpha: 0.10)
              : context.muted,
          border: Border.all(
            color: selected ? context.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: AppDimens.iconMd,
          color: selected ? context.primary : context.textSecondary,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.controller});

  final Category category;
  final CategoriesController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingMd,
        vertical: AppDimens.gapSm,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.iconXl,
            height: AppDimens.iconXl,
            decoration: BoxDecoration(
              color: context.muted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.iconFor(category.iconCode),
              size: AppDimens.iconMd,
              color: context.onMuted,
            ),
          ),
          const SizedBox(width: AppDimens.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeBody,
                    fontWeight: AppDimens.fontWeightMedium,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.gapXs),
                Text(
                  _typeLabel(category.type),
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeCaption,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.gapSm),
          AppIconButton(
            icon: TablerIcons.edit,
            tooltip: AppStrings.edit,
            onPressed: () => controller.startEdit(category),
          ),
          const SizedBox(width: AppDimens.gapSm),
          AppIconButton(
            icon: TablerIcons.trash,
            tooltip: AppStrings.delete,
            onPressed: () => controller.delete(category),
          ),
        ],
      ),
    );
  }
}

String _typeLabel(CategoryType type) {
  return switch (type) {
    CategoryType.expense => AppStrings.typeExpense,
    CategoryType.income => AppStrings.typeIncome,
    CategoryType.both => AppStrings.typeBoth,
  };
}