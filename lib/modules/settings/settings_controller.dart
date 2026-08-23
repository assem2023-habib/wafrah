import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_service.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/electricity_settings.dart';
import '../../data/repositories/interfaces/electricity_repository_interface.dart';

class TierRowControllers {
  TierRowControllers(this.limitCtrl, this.priceCtrl);

  final TextEditingController limitCtrl;
  final TextEditingController priceCtrl;

  void dispose() {
    limitCtrl.dispose();
    priceCtrl.dispose();
  }
}

class SettingsController extends GetxController {
  SettingsController({required IElectricityRepository electricityRepository})
      : _electricityRepository = electricityRepository;

  final IElectricityRepository _electricityRepository;

  final RxBool darkMode = false.obs;
  final RxBool reduceMotion = false.obs;
  final RxList<TierRowControllers> tierRows = <TierRowControllers>[].obs;
  final TextEditingController cycleMonthsCtrl = TextEditingController();
  final RxString tariffError = ''.obs;
  final RxBool tariffSaved = false.obs;
  final RxBool loading = true.obs;
  final RxBool saving = false.obs;

  ElectricitySettings? _current;

  @override
  void onInit() {
    super.onInit();
    darkMode.value = Get.isDarkMode;
    reduceMotion.value = ThemeService.reduceMotion;
    load();
  }

  @override
  void onClose() {
    _disposeRows();
    cycleMonthsCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      _current = await _electricityRepository.getElectricitySettings();
      cycleMonthsCtrl.text = NumberFormatter.formatNumber(
        _current?.cycleMonths.toDouble() ??
            AppDefaults.defaultCycleMonths.toDouble(),
      );
      final tiers = (_current?.tiers.isNotEmpty ?? false)
          ? _current!.tiers
          : [
              ElectricityTier(
                limit: AppDefaults.defaultTierLimit,
                price: AppDefaults.defaultTierPrice,
              ),
            ];
      _rebuildRows(tiers);
    } finally {
      loading.value = false;
    }
  }

  void setDarkMode(bool value) {
    darkMode.value = value;
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(mode);
    ThemeService.save(mode);
  }

  void setReduceMotion(bool value) {
    Motion.set(value);
  }

  void addTier() {
    tierRows.add(
      TierRowControllers(
        TextEditingController(),
        TextEditingController(),
      ),
    );
    clearTariffError();
  }

  void removeTierAt(int index) {
    if (tierRows.length <= 1) {
      return;
    }
    tierRows[index].dispose();
    tierRows.removeAt(index);
    clearTariffError();
  }

  void clearTariffError() {
    if (tariffError.isNotEmpty) {
      tariffError.value = '';
    }
  }

  Future<void> saveTariff() async {
    final cycleText = cycleMonthsCtrl.text.trim();
    final cycle = Validators.parseNumber(cycleText)?.toInt();
    if (cycle == null || cycle <= 0) {
      tariffError.value = AppStrings.cycleRequired;
      return;
    }
    final tiers = <ElectricityTier>[];
    for (final row in tierRows) {
      final limit = Validators.parseNumber(row.limitCtrl.text);
      final price = Validators.parseNumber(row.priceCtrl.text);
      if (limit == null || limit <= 0 || price == null || price <= 0) {
        tariffError.value = AppStrings.tierValuesRequired;
        return;
      }
      tiers.add(ElectricityTier(limit: limit, price: price));
    }
    for (var i = 1; i < tiers.length; i++) {
      if (tiers[i].limit <= tiers[i - 1].limit) {
        tariffError.value = AppStrings.tiersAscending;
        return;
      }
    }
    tariffError.value = '';
    saving.value = true;
    try {
      final settings = ElectricitySettings(cycleMonths: cycle, tiers: tiers);
      await _electricityRepository.updateElectricitySettings(settings);
      _current = settings;
      tariffSaved.value = true;
    } finally {
      saving.value = false;
    }
  }

  void dismissSaved() => tariffSaved.value = false;

  void _rebuildRows(List<ElectricityTier> tiers) {
    _disposeRows();
    for (final tier in tiers) {
      tierRows.add(
        TierRowControllers(
          TextEditingController(text: NumberFormatter.formatNumber(tier.limit)),
          TextEditingController(text: NumberFormatter.formatNumber(tier.price)),
        ),
      );
    }
  }

  void _disposeRows() {
    for (final row in tierRows) {
      row.dispose();
    }
    tierRows.clear();
  }
}
