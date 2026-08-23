import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wafrah/core/constants/app_defaults.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/electricity_reading.dart';
import 'package:wafrah/data/models/electricity_settings.dart';
import 'package:wafrah/data/repositories/interfaces/electricity_repository_interface.dart';
import 'package:wafrah/modules/settings/settings_controller.dart';

class FakeElectricityRepository implements IElectricityRepository {
  FakeElectricityRepository(this.settings);

  ElectricitySettings settings;
  final List<ElectricityReading> readings = [];

  @override
  Future<List<ElectricityReading>> getAllReadings() async => readings;

  @override
  Future<ElectricityReading?> getReadingById(String id) async {
    for (final reading in readings) {
      if (reading.id == id) return reading;
    }
    return null;
  }

  @override
  Future<ElectricityReading> addReading(ElectricityReading reading) async {
    readings.add(reading);
    return reading;
  }

  @override
  Future<void> deleteReading(String id) async {
    readings.removeWhere((r) => r.id == id);
  }

  @override
  Future<ElectricitySettings> getElectricitySettings() async => settings;

  @override
  Future<void> updateElectricitySettings(ElectricitySettings value) async {
    settings = value;
  }

  @override
  Future<AppSettings> getAppSettings() async => AppSettings(
        darkMode: false,
        reduceMotion: false,
        electricity: settings,
      );

  @override
  Future<void> updateAppSettings(AppSettings value) async {}
}

void main() {
  setUp(() {
    Get.reset();
  });

  SettingsController buildController(ElectricitySettings settings) {
    final controller = SettingsController(
      electricityRepository: FakeElectricityRepository(settings),
    );
    Get.put(controller);
    return controller;
  }

  test('load falls back to defaults when nothing saved', () async {
    final controller = buildController(
      const ElectricitySettings(cycleMonths: AppDefaults.defaultCycleMonths, tiers: []),
    );
    await controller.load();

    expect(controller.tierRows, hasLength(1));
    expect(controller.cycleMonthsCtrl.text, isNotEmpty);
  });

  test('saveTariff rejects non-ascending tier limits', () async {
    final controller = buildController(
      const ElectricitySettings(cycleMonths: 2, tiers: []),
    );
    await controller.load();

    controller.addTier();
    controller.tierRows[0].limitCtrl.text = '300';
    controller.tierRows[0].priceCtrl.text = '600';
    controller.tierRows[1].limitCtrl.text = '200';
    controller.tierRows[1].priceCtrl.text = '500';
    await controller.saveTariff();

    expect(controller.tariffError.value, AppStrings.tiersAscending);
    expect(controller.tariffSaved.value, isFalse);
  });

  test('saveTariff persists valid tariff', () async {
    final repo = FakeElectricityRepository(
      const ElectricitySettings(cycleMonths: 2, tiers: []),
    );
    final controller = SettingsController(electricityRepository: repo);
    Get.put(controller);
    await controller.load();

    controller.cycleMonthsCtrl.text = '3';
    controller.tierRows[0].limitCtrl.text = '٣٠٠';
    controller.tierRows[0].priceCtrl.text = '600';
    await controller.saveTariff();

    expect(controller.tariffError.value, isEmpty);
    expect(controller.tariffSaved.value, isTrue);
    expect(repo.settings.cycleMonths, 3);
    expect(repo.settings.tiers, hasLength(1));
    expect(repo.settings.tiers.first.limit, 300);
  });
}
