import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/tariff_calculator.dart';
import '../../data/models/electricity_reading.dart';
import '../../data/repositories/interfaces/electricity_repository_interface.dart';

class ReadingRow {
  ReadingRow({
    required this.reading,
    required this.consumption,
    required this.cost,
    required this.canDelete,
  });

  final ElectricityReading reading;
  final double consumption;
  final double cost;
  final bool canDelete;
}

class ReadingLogController extends GetxController {
  ReadingLogController({
    required IElectricityRepository electricityRepository,
  }) : _electricityRepository = electricityRepository;

  final IElectricityRepository _electricityRepository;

  final RxList<ReadingRow> rows = <ReadingRow>[].obs;
  final RxBool loading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final readings = await _electricityRepository.getAllReadings();
      final settings = await _electricityRepository.getElectricitySettings();
      final sorted = [...readings]
        ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
      final result = <ReadingRow>[];
      for (var i = 0; i < sorted.length; i++) {
        final consumption =
            i == 0 ? 0.0 : (sorted[i].kwhValue - sorted[i - 1].kwhValue);
        result.add(
          ReadingRow(
            reading: sorted[i],
            consumption: consumption.clamp(0.0, double.infinity),
            cost: TariffCalculator.costOfConsumption(
              consumption,
              settings.tiers,
            ),
            canDelete: i != sorted.length - 1,
          ),
        );
      }
      rows.assignAll(result.reversed);
    } catch (_) {
      error.value = AppStrings.loadFailed;
    } finally {
      loading.value = false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _electricityRepository.deleteReading(id);
      error.value = '';
      await load();
    } catch (_) {
      error.value = AppStrings.deleteFailed;
    }
  }

  void clearError() => error.value = '';
}
