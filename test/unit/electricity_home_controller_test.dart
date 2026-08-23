import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wafrah/core/constants/app_defaults.dart';
import 'package:wafrah/data/models/electricity_reading.dart';
import 'package:wafrah/data/models/electricity_settings.dart';
import 'package:wafrah/data/repositories/interfaces/electricity_repository_interface.dart';
import 'package:wafrah/modules/electricity_home/electricity_home_controller.dart';

class FakeElectricityRepository implements IElectricityRepository {
  FakeElectricityRepository({
    required this.settings,
    List<ElectricityReading> readings = const [],
  }) : _readings = [...readings];

  final List<ElectricityReading> _readings;
  ElectricitySettings settings;

  @override
  Future<List<ElectricityReading>> getAllReadings() async =>
      List.of(_readings);

  @override
  Future<ElectricityReading?> getReadingById(String id) async {
    for (final reading in _readings) {
      if (reading.id == id) return reading;
    }
    return null;
  }

  @override
  Future<ElectricityReading> addReading(ElectricityReading reading) async {
    _readings.add(reading);
    return reading;
  }

  @override
  Future<void> deleteReading(String id) async {
    _readings.removeWhere((r) => r.id == id);
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

ElectricitySettings tariff(List<(double, double)> tiers) => ElectricitySettings(
      cycleMonths: AppDefaults.defaultCycleMonths,
      tiers: [
        for (final (limit, price) in tiers)
          ElectricityTier(limit: limit, price: price),
      ],
    );

void main() {
  setUp(() {
    Get.reset();
  });

  ElectricityHomeController buildController({
    required ElectricitySettings settings,
    List<ElectricityReading> readings = const [],
  }) {
    final controller = ElectricityHomeController(
      electricityRepository: FakeElectricityRepository(
        settings: settings,
        readings: readings,
      ),
    );
    Get.put(controller);
    return controller;
  }

  ElectricityReading reading(String id, DateTime date, double kwh) =>
      ElectricityReading(id: id, fromDate: date, kwhValue: kwh);

  test('no readings keeps gauge empty and hides warning', () async {
    final controller = buildController(settings: tariff([(300, 600)]));
    await controller.load();

    expect(controller.showGauge, isFalse);
    expect(controller.consumption.value, 0);
    expect(controller.warning.value, isFalse);
  });

  test('single reading shows gauge without consumption', () async {
    final controller = buildController(
      settings: tariff([(300, 600)]),
      readings: [reading('r1', DateTime(2026, 7, 1), 1200)],
    );
    await controller.load();

    expect(controller.showGauge, isTrue);
    expect(controller.consumption.value, 0);
    expect(controller.lastReadingValue, 1200);
  });

  test('consumption and tiered cost are computed from last two readings',
      () async {
    final controller = buildController(
      settings: tariff([(200, 500), (400, 700)]),
      readings: [
        reading('r1', DateTime(2026, 7, 1), 1000),
        reading('r2', DateTime(2026, 8, 1), 1350),
      ],
    );
    await controller.load();

    expect(controller.consumption.value, 350);
    expect(controller.estimatedCost.value, 205000);
    expect(controller.cycleProgress.value, 1.0);
    expect(controller.warning.value, isTrue);
  });

  test('comparison uses third reading when available', () async {
    final controller = buildController(
      settings: tariff([(300, 600)]),
      readings: [
        reading('r1', DateTime(2026, 6, 1), 800),
        reading('r2', DateTime(2026, 7, 1), 1100),
        reading('r3', DateTime(2026, 8, 1), 1250),
      ],
    );
    await controller.load();

    expect(controller.showComparison, isTrue);
    expect(controller.previousConsumption, 300);
    expect(controller.consumption.value, 150);
    expect(controller.warning.value, isFalse);
  });
}
