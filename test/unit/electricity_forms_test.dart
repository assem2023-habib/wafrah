import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/electricity_reading.dart';
import 'package:wafrah/data/models/electricity_settings.dart';
import 'package:wafrah/data/repositories/interfaces/electricity_repository_interface.dart';
import 'package:wafrah/modules/add_reading/add_reading_controller.dart';
import 'package:wafrah/modules/reading_log/reading_log_controller.dart';

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

void main() {
  setUp(() {
    Get.reset();
  });

  final tiers = [
    const ElectricityTier(limit: 200, price: 500),
    const ElectricityTier(limit: 400, price: 700),
  ];
  final settings = ElectricitySettings(cycleMonths: 2, tiers: tiers);

  AddReadingController buildAddController({
    List<ElectricityReading> readings = const [],
  }) {
    final controller = AddReadingController(
      electricityRepository: FakeElectricityRepository(
        settings: settings,
        readings: readings,
      ),
    );
    Get.put(controller);
    return controller;
  }

  ReadingLogController buildLogController({
    List<ElectricityReading> readings = const [],
  }) {
    final controller = ReadingLogController(
      electricityRepository: FakeElectricityRepository(
        settings: settings,
        readings: readings,
      ),
    );
    Get.put(controller);
    return controller;
  }

  group('AddReadingController', () {
    test('save rejects value not greater than zero', () async {
      final controller = buildAddController();
      await controller.load();

      controller.valueCtrl.text = '0';
      await controller.save();

      expect(controller.error.value, AppStrings.amountPositive);
    });

    test('save rejects end date before start date', () async {
      final controller = buildAddController();
      await controller.load();

      controller.valueCtrl.text = '1500';
      controller.fromDate.value = DateTime(2026, 8, 20);
      controller.setToDate(DateTime(2026, 8, 10));
      await controller.save();

      expect(controller.error.value, AppStrings.toDateAfterFrom);
    });

    test('preview consumption and cost use previous reading and tiers',
        () async {
      final controller = buildAddController(
        readings: [
          ElectricityReading(
            id: 'r1',
            fromDate: DateTime(2026, 7, 1),
            kwhValue: 1000,
          ),
        ],
      );
      await controller.load();

      controller.valueCtrl.text = '1350';

      expect(controller.showPreview, isTrue);
      expect(controller.previewConsumption, 350);
      expect(controller.previewCost, 205000);
    });
  });

  group('ReadingLogController', () {
    test('rows compute consumption and cost; newest cannot be deleted',
        () async {
      final controller = buildLogController(
        readings: [
          ElectricityReading(
            id: 'r1',
            fromDate: DateTime(2026, 7, 1),
            kwhValue: 1000,
          ),
          ElectricityReading(
            id: 'r2',
            fromDate: DateTime(2026, 8, 1),
            kwhValue: 1200,
          ),
          ElectricityReading(
            id: 'r3',
            fromDate: DateTime(2026, 9, 1),
            kwhValue: 1300,
          ),
        ],
      );
      await controller.load();

      expect(controller.rows, hasLength(3));
      expect(controller.rows.first.reading.id, 'r3');
      expect(controller.rows.first.canDelete, isFalse);
      expect(controller.rows[1].canDelete, isTrue);

      final middle = controller.rows[1];
      expect(middle.consumption, 200);
      expect(middle.cost, 100000);
    });

    test('delete removes the reading and refreshes rows', () async {
      final controller = buildLogController(
        readings: [
          ElectricityReading(
            id: 'r1',
            fromDate: DateTime(2026, 7, 1),
            kwhValue: 1000,
          ),
          ElectricityReading(
            id: 'r2',
            fromDate: DateTime(2026, 8, 1),
            kwhValue: 1200,
          ),
        ],
      );
      await controller.load();

      await controller.delete('r1');

      expect(controller.rows, hasLength(1));
      expect(controller.rows.first.reading.id, 'r2');
      expect(controller.rows.first.consumption, 0);
      expect(controller.error.value, isEmpty);
    });
  });
}
