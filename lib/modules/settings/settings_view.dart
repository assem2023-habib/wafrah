import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_number_field.dart';
import '../../widgets/page_header.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: AppStrings.settingsTitle,
                onBack: () => Get.back(),
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
                      _SectionTitle(AppStrings.appearance),
                      AppCard(
                        child: Obx(
                          () => SwitchListTile.adaptive(
                            value: controller.darkMode.value,
                            onChanged: controller.setDarkMode,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            title: Row(
                              children: [
                                Icon(
                                  TablerIcons.moon,
                                  size: AppDimens.iconMd,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: AppDimens.gapSm),
                                Text(
                                  AppStrings.darkMode,
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeBody,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppCard(
                        child: Obx(
                          () => SwitchListTile.adaptive(
                            value: controller.reduceMotion.value,
                            onChanged: controller.setReduceMotion,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            title: Row(
                              children: [
                                Icon(
                                  TablerIcons.wave_sine,
                                  size: AppDimens.iconMd,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: AppDimens.gapSm),
                                Text(
                                  AppStrings.reduceMotion,
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeBody,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.spacingLg),
                      _SectionTitle(AppStrings.data),
                      _LinkRow(
                        icon: TablerIcons.category,
                        label: AppStrings.manageCategories,
                        onTap: () => Get.toNamed(AppRoutes.categories),
                      ),
                      _LinkRow(
                        icon: TablerIcons.box,
                        label: AppStrings.manageProducts,
                        onTap: () => Get.toNamed(AppRoutes.products),
                      ),
                      const SizedBox(height: AppDimens.spacingLg),
                      _TariffSection(controller: controller),
                      const SizedBox(height: AppDimens.spacingLg),
                      _SectionTitle(AppStrings.other),
                      _AboutCard(),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppDimens.fontSizeHeading,
          fontWeight: AppDimens.fontWeightMedium,
          color: context.textPrimary,
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingMd,
          vertical: AppDimens.gapSm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: AppDimens.iconXl,
              height: AppDimens.iconXl,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppDimens.iconMd, color: context.primary),
            ),
            const SizedBox(width: AppDimens.gapMd),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeBody,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
            ),
            Icon(
              TablerIcons.chevron_left,
              size: AppDimens.iconMd,
              color: context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TariffSection extends StatelessWidget {
  const _TariffSection({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppStrings.tariffSettings),
        Obx(
          () => ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              if (controller.tariffError.value.isNotEmpty) ...[
                AppErrorBanner(
                  message: controller.tariffError.value,
                  onClose: controller.clearTariffError,
                ),
                const SizedBox(height: AppDimens.gapMd),
              ],
              if (controller.tariffSaved.value) ...[
                AppCard(
                  color: context.primary.withValues(alpha: 0.10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingMd,
                    vertical: AppDimens.gapSm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.check,
                        size: AppDimens.iconMd,
                        color: context.primary,
                      ),
                      const SizedBox(width: AppDimens.gapSm),
                      Expanded(
                        child: Text(
                          AppStrings.savedSuccess,
                          style: TextStyle(
                            fontSize: AppDimens.fontSizeLabel,
                            color: context.primary,
                          ),
                        ),
                      ),
                      AppIconButton(
                        icon: TablerIcons.x,
                        onPressed: controller.dismissSaved,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.gapMd),
              ],
              AppNumberField(
                label: AppStrings.cycleMonths,
                controller: controller.cycleMonthsCtrl,
                suffix: AppStrings.month,
                onChanged: (_) => controller.clearTariffError(),
              ),
              const SizedBox(height: AppDimens.gapMd),
              for (var i = 0; i < controller.tierRows.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.gapSm),
                  child: _TierRow(
                    index: i,
                    controllers: controller.tierRows[i],
                    canRemove: controller.tierRows.length > 1,
                    controller: controller,
                  ),
                ),
              AppSecondaryButton(
                label: AppStrings.addTier,
                icon: TablerIcons.plus,
                onPressed: controller.addTier,
              ),
              const SizedBox(height: AppDimens.gapMd),
              Obx(
                () => AppPrimaryButton(
                  label: AppStrings.save,
                  onPressed:
                      controller.saving.value ? null : controller.saveTariff,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.index,
    required this.controllers,
    required this.canRemove,
    required this.controller,
  });

  final int index;
  final TierRowControllers controllers;
  final bool canRemove;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${AppStrings.tier} ${index + 1}',
                style: TextStyle(
                  fontSize: AppDimens.fontSizeLabel,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              if (canRemove)
                AppIconButton(
                  icon: TablerIcons.trash,
                  tooltip: AppStrings.delete,
                  onPressed: () => controller.removeTierAt(index),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.gapSm),
          AppNumberField(
            label: AppStrings.tierLimit,
            controller: controllers.limitCtrl,
            suffix: AppStrings.kwhUnit,
            onChanged: (_) => controller.clearTariffError(),
          ),
          const SizedBox(height: AppDimens.gapMd),
          AppNumberField(
            label: AppStrings.tierPrice,
            controller: controllers.priceCtrl,
            suffix: AppStrings.currencyUnit,
            onChanged: (_) => controller.clearTariffError(),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.border, width: 1),
              color: context.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              isDark ? 'assets/wifra_icon_dark.png' : 'assets/wifra_icon.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppDimens.gapMd),
          Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: AppDimens.fontSizeHeading,
              fontWeight: AppDimens.fontWeightMedium,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimens.gapXs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingMd,
              vertical: AppDimens.gapXs,
            ),
            decoration: BoxDecoration(
              color: context.muted,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              AppStrings.version,
              style: TextStyle(
                fontSize: AppDimens.fontSizeCaption,
                fontWeight: AppDimens.fontWeightMedium,
                color: context.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.gapSm),
          Text(
            AppStrings.appFooter,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              color: context.textSecondary,
              height: AppDimens.lineHeight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.gapMd),
            child: Divider(height: 1, thickness: 1, color: context.border),
          ),
          _AboutRow(
            icon: TablerIcons.brand_github,
            label: 'GitHub',
            value: 'github.com/assem2023-habib/wafrah',
          ),
          const SizedBox(height: AppDimens.gapSm),
          _AboutRow(
            icon: TablerIcons.heart,
            label: 'صُنع بـ',
            value: 'Flutter & Hive',
          ),
          const SizedBox(height: AppDimens.gapSm),
          Text(
            '© 2026 وِفرة — جميع الحقوق محفوظة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption - 1,
              color: context.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.muted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: context.textSecondary),
        ),
        const SizedBox(width: AppDimens.gapSm),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimens.fontSizeCaption,
            color: context.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppDimens.fontSizeCaption,
              fontWeight: AppDimens.fontWeightMedium,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
