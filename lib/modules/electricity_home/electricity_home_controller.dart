import 'dart:math';

import 'package:get/get.dart';

import '../../core/constants/app_defaults.dart';
import '../../data/models/electricity_reading.dart';
import '../../data/repositories/interfaces/electricity_repository_interface.dart';
class ElectricityHomeController extends GetxController {
  ElectricityHomeController({
    required IElectricityRepository electricityRepository,
  }) : _electricityRepository = electricityRepository;

  final IElectricityRepository _electricityRepository;

  final RxList<ElectricityReading> readings = <ElectricityReading>[].obs;
  final RxBool loading = true.obs;
  final RxDouble consumption = 0.0.obs;
  final RxDouble estimatedCost = 0.0.obs;
  final RxDouble cycleProgress = 0.0.obs;
  final RxBool warning = false.obs;

  List<(double, double)> _tiers = const [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final items = await _electricityRepository.getAllReadings();
      final settings = await _electricityRepository.getElectricitySettings();
      final sorted = [...items]
        ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
      readings.assignAll(sorted);
      _tiers = [
        for (final tier in settings.tiers) (tier.limit, tier.price),
      ];
      _compute();
    } finally {
      loading.value = false;
    }
  }

  void _compute() {
    if (readings.length < 2) {
      consumption.value = 0;
      estimatedCost.value = 0;
      cycleProgress.value = 0;
      warning.value = false;
      return;
    }
    final latest = readings[readings.length - 1];
    final previous = readings[readings.length - 2];
    final used = max(latest.kwhValue - previous.kwhValue, 0.0);
    consumption.value = used;
    estimatedCost.value = _tieredCost(used, _tiers);
    cycleProgress.value = (used / AppDefaults.maxConsumption).clamp(0.0, 1.0);
    warning.value =
        used > AppDefaults.maxConsumption * AppDefaults.warningThreshold;
  }

  double get lastReadingValue =>
      readings.isEmpty ? 0 : readings.last.kwhValue;

  double get previousConsumption =>
      readings.length < 3
          ? 0
          : max(
              readings[readings.length - 2].kwhValue -
                  readings[readings.length - 3].kwhValue,
              0,
            );

  bool get showGauge => readings.isNotEmpty;

  bool get showComparison => readings.length >= 3;

  double _tieredCost(double usedKwh, List<(double, double)> tiers) {
    var cost = 0.0;
    var previousLimit = 0.0;
    for (final (limit, price) in tiers) {
      if (usedKwh > previousLimit) {
        final inTier = min(usedKwh, limit) - previousLimit;
        cost += inTier * price;
      }
      previousLimit = limit;
    }
    return cost;
  }
}
